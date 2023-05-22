import 'dart:convert';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:dio/dio.dart';
import 'package:book_reader/common/message_event.dart';

///日志拦截器
class LogsInterceptors extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (AppConfig.APP_DEBUG_NETWORK) {
      try{
        print("[${DateTime.now()}]请求URL：${options.path}");
        print("[${DateTime.now()}]请求类型：${options.method}");
        print('[${DateTime.now()}]请求头: ${options.headers.toString()}');
        if (options.data != null) {
          if(options.data is FormData){
            print('[${DateTime.now()}]请求参数POST: ${options.data.fields.toString()}');
          } else if(options.data is Stream){
            print('[${DateTime.now()}]请求参数POST: ${options.data.toString()}');
          } else{
            print('[${DateTime.now()}]请求参数POST: ${options.data.toString()}');
          }
        }
        if (options.queryParameters.isNotEmpty && options.queryParameters.isNotEmpty) {
          print('[${DateTime.now()}]请求参数GET: ${options.queryParameters.toString()}');
        }
      }catch(e){}
    }
    return options;
  }

  @override
  Future onResponse(Response? response, ResponseInterceptorHandler handler) async {
    if (AppConfig.APP_DEBUG_NETWORK) {
      if (response != null) {
        try{
          String location = response.headers.value("location") ?? "";
          print('[${DateTime.now()}]返回状态: ${((response.statusCode == null) ? "" :response.statusCode.toString())}');
          print('[${DateTime.now()}]返回头:\r\n ${response.headers.toString()}');
          if(location != "") print('重定向地址: $location');
          if(AppConfig.APP_DEBUG_NETWORK_CONTENT) {
            if(response.data is List<int>){
              print('[${DateTime.now()}]返回Byte内容: \r\n${gbk.decode(response.data)}');
            }else if(response.data is Map){
              print('[${DateTime.now()}]返回Json: \r\n${jsonEncode(response.data)}');
            }else if(response.data is ResponseBody){
              print('[${DateTime.now()}]返回Stream: \r\n${response.data}');
            }else{
              print('[${DateTime.now()}]返回默认内容: \r\n${response.data}');
            }
          }
        }catch(e){}
      }
    }
    return response; // continue
  }

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    print('请求异常: ${err.toString()}');
    if(err.response != null){
      try{
        if(err.response?.data is List<int>){
          err.response?.data = gbk.decode(err.response?.data);
        }else if(err.response?.data is Map){
          err.response?.data = jsonEncode(err.response?.data);
        }
        print('请求异常信息: ${err.response?.data}');
        if(err.response?.statusCode == 401){
          MessageEventBus.handleGlobalEvent(MessageCode.NETWORK_ERROR_401, "");
        }else if(err.response?.statusCode == 403){
          MessageEventBus.handleGlobalEvent(MessageCode.NETWORK_ERROR_403, "");
        }else if(err.response?.statusCode == 404){
          MessageEventBus.handleGlobalEvent(MessageCode.NETWORK_ERROR_404, "");
        }
      }catch(e){}
    }
    if(err.type == DioErrorType.connectionTimeout || err.type == DioErrorType.receiveTimeout || err.type == DioErrorType.sendTimeout){
      MessageEventBus.handleGlobalEvent(MessageCode.NETWORK_TIMEOUT, "");
    }
    return err;
  }

}
