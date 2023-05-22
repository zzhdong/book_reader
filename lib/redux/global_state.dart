import 'package:book_reader/common/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:book_reader/redux/theme_redux.dart';
import 'package:book_reader/redux/locale_redux.dart';

///全局Redux store 的对象，保存State数据
class GlobalState {

  ///当前手机平台默认语言
  Locale? platformLocale;

  ///语言
  Locale locale;

  ///主题数据
  ThemeModel theme;

  ///构造方法
  GlobalState({required this.theme, required this.locale});
}

///创建 Reducer
///源码中 Reducer 是一个方法 typedef State Reducer<State>(State state, dynamic action);
///我们自定义了 appReducer 用于创建 store
GlobalState appReducer(GlobalState state, action) {
  return GlobalState(
    ///通过 localeReducer 将 GlobalState 内的 locale 和 action 关联在一起
    locale: localeReducer(state.locale, action),

    ///通过 themeReducer 将 GlobalState 内的 theme 和 action 关联在一起
    theme: themeReducer(state.theme, action),
  );
}