import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:book_reader/localizations/app_localizations_default.dart';

///多语言代理
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizationsDefault> {

  AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    ///支持中文和英语
    return ['zh', 'en'].contains(locale.languageCode);
  }

  ///根据locale，创建一个对象用于提供当前locale下的文本显示
  @override
  Future<AppLocalizationsDefault> load(Locale locale) {
    return SynchronousFuture<AppLocalizationsDefault>(AppLocalizationsDefault(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizationsDefault> old) {
    return false;
  }

  ///全局静态的代理
  static AppLocalizationsDelegate delegate = AppLocalizationsDelegate();
}
