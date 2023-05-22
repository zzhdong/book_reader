import 'dart:async';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/schema/search_book_schema.dart';
import 'package:book_reader/module/book/task/book_source_change_task.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/task/book_chapter_task.dart';
import 'package:book_reader/module/book/task/book_detail_task.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/module/book/utils/change_source_utils.dart';
import 'package:book_reader/pages/module/book/book_chapter_page.dart';
import 'package:book_reader/pages/module/book/book_source_change_page.dart';
import 'package:book_reader/pages/module/read/read_page.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/ad_manager.dart';
import 'package:book_reader/utils/date_utils.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/pages/widget/book_cover.dart';
import 'package:book_reader/widget/dialog/app_copy_text.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class BookDetailPage extends StatefulWidget {
  //1书架进入 2搜索进入
  final int openType;

  final BookModel? bookModel;

  final SearchBookModel? searchBookModel;

  const BookDetailPage(this.openType, {super.key, this.bookModel, this.searchBookModel});

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends AppState<BookDetailPage> {

  static const String _pageName = "BookDetailPage";
  //搜索结果对象
  SearchBookModel _searchBookModel = SearchBookModel();
  //书架对象
  BookModel _bookModel = BookModel();
  //当前书源
  BookSourceModel? _bookSourceModel;
  //是否在书架中
  bool _inBookShelf = false;
  //书源总数
  int _sourceTotal = 0;
  int _sourceExistTotal = 0;
  //章节列表
  List<BookChapterModel> _chapterModelList = [];
  //是否正在加载书籍信息
  bool _isLoadInfo = true;
  //是否正在加载书源
  bool _isLoadBookSource = true;
  //是否正在加载章节列表
  bool _isLoadChapter = true;
  //全局通知事件
  late StreamSubscription _streamSubscription;

  //事件订阅
  late StreamSubscription _bookDetailSubscription;
  final BookDetailTask _bookDetailTask = BookDetailTask(_pageName);
  late StreamSubscription _bookSourceUpdateSubscription;
  final BookSourceChangeTask _bookSourceChangeTask = BookSourceChangeTask(_pageName);
  late StreamSubscription _bookChapterSubscription;
  final BookChapterTask _bookChapterTask = BookChapterTask();

  @override
  void initState() {
    super.initState();
    //监听全局消息
    _streamSubscription = MessageEventBus.globalEventBus.on<MessageEvent>().listen((event) {
      _onHandleGlobalEvent(event.code, event.message);
    });
    _bookDetailSubscription = MessageEventBus.bookDetailEventBus.on<BookDetailEvent>().listen((event) {
      _onHandleBookDetailEvent(event.code, event.taskName, bookModel: event.bookModel, errorMsg: event.errorMsg);
    });
    _bookSourceUpdateSubscription = MessageEventBus.bookSourceUpdateEventBus.on<BookSourceUpdateEvent>().listen((event) {
      _onHandleBookSourceUpdateEvent(event.code, event.taskName, searchBookModelList: event.searchBookModelList, errorMsg: event.errorMsg);
    });
    _bookChapterSubscription = MessageEventBus.bookChapterEventBus.on<BookChapterEvent>().listen((event) {
      _onHandleBookChapterEvent(event.code,
          bookModel: event.bookModel,
          bookChapterModelList: event.bookChapterModelList,
          errorMsg: event.errorMsg);
    });
    _initBookInfo();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _stopAll();
    _bookDetailSubscription.cancel();
    _bookSourceUpdateSubscription.cancel();
    _bookChapterSubscription.cancel();
    super.dispose();
  }

  _onHandleGlobalEvent(int code, message) async {
    switch (code) {
      case MessageCode.NOTICE_ADD_TO_BOOKSHELF:
        _bookModel.hasUpdate = 0;
        BookUtils.saveBookToShelf(_bookModel);
        setState(() {
          _searchBookModel.setIsCurrentSource(true);
          _inBookShelf = true;
        });
        break;
      case MessageCode.NOTICE_UPDATE_BOOK_SOURCE_CNT:
        //书源搜索
        List<SearchBookModel> dbSearchBookList = await SearchBookSchema.getInstance.getByNameAndAuthor(_bookModel.name, _bookModel.author);
        List<BookSourceModel> dbSourceList = await BookSourceSchema.getInstance.getBookSourceListByEnable();
        List<SearchBookModel> handleSearchBookList = [];
        for (BookSourceModel bookSource in dbSourceList) {
          for (SearchBookModel searchBook in dbSearchBookList) {
            if (searchBook.origin == bookSource.bookSourceUrl) {
              if (searchBook.origin != _bookModel.origin) handleSearchBookList.add(searchBook);
              break;
            }
          }
        }
        setState(() {
          _sourceTotal = _sourceExistTotal = handleSearchBookList.length;
        });
        break;
    }
  }

  _onHandleBookDetailEvent(int code, String taskName, {BookModel? bookModel, String errorMsg = ""}) {
    if(taskName == _pageName){
      setState(() {
        if (code == MessageCode.SEARCH_LOAD_MORE_OBJECT && bookModel != null) {
          //更新书籍信息
          if (_inBookShelf) {
            BookUtils.saveBookToShelf(_bookModel);
            //发送刷新书架通知
            MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
          }
        } else{
          _isLoadInfo = false;
        }
      });
    }
  }

  _onHandleBookSourceUpdateEvent(int code, String taskName, {List<SearchBookModel>? searchBookModelList, String errorMsg = ""}) {
    if(taskName == _pageName){
      setState(() {
        if (code == MessageCode.SEARCH_LOAD_MORE_OBJECT && searchBookModelList != null && searchBookModelList.isNotEmpty) {
          _sourceTotal = _sourceExistTotal + searchBookModelList.length;
          if(_sourceTotal > 10){
            _bookSourceChangeTask.stopSearch();
          }
        } else {
          _isLoadBookSource = false;
        }
      });
    }
  }

  _onHandleBookChapterEvent(int code, {BookModel? bookModel, List<BookChapterModel>? bookChapterModelList, String errorMsg = ""}) {
    setState(() {
      if (code == MessageCode.SEARCH_LOAD_MORE_OBJECT && bookChapterModelList != null && bookChapterModelList.isNotEmpty) {
        _chapterModelList = bookChapterModelList;
        if(_bookModel.latestChapterTitle == "") {
          _bookModel.durChapterIndex = bookModel?.durChapterIndex ?? 0;
          _bookModel.durChapterTitle = bookModel?.durChapterTitle ?? "";
        }
        _bookModel.totalChapterNum = bookModel?.totalChapterNum ?? 0;
        _bookModel.latestChapterTitle = bookModel?.getLatestChapterTitle() ?? "";
      } else {
        _isLoadChapter = false;
      }
    });
  }

  void _initBookInfo() async{
    //判断打开来源
    if (widget.openType == 1) {
      //判断对象是否存在
      if (widget.bookModel == null) {
        NavigatorUtils.goBack(context);
        return;
      }
      //初始化对象
      _bookModel = widget.bookModel!.clone();
      _initBookShelfBook();
    } else {
      //判断对象是否存在
      if (widget.searchBookModel == null) {
        NavigatorUtils.goBack(context);
        return;
      }
      _searchBookModel = widget.searchBookModel!.clone();
      _bookModel = _searchBookModel.toBook();
      //判断是否已保存书架
      BookModel? tmpBookInfo = await BookUtils.getBookByNameAndAuthor(_bookModel.name, _bookModel.author);
      if(tmpBookInfo != null){
        _bookModel = tmpBookInfo;
        _initBookShelfBook();
      }else{
        //初始化对象
        _inBookShelf = _searchBookModel.getIsCurrentSource();
        //刷新书籍
        _refreshBook(isRefresh: false);
      }
    }
  }

  void _initBookShelfBook(){
    _inBookShelf = true;
    _searchBookModel = SearchBookModel();
    _searchBookModel.bookUrl = _bookModel.bookUrl;
    _searchBookModel.origin = _bookModel.origin;
    //刷新书籍
    _refreshBook(isRefresh: false);
  }

  void _stopAll() {
    _bookDetailTask.stopSearch();
    _bookSourceChangeTask.stopSearch();
    _bookChapterTask.stopSearch();
  }

  void _refreshBook({bool isRefresh = true}) async {
    if(isRefresh) _stopAll();
    if (AppConfig.BOOK_LOCAL_TAG == _bookModel.origin) return;
    _bookSourceModel = await BookSourceSchema.getInstance.getByBookSourceUrl(_bookModel.origin);
    //更新状态
    setState(() {
      _isLoadInfo = true;
      _isLoadBookSource = true;
      _isLoadChapter = true;
    });
    //启动书籍详情搜索
    _bookDetailTask.startSearch(_bookModel, await BookSourceSchema.getInstance.getToSearchDetailList());
    //启动书籍章节搜索
    _bookChapterTask.startSearch(_bookModel, _inBookShelf);
    //书源搜索
    List<SearchBookModel> dbSearchBookList = await SearchBookSchema.getInstance.getByNameAndAuthor(_bookModel.name, _bookModel.author);
    List<BookSourceModel> dbSourceList = await BookSourceSchema.getInstance.getBookSourceListByEnable();
    List<SearchBookModel> handleSearchBookList = [];
    List<BookSourceModel> handleSourceList = [];
    for (BookSourceModel bookSource in dbSourceList) {
      bool hasSource = false;
      for (SearchBookModel searchBook in dbSearchBookList) {
        if (searchBook.origin == bookSource.bookSourceUrl) {
          if (searchBook.origin != _bookModel.origin) {
            handleSearchBookList.add(searchBook);
          }
          hasSource = true;
          break;
        }
      }
      if (!hasSource) {
        handleSourceList.add(bookSource);
      }
    }
    //当前搜索过的书源总数超过10个，则不进行搜索
    if(dbSearchBookList.length > 10){
      _isLoadBookSource = false;
    }else{
      //延迟1秒启动书源搜索
      Future.delayed(const Duration(milliseconds: 1200), () {
        _bookSourceChangeTask.startSearch(_bookModel, handleSourceList);
      });
    }
    setState(() {
      _sourceTotal = _sourceExistTotal = dbSearchBookList.length;
    });
  }

  //加入书架
  void addToBookShelf() async {
    //新加入书架的书籍不需要显示更新标签
    _bookModel.hasUpdate = 0;
    await BookUtils.saveBookToShelf(_bookModel);
    _searchBookModel.setIsCurrentSource(true);
    _inBookShelf = true;
    setState(() {});
    //发送刷新书架通知
    MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
    //加入成功后，启动下载前五章
    Future.delayed(const Duration(milliseconds: 1000), () {
      BookUtils.downloadPreChapter(_bookModel);
    });
  }

  //移出书架
  void removeFromBookShelf() async {
    await BookUtils.removeFromBookShelf(_bookModel);
    _searchBookModel.setIsCurrentSource(false);
    _inBookShelf = false;
    setState(() {});
    //发送刷新书架通知
    MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
  }

  //更换书源
  void _changeBookSource(SearchBookModel searchBook) async {
    searchBook.name = _bookModel.name;
    searchBook.author = _bookModel.author;
    _searchBookModel = searchBook;
    List<dynamic> retList = await ChangeSourceUtils.changeBookSource(searchBook, _bookModel);
    _bookModel = retList[0];
    _chapterModelList = retList[1];
    //刷新书架
    MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
    BookSourceModel? bookSourceModel = await BookSourceSchema.getInstance.getByBookSourceUrl(_bookModel.origin);
    //更新权重
    bookSourceModel?.weight++;
    BookSourceSchema.getInstance.updateBookSource(bookSourceModel);
    //刷新界面
    _refreshBook();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(_bookModel.name,
          rightWidget: WidgetUtils.getHeaderIconData(0xe672),
          onRightPressed: () => {_refreshBook()},
        )),
        backgroundColor: store.state.theme.body.background,
        floatingActionButton: (_isLoadInfo || _isLoadBookSource || _isLoadChapter)
            ? FloatingActionButton(
          backgroundColor: Colors.red,
          mini: true,
          onPressed: () => _stopAll(),
          child: const Icon(IconData(0xe68d, fontFamily: 'iconfont'), size: 15, color: Colors.white),
        )
            : null,
        floatingActionButtonLocation: AppConfig.APP_FLOATING_BUTTON_LOCATION,
        body: Column(children: <Widget>[
          Expanded(
              child: AppScrollView(
                  showBar: false,
                  child: Column(children: <Widget>[
                    _renderBookInfo(),
                    _renderBookContent(),
                    _adLoadSuccess ? _renderAdBanner() : Container(),
                    _renderBookSource(),
                    _renderBookChapter(),
                    _renderAdBanner(),
                    Container(height: 10)
                  ]))),
          Container(
            color: store.state.theme.body.background,
            padding: const EdgeInsets.fromLTRB(0.0, 1.0, 0.0, 0.0),
            height: 53 + ScreenUtils.getViewPaddingBottom(),
            child: Container(
                color: getStore().state.theme.tabMenu.background,
                height: 52 + ScreenUtils.getViewPaddingBottom(),
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, ScreenUtils.getViewPaddingBottom()),
                child: Row(
              children: <Widget>[
                Expanded(
                    child: AppTouchEvent(
                        onTap: () {
                          if (_inBookShelf) {
                            removeFromBookShelf();
                          } else {
                            addToBookShelf();
                          }
                        },
                        child: Container(
                            alignment: Alignment.center,
                            height: 45,
                            color: WidgetUtils.gblStore?.state.theme.bookDetail.btnBackground,
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              Icon(IconData(_inBookShelf ? 0xe6b9 : 0xe6b8, fontFamily: 'iconfont'),
                                  color: _inBookShelf ? Colors.green : Colors.red, size: 17),
                              Container(width: 5),
                              Text(
                                  _inBookShelf
                                      ? AppUtils.getLocale()?.bookDetailBtnRemove ?? ""
                                      : AppUtils.getLocale()?.bookDetailBtnAdd ?? "",
                                  style: _inBookShelf
                                      ? const TextStyle(color: Colors.green, fontSize: 15)
                                      : const TextStyle(color: Colors.red, fontSize: 15))
                            ])))),
                Expanded(
                    child:
                    ElevatedButton(
                      //style: ElevatedButton.styleFrom(fixedSize: Size(MediaQuery.of(context).size.width - 50, 0)),
                      child: Text(AppUtils.getLocale()?.bookDetailBtnRead ?? ""),
                      onPressed: () {
                        _stopAll();
                        NavigatorUtils.changePage(context, ReadPage(1, _inBookShelf, _bookModel), animationType: 3);
                      },
                    ),
                ),
              ],
            )),
          )
        ]),
      );
    });
  }

  //显示书籍信息模块
  Widget _renderBookInfo() {
    return Container(
        color: getStore().state.theme.bookDetail.background,
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          BookCover(_bookModel, width: 90, height: 125, marginLeft: 0),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Container(height: 5),
              AppCopyText(
                  _bookModel.name,
                  maxLines: 1,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: getStore().state.theme.bookList.title)
              ),
              Container(height: 4),
              Row(children: <Widget>[
                Icon(const IconData(0xe6ab, fontFamily: 'iconfont'),
                    color: WidgetUtils.gblStore?.state.theme.bookList.desc, size: 14),
                Container(width: 5),
                Flexible(
                    child: AppCopyText(
                        (StringUtils.isEmpty(_bookModel.getRealAuthor())
                            ? AppUtils.getLocale()?.bookDetailMsgUnknown ?? ""
                            : _bookModel.getRealAuthor()),
                        maxLines: 1,
                        style: TextStyle(fontSize: 14, color: getStore().state.theme.bookList.author)))
              ]),
              Container(height: 4),
              Row(children: <Widget>[
                Icon(const IconData(0xe6a9, fontFamily: 'iconfont'),
                    color: WidgetUtils.gblStore?.state.theme.bookList.desc, size: 14),
                Container(width: 5),
                Expanded(
                    child: Text(_bookModel.getKindNoTime(false),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 13, color: getStore().state.theme.bookList.subDesc)))
              ]),
              Container(height: 4),
              Row(children: <Widget>[
                Icon(const IconData(0xe6a6, fontFamily: 'iconfont'),
                    color: WidgetUtils.gblStore?.state.theme.bookList.desc, size: 15),
                Container(width: 4),
                Expanded(
                    child: Text(_bookModel.getLatestChapterTitle(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 13, color: getStore().state.theme.bookList.subDesc)))
              ]),
              Container(height: 4),
              Row(children: <Widget>[
                Icon(const IconData(0xe6aa, fontFamily: 'iconfont'),
                    color: WidgetUtils.gblStore?.state.theme.bookList.desc, size: 14),
                Container(width: 5),
                Expanded(
                    child: Text(StringUtils.getTimeStr(AppDateUtils.getDateTime(_bookModel.updateTime)),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 13, color: getStore().state.theme.bookList.subDesc)))
              ]),
            ]),
          ),
        ]));
  }

  //显示书籍内容模块
  Widget _renderBookContent() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      color: getStore().state.theme.bookDetail.background,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: getStore().state.theme.bookDetail.box,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(AppUtils.getLocale()?.bookDetailTitleIntro ?? "",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: getStore().state.theme.bookDetail.title)),
                    ),
                    Visibility(
                      visible: _isLoadInfo,
                      child: const CupertinoActivityIndicator(radius: 11),
                    ),
                  ],
                ),
                Container(height: 3),
                Text(StringUtils.getTextIndent(_bookModel.intro),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 100,
                    style: TextStyle(fontSize: 13, color: getStore().state.theme.bookDetail.intro))
              ],
            ),
          ),
        ],
      ),
    );
  }

  //显示书源模块
  Widget _renderBookSource() {
    String source = AppUtils.getLocale()?.bookDetailMsgUnknown ?? "";
    if(StringUtils.isNotEmpty(_bookModel.originName)){
      source = "${_bookModel.originName} [${_bookSourceModel?.bookSourceGroup}]";
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      color: getStore().state.theme.bookDetail.background,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: getStore().state.theme.bookDetail.box,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(AppUtils.getLocale()?.bookDetailTitleBookSource ?? "",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: getStore().state.theme.bookDetail.title)),
                    ),
                    Visibility(
                      visible: _isLoadBookSource,
                      child: const CupertinoActivityIndicator(radius: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 3),
          Text(
              "${AppUtils.getLocale()?.bookDetailMsgSourceNum}：${AppUtils.getLocale()?.bookDetailMsgTotal} ${_sourceTotal > 10 ? "10+" : _sourceTotal} ${AppUtils.getLocale()?.bookDetailMsgTotalBookSource}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 13, color: getStore().state.theme.bookDetail.intro)),
          Container(height: 3),
          Text(
              "${AppUtils.getLocale()?.bookDetailMsgBookSourceCurrent}：$source ",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 13, color: getStore().state.theme.bookDetail.intro)),
          AppTouchEvent(
              onTap: () {
                _stopAll();
                Navigator.push<SearchBookModel>(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => BookSourceChangePage(_bookModel, _chapterModelList))).then((data) {
                  if (data != null) Future.delayed(const Duration(milliseconds: 500), () => _changeBookSource(data));
                });
              },
              child: Container(
                height: 25,
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                alignment: Alignment.center,
                child: Text(AppUtils.getLocale()?.bookDetailMsgBookSourceMore ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: WidgetUtils.gblStore?.state.theme.tabMenu.activeTint)),
              )),
        ],
      ),
    );
  }

  //显示章节模块
  Widget _renderBookChapter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      color: getStore().state.theme.bookDetail.background,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: getStore().state.theme.bookDetail.box,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(AppUtils.getLocale()?.bookDetailTitleChapter ?? "",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: getStore().state.theme.bookDetail.title)),
                    ),
                    Visibility(
                      visible: _isLoadChapter,
                      child: const CupertinoActivityIndicator(radius: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 3),
          Text(
              "${AppUtils.getLocale()?.bookDetailMsgChapterNum}：${AppUtils.getLocale()?.bookDetailMsgTotal} ${_chapterModelList.isEmpty ? _bookModel.totalChapterNum : _chapterModelList.length} ${AppUtils.getLocale()?.bookDetailMsgTotalChapter}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 13, color: getStore().state.theme.bookDetail.intro)),
          Container(height: 3),
          Text("${AppUtils.getLocale()?.bookDetailMsgLastChapter}：${_bookModel.getLatestChapterTitle()}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 13, color: getStore().state.theme.bookDetail.intro)),
          Container(height: 3),
          Text(
              "${AppUtils.getLocale()?.bookDetailMsgUpdateTime}：${StringUtils.getTimeStr(AppDateUtils.getDateTime(_bookModel.updateTime))}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 13, color: getStore().state.theme.bookDetail.intro)),
          AppTouchEvent(
              onTap: () {
                if (_bookModel.totalChapterNum == 0 && ( _chapterModelList.isEmpty)) {
                  ToastUtils.showToast(AppUtils.getLocale()?.msgBookChapterUnLoadFinish ?? "");
                  return;
                }
                NavigatorUtils.changePage(context, BookChapterPage(_bookModel, _chapterModelList));
              },
              child: Container(
                height: 25,
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                alignment: Alignment.center,
                child: Text(AppUtils.getLocale()?.bookDetailMsgChapterAll ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: WidgetUtils.gblStore?.state.theme.tabMenu.activeTint)),
              )),
        ],
      ),
    );
  }

  bool _adLoadSuccess = false;
  //显示广告
  Widget _renderAdBanner(){
    if (AppParams.getInstance().getOpenAd() && !AppParams.getInstance().isVideoReward()) {
      return Container(
          margin: const EdgeInsets.only(top: 10.0),
          child: AdmobBanner(
              adUnitId: AdManager.bannerAdUnitId,
              adSize: AdmobBannerSize(width: ScreenUtils.getScreenWidth().toInt(), height: 60, name: 'ADAPTIVE_BANNER'),
              listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
                if(!_adLoadSuccess && event == AdmobAdEvent.loaded) setState(() {_adLoadSuccess = true;});
                print("书籍详情广告加载结果：$event");
              }
          )
      );
    } else {
      return Container();
    }
  }
}
