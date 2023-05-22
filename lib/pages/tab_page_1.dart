import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_group_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/schema/book_group_schema.dart';
import 'package:book_reader/database/schema/book_schema.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/task/book_detail_task.dart';
import 'package:book_reader/module/book/task/book_shelf_task.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/pages/module/book/book_search_page.dart';
import 'package:book_reader/pages/module/book/book_shelf_edit_page.dart';
import 'package:book_reader/pages/module/book/web_server_page.dart';
import 'package:book_reader/pages/module/read/read_page.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_refresh_list.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:book_reader/pages/widget/book_grid_item.dart';
import 'package:book_reader/pages/widget/book_group_item.dart';
import 'package:book_reader/pages/widget/book_list_item.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

import 'menu/menu_edit_box.dart';

class TabPage1 extends StatefulWidget {
  const TabPage1({super.key});

  @override
  _TabPage1State createState() => _TabPage1State();
}

class _TabPage1State extends AppState<TabPage1> {

  static const String _pageName = "TabPage1";
  //全局通知事件
  StreamSubscription? _streamSubscription;
  //数据列表控件
  final GlobalKey<AppRefreshListState> _appRefreshListState = GlobalKey<AppRefreshListState>();
  //是否更新数据
  bool needToGetData = false;

  //书架搜索任务
  StreamSubscription? _bookShelfSubscription;
  final BookShelfTask _bookShelfTask = BookShelfTask();
  //刷新书籍详情
  StreamSubscription? _bookDetailSubscription;
  final BookDetailTask _bookDetailTask = BookDetailTask(_pageName);

  int _bookDetailTaskIndex = 0;
  List<BookSourceModel> _allBookSourceList = [];
  //是否为列表
  bool _isList = true;


  @override
  void initState() {
    super.initState();
    if(AppParams.getInstance().getBookShelfIsList()){
      if(AppParams.getInstance().getBookShelfShowType() == 2) _isList = false;
    }
    //监听全局消息
    _streamSubscription = MessageEventBus.globalEventBus.on<MessageEvent>().listen((event) {
      _onHandleGlobalEvent(event.code, event.message);
    });
    _bookShelfSubscription = MessageEventBus.bookShelfEventBus.on<BookShelfEvent>().listen((event) {
      _onHandleBookShelfEvent(event.code, dataList: event.dataList, errorMsg: event.errorMsg);
    });
    _bookDetailSubscription = MessageEventBus.bookDetailEventBus.on<BookDetailEvent>().listen((event) {
      _onHandleBookDetailEvent(event.code, event.taskName, bookModel: event.bookModel, errorMsg: event.errorMsg);
    });
    AppUtils.initDelayed(() {
      //判断是否启动后继续上一次阅读
      if(AppParams.getInstance().getStartUpToRead() && !StringUtils.isEmpty(AppParams.getInstance().getLastReadBookId())){
        BookSchema.getInstance.getByBookUrl(AppParams.getInstance().getLastReadBookId()).then((BookModel? book){
          //跳转到阅读界面
          if(book != null) Future.delayed(const Duration(milliseconds: 1000), () => NavigatorUtils.changePage(context, ReadPage(1, true, book), animationType: 3));
        });
      }
      //判断启动后是否自动刷新书架
      needToGetData = AppParams.getInstance().getStartUpToRefresh();
      _appRefreshListState.currentState?.beginToRefresh();
    }, duration: 10);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _bookShelfTask.stopSearch();
    _bookShelfSubscription?.cancel();
    _bookShelfSubscription = null;
    _bookDetailSubscription?.cancel();
    _bookDetailSubscription = null;
    _bookDetailTask.stopSearch();
    super.dispose();
  }

  _onHandleGlobalEvent(int code, message) {
    switch (code) {
      case MessageCode.NOTICE_REFRESH_BOOKSHELF:
        _isList = true;
        if(AppParams.getInstance().getBookShelfIsList()){
          if(AppParams.getInstance().getBookShelfShowType() == 2) _isList = false;
        }
        needToGetData = false;
        _appRefreshListState.currentState?.beginToRefresh();
        break;
    }
  }

  _onHandleBookShelfEvent(int code, {List<BookModel>? dataList, String errorMsg = ""}) {
    setState(() {});
  }

  _onHandleBookDetailEvent(int code, String taskName, {BookModel? bookModel, String errorMsg = ""}){
    if(taskName == _pageName){
      setState(() {
        if(code == MessageCode.SEARCH_LOAD_MORE_OBJECT && bookModel != null && _bookDetailTaskIndex < (_appRefreshListState.currentState?.getDataList().length ?? 0)) {
          _appRefreshListState.currentState?.getDataList()[_bookDetailTaskIndex].setBookInfoModel(bookModel);
          BookUtils.saveBookToShelf(_appRefreshListState.currentState?.getDataList()[_bookDetailTaskIndex]);
        }else {
          _bookDetailTaskIndex++;
          if(_bookDetailTaskIndex < (_appRefreshListState.currentState?.getDataList().length ?? 0)){
            _bookDetailTask.startSearch((_appRefreshListState.currentState?.getDataList()[_bookDetailTaskIndex] as BookModel), _allBookSourceList);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(
          AppTitleBar(AppUtils.getLocale()?.homeTab_1 ?? "",
              showLeftBtn: false,
              rightWidget: WidgetUtils.getHeaderIconData(0xe632),
              onRightPressed: () => _showDropDownMenu(),
              right2Widget: WidgetUtils.getHeaderIconData(0xe631),
              onRight2Pressed: () async {
                NavigatorUtils.changePage(context, BookSearchPage());
              }),
        ),
        backgroundColor: _isList ? store.state.theme.body.background : Colors.white,
        body: _renderDataList(),
      );
    });
  }

  Widget _renderDataList() {
    return AppRefreshList(
      key: _appRefreshListState,
      showNoDataInfo: true,
      noDataText: AppUtils.getLocale()?.bookshelfMsgNoData,
      noDataIcon: const Image(image: AssetImage('assets/images/book_shelf_empty.png'), fit: BoxFit.cover),
      onLoadData: (reload) async {
        if (AppParams.getInstance().getBookShelfIsList()) {
          //获取书源列表
          _allBookSourceList = await BookSourceSchema.getInstance.getToSearchDetailList();
          List<BookModel> dataList = await BookUtils.getAllBook();
          _appRefreshListState.currentState?.loadDataFinish(reload, dataList, isLoadAll: true);
          //启动更新数据
          if (needToGetData) {
            _bookShelfTask.updateBook(dataList);
            _bookDetailTaskIndex = 0;
            if(_bookDetailTaskIndex < (_appRefreshListState.currentState?.getDataList().length ?? 0)){
              _bookDetailTask.startSearch(dataList[_bookDetailTaskIndex], _allBookSourceList);
            }
          }
          needToGetData = true;
        } else {
          _appRefreshListState.currentState?.loadDataFinish(reload, await BookGroupSchema.getInstance.getAllGroups(), isLoadAll: true);
        }
        setState(() {});
      },
      isList: _isList,
      renderDataRow: (row, index) {
        if (row is BookModel) {
          if (AppParams.getInstance().getBookShelfShowType() == 1) {
            return BookListItem(row, callback: (String cmd, List<dynamic> list){
              if(cmd == "RefreshList"){
                needToGetData = false;
                _appRefreshListState.currentState?.beginToRefresh();
              }else if(cmd == "BookShelfDelete"){
                BookUtils.removeFromBookShelf(list[0]);
                _appRefreshListState.currentState?.removeObj(list[0]);
              }
            });
          }else{
            return BookGridItem(row);
          }
        }
        else{
          return BookGroupItem(row, callback: (String cmd, List<dynamic> list) {
            if (cmd == "RefreshList") {
              needToGetData = false;
              _appRefreshListState.currentState?.beginToRefresh();
            }
          });
        }
      },
    );
  }

  //显示下拉菜单
  void _showDropDownMenu() {
    List<PopupMenuEntry<String>> widgetList = [];
    //特殊节点
    widgetList.add(PopupMenuItem<String>(
        value: 'changeShowType',
        child: Row(children: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
              child: Icon(
                  IconData(AppParams.getInstance().getBookShelfIsList() ? 0xe678 : 0xe66d, fontFamily: 'iconfont'),
                  size: 22,
                  color: getStore().state.theme.dropDownMenu.icon)),
          Text(
              AppParams.getInstance().getBookShelfIsList()
                  ? (AppUtils.getLocale()?.appGroupModel ?? "")
                  : AppParams.getInstance().getBookShelfShowType() == 1 ? (AppUtils.getLocale()?.appListModel ?? "") : (AppUtils.getLocale()?.appGridModel ?? ""),
              style: TextStyle(fontSize: 16.0,
                  color: getStore().state.theme.dropDownMenu.icon))
        ])));
    if (AppParams.getInstance().getBookShelfIsList()) {
      dropMenuIdList = [
        "bookClearUp",
        "importBook",
        "downloadAll",
        "webService",
      ];
      dropMenuIconList = [0xe686, 0xe661, 0xe691, 0xe695];
      dropMenuNameList = [
        AppUtils.getLocale()?.bookshelfMenuClearUp ?? "",
        AppUtils.getLocale()?.bookshelfMenuImportLocal ?? "",
        AppUtils.getLocale()?.bookshelfMenuDownload ?? "",
        AppUtils.getLocale()?.bookshelfMenuWeb ?? "",
      ];
    } else {
      dropMenuIdList = [
        "newGroup",
        "downloadAll",
        "webService",
      ];
      dropMenuIconList = [0xe684, 0xe691, 0xe695];
      dropMenuNameList = [
        AppUtils.getLocale()?.bookshelfMenuNewGroup ?? "",
        AppUtils.getLocale()?.bookshelfMenuDownload ?? "",
        AppUtils.getLocale()?.bookshelfMenuWeb ?? "",
      ];
    }
    showDropMenu(widgetList, (value) => _menuOnPress(value));
  }

  //菜单点击事件
  void _menuOnPress(value) async{
    if (value == "changeShowType") {
      if (AppParams.getInstance().getBookShelfIsList()) {
        AppParams.getInstance().setBookShelfIsList(false);
      } else {
        AppParams.getInstance().setBookShelfIsList(true);
      }
      //重置
      _isList = true;
      if(AppParams.getInstance().getBookShelfIsList()){
        if(AppParams.getInstance().getBookShelfShowType() == 2) _isList = false;
      }
      //刷新界面
      needToGetData = false;
      _appRefreshListState.currentState?.beginToRefresh();
    } else if (value == "bookClearUp") {
      NavigatorUtils.changePage(context, BookShelfEditPage(null), animationType: 3);
    } else if (value == "importBook") {
      await BookUtils.importBook();
      ToolsPlugin.hideLoading();
      //刷新界面
      needToGetData = false;
      _appRefreshListState.currentState?.beginToRefresh();
    } else if (value == "newGroup") {
      showCupertinoModalBottomSheet(
        expand: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) =>
            MenuEditBox(titleName: AppUtils.getLocale()?.bookshelfGroupInputTitle ?? "", btnText: "创　　建", onPress: (value) async {
              if(value.length <= 20){
                BookGroupModel model = BookGroupModel();
                model.groupId = await BookGroupSchema.getInstance.getMaxGroupId();
                model.groupName = value;
                await BookGroupSchema.getInstance.save(model);
                needToGetData = false;
                _appRefreshListState.currentState?.beginToRefresh();
              } else{
                ToastUtils.showToast(AppUtils.getLocale()?.bookshelfGroupNameLen ?? "");
              }
            }),
      );
    } else if (value == "downloadAll") {
      BookUtils.downloadAllBook();
    } else if (value == "webService") {
      NavigatorUtils.changePage(context, WebServerPage());
    }
  }
}
