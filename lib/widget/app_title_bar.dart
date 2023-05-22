import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_reader/utils/widget_utils.dart';

///title 控件
class AppTitleBar extends StatelessWidget {
  final String title;

  final double titleSize;

  final Color? titleColor;

  final String? leftWidgetIcon;

  final Widget? leftWidget;

  final bool? showLeftBtn;

  final VoidCallback? onLeftPressed;

  final String? rightWidgetIcon;

  final Widget? rightWidget;

  final VoidCallback? onRightPressed;

  final String? right2WidgetIcon;

  final Widget? right2Widget;

  final VoidCallback? onRight2Pressed;

  const AppTitleBar(this.title,
      {
        super.key,
        this.titleSize = 20.0,
        this.titleColor,
      this.leftWidgetIcon,
      this.leftWidget,
      this.showLeftBtn = true,
      this.onLeftPressed,
      this.rightWidgetIcon,
      this.rightWidget,
      this.onRightPressed,
      this.right2WidgetIcon,
      this.right2Widget,
      this.onRight2Pressed});

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      Widget? _leftWidget = leftWidget;
      Widget _left2Widget = Container(width: 0);
      if (leftWidget == null) {
        if (leftWidgetIcon == null) {
          _leftWidget = Container(width: 48);
        } else {
          _leftWidget = IconButton(
              icon: SvgPicture.asset(leftWidgetIcon!, color: store.state.theme.body.headerBtn, width: 22, height: 22),
              onPressed: onLeftPressed);
        }
      }else{
        _leftWidget = SizedBox(width: 48, child: IconButton(icon: leftWidget!, onPressed: onLeftPressed));
      }
      if (leftWidget == null && leftWidgetIcon == null && (showLeftBtn ?? false)) {
        _leftWidget = IconButton(
            icon: WidgetUtils.getHeaderIconData(0xe636),
            onPressed: () => NavigatorUtils.goBack(context));
      }

      Widget? _rightWidget = rightWidget;
      if (rightWidget == null) {
        if (rightWidgetIcon == null) {
          _rightWidget = Container(width: 48);
        } else {
          _rightWidget = IconButton(
              icon: SvgPicture.asset(rightWidgetIcon!, color: store.state.theme.body.headerBtn, width: 22, height: 22),
              onPressed: onRightPressed);
        }
      }else{
        _rightWidget = SizedBox(width: 48, child: IconButton(icon: rightWidget!, onPressed: onRightPressed));
      }
      Widget? _right2Widget = right2Widget;
      if (right2Widget == null) {
        if (right2WidgetIcon == null) {
          _right2Widget = Container(width: 0);
        } else {
          _right2Widget = IconButton(
              icon:
                  SvgPicture.asset(right2WidgetIcon!, color: store.state.theme.body.headerBtn, width: 22, height: 22),
              onPressed: onRight2Pressed);
          _left2Widget = Container(width: 38);
        }
      }else{
        _right2Widget = SizedBox(width: 38, child: IconButton(icon: right2Widget!, onPressed: onRight2Pressed));
        _left2Widget = Container(width: 38);
      }
      return Row(
        children: <Widget>[
          _leftWidget,
          _left2Widget,
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center, style:
            (titleColor == null) ? TextStyle(fontSize: titleSize, fontWeight: FontWeight.w500, color: store.state.theme.body.headerTitle) :
                TextStyle(fontSize: titleSize, fontWeight: FontWeight.w500, color: titleColor)
            ),
          ),
          _right2Widget,
          _rightWidget,
        ],
      );
    });
  }
}
