import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

///列表菜单
class AppListMenu extends StatelessWidget {
  final String title;
  final String titleFontFamily;
  final Color? titleColor;
  final Widget? icon;
  final String? subTitle;
  final bool showArrow;
  final Widget? customWidget;
  final VoidCallback? onPressed;

  const AppListMenu(this.title, {super.key, this.titleFontFamily = AppConfig.DEF_FONT_FAMILY, this.titleColor, this.icon, this.subTitle, this.showArrow = true, this.onPressed, this.customWidget});

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      Widget subTitleWidget = Container(width: 0);
      if (subTitle != null) {
        subTitleWidget = Container(
            margin: const EdgeInsets.fromLTRB(0, 2, 5, 0),
            child:
            Text(subTitle!, style: TextStyle(fontSize: 13.0, color: store.state.theme.listMenu.content)));
      }
      Widget arrowWidget = Container(width: 0);
      if (showArrow) {
        arrowWidget = Icon(const IconData(0xe653,fontFamily: 'iconfont'), color: store.state.theme.listMenu.arrow, size: 18,);
      }
      if(customWidget != null) {
        arrowWidget = customWidget!;
      }

      return AppTouchEvent(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
        onTap: onPressed,
        child: Container(
          height: 50,
          padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
          child: Row(
            children: <Widget>[
              Visibility(
                visible: icon != null,
                child: Container(alignment: Alignment.centerLeft, width: 36, child: icon),
              ),
              Expanded(
                child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Text(title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 16.0, color: titleColor ?? store.state.theme.listMenu.title, fontFamily: titleFontFamily))),
              ),
              subTitleWidget,
              arrowWidget,
            ],
          ),
        ),
      );
    });
  }
}
