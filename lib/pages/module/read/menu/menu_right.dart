import 'package:flutter/material.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/app_utils.dart';

class MenuRight extends StatefulWidget {
  final Function? onPress;

  const MenuRight({super.key, this.onPress});

  @override
  MenuRightStatus createState() => MenuRightStatus();
}

class MenuRightStatus extends State<MenuRight> {
  double _rightWidgetWidth = -70;

  void toggleMenu() {
    setState(() {
      _rightWidgetWidth = _rightWidgetWidth == 20 ? -70 : 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.fastLinearToSlowEaseIn,
      duration: const Duration(milliseconds: 1000),
      bottom: 140 + ScreenUtils.getViewPaddingBottom(),
      right: _rightWidgetWidth,
      child: Column(children: <Widget>[
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(bottom: 3),
          margin: const EdgeInsets.only(bottom: 20),
          constraints: const BoxConstraints.expand(
            width: 44.0,
            height: 44.0,
          ),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22.0), color: const Color.fromRGBO(0, 0, 0, 0.5)),
          child: IconButton(
              icon: const Icon(IconData(0xe6c2, fontFamily: 'iconfont'), color: Color(0xffeeeeee), size: 26),
              onPressed: () {
                if (widget.onPress != null) widget.onPress!("LoadVideoReward");
              }),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(bottom: 3),
          constraints: const BoxConstraints.expand(
            width: 44.0,
            height: 44.0,
          ),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22.0), color: const Color.fromRGBO(0, 0, 0, 0.5)),
          child: IconButton(
              icon: Icon(IconData((AppParams.getInstance().getAppTheme() == 1) ? 0xe698 : 0xe66e, fontFamily: 'iconfont'), color: const Color(0xffeeeeee), size: 26),
              onPressed: () {
                AppParams.getInstance().setAppTheme(AppParams.getInstance().getAppTheme() == 1 ? 2 : 1);
                BookParams.getInstance().setDayTheme();
                if (widget.onPress != null) widget.onPress!("Refresh");
                AppUtils.updateAppTheme();
                setState(() {});
              }),
        )
      ]),
    );
  }
}
