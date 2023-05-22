import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/network/interceptors/error_interceptor.dart';
import 'package:book_reader/network/interceptors/header_interceptor.dart';
import 'package:book_reader/network/interceptors/log_interceptor.dart';
import 'package:book_reader/network/interceptors/response_interceptor.dart';
import 'package:book_reader/network/interceptors/token_interceptor.dart';
import 'package:book_reader/plugin/http_plugin.dart';
import 'package:book_reader/plugin/tools_plugin.dart';

///http请求
class HttpManager {
  static const CONTENT_TYPE_JSON = "application/json";
  static const CONTENT_TYPE_FORM = "application/x-www-form-urlencoded";

  static HttpManager? _singleton;

  factory HttpManager() {
    _singleton ??= HttpManager._();
    return _singleton!;
  }

  //构造函数，创建拦截器
  HttpManager._(){
    _dio.interceptors.add(LogsInterceptors());
    _dio.interceptors.add(HeaderInterceptors());
    _dio.interceptors.add(ResponseInterceptors());
    _dio.interceptors.add(ErrorInterceptors(_dio));
//    _dio.interceptors.add(_tokenInterceptors);

    //配置抓包代理
//    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
//      client.findProxy = (uri) {
//        //代理PC的IP端口
//        return "PROXY 192.168.70.169:8888";
//      };
//      // you can also create a HttpClient to dio
//      // return HttpClient();
//    };
  }

  // 使用默认配置
  final Dio _dio = Dio();
  // 请求取消
  CancelToken _cancelToken = CancelToken();

  final TokenInterceptors _tokenInterceptors = TokenInterceptors();

  /// get请求
  Future<String> fetchGetString(url, {Map<String, dynamic>? params, Options? option}) async {
    Response response;
    try {
      response = await _dio.get(url, queryParameters: params, options: option, cancelToken: _cancelToken);
    } on DioError catch (e) {
      return "";
    }
    return response.data;
  }

  /// get请求
  fetchGet(url, {Map<String, dynamic>? params, Options? option}) async {
    Response response;
    try {
      response = await _dio.get(url, queryParameters: params, options: option, cancelToken: _cancelToken);
    } on DioError catch (e) {
      return e.response;
    }
    return response;
  }

  /// post请求
  fetchPost(url, {Map<String, dynamic>? params, Options? option}) async {
    Response response;
    try {
      response = await _dio.post(url, data: params, options: option, cancelToken: _cancelToken);
    } on DioError catch (e) {
      if(e.response?.statusCode == 302 || e.response?.statusCode == 301){
        String location = e.response?.headers.value("location") ?? "";
        if (AppConfig.APP_DEBUG_NETWORK) {
          print('返回状态: ${e.response?.statusCode.toString()}');
          print('返回头: ${e.response?.headers.toString()}');
          print('重定向地址: $location');
        }
        return await fetchPost(await ToolsPlugin.getAbsoluteURL(url, location), params: params, option: option);
      }
      return e.response;
    }
    return response;
  }

  /// post请求 请求数据为表单
  fetchPostFormData(url, {Map<String, dynamic>? params, Options? option}) async {
    Response response;
    try {
      response = await _dio.post(url, data: FormData.fromMap(params ?? Map()), options: option, cancelToken: _cancelToken);
    } on DioError catch (e) {
      if(e.response?.statusCode == 302 || e.response?.statusCode == 301){
        String location = e.response?.headers.value("location") ?? "";
        if (AppConfig.APP_DEBUG_NETWORK) {
          print('返回状态: ${e.response?.statusCode.toString()}');
          print('返回头: ${e.response?.headers.toString()}');
          print('重定向地址: $location');
        }
        return await fetchPostFormData(await ToolsPlugin.getAbsoluteURL(url, location), params: params, option: option);
      }
      return e.response;
    }
    return response;
  }

  /// post请求 请求数据为流
  fetchPostStream(url, {Map<String, dynamic>? params, Options? option}) async {
    Response response;
    try {
      List<int> postData = gbk.encode(jsonEncode(params));
      option ??= Options();
      option.headers?[HttpHeaders.contentLengthHeader] = postData.length;
      response = await _dio.post(url, data: Stream.fromIterable(postData.map((e) => [e])), options: option, cancelToken: _cancelToken);
    } on DioError catch (e) {
      if(e.response?.statusCode == 302 || e.response?.statusCode == 301){
        String location = e.response?.headers.value("location") ?? "";
        if (AppConfig.APP_DEBUG_NETWORK) {
          print('返回状态: ${e.response?.statusCode.toString()}');
          print('返回头: ${e.response?.headers.toString()}');
          print('重定向地址: $location');
        }
        return await fetchPostStream(await ToolsPlugin.getAbsoluteURL(url, location), params: params, option: option);
      }
      return e.response;
    }
    return response;
  }

  fetchCancel() {
    if(!_cancelToken.isCancelled){
      _cancelToken.cancel("cancelled");
      _cancelToken = CancelToken();
    }
    HttpPlugin.cancelAll();
  }

  bool getIsCancel() => _cancelToken.isCancelled;

  ///清除授权
  clearAuthorization() {
    _tokenInterceptors.clearAuthorization();
  }

  ///获取授权token
  getAuthorization() async {
    return _tokenInterceptors.getAuthorization();
  }

  // 自定义发送编码，用法：option.requestEncoder = gbkEncoder;(发现不生效)
  List<int> gbkEncoder(String request, RequestOptions options) {
    return gbk.encode(request);
  }

  //自定义接收消息解码，用法：option.responseDecoder = gbkDecoder;
  String gbkDecoder(List<int> responseBytes, RequestOptions options, ResponseBody responseBody) {
    return gbk.decode(responseBytes);
  }
}
