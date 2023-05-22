import 'package:flutter/material.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_touch_event.dart';

class MenuBookSource extends StatelessWidget {
  final double menuHeight;

  final ValueChanged<int>? onPress;

  const MenuBookSource({super.key, required this.menuHeight, this.onPress});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      width: ScreenUtils.getScreenWidth(),
      child: Container(
        color: WidgetUtils.gblStore?.state.theme.body.background,
        height: menuHeight + ScreenUtils.getViewPaddingBottom(),
        padding: const EdgeInsets.fromLTRB(0, 1, 0, 0),
        child: Container(
            height: menuHeight + ScreenUtils.getViewPaddingBottom(),
            alignment: Alignment.topCenter,
            color: WidgetUtils.gblStore?.state.theme.tabMenu.background,
            child: Row(
              children: <Widget>[
                Expanded(
                    child: AppTouchEvent(
                        onTap: (){ if(onPress != null) onPress!(0); },
                        child: Container(
                            height: menuHeight,
                            alignment: Alignment.center,
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              Icon(const IconData(0xe655, fontFamily: 'iconfont'), color: WidgetUtils.gblStore?.state.theme.body.inputText, size: 16),
                              Container(width: 5),
                              Text(AppUtils.getLocale()?.appButtonEnable ?? "", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: WidgetUtils.gblStore?.state.theme.body.inputText, fontWeight: FontWeight.w600))
                            ])))),
                Container(width: 1, height: menuHeight, color: WidgetUtils.gblStore?.state.theme.tabMenu.background, alignment: Alignment.center, child: Container(height: 18, color: WidgetUtils.gblStore?.state.theme.bottomMenu.border)),
                Expanded(
                    child: AppTouchEvent(
                        onTap: (){ if(onPress != null) onPress!(1); },
                        child: Container(
                            height: menuHeight,
                            alignment: Alignment.center,
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              Icon(const IconData(0xe6ba, fontFamily: 'iconfont'), color: WidgetUtils.gblStore?.state.theme.body.inputText, size: 16),
                              Container(width: 5),
                              Text("${AppUtils.getLocale()?.appButtonDisable}", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: WidgetUtils.gblStore?.state.theme.body.inputText, fontWeight: FontWeight.w600))
                            ])))),
                Container(width: 1, height: menuHeight, color: WidgetUtils.gblStore?.state.theme.tabMenu.background, alignment: Alignment.center, child: Container(height: 18, color: WidgetUtils.gblStore?.state.theme.bottomMenu.border)),
                Expanded(
                    child: AppTouchEvent(
                        onTap: (){ if(onPress != null) onPress!(2); },
                        child: Container(
                            height: menuHeight,
                            alignment: Alignment.center,
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              Icon(const IconData(0xe679, fontFamily: 'iconfont'), color: WidgetUtils.gblStore?.state.theme.body.inputText, size: 16),
                              Container(width: 5),
                              Text("${AppUtils.getLocale()?.appButtonReversal}", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: WidgetUtils.gblStore?.state.theme.body.inputText, fontWeight: FontWeight.w600))
                            ])))),
                Container(width: 1, height: menuHeight, color: WidgetUtils.gblStore?.state.theme.tabMenu.background, alignment: Alignment.center, child: Container(height: 18, color: WidgetUtils.gblStore?.state.theme.bottomMenu.border)),
                Expanded(
                    child: AppTouchEvent(
                        onTap: (){ if(onPress != null) onPress!(3); },
                        child: Container(
                            height: menuHeight,
                            alignment: Alignment.center,
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              const Icon(IconData(0xe63a, fontFamily: 'iconfont'), color: Colors.red, size: 16),
                              Container(width: 5),
                              Text(AppUtils.getLocale()?.appButtonDelete ?? "", overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.w600))
                            ])))),
              ],
            )),
      ),
    );
  }
}
