
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sprintf/sprintf.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/utils/book_analyze_utils.dart';
import 'package:book_reader/utils/string_utils.dart';

class AppWebSocketServer{

  WebSocket? _webSocket;
  StreamSubscription? _streamSubscription;
  BookAnalyzeUtils? _bookAnalyzeUtils;
  DateTime? _outputTime;

  AppWebSocketServer(HttpServer httpServer, int timeout){
    print("Web Socket Server Start at ${httpServer.address.address}:${httpServer.port}");
    _start(httpServer, timeout);
  }

  void _start(HttpServer httpServer, int timeout) async{
    //启动监听，接收消息流
    _streamSubscription = MessageEventBus.bookSourceDebugEventBus.on<MessageEvent>().listen((event) {
      _onHandleBookSourceAnalyzeEvent(event.code, event.message, event.printLog);
    });
    await for (HttpRequest request in httpServer) {
      print("Web Socket Request Method[${request.method}], URL[${request.requestedUri}], Path[${request.requestedUri.path}]");
      if (request.uri.path == '/sourceDebug') {
        // 将一个HttpRequest提升为WebSocket连接
        await _webSocket?.close();
        _webSocket = await WebSocketTransformer.upgrade(request);
        //监听客户端发送过来的数据
        _webSocket?.listen((event) {
          dynamic message = json.decode(event);
//          print(message);
          //connect和speak数据都使用了Map
          if(message is! Map) {
            _webSocket?.add("接收参数错误！");
            return;
          }
          String tag = message['tag'];
          String key = message['key'];
          _startDebug(tag, key);
        });
        //客户端关闭的时候，删除存储信息，更新在线列表
        _webSocket?.done.whenComplete(() {
          print("客户端连接断开连接, IP：${request.connectionInfo?.remoteAddress.address} 端口：${request.connectionInfo?.remotePort}");
          _webSocket?.close();
        });
        //超时关闭客户端
        Future.delayed(Duration(milliseconds: timeout), ()=> _webSocket?.close());
      }else{
        request.response
          ..headers.contentType = ContentType.html
          ..headers.add("Access-Control-Allow-Methods", "GET, POST")
          ..headers.add("Access-Control-Allow-Origin", request.headers["origin"] ?? "")
          ..write(await rootBundle.loadString("404.html"))
          ..close();
      }
    }
    print("Web Socket Server Stop");
  }

  Future stop(HttpServer httpServer) async{
    await httpServer.close(force: true);
    await _webSocket?.close();
    _bookAnalyzeUtils?.stop();
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  void _startDebug(String tag, String key) async{
    BookSourceModel? bookSource = await BookSourceSchema.getInstance.getByBookSourceUrl(tag);
    _bookAnalyzeUtils = BookAnalyzeUtils(bookSource);
    //输出日志内容
    _outputTime = DateTime.now();
    _outputInfo("⇣开始搜索指定关键字【$key】", isClean: true);
    //书籍搜索
    try {
      List<SearchBookModel> bookList = await _bookAnalyzeUtils?.searchBookAction(key, 1) ?? [];
      //处理书籍详情
      if (bookList.isNotEmpty) {
        BookModel bookModel = bookList[0].toBook();
        await _bookAnalyzeUtils?.getBookInfoAction(bookModel);
        List<BookChapterModel> bookChapterList = await _bookAnalyzeUtils?.getChapterListAction(bookModel) ?? [];
        if (bookChapterList.isNotEmpty) {
          BookChapterModel? nextChapter = bookChapterList.length > 2 ? bookChapterList[1] : null;
          await _bookAnalyzeUtils?.getBookContent(bookChapterList[0], nextChapter, bookModel);
        }
      }
    } catch (e) {
      _outputInfo("⊗出错：${e.toString()}");
    }
    //一秒钟后关闭socket
    Future.delayed(const Duration(milliseconds: 1000), ()=> _webSocket?.close());
  }

  //输出显示信息
  void _outputInfo(String value, {isClean = false, printLog = true}) {
    //是否显示日志
    if (!printLog) return;
    DateTime now = DateTime.now();
    Duration dif = now.difference(_outputTime!);
    String time = sprintf("%02d:%02d.%03d", [
      dif.inMinutes - dif.inHours * 60,
      dif.inSeconds - dif.inMinutes * 60,
      dif.inMilliseconds - dif.inSeconds * 1000
    ]);
    _webSocket?.add("[$time] $value");
  }

  //处理消息事件
  _onHandleBookSourceAnalyzeEvent(int code, String message, bool printLog) {
    if (StringUtils.isEmpty(message)) return;
    if (code == 111) message = message.replaceAll("\n", ",");
    if (code == 112) message = message.replaceAll("\n", "<br/><a></a>");
    _outputInfo(message, printLog: printLog);
  }
}