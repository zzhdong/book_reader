import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/schema/search_book_schema.dart';
import 'package:book_reader/module/book/task/book_source_exist_task.dart';
import 'package:book_reader/module/book/utils/book_analyze_utils.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/task/book_source_change_task.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class BookSourceChangePage extends StatefulWidget {
  final BookModel bookModel;
  final List<BookChapterModel> chapterModelList;

  const BookSourceChangePage(this.bookModel, this.chapterModelList, {super.key});

  @override
  _BookSourceChangePageState createState() => _BookSourceChangePageState();
}

class _BookSourceChangePageState extends AppState<BookSourceChangePage> {
  static const String _pageName = "BookSourceChangePage";

  //书源搜索任务对象-事件订阅
  late StreamSubscription _bookSourceExistSubscription;
  final BookSourceExistTask _bookSourceExistTask = BookSourceExistTask();

  //书源搜索任务对象-事件订阅
  late StreamSubscription _bookSourceUpdateSubscription;
  final BookSourceChangeTask _bookSourceChangeTask = BookSourceChangeTask(_pageName);

  //侧滑删除控件控制器
  final SlidableController slideController = SlidableController();

  //是否正在加载当前书源数据
  bool _isLoadCurrent = true;

  //是否正在加载其他书源数据
  bool _isLoadExistMore = true;
  bool _isLoadOtherMore = true;

  //当前书源
  SearchBookModel _currentSearchBook = SearchBookModel();
  BookSourceModel? _currentBookSource;

  final List<Map<String, dynamic>> _dataList = [];
  final double _itemResultExtent = 93;

  late Timer _timerRefresh;

  @override
  void initState() {
    super.initState();
    _bookSourceExistSubscription = MessageEventBus.bookSourceExistEventBus.on<BookSourceExistEvent>().listen((event) {
      _onHandleBookSourceExistEvent(event.code, searchBookModelList: event.searchBookModelList, errorMsg: event.errorMsg);
    });
    _bookSourceUpdateSubscription = MessageEventBus.bookSourceUpdateEventBus.on<BookSourceUpdateEvent>().listen((event) {
      _onHandleBookSourceUpdateEvent(event.code, event.taskName, searchBookModelList: event.searchBookModelList, errorMsg: event.errorMsg);
    });
    if(widget.chapterModelList.isNotEmpty){
      _currentSearchBook.latestChapterTitle = widget.chapterModelList[widget.chapterModelList.length - 1].chapterTitle;
      _currentSearchBook.totalChapterNum = widget.chapterModelList.length;
      _currentSearchBook.accessSpeed = 1;
    }
    //获取内容
    _loadCurrentBookSource();
    _loadOtherBookSource();
    //判断网络是否可用
    Connectivity().checkConnectivity().then((value){
      //网络不可用，停止搜索，提示
      if(value == ConnectivityResult.none){
        ToastUtils.showToast("当前网络不可用，请检查网络连接！");
        _bookSourceChangeTask.stopSearch();
        _bookSourceExistTask.stopSearch();
      }
    });
  }

  @override
  void dispose() {
    _timerRefresh.cancel();
    _bookSourceChangeTask.stopSearch();
    _bookSourceUpdateSubscription.cancel();
    _bookSourceExistTask.stopSearch();
    _bookSourceExistSubscription.cancel();
    super.dispose();
  }

  _onHandleBookSourceExistEvent(int code, {List<SearchBookModel>? searchBookModelList, String errorMsg = ""}) {
    if (code == MessageCode.SEARCH_LOAD_MORE_OBJECT && searchBookModelList != null && searchBookModelList.isNotEmpty) {
      _reloadDataList(searchBookModelList, []);
    } else {
      _isLoadExistMore = false;
    }
  }

  _onHandleBookSourceUpdateEvent(int code, String taskName, {List<SearchBookModel>? searchBookModelList, String errorMsg = ""}) {
    if (taskName == _pageName) {
      if (code == MessageCode.SEARCH_LOAD_MORE_OBJECT && searchBookModelList != null && searchBookModelList.isNotEmpty) {
        _reloadDataList([], searchBookModelList);
      } else {
        _isLoadOtherMore = false;
      }
    }
  }

  Future _reloadDataList(List<SearchBookModel> existList, List<SearchBookModel> otherList) async {
    Map<String, dynamic> tmpMap;
    BookSourceModel? bookSourceModel;
    for (int i = 0; i < existList.length; i++) {
      bool isExist = false;
      bookSourceModel = await BookSourceSchema.getInstance.getByBookSourceUrl(existList[i].origin);
      //如果书源被禁用，则不加入列表
      if(bookSourceModel != null && bookSourceModel.enable != 1) continue;
      for (int j = 0; j < _dataList.length; j++) {
        if (_dataList[j]["searchBook"].origin == existList[i].origin) {
          isExist = true;
          _dataList[j]["searchBook"] = existList[i];
          if (bookSourceModel == null) {
            _dataList[j]["groupName"] = "";
            _dataList[j]["enable"] = "0";
          } else {
            _dataList[j]["groupName"] = bookSourceModel.bookSourceGroup;
            _dataList[j]["enable"] = bookSourceModel.enable.toString();
          }
          break;
        }
      }
      if (!isExist) {
        tmpMap = <String, dynamic>{};
        if (bookSourceModel == null) {
          tmpMap["groupName"] = "";
          tmpMap["enable"] = "0";
        } else {
          tmpMap["groupName"] = bookSourceModel.bookSourceGroup;
          tmpMap["enable"] = bookSourceModel.enable.toString();
        }
        tmpMap["searchBook"] = existList[i];
        _dataList.add(tmpMap);
      }
    }
    for (int i = 0; i < otherList.length; i++) {
      bool isExist = false;
      for (int j = 0; j < _dataList.length; j++) {
        if (_dataList[j]["searchBook"].origin == otherList[i].origin) {
          isExist = true;
          break;
        }
      }
      if (!isExist) {
        tmpMap = <String, dynamic>{};
        bookSourceModel = await BookSourceSchema.getInstance.getByBookSourceUrl(otherList[i].origin);
        if(bookSourceModel != null && bookSourceModel.enable != 1) continue;
        if (bookSourceModel == null) {
          tmpMap["groupName"] = "";
          tmpMap["enable"] = "0";
        } else {
          tmpMap["groupName"] = bookSourceModel.bookSourceGroup;
          tmpMap["enable"] = bookSourceModel.enable.toString();
        }
        tmpMap["searchBook"] = otherList[i];
        _dataList.add(tmpMap);
      }
    }
  }

  //加载当前书源
  void _loadCurrentBookSource({bool isRefresh = false}) async {
    if(isRefresh){
      setState(() {
        _currentSearchBook.latestChapterTitle = "";
        _currentSearchBook.totalChapterNum = 0;
        _currentSearchBook.accessSpeed = 0;
        _isLoadCurrent = true;
      });
    }else{
      bool needToRefresh = false;
      //判断是否需要刷新
      List<SearchBookModel> dbSearchBookList = await SearchBookSchema.getInstance.getByNameAndAuthor(widget.bookModel.name, widget.bookModel.author);
      for (SearchBookModel searchBook in dbSearchBookList) {
        if (searchBook.origin == widget.bookModel.origin) {
          _currentSearchBook = searchBook.clone();
          int day = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(searchBook.searchTime)).inDays;
          if(searchBook.getLatestChapterTitle() == "" || searchBook.totalChapterNum == 0 || day >= 1) {
            needToRefresh = true;
          }
          break;
        }
      }
      _currentBookSource = await BookSourceSchema.getInstance.getByBookSourceUrl(widget.bookModel.origin);
      setState(() {_isLoadCurrent = false;});
      if(!needToRefresh) return;
    }
    //需要判断当前书源是否被删除
    if(_currentBookSource != null){
      //刷新当前书源
      int startTime = DateTime.now().millisecondsSinceEpoch;
      BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils(_currentBookSource);
      //查找书籍
      List<SearchBookModel> searchList = await bookAnalyzeUtils.searchBookAction(widget.bookModel.name, 1);
      for (SearchBookModel model in searchList) {
        //找到当前书源
        if (model.name == widget.bookModel.name && model.author == widget.bookModel.author) {
          _currentSearchBook.latestChapterTitle = model.getLatestChapterTitle();
          _currentSearchBook.accessSpeed = DateTime.now().millisecondsSinceEpoch - startTime;
          _currentSearchBook.searchTime = DateTime.now().millisecondsSinceEpoch;
          //判断是否需要加载章节列表
          if (StringUtils.isEmpty(_currentSearchBook.getLatestChapterTitle()) || _currentSearchBook.totalChapterNum <= 0) {
            //获取书籍详情
            BookModel bookModel = model.toBook();
            await bookAnalyzeUtils.getBookInfoAction(bookModel);
            //获取章节列表
            List<BookChapterModel> tmpChapterList = await bookAnalyzeUtils.getChapterListAction(bookModel);
            _currentSearchBook.latestChapterTitle = tmpChapterList[tmpChapterList.length - 1].chapterTitle;
            _currentSearchBook.totalChapterNum = tmpChapterList.length;
          }//更新数据
          await SearchBookSchema.getInstance.save(_currentSearchBook);
          break;
        }
      }
    }
    _isLoadCurrent = false;
  }

  //加载其他书源
  void _loadOtherBookSource({bool isRefresh = false}) async {
    if(isRefresh){
      setState(() {
        _isLoadExistMore = true;
        _isLoadOtherMore = true;
      });
    }
    List<SearchBookModel> dbSearchBookList = await SearchBookSchema.getInstance.getByNameAndAuthor(widget.bookModel.name, widget.bookModel.author);
    List<BookSourceModel> dbSourceList = await BookSourceSchema.getInstance.getBookSourceListByEnable();
    List<SearchBookModel> toShowBookList = [];
    List<SearchBookModel> handleSearchBookList = [];
    List<BookSourceModel> handleSourceList = [];
    for (BookSourceModel bookSource in dbSourceList) {
      bool hasSource = false;
      for (SearchBookModel searchBook in dbSearchBookList) {
        if (searchBook.origin == bookSource.bookSourceUrl) {
          //判断书源是否需要搜索，条件：1不是当前书源 2：章节总数为空 3：最新章节为空 4访问时间超过一天
          if (searchBook.origin != widget.bookModel.origin) {
            toShowBookList.add(searchBook);
            int day = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(searchBook.searchTime)).inDays;
            if(searchBook.getLatestChapterTitle() == "" || searchBook.totalChapterNum == 0 || day >= 1) {
              handleSearchBookList.add(searchBook);
            }
          }
          hasSource = true;
          break;
        }
      }
      if (!hasSource) {
        handleSourceList.add(bookSource);
      }
    }
    //如果是刷新，则所有内容重新获取
    if(isRefresh) {
      handleSearchBookList = [];
      for(SearchBookModel model in toShowBookList){
        model.latestChapterTitle = "";
        model.accessSpeed = 0;
        model.totalChapterNum = 0;
        handleSearchBookList.add(model);
      }
      await _reloadDataList(handleSearchBookList, []);
    }else{
      await _reloadDataList(toShowBookList, []);
    }
    setState(() {});
    //更新已存在于数据库的搜索记录
    if (handleSearchBookList.isNotEmpty) _bookSourceExistTask.startSearch(widget.bookModel, handleSearchBookList);
    if(handleSourceList.isNotEmpty){
      //获取所有未搜索过的书源，进行搜索
      _bookSourceChangeTask.startSearch(widget.bookModel, handleSourceList);
      //启动定时器，定时刷新一次
      _timerRefresh = Timer.periodic(const Duration(milliseconds: 3500), (timer) => setState(() {
        if(!_isLoadExistMore && !_isLoadOtherMore){
          _timerRefresh.cancel();
        }else{
          MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_UPDATE_BOOK_SOURCE_CNT, "");
        }
      }));
    }else{
      setState(() {
        _isLoadExistMore = false;
        _isLoadOtherMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(
          AppUtils.getLocale()?.selectBookSourceTitle ?? "",
          rightWidget: WidgetUtils.getHeaderIconData(0xe672),
          onRightPressed: () {
            _loadCurrentBookSource(isRefresh: true);
            _loadOtherBookSource(isRefresh: true);
          },
        )),
        backgroundColor: store.state.theme.body.background,
        floatingActionButton: (_isLoadExistMore || _isLoadOtherMore)
            ? FloatingActionButton(
                backgroundColor: Colors.red,
                mini: true,
                onPressed: () {
                  _bookSourceExistTask.stopSearch();
                  _bookSourceChangeTask.stopSearch();
                },
                child: const Icon(IconData(0xe68d, fontFamily: 'iconfont'), size: 15, color: Colors.white),
              )
            : null,
        floatingActionButtonLocation: AppConfig.APP_FLOATING_BUTTON_LOCATION,
        body: AppScrollView(
            showBar: true,
            child: Column(children: <Widget>[
              Container(
                height: 35,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: Row(children: <Widget>[
                  Expanded(
                    child: Text((AppUtils.getLocale()?.selectBookSourceCurrent ?? "") + (_currentBookSource != null ? "" : "(已删除)"), overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 15, color: getStore().state.theme.bookSource.title)),
                  ),
                  Visibility(
                    visible: _isLoadCurrent,
                    child: const CupertinoActivityIndicator(radius: 11)
                  ),
                ]),
              ),
              _renderItem(true, _currentSearchBook, _currentBookSource?.bookSourceGroup == null ? "书源已删除" : _currentBookSource!.bookSourceGroup, _currentBookSource?.enable == null ? "1" : _currentBookSource!.enable.toString()),
              Container(
                height: 35,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: Row(children: <Widget>[
                  Expanded(
                    child: Text("${AppUtils.getLocale()?.selectBookSourceTmp ?? ""}[${_dataList.length}]", style: TextStyle(fontSize: 15, color: getStore().state.theme.bookSource.title), overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                  Visibility(
                      visible: _isLoadExistMore || _isLoadOtherMore,
                      child: const CupertinoActivityIndicator(radius: 11)
                  ),
                ]),
              ),
              Visibility(
                  visible: _dataList.isNotEmpty,
                  child: _renderMore()
              ),
            ])),
      );
    });
  }

  Widget _renderMore() {
    return ListView.builder(
      itemCount: _dataList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _renderItem(false, _dataList[index]["searchBook"], _dataList[index]["groupName"], _dataList[index]["enable"]);
      },
    );
  }

  Widget _renderItem(bool isCurrent, SearchBookModel item, String groupName, String enable) {
    return AppTouchEvent(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
        child: Slidable.builder(
          key: Key(item.origin),
          actionPane: const SlidableStrechActionPane(),
          actionExtentRatio: 0.18,
          controller: slideController,
          secondaryActionDelegate: SlideActionBuilderDelegate(
              actionCount: (isCurrent) ? 1 : 2,
              builder: (context, index, animation, renderingMode) {
                if (index == 0) {
                  if (enable == "0") {
                    return _getSlideActionEnable(animation, item.origin);
                  } else {
                    return _getSlideActionDisable(animation, item.origin);
                  }
                } else if (index == 1) {
                  return _getSlideActionDelete(animation, item.origin);
                } else {
                  return IconSlideAction();
                }
              }),
          child: Container(
              height: _itemResultExtent,
              color: getStore().state.theme.bookDetail.background,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Row(children: <Widget>[
                      Text("${AppUtils.getLocale()?.bookDetailMsgSpeed}：", style: TextStyle(fontSize: 12, color: getStore().state.theme.bookSource.info)),
                      Text("${(item.accessSpeed == 0) ? AppUtils.getLocale()?.bookDetailMsgSpeedTest : item.accessSpeed.toString() + (AppUtils.getLocale()?.bookDetailMsgSpeedTime ?? "")}",
                          style: const TextStyle(fontSize: 12, color: Colors.red)),
                    ]),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints.expand(
                          width: 35.0,
                          height: 35.0,
                        ),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: getStore().state.theme.bookSource.header),
                        child: Text(_getFirstFont(item.originName, 0), style: TextStyle(color: getStore().state.theme.bookSource.headerText)),
                      ),
                      Container(width: 15),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(children: <Widget>[
                            Icon(const IconData(0xe6a6, fontFamily: 'iconfont'), color: getStore().state.theme.bookSource.info, size: 15),
                            Container(width: 4),
                            Expanded(
                                child: Text(
                              item.getLatestChapterTitle(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 15, color: getStore().state.theme.bookSource.info),
                            ))
                          ]),
                        ],
                      ))
                    ],
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Row(children: <Widget>[
                      Expanded(child: Row(children: <Widget>[
                        Flexible(child:Text("${AppUtils.getLocale()?.bookDetailMsgFrom}：${item.originName} [$groupName]", overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 12, color: getStore().state.theme.bookSource.info))),
                        Text(enable == "1" ? "" : "(${AppUtils.getLocale()?.appButtonDisabled})", overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 12, color: Colors.red))
                      ])),
                      Text("[${AppUtils.getLocale()?.bookDetailMsgTotal}${item.totalChapterNum}${AppUtils.getLocale()?.bookDetailMsgTotalChapter}]",
                          overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 12, color: getStore().state.theme.bookSource.info)),
                    ]),
                  ),
                ],
              )),
        ),
        onTap: () {
          bool isChangePage = true;
          if (slideController.activeState != null) {
            Key tmpKey = Key(item.origin);
            if (slideController.activeState?.widget.key != null && slideController.activeState?.widget.key == tmpKey) {
              isChangePage = false;
            }
            slideController.activeState?.close();
          }
          if (isChangePage){
            //返回书源
            if (item.origin == _currentSearchBook.origin) return;
            Navigator.pop<SearchBookModel>(context, item);
          }
        });
  }

  Widget _getSlideActionEnable(animation, String bookSourceUrl) {
    return IconSlideAction(
      caption: AppUtils.getLocale()?.appButtonEnable,
      color: WidgetUtils.gblStore?.state.theme.listSlideMenu.textGreen.withOpacity(animation.value),
      foregroundColor: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconGreen,
      iconWidget: Container(padding: const EdgeInsets.fromLTRB(0, 0, 0, 8), child: Icon(const IconData(0xe655, fontFamily: 'iconfont'), size: 22, color: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconBlue)),
      onTap: () async {
        for (int i = 0; i < _dataList.length; i++) {
          if (_dataList[i]["searchBook"].origin == bookSourceUrl) {
            _dataList[i]["enable"] = "1";
            break;
          }
        }
        await BookSourceSchema.getInstance.setEnableStatus(bookSourceUrl, 1);
        setState(() {});
      },
    );
  }

  Widget _getSlideActionDisable(animation, String bookSourceUrl) {
    return IconSlideAction(
      caption: AppUtils.getLocale()?.appButtonDisable,
      color: WidgetUtils.gblStore?.state.theme.listSlideMenu.textBlue.withOpacity(animation.value),
      foregroundColor: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconBlue,
      iconWidget: Container(padding: const EdgeInsets.fromLTRB(0, 0, 0, 8), child: Icon(const IconData(0xe6ba, fontFamily: 'iconfont'), size: 22, color: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconBlue)),
      onTap: () async {
        for (int i = 0; i < _dataList.length; i++) {
          if (_dataList[i]["searchBook"].origin == bookSourceUrl) {
            _dataList[i]["enable"] = "0";
            break;
          }
        }
        await BookSourceSchema.getInstance.setEnableStatus(bookSourceUrl, 0);
        setState(() {});
      },
    );
  }

  Widget _getSlideActionDelete(animation, String bookSourceUrl) {
    return IconSlideAction(
      caption: AppUtils.getLocale()?.appButtonDelete,
      color: WidgetUtils.gblStore?.state.theme.listSlideMenu.textRed.withOpacity(animation.value),
      foregroundColor: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconRed,
      iconWidget: Container(padding: const EdgeInsets.fromLTRB(0, 0, 0, 8), child: Icon(const IconData(0xe63a, fontFamily: 'iconfont'), size: 22, color: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconRed)),
      onTap: () async {
        for (int i = 0; i < _dataList.length; i++) {
          if (_dataList[i]["searchBook"].origin == bookSourceUrl) {
            _dataList.removeAt(i);
            break;
          }
        }
        await BookSourceSchema.getInstance.delBookSourceByUrl(bookSourceUrl);
        setState(() {});
      },
    );
  }

  String _getFirstFont(String name, int index) {
    String retVal = name.length > index ? name[index] : AppUtils.getLocale()?.bookDetailMsgSource ?? "";
    //匹配中文，英文字母和数字及_，不存在则递归获取下一个
    if (!RegExp("^[\u4e00-\u9fa5_a-zA-Z0-9]+\$").hasMatch(retVal)) {
      retVal = _getFirstFont(name, index + 1);
    }
    return retVal;
  }
}
