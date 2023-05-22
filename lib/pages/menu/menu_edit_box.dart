import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class MenuEditBox extends StatefulWidget {
  final String titleName;

  final String defVal;

  final String btnText;

  final Function? onPress;

  final int maxLines;

  const MenuEditBox({super.key,
    required this.titleName,
    this.defVal = "",
    required this.btnText,
    this.maxLines = 1,
    this.onPress,
  });

  @override
  _MenuEditBoxState createState() => _MenuEditBoxState();
}

class _MenuEditBoxState extends AppState<MenuEditBox> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defVal);
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(
            AppTitleBar(
          widget.titleName,
              titleSize: 18,
              titleColor: store.state.theme.popMenu.titleText,
          showLeftBtn: false,
          rightWidget: Icon(const IconData(0xe65c, fontFamily: 'iconfont'), color: store.state.theme.popMenu.titleText.withOpacity(0.5), size: 20),
          onRightPressed: () => {Navigator.of(context).pop()},
        ),
          backgroundColor:store.state.theme.popMenu.title),
        backgroundColor: store.state.theme.body.background,
        body: Column(
          children: <Widget>[
            Container(height: 20),
            TextField(
              controller: _controller,
              keyboardAppearance: (AppParams.getInstance().getAppTheme() == 1) ? Brightness.light : Brightness.dark,
              maxLines: widget.maxLines,
              autofocus: true,
              //最大行数
              style: TextStyle(fontSize: 15.0, color: WidgetUtils.gblStore?.state.theme.body.inputText),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(color: WidgetUtils.gblStore!.state.theme.body.inputBackground, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(color: WidgetUtils.gblStore!.state.theme.body.inputBackground, width: 1.0),
                ),
                filled: true,
                fillColor: WidgetUtils.gblStore?.state.theme.body.inputBackground,
              ),
            ),
            Container(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(fixedSize: Size(MediaQuery.of(context).size.width - 50, 0)),
              child: Text(StringUtils.isBlank(widget.btnText) ? (AppUtils.getLocale()?.appButtonOk ?? "") : widget.btnText),
              onPressed: () {
                if (_controller.text == "") {
                  ToastUtils.showToast(AppUtils.getLocale()?.msgInput ?? "");
                } else {
                  if (widget.onPress != null) {
                    widget.onPress!(_controller.text);
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      );
    });
  }
}
