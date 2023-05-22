import 'package:flutter/material.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/dialog/app_custom_dialog_checkbox.dart';
import 'package:book_reader/widget/dialog/app_custom_dialog_radio.dart';
import 'package:book_reader/utils/screen_utils.dart';

class AppCustomDialog {
  //================================弹窗属性======================================
  List<Widget> widgetList = []; //弹窗内部所有组件

  static BuildContext? _context; //弹窗上下文

  BuildContext? context; //弹窗上下文

  double? width; //弹窗宽度

  double height = ScreenUtils.getScreenHeight() - 280; //弹窗高度

  Duration duration = const Duration(milliseconds: 250); //弹窗动画出现的时间

  Gravity gravity = Gravity.center; //弹窗出现的位置

  bool gravityAnimationEnable = false; //弹窗出现的位置带有的默认动画是否可用

  Color barrierColor = Colors.black.withOpacity(.3); //弹窗外的背景色

  Color backgroundColor = Colors.white; //弹窗内的背景色

  double borderRadius = 0.0; //弹窗圆角

  BoxConstraints? constraints; //弹窗约束

  Function(Widget child, Animation<double> animation)? animatedFunc; //弹窗出现的动画

  bool barrierDismissible = true; //是否点击弹出外部消失

  EdgeInsets margin = const EdgeInsets.all(0.0); //弹窗布局的外边距

  Function()? showCallBack; //展示的回调

  Function()? dismissCallBack; //消失的回调

  get isShowing => _isShowing; //当前弹窗是否可见

  bool _isShowing = false;
  //============================================================================

  static void init(BuildContext ctx) {
    _context = ctx;
  }

  AppCustomDialog build([BuildContext? ctx]) {
    if (ctx == null && _context != null) {
      context = _context;
      return this;
    }
    context = ctx;
    return this;
  }

  AppCustomDialog widget(Widget child) {
    widgetList.add(child);
    return this;
  }

  AppCustomDialog text(
      {padding,
        text,
        color,
        fontSize,
        alignment,
        textAlign,
        maxLines,
        textDirection,
        overflow,
        fontWeight,
        fontFamily}) {
    return widget(
      Padding(
        padding: padding ?? const EdgeInsets.all(0.0),
        child: Align(
          alignment: alignment ?? Alignment.centerLeft,
          child: Text(
            text ?? "",
            textAlign: textAlign,
            maxLines: maxLines,
            textDirection: textDirection,
            overflow: overflow,
            style: TextStyle(
              color: color ?? Colors.black,
              fontSize: fontSize ?? 14.0,
              fontWeight: fontWeight,
              fontFamily: fontFamily,
            ),
          ),
        ),
      ),
    );
  }

  AppCustomDialog doubleButton({
    padding,
    gravity,
    height,
    isClickAutoDismiss = true, //点击按钮后自动关闭
    withDivider = false, //中间分割线
    text1,
    color1,
    fontSize1,
    fontWeight1,
    fontFamily1,
    VoidCallback? onTap1,
    text2,
    color2,
    fontSize2,
    fontWeight2,
    fontFamily2,
    onTap2,
  }) {
    return widget(
      SizedBox(
        height: height ?? 45.0,
        child: Row(
          mainAxisAlignment: getRowMainAxisAlignment(gravity),
          children: <Widget>[
            TextButton(
              onPressed: () {
                if (onTap1 != null) onTap1();
                if (isClickAutoDismiss) {
                  dismiss();
                }
              },
              //padding: EdgeInsets.all(0.0),
              child: Text(
                text1 ?? "",
                style: TextStyle(
                  color: color1,
                  fontSize: fontSize1,
                  fontWeight: fontWeight1,
                  fontFamily: fontFamily1,
                ),
              ),
            ),
            Visibility(
              visible: withDivider,
              child: const VerticalDivider(),
            ),
            TextButton(
              onPressed: () {
                if (onTap2 != null) onTap2();
                if (isClickAutoDismiss) {
                  dismiss();
                }
              },
              //padding: EdgeInsets.all(0.0),
              child: Text(
                text2 ?? "",
                style: TextStyle(
                  color: color2 ?? Colors.black,
                  fontSize: fontSize2 ?? 14.0,
                  fontWeight: fontWeight2,
                  fontFamily: fontFamily2,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  AppCustomDialog listViewOfListTile({
    required List<ListTileItem> items,
    double? height,
    double itemExtent = 40,
    isClickAutoDismiss = true,
    Function(int)? onClickItemListener,
  }) {
    return widget(
      SizedBox(
        height: height,
        child: ListView.builder(
          padding: const EdgeInsets.all(0.0),
          shrinkWrap: true,
          itemCount: items.length,
          itemExtent: itemExtent,
          itemBuilder: (BuildContext context, int index) {
            return Material(
              color: Colors.white,
              child: InkWell(
                child: ListTile(
                  onTap: () {
                    if (onClickItemListener != null) {
                      onClickItemListener(index);
                    }
                    if (isClickAutoDismiss) {
                      dismiss();
                    }
                  },
                  contentPadding: items[index].padding ?? const EdgeInsets.all(0.0),
                  leading: items[index].leading,
                  title: Text(
                    items[index].text ?? "",
                    style: TextStyle(
                      color: items[index].color,
                      fontSize: items[index].fontSize,
                      fontWeight: items[index].fontWeight,
                      fontFamily: items[index].fontFamily,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  AppCustomDialog listViewOfRadioButton({
    required List<RadioItem> items,
    double? height,
    double itemExtent = 40,
    Color? activeColor,
    required EdgeInsets padding,
    String groupValue = "",
    required Function(String) onClickItemListener,
  }) {
    return widget(
      Container(
        color: WidgetUtils.gblStore?.state.theme.popMenu.background,
        height: height,
        child: AppCustomRadioListTile(
          items: items,
          itemExtent: itemExtent,
          activeColor: activeColor,
          padding: padding,
          groupValue: groupValue,
          onChanged: onClickItemListener,
        ),
      ),
    );
  }

  AppCustomDialog listViewOfCheckboxButton({
    required List<CheckboxItem> items,
    double? height,
    double itemExtent = 40,
    Color? activeColor,
    required EdgeInsets padding,
    required Function(List<CheckboxItem> items, int, bool) onClickItemListener,
  }) {
    return widget(
      Container(
        color: WidgetUtils.gblStore?.state.theme.popMenu.background,
        height: height,
        child: AppCustomCheckboxListTile(
          items: items,
          itemExtent: itemExtent,
          activeColor: activeColor,
          padding: padding,
          onChanged: onClickItemListener,
        ),
      ),
    );
  }

  AppCustomDialog circularProgress(
      {padding, backgroundColor, valueColor, strokeWidth}) {
    return widget(Padding(
      padding: padding,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth ?? 4.0,
        backgroundColor: backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(valueColor),
      ),
    ));
  }

  AppCustomDialog divider({color, height}) {
    return widget(
      Divider(
        color: color ?? Colors.grey[300],
        height: height ?? 0.1,
      ),
    );
  }

  ///  x坐标
  ///  y坐标
  void show([x, y]) {
    var mainAxisAlignment = getColumnMainAxisAlignment(gravity);
    var crossAxisAlignment = getColumnCrossAxisAlignment(gravity);
    if (x != null && y != null) {
      gravity = Gravity.leftTop;
      margin = EdgeInsets.only(left: x, top: y);
    }
    CustomDialog(
      gravity: gravity,
      gravityAnimationEnable: gravityAnimationEnable,
      context: context,
      barrierColor: barrierColor,
      animatedFunc: animatedFunc,
      barrierDismissible: barrierDismissible,
      duration: duration,
      child: Padding(
        padding: margin,
        child: Column(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: <Widget>[
            Material(
              type: MaterialType.transparency,
              child: Container(
                padding: EdgeInsets.all(borderRadius / 3.14),
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  color: backgroundColor,
                ),
                constraints: constraints ?? const BoxConstraints(),
                child: CustomDialogChildren(
                  widgetList: widgetList,
                  isShowingChange: (bool isShowingChange) {
                    // showing or dismiss Callback
                    if (isShowingChange) {
                      if (showCallBack != null) {
                        showCallBack!();
                      }
                    } else {
                      if (dismissCallBack != null) {
                        dismissCallBack!();
                      }
                    }
                    _isShowing = isShowingChange;
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void dismiss() {
    if (_isShowing) {
      Navigator.of(context!, rootNavigator: true).pop();
    }
  }

  getColumnMainAxisAlignment(gravity) {
    var mainAxisAlignment = MainAxisAlignment.start;
    switch (gravity) {
      case Gravity.bottom:
      case Gravity.leftBottom:
      case Gravity.rightBottom:
        mainAxisAlignment = MainAxisAlignment.end;
        break;
      case Gravity.top:
      case Gravity.leftTop:
      case Gravity.rightTop:
        mainAxisAlignment = MainAxisAlignment.start;
        break;
      case Gravity.left:
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      case Gravity.right:
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      case Gravity.center:
      default:
        mainAxisAlignment = MainAxisAlignment.center;
        break;
    }
    return mainAxisAlignment;
  }

  getColumnCrossAxisAlignment(gravity) {
    var crossAxisAlignment = CrossAxisAlignment.center;
    switch (gravity) {
      case Gravity.bottom:
        break;
      case Gravity.top:
        break;
      case Gravity.left:
      case Gravity.leftTop:
      case Gravity.leftBottom:
        crossAxisAlignment = CrossAxisAlignment.start;
        break;
      case Gravity.right:
      case Gravity.rightTop:
      case Gravity.rightBottom:
        crossAxisAlignment = CrossAxisAlignment.end;
        break;
      default:
        break;
    }
    return crossAxisAlignment;
  }

  getRowMainAxisAlignment(gravity) {
    var mainAxisAlignment = MainAxisAlignment.start;
    switch (gravity) {
      case Gravity.bottom:
        break;
      case Gravity.top:
        break;
      case Gravity.left:
        mainAxisAlignment = MainAxisAlignment.start;
        break;
      case Gravity.right:
        mainAxisAlignment = MainAxisAlignment.end;
        break;
      case Gravity.center:
      default:
        mainAxisAlignment = MainAxisAlignment.center;
        break;
    }
    return mainAxisAlignment;
  }
}

///弹窗的内容作为可变组件
class CustomDialogChildren extends StatefulWidget {
  List<Widget> widgetList = []; //弹窗内部所有组件
  Function(bool)? isShowingChange;

  CustomDialogChildren({super.key, required widgetList, isShowingChange});

  @override
  CustomDialogChildState createState() => CustomDialogChildState();
}

class CustomDialogChildState extends State<CustomDialogChildren> {
  @override
  Widget build(BuildContext context) {
    if (widget.isShowingChange != null) {
      widget.isShowingChange!(true);
    }
    return Column(
      children: widget.widgetList,
    );
  }

  @override
  void dispose() {
    if (widget.isShowingChange != null) {
      widget.isShowingChange!(false);
    }
    super.dispose();
  }
}

///弹窗API的封装
class CustomDialog {
  final BuildContext? _context;
  final Widget _child;
  final Duration? _duration;
  Color? _barrierColor;
  final RouteTransitionsBuilder? _transitionsBuilder;
  final bool? _barrierDismissible;
  final Gravity? _gravity;
  final bool? _gravityAnimationEnable;
  final Function? _animatedFunc;

  CustomDialog({
    required Widget child,
    BuildContext? context,
    Duration? duration,
    Color? barrierColor,
    RouteTransitionsBuilder? transitionsBuilder,
    Gravity? gravity,
    bool? gravityAnimationEnable,
    Function? animatedFunc,
    bool? barrierDismissible,
  })  : _child = child,
        _context = context,
        _gravity = gravity,
        _gravityAnimationEnable = gravityAnimationEnable,
        _duration = duration,
        _barrierColor = barrierColor,
        _animatedFunc = animatedFunc,
        _transitionsBuilder = transitionsBuilder,
        _barrierDismissible = barrierDismissible {
    show();
  }

  show() {
    //fix transparent error
    if (_barrierColor == Colors.transparent) {
      _barrierColor = Colors.white.withOpacity(0.0);
    }

    showGeneralDialog(
      context: _context!,
      barrierColor: _barrierColor ?? Colors.black.withOpacity(.3),
      barrierDismissible: _barrierDismissible ?? true,
      barrierLabel: "",
      transitionDuration: _duration ?? const Duration(milliseconds: 250),
      transitionBuilder: _transitionsBuilder ?? _buildMaterialDialogTransitions,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Builder(
          builder: (BuildContext context) {
            return _child;
          },
        );
      },
    );
  }

  Widget _buildMaterialDialogTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    Animation<Offset> custom;
    switch (_gravity) {
      case Gravity.top:
      case Gravity.leftTop:
      case Gravity.rightTop:
        custom = Tween<Offset>(
          begin: const Offset(0.0, -1.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
      case Gravity.left:
        custom = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
      case Gravity.right:
        custom = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
      case Gravity.bottom:
      case Gravity.leftBottom:
      case Gravity.rightBottom:
        custom = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
      case Gravity.center:
      default:
        custom = Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
    }

    //自定义动画
    if (_animatedFunc != null) {
      return _animatedFunc!(child, animation);
    }

    //不需要默认动画
    if (_gravityAnimationEnable != null && !_gravityAnimationEnable!) {
      custom = Tween<Offset>(
        begin: const Offset(0.0, 0.0),
        end: const Offset(0.0, 0.0),
      ).animate(animation);
    }

    return SlideTransition(
      position: custom,
      child: child,
    );
  }
}

//================================弹窗重心======================================
enum Gravity {
  left,
  top,
  bottom,
  right,
  center,
  rightTop,
  leftTop,
  rightBottom,
  leftBottom,
}

//================================弹窗实体======================================
class ListTileItem {
  ListTileItem({
    this.padding,
    this.leading,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
  });

  EdgeInsets? padding;
  Widget? leading;
  String? text;
  Color? color;
  double? fontSize;
  FontWeight? fontWeight;
  String? fontFamily;
}

class RadioItem {
  RadioItem({
    this.text,
    this.value,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.onTap,
  });

  String? text;
  String? value;
  Color? color;
  double? fontSize;
  FontWeight? fontWeight;
  Function(int)? onTap;
}

class CheckboxItem {
  CheckboxItem({
    this.title,
    this.value,
    this.activeColor,
    this.checkColor,
    this.fontSize,
    this.fontWeight,
    this.onTap,
  });

  Widget? title;
  bool? value;
  Color? activeColor;
  Color? checkColor;
  double? fontSize;
  FontWeight? fontWeight;
  Function(int)? onTap;
}