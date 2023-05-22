import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/widget/dialog/app_popup_menu.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class AppCopyText extends StatelessWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;

  const AppCopyText(this.text, {super.key, this.maxLines = 1, this.style});

  @override
  Widget build(BuildContext context) {
    return AppPopupMenu(
        backgroundColor: Colors.black.withOpacity(0.8),
        menuWidth: 80,
        pressType: PressType.singleClick,
        actions: [AppUtils.getLocale()?.appButtonCopy ?? ""],
        onValueChanged: (int selected) {
          switch (selected) {
            case 0:
              Clipboard.setData(ClipboardData(text: text.trim()));
              ToastUtils.showToast(AppUtils.getLocale()?.msgCopySuccess ?? "");
              break;
          }
        },
        child: Text(text.trim(), maxLines: maxLines, style: style));
  }
}
