import 'package:book_reader/redux/global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

///点击控件
class AppTouchEvent extends StatelessWidget {
  //子控件
  final Widget child;

  //背景颜色
  final Color? background;

  //点击后的颜色
  final Color? pressColor;

  //点击事件
  final VoidCallback? onTap;

  //长按
  final VoidCallback? onLongPress;

  //margin
  final EdgeInsetsGeometry margin;

  //使用默认效果
  final bool defEffect;

  //是否透明
  final bool isTransparent;

  const AppTouchEvent({super.key, required this.child, this.background, this.pressColor, this.onTap, this.onLongPress, this.margin = const EdgeInsets.all(0), this.defEffect = false, this.isTransparent = false});

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      var background = store.state.theme.body.btnUnPress;
      if (this.background != null) background = this.background!;
      var pressColor = store.state.theme.body.btnPress;
      if (this.pressColor != null) pressColor = this.pressColor!;
      if (isTransparent) {
        background = Colors.transparent;
        pressColor = Colors.transparent;
      }
      //判断是否默认效果
      if(defEffect){
        return Container(
            margin: margin,
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: onTap,
                    onLongPress: onLongPress,
                    radius: 0,
                    child: child
                )
            )
        );
      }else{
        return Container(
            margin: margin,
            child: Material(
                color: background,
                child: InkWell(
                    highlightColor: pressColor,
                    splashColor: background,
                    onTap: onTap,
                    onLongPress: onLongPress,
                    child: child,
                )
            )
        );
      }

    });
  }
}
