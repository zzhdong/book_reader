import 'dart:convert';
import 'dart:io';
import 'package:book_reader/module/web/book_controller.dart';
import 'package:book_reader/module/web/return_data.dart';
import 'package:book_reader/module/web/source_controller.dart';

class AppHttpServer{

  AppHttpServer(HttpServer httpServer){
    print("Http Server Start at ${httpServer.address.address}:${httpServer.port}");
    _start(httpServer);
  }

  void _start(HttpServer httpServer) async{
    await for (HttpRequest request in httpServer) {
      print("Http Request Method[${request.method}], URL[${request.requestedUri}], Path[${request.requestedUri.path}]");
      ReturnData? returnData;
      try{
        switch(request.method){
          case "OPTIONS":
            request.response
              ..headers.add("Access-Control-Allow-Methods", "POST, OPTIONS")
              ..headers.add("Access-Control-Allow-Headers", 'Origin, X-Requested-With, Content-Type, Accept')
              ..headers.add("Access-Control-Allow-Origin", request.headers["origin"] ?? "")
              ..write("")
              ..close();
            return;
          case "POST":
            String postData = await utf8.decoder.bind(request).join();
            switch (request.requestedUri.path) {
              case "/uploadFiles":
                returnData = await BookController().uploadFiles(postData);
                break;
              case "/deleteFile":
                returnData = await BookController().deleteFile(postData);
                break;
              case "/downloadFile":
                returnData = await BookController().downloadFile(postData);
                break;
              case "/saveSource":
                returnData = await SourceController().saveSource(postData);
                break;
              case "/saveSources":
                returnData = await SourceController().saveSources(postData);
                break;
              case "/saveBook":
                returnData = await BookController().saveBook(postData);
                break;
              case "/deleteSources":
                returnData = await SourceController().deleteSources(postData);
                break;
            }
            break;
          case "GET":
            Map<String, List<String>> parameters = request.requestedUri.queryParametersAll;
            switch (request.requestedUri.path) {
              case "/getLocalBookList":
                returnData = await BookController().getLocalBookList();
                break;
              case "/getSource":
                returnData = await SourceController().getSource(parameters);
                break;
              case "/getSources":
                returnData = await SourceController().getSources();
                break;
              case "/getBookshelf":
                returnData = await BookController().getBookshelf();
                break;
              case "/getChapterList":
                returnData = await BookController().getChapterList(parameters);
                break;
              case "/getBookContent":
                returnData = await BookController().getBookContent(parameters);
                break;
            }
            break;
        }
        if (returnData == null) {
          returnData = ReturnData();
          if(request.requestedUri.path == "/") {
            await returnData.initFromPath("/index.html");
          } else {
            await returnData.initFromPath(request.requestedUri.path);
          }
          if(returnData.isDataArray){
            request.response.headers.set('Content-Type', returnData.dataArrayType);
            request.response.headers.set('Content-Length', returnData.dataArrayLength);
            request.response.add(returnData.getData() as List<int>);
            request.response.close();
          }else{
            request.response
              ..headers.contentType = returnData.getContentType()
              ..write(returnData.getData())
              ..close();
          }
        }else{
          if(returnData.dataArrayType == ""){
            request.response
              ..headers.contentType = ContentType.html
              ..headers.add("Access-Control-Allow-Methods", "GET, POST")
              ..headers.add("Access-Control-Allow-Origin", request.headers["origin"] ?? "")
              ..write(json.encode(returnData.toMap()))
              ..close();
          }else{
            request.response.headers.set('Content-Type', returnData.dataArrayType ?? "");
            request.response.headers.set('Content-Length', returnData.dataArrayLength ?? "");
            request.response.add(returnData.getData() as List<int>);
            request.response.close();
          }
        }
      }catch(e){
        returnData = ReturnData();
        returnData.setErrorMsg(e.toString());
        request.response
          ..headers.contentType = ContentType.html
          ..headers.add("Access-Control-Allow-Methods", "GET, POST")
          ..headers.add("Access-Control-Allow-Origin", request.headers["origin"] ?? "")
          ..write(json.encode(returnData.toMap()))
          ..close();
      }
    }
    print("Http Server Stop");
  }
}