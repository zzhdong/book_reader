import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class ReturnData {

  final String _assetsWebPath = "assets/web";
  late String _path;
  late Object _data;
  late ContentType _contentType;
  late int _errorCode;
  late String _errorMsg;
  late bool isSuccess;
  late bool isDataArray;
  late int dataArrayLength;
  late String dataArrayType;

  ReturnData() {
    isSuccess = false;
    isDataArray = false;
    dataArrayLength = 0;
    dataArrayType = "";
    _errorMsg = "未知错误,请联系开发者!";
  }
  
  Future initFromPath(String path) async{
    path = "$_assetsWebPath$path";
    isSuccess = true;
    _errorMsg = "";
    _path = path;
    //分析类型
    try{
      String suffix = path.substring(path.lastIndexOf("."));
      if (suffix == "") {
        _contentType = ContentType.html;
        _data = await rootBundle.loadString("$_assetsWebPath/404.html");
      } else if (suffix == ".html" || suffix == ".htm") {
        _contentType = ContentType.html;
        _data = await rootBundle.loadString(path);
      } else if (suffix == ".txt") {
        _contentType = ContentType.text;
        _data = await rootBundle.loadString(path);
      } else if (suffix == ".json") {
        _contentType = ContentType.json;
        _data = await rootBundle.loadString(path);
      } else if (suffix == ".js") {
        _contentType = ContentType("text", "javascript", charset: "utf-8");
        _data = await rootBundle.loadString(path);
      } else if (suffix == ".css") {
        _contentType = ContentType("text", "css", charset: "utf-8");
        _data = await rootBundle.loadString(path);
      } else if (suffix == ".ico" || suffix == ".png" || suffix == ".jpg" || suffix == ".jpeg" || suffix == ".gif" || suffix == ".svg") {
        ByteData byteData = await rootBundle.load(path);
        isDataArray = true;
        dataArrayType = "image/${suffix.substring(1)}";
        dataArrayLength = byteData.buffer.lengthInBytes;
        _data = byteData.buffer.asUint8List();
      } else if (suffix == ".ttf" || suffix == ".woff" || suffix == ".woff2" || suffix == ".eot") {
        ByteData byteData = await rootBundle.load(path);
        isDataArray = true;
        dataArrayType = "font/${suffix.substring(1)}";
        dataArrayLength = byteData.buffer.lengthInBytes;
        _data = byteData.buffer.asUint8List();
      } else{
        _contentType = ContentType.html;
        _data = await rootBundle.load(path);
      }
    }catch(e){
      print(e);
      _contentType = ContentType.html;
      _data = await rootBundle.loadString("$_assetsWebPath/404.html");
    }
  }
  
  String getPath() => _path;
  void setPath(String path) => _path = path;

  Object getData() => _data;
  ReturnData setData(Object data) {
    isSuccess = true;
    _errorMsg = "";
    _data = data;
    return this;
  }

  ContentType getContentType() => _contentType;
  void setContentType(ContentType contentType) => _contentType = contentType;

  int getErrorCode() => _errorCode;
  void setErrorCode(int errorCode) => _errorCode = errorCode;

  String getErrorMsg() => _errorMsg;
  ReturnData setErrorMsg(String errorMsg) {
    isSuccess = false;
    _errorMsg = errorMsg;
    return this;
  }

  Map<String, dynamic> toMap() =>
      <String, dynamic>{
        'isSuccess': isSuccess,
        'data': _data,
        'errorCode': _errorCode,
        'errorMsg': _errorMsg,
      };
}