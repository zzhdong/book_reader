import 'package:book_reader/widget/app_floating_action_button_location.dart';
import 'package:shared_preferences/shared_preferences.dart';

///常量
class AppConfig {

  // 应用名称
  static const APP_NAME = "BookReader";
  // 是否调试模式
  static const APP_DEBUG = false;
  static const APP_DEBUG_DATABASE = false;
  static const APP_DEBUG_NETWORK = true;
  static const APP_DEBUG_NETWORK_CONTENT = false;
  static const APP_DEBUG_PLUGIN = true;
  static const double APP_DEBUG_PLUGIN_TIME = 100;
  // 去广告奖励时长
  static const int VIDEO_REMOVE_AD_TIME = 6;
  // 本地常量存储
  static const LOCAL_STORE_SEARCH = "LOCAL_STORE_SEARCH";
  // 本地常量存储
  static const LOCAL_STORE_CONTENT_SEARCH = "LOCAL_STORE_CONTENT_SEARCH";
  // 请求API的token
  static const LOCAL_STORE_TOKEN = "token";
  static const LOCAL_STORE_BASIC_CODE = "APP_API_BASIC_CODE";
  // 默认字体
  static const DEF_FONT_FAMILY = "PingFangMedium";
  // 列表分页大小
  static const APP_LIST_PAGE_SIZE = 20;
  // 默认请求头
  static const APP_HTTP_HEADER = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36";

  static const BOOK_TYPE_AUDIO = "AUDIO";

  static const BOOK_LOCAL_TAG = "BOOK_LOCAL_TAG";

  static const BOOKSOURCE_SEARCH_FOR_DETAIL = "BOOKSOURCE_SEARCH_FOR_DETAIL";

  //全局正则表达式
  static final RegExp gblJsPattern = RegExp("(<js>[\\w\\W]*?</js>|@js:[\\w\\W]*\$)", caseSensitive: false);
  static final RegExp gblExpPattern = RegExp("\\{\\{([\\w\\W]*?)\\}\\}");
  static final RegExp gblAuthorPattern = RegExp("作\\s*者\\s*[：:]");

  //本地数据快速存储
  static late SharedPreferences prefs;
  //悬浮按钮位置
  static const AppFloatingActionButtonLocation APP_FLOATING_BUTTON_LOCATION = AppFloatingActionButtonLocation();
}
