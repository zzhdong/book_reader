import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:book_reader/common/message_event.dart';

/// 错误拦截
class ErrorInterceptors extends InterceptorsWrapper {
  final Dio _dio;

  ErrorInterceptors(this._dio);

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    //没有网络
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      MessageEventBus.handleGlobalEvent(MessageCode.NETWORK_ERROR, "");
    }
    return options;
  }
}
