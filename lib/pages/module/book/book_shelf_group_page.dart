import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_group_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/schema/book_schema.dart';
import 'package:book_reader/module/book/task/book_shelf_task.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/pages/module/book/book_search_page.dart';
import 'package:book_reader/pages/module/book/book_shelf_edit_page.dart';
import 'package:book_reader/pages/module/book/web_server_page.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_refresh_list.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:book_reader/pages/widget/book_grid_item.dart';
import 'package:book_reader/pages/widget/book_list_item.dart';

class BookShelfGroupPage extends StatefulWidget {

  final BookGroupModel bookGroupModel;

  const BookShelfGroupPage(this.bookGroupModel, {super.key});

  @override
  _BookShelfGroupPageState createState() => _BookShelfGroupPageState();
}

class _BookShelfGroupPageState extends AppState<BookShelfGroupPage> {
  //全局通知事件
  late StreamSubscription _streamSubscription;
  //数据列表控件
  final GlobalKey<AppRefreshListState> _appRefreshListState = GlobalKey<AppRefreshListState>();
  //侧滑删除控件控制器
  final SlidableController slideController = SlidableController();
  //是否更新数据
  bool needToGetData = false;
  //书架搜索任务
  late StreamSubscription _bookShelfSubscription;
  final BookShelfTask _bookShelfTask = BookShelfTask();

  @override
  void initState() {
    super.initState();
    //监听全局消息
    _streamSubscription = MessageEventBus.globalEventBus.on<MessageEvent>().listen((event) {
      _onHandleGlobalEvent(event.code, event.message);
    });
    _bookShelfSubscription = MessageEventBus.bookShelfEventBus.on<BookShelfEvent>().listen((event) {
      _onHandleBookShelfEvent(event.code, dataList: event.dataList, errorMsg: event.errorMsg);
    });
    AppUtils.initDelayed(() {
      //判断启动后是否自动刷新书架
      needToGetData = AppParams.getInstance().getStartUpToRefresh();
      _appRefreshListState.currentState?.beginToRefresh();
    }, duration: 10);
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _bookShelfTask.stopSearch();
    _bookShelfSubscription.cancel();
    super.dispose();
  }

  _onHandleGlobalEvent(int code, message) {
    switch (code) {
      case MessageCode.NOTICE_REFRESH_BOOKSHELF:
        needToGetData = false;
        _appRefreshListState.currentState?.beginToRefresh();
        break;
    }
  }

  _onHandleBookShelfEvent(int code, {List<BookModel>? dataList, String errorMsg = ""}) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(widget.bookGroupModel.groupName,
            rightWidget: WidgetUtils.getHeaderIconData(0xe632),
            onRightPressed: () => _showDropDownMenu(),
            right2Widget: WidgetUtils.getHeaderIconData(0xe631),
            onRight2Pressed: () async {
              NavigatorUtils.changePage(context, BookSearchPage());
            }),
        ),
        backgroundColor: (AppParams.getInstance().getBookShelfShowType() == 1) ? store.state.theme.body.background : Colors.white,
        body: _renderDataList(),
      );
    });
  }


  Widget _renderDataList() {
    return AppRefreshList(
      key: _appRefreshListState,
      noDataText: AppUtils.getLocale()?.bookshelfMsgNoData,
      onLoadData: (reload) async {
        List<BookModel> dataList = await BookSchema.getInstance.getBooksByGroup(widget.bookGroupModel.groupId);
        _appRefreshListState.currentState?.loadDataFinish(reload, dataList, isLoadAll: true);
        //启动更新数据
        if (needToGetData) {
          _bookShelfTask.updateBook(dataList);
        }
        needToGetData = true;
      },
      isList: (AppParams.getInstance().getBookShelfShowType() == 1),
      renderDataRow: (row, index) {
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
      },
    );
  }
  
  //显示下拉菜单
  void _showDropDownMenu() {
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
    showDropMenu(null, (value) => _menuOnPress(value));
  }

  //菜单点击事件
  void _menuOnPress(value) {
    if (value == "bookClearUp") {
      NavigatorUtils.changePage(context, BookShelfEditPage(widget.bookGroupModel), animationType: 3);
    } else if (value == "importBook") {
      BookUtils.importBook();
    } else if (value == "downloadAll") {
      BookUtils.downloadAllBook();
    } else if (value == "webService") {NavigatorUtils.changePage(context, WebServerPage());
    }
  }
}
