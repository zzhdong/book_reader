
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class BookBackupPage extends StatefulWidget {
  const BookBackupPage({super.key});

  @override
  _BookBackupPageState createState() => _BookBackupPageState();
}

class _BookBackupPageState extends AppState<BookBackupPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(AppUtils.getLocale()?.settingMenuBookBackup ?? "")),
        backgroundColor: store.state.theme.body.background,
        body: const Text(""),
      );
    });
  }

}
