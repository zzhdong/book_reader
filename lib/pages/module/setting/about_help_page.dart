
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class AboutHelpPage extends StatefulWidget {
  const AboutHelpPage({super.key});

  @override
  _AboutHelpPageState createState() => _AboutHelpPageState();
}

class _AboutHelpPageState extends AppState<AboutHelpPage> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar:
        WidgetUtils.getDefaultTitleBar(AppTitleBar(AppUtils.getLocale()?.aboutToHelp ?? "")),
        backgroundColor: store.state.theme.body.background,
        body: AppScrollView(
            showBar: false,
            child: Column(children: <Widget>[
              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),

              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
            ])),
      );
    });
  }

}
