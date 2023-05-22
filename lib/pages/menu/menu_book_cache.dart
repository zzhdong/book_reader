import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_touch_event.dart';

class MenuBookCache extends StatelessWidget {
  final double menuHeight;

  final totalNum;

  final ValueChanged<int>? onPress;

  const MenuBookCache({super.key, required this.menuHeight, this.totalNum, this.onPress});

  @override
  Widget build(BuildContext context) {
    return
      Positioned(
        bottom: 0,
        width: ScreenUtils.getScreenWidth(),
        child: Container(
          color: WidgetUtils.gblStore?.state.theme.body.background,
          padding: const EdgeInsets.fromLTRB(0, 1, 0, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: AppTouchEvent(
                      onTap: () {},
                      child: Container(
                          height: menuHeight,
                          alignment: Alignment.center,
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            Icon(const IconData(0xe67e, fontFamily: 'iconfont'),
                                color: WidgetUtils.gblStore?.state.theme.body.inputText, size: 16),
                            Container(width: 5),
                            Text("${AppUtils.getLocale()?.appButtonChoose}($totalNum)",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: WidgetUtils.gblStore?.state.theme.body.inputText,
                                    fontWeight: FontWeight.w600))
                          ])))),
              Container(
                  width: 1,
                  height: menuHeight,
                  color: WidgetUtils.gblStore?.state.theme.tabMenu.background,
                  alignment: Alignment.center,
                  child: Container(height: 18, color: WidgetUtils.gblStore?.state.theme.bottomMenu.border)),
              Expanded(
                  child: AppTouchEvent(
                      onTap: (){ if(onPress != null) onPress!(0); },
                      child: Container(
                          height: menuHeight,
                          alignment: Alignment.center,
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            Icon(const IconData(0xe63a, fontFamily: 'iconfont'),
                                color: WidgetUtils.gblStore?.state.theme.tabMenu.activeTint, size: 16),
                            Container(width: 5),
                            Text(AppUtils.getLocale()?.appButtonClear ?? "",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: WidgetUtils.gblStore?.state.theme.tabMenu.activeTint,
                                    fontWeight: FontWeight.w600))
                          ])))),
            ],
          ),
        ),
      );
  }
}
