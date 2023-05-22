import 'dart:async';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/download_book_model.dart';
import 'package:book_reader/database/model/download_chapter_model.dart';
import 'package:book_reader/database/schema/download_book_schema.dart';
import 'package:book_reader/module/book/download/download_service.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/pages/widget/book_cover.dart';

class BookDownloadPage extends StatefulWidget {
  const BookDownloadPage({super.key});

  @override
  _BookDownloadPageState createState() => _BookDownloadPageState();
}

class _BookDownloadPageState extends AppState<BookDownloadPage> {
  StreamSubscription? _downloadSubscription;
  List<DownloadBookModel> _downloadBookList = [];
  List<DownloadChapterModel> _downloadChapterList = [];
  final double _itemExtent = 85;

  @override
  void initState() {
    super.initState();
    //监听全局消息
    _downloadSubscription = MessageEventBus.bookDownloadEventBus.on<BookDownloadEvent>().listen((event) {
      _onHandleBookDownloadEvent(event.code, data: event.downloadChapterModel, errorMsg: event.errorMsg);
    });
    _refreshDataList(true, null);
  }

  @override
  void dispose() {
    _downloadSubscription?.cancel();
    _downloadSubscription = null;
    super.dispose();
  }

  _onHandleBookDownloadEvent(int code, {DownloadChapterModel? data, String errorMsg = ""}) {
    _refreshDataList(false, data);
  }

  //刷新数据
  void _refreshDataList(bool init, DownloadChapterModel? data) async {
    List<DownloadBookModel> tmpList = await DownloadBookSchema.getInstance.getAll();
    bool isGetNew = false;
    if(_downloadBookList.length != tmpList.length){
      isGetNew = true;
    }
    _downloadBookList =  tmpList;
    if (init) {
      for (DownloadBookModel obj in _downloadBookList) {
        _downloadChapterList.add(DownloadChapterModel()..bookUrl = obj.bookUrl);
      }
    }else{
      if(isGetNew){
        //更新当前下载章节
        List<DownloadChapterModel> tmpList = [];
        for (DownloadBookModel obj in _downloadBookList) {
          for (DownloadChapterModel model in _downloadChapterList) {
            if(model.bookUrl == obj.bookUrl) {
              tmpList.add(model.clone());
              break;
            }
          }
        }
        _downloadChapterList = tmpList;
      }
    }
    //更新数据
    if(data != null){
      for (int i = 0; i < _downloadChapterList.length; i++) {
        if (_downloadChapterList[i].bookUrl == data.bookUrl) {
          _downloadChapterList[i] = data;
          break;
        }
      }
    }
    setState(() {});
  }

  void _toggleDownload() async {
    if(_downloadBookList.isEmpty) return;
    if (DownloadService.isRunning) {
      DownloadService.cancelDownload();
    } else {
      DownloadService.startHistory(await DownloadBookSchema.getInstance.getAll());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(AppUtils.getLocale()?.settingMenuBookDownload ?? "",
            rightWidget: WidgetUtils.getHeaderIconData(DownloadService.isRunning ? 0xe68c : 0xe699),
            onRightPressed: () => _toggleDownload())),
        backgroundColor: store.state.theme.body.background,
        body: (_downloadBookList.isEmpty) ? _renderEmpty() : _renderDataList(),
      );
    });
  }

  Widget _renderEmpty(){
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: Column(
        children: <Widget>[
          Container(
            height: 220,
            width: 220,
            alignment: Alignment.bottomCenter,
            child: const Image(image: AssetImage('assets/images/book_download_empty.png'), fit: BoxFit.cover),
          ),
          Container(height: 20),
          Text(
            AppUtils.getLocale()?.msgBookDownloadEmpty ?? "",
            style: TextStyle(fontSize: 18, color: getStore().state.theme.bookList.noDataText),
          )
        ],
      ),
    );
  }

  Widget _renderDataList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _downloadBookList.length,
      itemExtent: _itemExtent,
      itemBuilder: (context, index) {
        return _renderDataRow(_downloadBookList[index],
            _downloadChapterList.length > index ? _downloadChapterList[index] : DownloadChapterModel());
      },
    );
  }

  Widget _renderDataRow(DownloadBookModel model, DownloadChapterModel data) {
    return Container(
      height: _itemExtent,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      color: getStore().state.theme.body.background,
      child: Row(children: <Widget>[
        BookCover(BookModel()..coverUrl = model.coverUrl, width: 50, height: 70),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(model.bookName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: getStore().state.theme.bookList.title)),
            Container(height: 3),
            DownloadService.isRunning
                ? Text("${AppUtils.getLocale()?.bookDownload1}：${data.chapterTitle}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 12, color: Colors.green))
                : Text("${AppUtils.getLocale()?.bookDownload2}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 12, color: Colors.red)),
            Container(height: 3),
            Text("${AppUtils.getLocale()?.bookDownload3}${model.getWaitingCount()}${AppUtils.getLocale()?.bookDownload4}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.desc)),
          ],
        )),
        AppTouchEvent(
          isTransparent: true,
          child: Icon(const IconData(0xe63a, fontFamily: 'iconfont'),
              color: getStore().state.theme.listMenu.arrow, size: 24),
          onTap: () {
            DownloadService.removeDownload(model.bookUrl);
            DownloadBookSchema.getInstance.delete(model);
            _refreshDataList(false, null);
          },
        ),
      ]),
    );
  }
}
