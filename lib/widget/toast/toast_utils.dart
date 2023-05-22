import 'package:flutter/material.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/toast/toast_view.dart';

class ToastUtils{

  static final Color _backgroundColor = const Color(0xFF303030).withOpacity(0.8);

  static ToastView? _toastView;

  /// 显示toast, type=1:info 2:warn 3:error
  static void showToast(String msg, {String title = "", int type = 1}) {
    Color color = Colors.blue[300]!;
    if (type == 2) {
      color = Colors.yellow[300]!;
    } else if (type == 3) {
      color = Colors.red[300]!;
    }
    if(_toastView != null && !_toastView!.isHide()) _toastView!.hide();
    _toastView = ToastView(
      WidgetUtils.gblBuildContext,
      title: title,
      subTitle: msg,
      icon: Icon(Icons.info_outline, size: 28.0, color: color),
      color: _backgroundColor,
      duration: const Duration(milliseconds: 500),
      onTab: (){
        if(_toastView != null && !_toastView!.isHide()) _toastView!.hide();
      }
    );
    _toastView?.show();
  }
}