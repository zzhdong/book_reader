import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/module/book/task/book_search_task.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/pages/module/book/book_detail_page.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/pages/widget/book_cover.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class BookSearchPage extends StatefulWidget {
  @override
  _BookSearchPageState createState() => _BookSearchPageState();
}

class _BookSearchPageState extends AppState<BookSearchPage> {
  //事件订阅
  late StreamSubscription _streamSubscription;

  //搜索输入框
  final TextEditingController _searchController = TextEditingController();

  //搜索历史
  List<String>? _searchHistory;

  //所有书源
  final List<BookSourceModel> _allBookSource = [];

  //所有书源分组
  final List<BookSourceModel> _allBookSourceGroup = [];

  //已选择的书源
  final List<BookSourceModel> _selectBookSource = [];

  //搜索任务
  final BookSearchTask _bookSearchTask = BookSearchTask();

  //搜索结果
  List<SearchBookModel>? _searchBookResult;

  //上一次输入结果
  String _lastEditValue = "";
  final double _itemResultExtent = 98;

  @override
  void initState() {
    super.initState();
    _streamSubscription = MessageEventBus.bookSearchEventBus.on<BookSearchEvent>().listen((event) {
      _onHandleBookSearchEvent(event.code,
          searchBookModelList: event.searchBookModelList, isAll: event.isAll, errorMsg: event.errorMsg);
    });
    _init();
  }

  @override
  void dispose() {
    _bookSearchTask.stopSearch();
    _streamSubscription.cancel();
    super.dispose();
  }

  void _init() async {
    //加载所有书源
    _allBookSource.addAll(await BookSourceSchema.getInstance.getBookSourceListByEnable());
    _allBookSourceGroup.addAll(await BookSourceSchema.getInstance.getByBookSourceGroup());
    //搜索历史
    _searchHistory = AppConfig.prefs.getStringList(AppConfig.LOCAL_STORE_SEARCH);
    _searchHistory ??= [];
    setState(() {});
  }

  //处理消息事件
  _onHandleBookSearchEvent(code, {List<SearchBookModel>? searchBookModelList, bool isAll = false, String errorMsg = ""}) {
    switch (code) {
      case MessageCode.SEARCH_LOAD_MORE_OBJECT:
        if (searchBookModelList != null && searchBookModelList.isNotEmpty) {
          setState(() {
            _searchBookResult = searchBookModelList;
          });
        }
        break;
      case MessageCode.SEARCH_LOAD_MORE_FINISH:
        _stopLoad();
        break;
      case MessageCode.SEARCH_REFRESH_FINISH:
        _stopLoad();
        break;
      case MessageCode.SEARCH_ERROR:
        _stopLoad();
        break;
      default:
        break;
    }
  }

  void _beginToSearch(value) async {
    if (StringUtils.isEmpty(value)) {
      ToastUtils.showToast(AppUtils.getLocale()?.msgSearchInput ?? "");
      return;
    }
    //判断是否正在搜索
    if (isLoading) {
      _bookSearchTask.stopSearch();
      //清空搜索内容
      setState(() {
        _searchBookResult = [];
      });
      //一秒后重新搜索
      Future.delayed(const Duration(milliseconds: 800), () => _beginToSearch(value));
      return;
    }

    //显示正在加载
    _startLoad();
    _searchController.text = value;
    //写入搜索历史
    _searchHistory?.remove(value);
    _searchHistory?.insert(0, value);
    //超过条数，则删除最后一条
    if(_searchHistory != null && _searchHistory!.length > 30) _searchHistory!.removeLast();
    AppConfig.prefs.setStringList(AppConfig.LOCAL_STORE_SEARCH, _searchHistory!);
    //获取搜索结果
    _searchBookResult = [];
    if (_selectBookSource.isEmpty) {
      _bookSearchTask.searchBook(value, _allBookSource);
    } else {
      _bookSearchTask.searchBook(value, _selectBookSource);
    }
  }

  void _startLoad() {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
  }

  void _stopLoad() {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: _renderSearchBar() as PreferredSizeWidget,
        backgroundColor: store.state.theme.body.background,
        floatingActionButton: isLoading
            ? FloatingActionButton(
                backgroundColor: Colors.red,
                mini: true,
                onPressed: () {
                  _bookSearchTask.stopSearch();
                },
                child: const Icon(IconData(0xe68d, fontFamily: 'iconfont'), size: 15, color: Colors.white),
              )
            : null,
        floatingActionButtonLocation: AppConfig.APP_FLOATING_BUTTON_LOCATION,
        body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // 触摸收起键盘
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                renderLoadingBar(),
                (_searchBookResult == null) ? Expanded(child: _renderSearchHistory()) : Container(),
                (_searchBookResult != null) ? Expanded(child: _renderDataList()) : Container(),
              ],
            )),
      );
    });
  }

  Widget _renderSearchBar() {
    return PreferredSize(
        preferredSize: Size.fromHeight(ScreenUtils.getHeaderHeight()),
        child: Container(
          color: getStore().state.theme.primary,
          child: Padding(
            padding: EdgeInsets.only(top: ScreenUtils.getViewPaddingTop()),
            child: Row(
              children: <Widget>[
                IconButton(
                    icon: WidgetUtils.getHeaderIconData(0xe636), onPressed: () => NavigatorUtils.goBack(context)),
                Expanded(
                  child: SizedBox(
                    height: ScreenUtils.getHeaderHeight(),
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                        child: Card(
                            child: Container(
                          decoration: BoxDecoration(
                              color: getStore().state.theme.searchBox.background,
                              borderRadius: BorderRadius.circular((4.0))),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.fromLTRB(5, 3, 0, 0),
                                child: Icon(
                                  Icons.search,
                                  color: getStore().state.theme.searchBox.icon,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  keyboardAppearance: (AppParams.getInstance().getAppTheme() == 1) ? Brightness.light : Brightness.dark,
                                  onSubmitted: (value) => _beginToSearch(value),
                                  onChanged: (value) {
                                    if (StringUtils.isEmpty(value) || StringUtils.isEmpty(_lastEditValue)) {
                                      setState(() {});
                                    }
                                    _lastEditValue = value;
                                  },
                                  controller: _searchController,
                                  style: TextStyle(fontSize: 16, color: getStore().state.theme.searchBox.input),
                                  textAlign: TextAlign.start,
                                  autofocus: true,
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.fromLTRB(5, 0, 0, 11),
                                      hintText: AppParams.getInstance().getSearchBookType() == 1 ? AppUtils.getLocale()?.bookSearchNotice1 : AppParams.getInstance().getSearchBookType() == 2 ? AppUtils.getLocale()?.bookSearchNotice2 : AppUtils.getLocale()?.bookSearchNotice3,
                                      hintStyle: TextStyle(
                                          fontSize: 16, color: getStore().state.theme.searchBox.placeholder),
                                      border: InputBorder.none),
                                ),
                              ),
                              Visibility(
                                visible: _searchController.text != "",
                                child: IconButton(
                                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                                  icon: const Icon(Icons.cancel),
                                  color: getStore().state.theme.searchBox.icon,
                                  iconSize: 18.0,
                                  onPressed: () {
                                    _searchController.clear();
                                    _lastEditValue = "";
                                    if (!isLoading) _searchBookResult = null;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ))),
                  ),
                ),
                IconButton(icon: WidgetUtils.getHeaderIconData(0xe68f), onPressed: () => _showDropDownMenu()),
              ],
            ),
          ),
        ));
  }

  Widget _renderSearchHistory() {
    List<Widget> widgetList = [];
    if (_searchHistory != null) {
      for (String str in _searchHistory!) {
        widgetList.add(AppTouchEvent(
            defEffect: true,
            onTap: () {
              //隐藏键盘
              FocusScope.of(context).requestFocus(FocusNode());
              _beginToSearch(str);
            },
            child: SizedBox(
                height: 20,
                child: Row(
                  children: <Widget>[
                    Icon(const IconData(0xe64e, fontFamily: 'iconfont'),
                        color: getStore().state.theme.searchBox.historyIcon, size: 15),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(str,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: getStore().state.theme.searchBox.historyText)),
                    ),
                  ],
                ))));
        widgetList.add(Divider(color: getStore().state.theme.searchBox.historyBorder));
      }
    }
    return AppScrollView(
        child: Column(children: <Widget>[
      Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(AppUtils.getLocale()?.bookSearchHistory ?? "",
                      style: TextStyle(fontSize: 16, color: getStore().state.theme.searchBox.historyKey)),
                ),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      setState(() {
                        AppConfig.prefs.remove(AppConfig.LOCAL_STORE_SEARCH);
                        _searchHistory = [];
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(const IconData(0xe63a, fontFamily: 'iconfont'),
                            color: getStore().state.theme.searchBox.clear, size: 16),
                        const SizedBox(width: 3),
                        Text(AppUtils.getLocale()?.appButtonClear ?? "",
                            style: TextStyle(fontSize: 14, color: getStore().state.theme.searchBox.clear)),
                      ],
                    )),
              ],
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(12, 5, 0, 0),
                child: Column(
                  children: widgetList,
                )),
          ],
        ),
      ),
    ]));
  }

  Widget _renderDataList() {
    return CupertinoScrollbar(
      child: ListView.builder(
        itemCount: _searchBookResult?.length ?? 0,
        itemExtent: _itemResultExtent,
        itemBuilder: (context, index) {
          SearchBookModel model = _searchBookResult![index];
          return AppTouchEvent(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
            child: Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Row(children: <Widget>[
                  BookCover(model.toBook(), width: 55, height: 70),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Container(height: 2),
                      Text(model.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700, color: getStore().state.theme.bookList.title)),
                      RichText(
                          text: TextSpan(
                              text: "${AppUtils.getLocale()?.bookDetailMsgAuthorName ?? ""}：",
                              style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.desc),
                              children: <TextSpan>[
                                TextSpan(text: (StringUtils.isEmpty(model.getRealAuthor())
                                    ? AppUtils.getLocale()?.bookDetailMsgUnknown
                                    : model.getRealAuthor()),
                                    style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.author)),
                                TextSpan(text: model.getKindString(true),
                                    style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.desc)),
                              ]
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                      ),
                      Text(
                          "${AppUtils.getLocale()?.bookDetailMsgBookSource}：${StringUtils.isEmpty(model.originName) ? AppUtils.getLocale()?.bookDetailMsgUnknown : model.originName} [${AppUtils.getLocale()?.bookDetailMsgTotal}${model.getOriginNum()}${AppUtils.getLocale()?.bookDetailMsgTotalBookSource}]",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.subDesc)),
                      Text("${AppUtils.getLocale()?.bookDetailMsgLastChapter}：${model.getLatestChapterTitle()}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.subDesc)),
                    ]),
                  ),
                ])),
            onTap: () {
              _bookSearchTask.stopSearch();
              NavigatorUtils.changePage(context, BookDetailPage(2, searchBookModel: model));
            },
          );
        },
      ),
    );
  }

  //显示下拉菜单
  void _showDropDownMenu() {
    dropMenuIdList = ["searchType", "filterType", "filterSource"];
    dropMenuIconList = [0xe62c, 0xe665, 0xe663];
    dropMenuNameList = [AppUtils.getLocale()?.bookSearchType ?? "", AppUtils.getLocale()?.bookSearchFilterType ?? "", AppUtils.getLocale()?.bookSearchFilterSource ?? ""];
    showDropMenu(null, (value) => _menuOnPress(value));
  }

  //菜单点击事件
  void _menuOnPress(value) async {
    if (value == "searchType") {
      WidgetUtils.selectSearchType(()=> setState(() {}));
    } else if (value == "filterType") {
      WidgetUtils.selectSourceFilter();
    } else if (value == "filterSource") {
      WidgetUtils.selectBookSource(AppParams.getInstance().getSearchBookSourceFilterType().toString(),
          _allBookSource, _allBookSourceGroup, _selectBookSource);
    }
  }
}
