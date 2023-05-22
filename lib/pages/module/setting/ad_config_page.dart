import 'package:flutter/cupertino.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_list_menu.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class AdConfigPage extends StatefulWidget {
  const AdConfigPage({super.key});

  @override
  _AdConfigPageState createState() => _AdConfigPageState();
}

class _AdConfigPageState extends AppState<AdConfigPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(AppUtils.getLocale()?.adConfig ?? "")),
        backgroundColor: store.state.theme.body.background,
        body: AppScrollView(
            showBar: false,
            child: Column(children: <Widget>[
              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
              AppListMenu(
                AppUtils.getLocale()?.adConfigOpen ?? "",
                icon: const Icon(IconData(0xe6bd, fontFamily: 'iconfont'), color: Color(0xff4ca9ec)),
                customWidget: CupertinoSwitch(
                  value: AppParams.getInstance().getOpenAd(),
                  onChanged: (bool value) {
                    setState(() {
                      AppParams.getInstance().setOpenAd(value);
                    });
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
            ])),
      );
    });
  }
}
