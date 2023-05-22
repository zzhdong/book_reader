import 'package:flutter/material.dart';
import 'package:book_reader/localizations/app_string_base.dart';
import 'package:book_reader/localizations/app_string_en.dart';
import 'package:book_reader/localizations/app_string_zh.dart';
import 'package:book_reader/localizations/app_string_zh_tw.dart';

///自定义多语言实现
class AppLocalizationsDefault {
  final Locale locale;

  AppLocalizationsDefault(this.locale);

  ///根据不同 locale.languageCode 加载不同语言对应
  ///AppStringEn和AppStringZh都继承了AppStringBase
  static final Map<String, AppStringBase> _localizedValues = {
    'zh_CH': AppStringZh(),
    'zh_TW': AppStringZhTw(),
    'en_US': AppStringEn(),
  };

  AppStringBase? get currentLocalized {
    return _localizedValues["${locale.languageCode}_${locale.countryCode}"];
  }

  ///通过 Localizations 加载当前的 AppLocalizationsDefault
  ///获取对应的 AppStringBase
  static AppLocalizationsDefault of(BuildContext context) {
    return Localizations.of(context, AppLocalizationsDefault);
  }
}
