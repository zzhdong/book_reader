import 'dart:async';
import 'package:book_reader/pages/tab_page_1.dart';
import 'package:book_reader/pages/tab_page_2.dart';
import 'package:book_reader/pages/tab_page_3.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

///主页
class HomePage extends StatefulWidget {
  static const String name = "home";

  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends AppState<HomePage> {
  DateTime? _lastPressedAt; //上次点击时间

  /// 单击提示退出
  Future<bool> _onExitApp(BuildContext context) async{
    if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      //两次点击间隔超过1秒则重新计时
      _lastPressedAt = DateTime.now();
      ToastUtils.showToast(AppUtils.getLocale()?.msgExit ?? "");
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return _onExitApp(context);
      },
      child: AppTabBar(
        tabItems: [
          BottomNavigationBarItem(label: AppUtils.getLocale()?.homeTab_1,
              icon: const Icon(IconData(0xe69b,fontFamily: 'iconfont'), size: 22),
              activeIcon: const Icon(IconData(0xe69c,fontFamily: 'iconfont'), size: 22)),
          BottomNavigationBarItem(label: AppUtils.getLocale()?.homeTab_2,
              icon: const Icon(IconData(0xe6a0,fontFamily: 'iconfont'), size: 22),
              activeIcon: const Icon(IconData(0xe6a2,fontFamily: 'iconfont'), size: 22)),
          BottomNavigationBarItem(label: AppUtils.getLocale()?.homeTab_3,
              icon: const Icon(IconData(0xe6a4,fontFamily: 'iconfont'), size: 22),
              activeIcon: const Icon(IconData(0xe6a3,fontFamily: 'iconfont'), size: 22)),
        ],
        tabViews: [
          TabPage1(),
          TabPage2(),
          TabPage3(),
        ],
      ),
    );
  }
}

