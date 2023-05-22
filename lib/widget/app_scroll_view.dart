import 'package:flutter/cupertino.dart';

// 滚动视图
class AppScrollView extends StatelessWidget {
  //子控件
  final Widget child;

  final ScrollController? controller;

  //显示滚动条
  final bool showBar;

  //padding
  final EdgeInsetsGeometry padding;

  const AppScrollView({super.key, required this.child, this.controller, this.showBar = true, this.padding = const EdgeInsets.all(0)});

  @override
  Widget build(BuildContext context) {
    if (showBar) {
      return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // 触摸收起键盘
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: CupertinoScrollbar(
              child: SingleChildScrollView(controller: controller, padding: padding, child: child)));
    } else {
      return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // 触摸收起键盘
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(controller: controller, padding: padding, child: child));
    }
  }
}
