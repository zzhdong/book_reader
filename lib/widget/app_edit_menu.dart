import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class AppEditMenu extends StatelessWidget {
  final String title;
  final String content;
  final Function? onChange;

  const AppEditMenu(this.title, {super.key, this.content = "", this.onChange});

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return AppTouchEvent(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
        child: Container(
          height: 50,
          padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
          child: Row(
            children: <Widget>[
              Text(title, style: TextStyle(fontSize: 16.0, color: store.state.theme.listMenu.title)),
              Container(margin: const EdgeInsets.fromLTRB(0, 0, 10, 0)),
              Expanded(
                  child: TextField(
                keyboardAppearance: (AppParams.getInstance().getAppTheme() == 1) ? Brightness.light : Brightness.dark,
                controller: TextEditingController(text: content),
                style: TextStyle(fontSize: 15.0, color: WidgetUtils.gblStore?.state.theme.body.inputText),
                textAlign: TextAlign.end,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  if (onChange != null) onChange!(value);
                },
              )),
            ],
          ),
        ),
      );
    });
  }
}
