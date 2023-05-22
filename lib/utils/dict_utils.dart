import 'package:book_reader/utils/app_utils.dart';

//字典工具类
class DictUtils{

  /// 获取字典值
  static String getDictValue(List<Map<String, String>> dict, String id){
    String defaultVal = dict[0]["NAME"] ?? "";
    for (Map<String, String> obj in dict) {
      if(obj["ID"] == id){
        defaultVal = obj["NAME"] ?? "";
        break;
      }
    }
    return defaultVal;
  }

  /// 获取主题列表Dict
  static List<Map<String, String>> getThemeDictList() {
    return [
      {"ID": '1', "NAME": AppUtils.getLocale()?.dictTheme_1 ?? ""},
      {"ID": '2', "NAME": AppUtils.getLocale()?.dictTheme_2 ?? ""},
    ];
  }

  /// 获取语言列表Dict
  static List<Map<String, String>> getLocaleDictList() {
    return [
      {"ID": '1', "NAME": AppUtils.getLocale()?.dictLocale_1 ?? ""},
      {"ID": '2', "NAME": AppUtils.getLocale()?.dictLocale_2 ?? ""},
//      {"ID": '3', "NAME": AppUtils.getLocale()?.dictLocale_3},
    ];
  }

  /// 书架模式
  static List<Map<String, String>> getBookshelfModelDictList() {
    return [
      {"ID": '1', "NAME": AppUtils.getLocale()?.dictBookshelfModel_1 ?? ""},
      {"ID": '2', "NAME": AppUtils.getLocale()?.dictBookshelfModel_2 ?? ""},
    ];
  }

  /// 获取排序列表Dict
  static List<Map<String, String>> getSortDictList() {
    return [
      {"ID": '1', "NAME": AppUtils.getLocale()?.dictSort_1 ?? ""},
      {"ID": '2', "NAME": AppUtils.getLocale()?.dictSort_2 ?? ""},
      {"ID": '3', "NAME": AppUtils.getLocale()?.dictSort_3 ?? ""},
    ];
  }

  /// 获取书源过滤模式列表Dict
  static List<Map<String, String>> getBookSourceFilterDictList() {
    return [
      {"ID": '1', "NAME": AppUtils.getLocale()?.dictBookSourceFilterModel_1 ?? ""},
      {"ID": '2', "NAME": AppUtils.getLocale()?.dictBookSourceFilterModel_2 ?? ""},
    ];
  }

  /// 获取数字列表
  static List<Map<String, String>> getNumberList() {
    return [
      {"ID": '1', "NAME": "1"},
      {"ID": '2', "NAME": "2"},
      {"ID": '3', "NAME": "3"},
      {"ID": '4', "NAME": "4"},
      {"ID": '5', "NAME": "5"},
      {"ID": '6', "NAME": "6"},
      {"ID": '7', "NAME": "7"},
      {"ID": '8', "NAME": "8"},
      {"ID": '9', "NAME": "9"},
      {"ID": '10', "NAME": "10"},
    ];
  }

  /// 书籍缓存
  static List<Map<String, String>> getBookCacheNumber() {
    return [
      {"ID": '1', "NAME": AppUtils.getLocale()?.readCacheBtn1 ?? ""},
      {"ID": '2', "NAME": AppUtils.getLocale()?.readCacheBtn2 ?? ""},
      {"ID": '3', "NAME": AppUtils.getLocale()?.readCacheBtn3 ?? ""},
    ];
  }

  /// 内容缩进
  static List<Map<String, String>> getBookIndentList() {
    return [
      {"ID": '0', "NAME": AppUtils.getLocale()?.bookMoreSettingIndent1 ?? ""},
      {"ID": '1', "NAME": AppUtils.getLocale()?.bookMoreSettingIndent2 ?? ""},
      {"ID": '2', "NAME": AppUtils.getLocale()?.bookMoreSettingIndent3 ?? ""},
      {"ID": '3', "NAME": AppUtils.getLocale()?.bookMoreSettingIndent4 ?? ""},
      {"ID": '4', "NAME": AppUtils.getLocale()?.bookMoreSettingIndent5 ?? ""},
    ];
  }

  /// 屏幕超时
  static List<Map<String, String>> getScreenTimeoutList() {
    return [
      {"ID": '0', "NAME": AppUtils.getLocale()?.bookMoreSettingTimeout1 ?? ""},
      {"ID": '60', "NAME": AppUtils.getLocale()?.bookMoreSettingTimeout2 ?? ""},
      {"ID": '120', "NAME": AppUtils.getLocale()?.bookMoreSettingTimeout3 ?? ""},
      {"ID": '180', "NAME": AppUtils.getLocale()?.bookMoreSettingTimeout4 ?? ""},
      {"ID": '240', "NAME": AppUtils.getLocale()?.bookMoreSettingTimeout5 ?? ""},
      {"ID": '300', "NAME": AppUtils.getLocale()?.bookMoreSettingTimeout6 ?? ""},
      {"ID": '-1', "NAME": AppUtils.getLocale()?.bookMoreSettingTimeout7 ?? ""},
    ];
  }

  /// 离线语音
  static List<Map<String, String>> getLocalReadAloudList() {
    return [
      {"ID": 'zh-CN', "NAME": AppUtils.getLocale()?.dictVoice_1 ?? ""},
      {"ID": 'zh-HK', "NAME": AppUtils.getLocale()?.dictVoice_2 ?? ""},
      {"ID": 'zh-TW', "NAME": AppUtils.getLocale()?.dictVoice_3 ?? ""},
    ];
  }

  ///书源排序
  static List<Map<String, String>> getBookSourceSortList() {
    return [
      {"ID": '1', "NAME": AppUtils.getLocale()?.dictBookSourceSort_1 ?? ""},
      {"ID": '2', "NAME": AppUtils.getLocale()?.dictBookSourceSort_2 ?? ""},
      {"ID": '3', "NAME": AppUtils.getLocale()?.dictBookSourceSort_3 ?? ""},
      {"ID": '4', "NAME": AppUtils.getLocale()?.dictBookSourceSort_4 ?? ""},
    ];
  }
}