import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/theme_dark.dart';
import 'package:book_reader/common/theme_default.dart';
import 'package:book_reader/database/schema/book_group_schema.dart';
import 'package:book_reader/localizations/app_localizations_default.dart';
import 'package:book_reader/localizations/app_string_base.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/redux/locale_redux.dart';
import 'package:book_reader/redux/theme_redux.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';

/// App 工具类
class AppUtils {

  //APP根目录
  static String documentDir = "";
  //书籍缓存目录
  static String bookCacheDir = "";
  //本地书籍目录
  static String bookLocDir = "";
  //ios版本
  static int iosMainVersion = 14;

  ///初始化信息
  static Future<bool> initSystemInfo() async {
    AppConfig.prefs = await SharedPreferences.getInstance();
    //初始化app目录
    Directory dir = await getApplicationDocumentsDirectory();
    documentDir = "${dir.path}/${AppConfig.APP_NAME}/";
    bookCacheDir = "${documentDir}bookCache/";
    bookLocDir = "${documentDir}bookLoc/";
    //创建目录
    Directory tmpDir = Directory(documentDir);
    if(!tmpDir.existsSync()) tmpDir.createSync(recursive: true);
    tmpDir = Directory(bookCacheDir);
    if(!tmpDir.existsSync()) tmpDir.createSync(recursive: true);
    tmpDir = Directory(bookLocDir);
    if(!tmpDir.existsSync()) tmpDir.createSync(recursive: true);
    print("Load documentDir:$documentDir");
    print("Load bookCacheDir:$bookCacheDir");
    print("Load bookLocDir:$bookLocDir");
    //设置主题和语言
    AppUtils.updateAppTheme();
    AppUtils.updateAppLocale();
    //初始化书籍默认分组
    await BookGroupSchema.getInstance.initDefaultGroup();
    //获取ios版本
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
      List<String> versionList = iosInfo.systemVersion.split(".") ?? [];
      iosMainVersion = StringUtils.stringToInt(versionList[0], def: 14);
      print("iOS版本: ${iosInfo.systemVersion} $iosMainVersion");
    }
    return true;
  }

  /// 初始化延迟调用
  static void initDelayed(Function callback, {Function? onceCallBack, bool loadMask = false, int duration = 500}){
    Future.delayed(Duration.zero, (){
      if(loadMask) ToolsPlugin.showLoading();
      if(onceCallBack != null) onceCallBack();
      Future.delayed(Duration(milliseconds: duration), callback as FutureOr Function()?);
    });
  }

  /// 获取主题
  static getAppTheme(int index) {
    if (index == 1) {
      SystemUiOverlayStyle style = const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white);
      SystemChrome.setSystemUIOverlayStyle(style);
      return ThemeDefault.theme;
    } else {
      SystemUiOverlayStyle style = SystemUiOverlayStyle(systemNavigationBarColor: ThemeDark.theme.primary);
      SystemChrome.setSystemUIOverlayStyle(style);
      return ThemeDark.theme;
    }
  }

  //更新主题和语言
  static void updateAppTheme(){
    WidgetUtils.gblStore?.dispatch(RefreshThemeAction(getAppTheme(AppParams.getInstance().getAppTheme())));
  }

  //更新语言
  static void updateAppLocale(){
    Locale? locale = WidgetUtils.gblStore?.state.platformLocale;
    if(AppParams.getInstance().getLocaleLanguage() == 1){
      locale = const Locale('zh', 'CH');
    }else if(AppParams.getInstance().getLocaleLanguage() == 2){
      locale = const Locale('zh', 'TW');
    }else if(AppParams.getInstance().getLocaleLanguage() == 3){
      locale = const Locale('en', 'US');
    }
    if (locale != null) {
      WidgetUtils.gblStore?.dispatch(RefreshLocaleAction(locale));
    }
  }

  /// 获取语言
  static AppStringBase? getLocale() {
    return AppLocalizationsDefault.of(WidgetUtils.gblBuildContext).currentLocalized;
  }
}
