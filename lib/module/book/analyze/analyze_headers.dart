import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:uuid/uuid.dart';

//解析Headers
class AnalyzeHeaders {

  static final RegExp headerPattern = RegExp("@Header:\\{.+?\\}", caseSensitive: false);

  static int i = 0;

  // 获取Http请求头
  static Map<String, dynamic> getRequestHeader(BookSourceModel? bookSourceModel) {
    Map<String, dynamic> headerMap = <String, dynamic>{};
    if (bookSourceModel != null && bookSourceModel.httpUserAgent != "") {
      headerMap["User-Agent"] = bookSourceModel.httpUserAgent;
    } else {
      headerMap["User-Agent"] = AppConfig.APP_HTTP_HEADER;
    }
    //动态修改cookie，可绕过30秒允许搜索次数
    headerMap["Cookie"] = const Uuid().v1();
    return headerMap;
  }
}
