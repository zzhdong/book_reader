import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:book_reader/pages/home_page.dart';
import 'package:flutter/cupertino.dart';

/// 导航工具类
class NavigatorUtils {

  /// 进入主页
  static goHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, HomePage.name);
  }

  /// 页面替换
  static pageReset(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  /// 切换页面
  static changePage(BuildContext context, Widget widget, {int animationType = 0}) {
    switch(animationType){
      case 0: return Navigator.push(context, MaterialWithModalsPageRoute(builder: (context) => widget));
      case 1: return Navigator.push(context, getAnimationBottomSlide(context, widget));
      case 2: return Navigator.push(context, getAnimationRotateFade(context, widget));
      case 3: return Navigator.push(context, getAnimationFade(context, widget));
    }
  }

  /// 切换页面-通过路由名称
  static changePageByName(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  /// 切换页面, 并返回参数
  static Future<String?> changePageGetBackParams(BuildContext context, Widget widget) async {
    return await Navigator.push<String>(context, CupertinoPageRoute(builder: (context) => widget));
  }

  /// 页面返回
  static goBack(BuildContext context) {
    Navigator.pop(context);
  }

  /// 页面返回-带参数
  static goBackWithParams(BuildContext context, String params) {
    Navigator.pop(context, params);
  }

  /// 页面底部弹出并淡出
  static getAnimationBottomSlide(BuildContext context, Widget widget) {
    return PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) => widget,
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation), child: child),
          );
        }
    );
  }

  /// 页面旋转淡入淡出效果
  static getAnimationRotateFade(BuildContext context, Widget widget) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 1000),
      pageBuilder: (context, _, __) => widget,
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) => FadeTransition(
            opacity: animation,
            child: RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
              child: child,
            ),
          ),
    );
  }

  static getAnimationFade(BuildContext context, Widget widget) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, _, __) => widget,
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) => FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}
