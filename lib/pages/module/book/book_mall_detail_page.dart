import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/find_kind_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/module/book/task/book_find_task.dart';
import 'package:book_reader/pages/module/book/book_detail_page.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/pages/widget/book_cover.dart';

//书城-发现列表-书籍列表
class BookMallDetailPage extends StatefulWidget {

  final FindKindModel findKindModel;

  BookMallDetailPage(this.findKindModel, {super.key});

  @override
  _BookMallDetailPageState createState() => _BookMallDetailPageState();
}

class _BookMallDetailPageState extends AppState<BookMallDetailPage> {

  //事件订阅
  late StreamSubscription _streamSubscription;
  //搜索任务
  final BookFindTask _bookFindTask = BookFindTask();
  //搜索结果
  final List<SearchBookModel> _searchBookResult = [];
  //结果项高度
  final double _itemResultExtent = 98;

  @override
  void initState() {
    super.initState();
    _streamSubscription = MessageEventBus.bookSearchEventBus.on<BookSearchEvent>().listen((event) {
      _onHandleBookSearchEvent(event.code, searchBookModelList: event.searchBookModelList, isAll: event.isAll, errorMsg: event.errorMsg);
    });
    //显示正在加载
    setState(() {
      isLoading = true;
    });
    _bookFindTask.searchBook(widget.findKindModel);
  }

  @override
  void dispose() {
    _bookFindTask.stopSearch();
    _streamSubscription.cancel();
    super.dispose();
  }

  //处理消息事件
  _onHandleBookSearchEvent(code, {List<SearchBookModel>? searchBookModelList, bool isAll = false, String errorMsg = ""}) {
    switch (code) {
      case MessageCode.SEARCH_LOAD_MORE_OBJECT:
        if (searchBookModelList != null && searchBookModelList.isNotEmpty) {
          _searchBookResult.addAll(searchBookModelList);
        }
        break;
      case MessageCode.SEARCH_REFRESH_FINISH:
        isLoading = false;
        break;
      default:
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar:
        WidgetUtils.getDefaultTitleBar(AppTitleBar(widget.findKindModel.getKindName())),
        backgroundColor: store.state.theme.body.background,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            renderLoadingBar(),
            (_searchBookResult.isNotEmpty) ? Expanded(child: _renderDataList()) : _renderError(),
          ],
        ),
      );
    });
  }

  Widget _renderDataList() {
    return CupertinoScrollbar(
      child: ListView.builder(
        itemCount: _searchBookResult.length,
        itemExtent: _itemResultExtent,
        itemBuilder: (context, index) {
          SearchBookModel model = _searchBookResult[index];
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
                          "${AppUtils.getLocale()?.bookDetailMsgBookSource}：${StringUtils.isEmpty(model.originName) ? AppUtils.getLocale()?.bookDetailMsgUnknown : model.originName} ",
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
              _bookFindTask.stopSearch();
              NavigatorUtils.changePage(context, BookDetailPage(2, searchBookModel: model));
            },
          );
        },
      ),
    );
  }

  Widget _renderError(){
    if(isLoading) {
      return Container();
    } else{
      return Container(
        padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Column(
          children: <Widget>[
            Container(
              height: 220,
              width: 220,
              alignment: Alignment.bottomCenter,
              child: const Image(image: AssetImage('assets/images/book_error.png'), fit: BoxFit.cover),
            ),
            Container(height: 20),
            Text(
              AppUtils.getLocale()?.bookChooseEmpty ?? "",
              style: TextStyle(fontSize: 18, color: getStore().state.theme.bookList.noDataText),
            )
          ],
        ),
      );
    }
  }
}
