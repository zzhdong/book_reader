import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:book_reader/common/book_params.dart';

/// 屏幕工具类
class ScreenUtils {

  static double getScreenHeight() => (WidgetsBinding.instance.window.physicalSize.height / WidgetsBinding.instance.window.devicePixelRatio).ceil().toDouble();

  static double getScreenWidth() => (WidgetsBinding.instance.window.physicalSize.width / WidgetsBinding.instance.window.devicePixelRatio).ceil().toDouble();

  static double getViewPaddingTop() => (WidgetsBinding.instance.window.viewPadding.top / WidgetsBinding.instance.window.devicePixelRatio).ceil().toDouble();

  static double getViewPaddingBottom() => (WidgetsBinding.instance.window.viewPadding.bottom / WidgetsBinding.instance.window.devicePixelRatio).ceil().toDouble();

  static double getViewPaddingLeft() => (WidgetsBinding.instance.window.viewPadding.left / WidgetsBinding.instance.window.devicePixelRatio).ceil().toDouble();

  static double getViewPaddingRight() => (WidgetsBinding.instance.window.viewPadding.right / WidgetsBinding.instance.window.devicePixelRatio).ceil().toDouble();

  static double getMaxViewPadding() => max(getViewPaddingLeft(), getViewPaddingRight());

  static double getHeaderHeightWithTop() => kToolbarHeight + getViewPaddingTop();

  static double getHeaderHeight() => kToolbarHeight;

  static double getBodyHeight() => getScreenHeight() - getHeaderHeightWithTop() - getViewPaddingBottom();

  /// 判断是否为iPhoneX
  static bool isIPhoneX() => getViewPaddingBottom() != 0;

  /// 判断是否为横屏
  static bool isLandscape() => getScreenWidth() > getScreenHeight();

  static int spToPx(int sp){
    return sp;
  }

  static int dpToPx(int dp) {
    return dp;
  }

  // 屏幕方向
  static Future setScreenDirection() async{
    if(BookParams.getInstance().getScreenDirection() == 0) {
      await SystemChrome.setPreferredOrientations([]);
    } else if(BookParams.getInstance().getScreenDirection() == 1) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else if(BookParams.getInstance().getScreenDirection() == 2) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    }
  }
}
