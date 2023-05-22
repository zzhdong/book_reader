
import 'dart:io';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:book_reader/pages/module/setting/about_disclaimer_page.dart';
import 'package:book_reader/pages/module/setting/about_privacy_page.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_list_menu.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends AppState<AboutPage> {

  final String _appName = "BookReader";
  String _versionCode = "";

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _versionCode = packageInfo.version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar:
        WidgetUtils.getDefaultTitleBar(AppTitleBar(AppUtils.getLocale()?.settingMenuBookAbout ?? "")),
        backgroundColor: store.state.theme.body.background,
        body: AppScrollView(
            showBar: false,
            child: Column(children: <Widget>[
              Container(margin: const EdgeInsets.fromLTRB(0, 30, 0, 0)),
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: const Image(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                  )
              ),
              Container(margin: const EdgeInsets.fromLTRB(0, 15, 0, 0)),
              Text(_appName, style: TextStyle(fontSize: 20, color: store.state.theme.body.fontColor, fontWeight: FontWeight.bold)),
              Container(margin: const EdgeInsets.fromLTRB(0, 5, 0, 0)),
              Text("Version $_versionCode", style: TextStyle(fontSize: 18, color: store.state.theme.body.fontColor)),
              Container(margin: const EdgeInsets.fromLTRB(0, 25, 0, 0)),
              AppListMenu(AppUtils.getLocale()?.aboutToShare ?? "",
                  icon: const Icon(IconData(0xe6be, fontFamily: 'iconfont'), color: Color(0xffc65259)),
                  onPressed: () => _toShare()),
//              AppListMenu(AppUtils.getLocale()?.aboutToHelp ?? "",
//                  icon: Icon(IconData(0xe6c1, fontFamily: 'iconfont'), color: Color(0xff4ca9ec)),
//                  subTitle: AppUtils.getLocale()?.msgView ?? "",
//                  onPressed: () => NavigatorUtils.changePage(context, AboutHelpPage())),
              AppListMenu(AppUtils.getLocale()?.aboutToPrivacy ?? "",
                  icon: const Icon(IconData(0xe6bf, fontFamily: 'iconfont'), color: Color(0xff5E6DB8)),
                  subTitle: AppUtils.getLocale()?.msgView,
                  onPressed: () => NavigatorUtils.changePage(context, const AboutPrivacyPage())),
              AppListMenu(AppUtils.getLocale()?.aboutToDisclaimer ?? "",
                  icon: const Icon(IconData(0xe6c0, fontFamily: 'iconfont'), color: Color(0xff46c68d)),
                  subTitle: AppUtils.getLocale()?.msgView,
                  onPressed: () => NavigatorUtils.changePage(context, const AboutDisclaimerPage())),
//              AppListMenu(AppUtils.getLocale()?.aboutToMe ?? "",
//                  icon: Icon(IconData(0xe6bb, fontFamily: 'iconfont'), color: Color(0xffEF9290)),
//                  subTitle: AppUtils.getLocale()?.msgView ?? "",
//                  onPressed: () => NavigatorUtils.changePage(context, AboutMePage())),
              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
            ])),
      );
    });
  }

  void _toShare() async{
    if (Platform.isIOS) {
      Clipboard.setData(const ClipboardData(text: "https://apps.apple.com/cn/app/id1520169333"));
      ToastUtils.showToast("下载链接已复制到剪切板！");
    }
  }
}
