import 'dart:async';
import 'dart:io';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/pages/module/setting/about_page.dart';
import 'package:book_reader/pages/module/setting/ad_config_page.dart';
import 'package:book_reader/pages/module/setting/book_cache_page.dart';
import 'package:book_reader/pages/module/setting/book_download_page.dart';
import 'package:book_reader/pages/module/setting/book_filter_page.dart';
import 'package:book_reader/pages/module/setting/book_other_setting_page.dart';
import 'package:book_reader/pages/module/setting/book_source_page.dart';
import 'package:book_reader/pages/module/setting/book_thread_page.dart';
import 'package:book_reader/pages/menu/menu_dict.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/dict_utils.dart';
import 'package:book_reader/utils/file_utils.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_list_menu.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'module/setting/video_reward_page.dart';

class TabPage3 extends StatefulWidget {
  const TabPage3({super.key});

  @override
  _TabPage3State createState() => _TabPage3State();
}

class _TabPage3State extends AppState<TabPage3> {
  String _versionCode = "";
  String _cacheNum = "0M";
  int _totalClickCount = 0;
  late Timer _resetClick;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _versionCode = "v${packageInfo.version}";
      });
    });
    //获取所有网络缓存
    _getNetworkCache();
  }

  void _getNetworkCache() async{
    Directory tempDir = await getTemporaryDirectory();
    _cacheNum = FileUtils.formatMb(FileUtils.getTotalSizeOfFilesInDir(tempDir));
    setState(() {});
  }

  void _clearCache() async {
    var appDir = (await getTemporaryDirectory()).path;
    Directory(appDir).delete(recursive: true);
    Future.delayed(const Duration(milliseconds: 1000), (){
      _getNetworkCache();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return CupertinoScaffold(
          body: Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar((AppUtils.getLocale()?.homeTab_3 ?? ""), showLeftBtn: false)),
        backgroundColor: store.state.theme.body.background,
        body: AppScrollView(
            showBar: false,
            child: Column(children: <Widget>[
              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
              AppListMenu(AppUtils.getLocale()?.settingMenuBookSource ?? "",
                  icon: const Icon(IconData(0xe663, fontFamily: 'iconfont'), color: Color(0xff4ca9ec)),
                  subTitle: AppUtils.getLocale()?.msgView,
                  onPressed: () => NavigatorUtils.changePage(context, const BookSourcePage())),
              AppListMenu(AppUtils.getLocale()?.settingMenuBookFilter ?? "",
                  icon: const Icon(IconData(0xe665, fontFamily: 'iconfont'), color: Color(0xff5E6DB8)),
                  subTitle: AppUtils.getLocale()?.msgView,
                  onPressed: () => NavigatorUtils.changePage(context, const BookFilterPage())),
              AppListMenu(AppUtils.getLocale()?.settingMenuBookThread ?? "",
                  icon: const Icon(IconData(0xe666, fontFamily: 'iconfont'), color: Color(0xff46c68d)),
                  subTitle: AppUtils.getLocale()?.msgView,
                  onPressed: () => NavigatorUtils.changePage(context, const BookThreadPage())),
              AppListMenu(AppUtils.getLocale()?.settingMenuBookDownload ?? "",
                  icon: const Icon(IconData(0xe691, fontFamily: 'iconfont'), color: Color(0xff5E6DB8)),
                  subTitle: AppUtils.getLocale()?.msgView,
                  onPressed: () => NavigatorUtils.changePage(context, const BookDownloadPage())),
              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
              AppListMenu(AppUtils.getLocale()?.settingMenuReward ?? "",
                  icon: const Icon(IconData(0xe6c2, fontFamily: 'iconfont'), color: Color(0xff46c68d)),
                  subTitle: AppUtils.getLocale()?.msgView,
                  onPressed: () => NavigatorUtils.changePage(context, const VideoRewardPage())),
              AppListMenu(AppUtils.getLocale()?.settingMenuBookTheme ?? "",
                  icon: const Icon(IconData(0xe628, fontFamily: 'iconfont'), color: Color(0xffc65259)),
                  subTitle: DictUtils.getDictValue(
                      DictUtils.getThemeDictList(), AppParams.getInstance().getAppTheme().toString()), onPressed: () {
                    showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          MenuDict(dictTitle: AppUtils.getLocale()?.dictThemeTitle ?? "", dictList: DictUtils.getThemeDictList(), onPress: (value){
                            if(AppParams.getInstance().getAppTheme() != StringUtils.stringToInt(value, def: 1)){
                              AppParams.getInstance().setAppTheme(StringUtils.stringToInt(value, def: 1));
                              BookParams.getInstance().setDayTheme();
                              AppUtils.updateAppTheme();
                              setState(() {});
                            }
                          }),
                    );
              }),
              AppListMenu(AppUtils.getLocale()?.settingMenuBookLanguage ?? "",
                  icon: const Icon(IconData(0xe658, fontFamily: 'iconfont'), color: Color(0xff4ca9ec)),
                  subTitle: DictUtils.getDictValue(
                      DictUtils.getLocaleDictList(), AppParams.getInstance().getLocaleLanguage().toString()),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          MenuDict(dictTitle: AppUtils.getLocale()?.dictLocaleTitle ?? "", dictList: DictUtils.getLocaleDictList(), onPress: (value){
                            if(AppParams.getInstance().getLocaleLanguage() != StringUtils.stringToInt(value, def: 1)){
                              AppParams.getInstance().setLocaleLanguage(StringUtils.stringToInt(value, def: 1));
                              AppUtils.updateAppLocale();
                              setState(() {});
                            }
                          }),
                    );
              }),
              AppListMenu(AppUtils.getLocale()?.settingMenuOther ?? "",
                  icon: const Icon(IconData(0xe645, fontFamily: 'iconfont'), color: Color(0xff46c68d)),
                  subTitle: AppUtils.getLocale()?.msgView,
                  onPressed: () => NavigatorUtils.changePage(context, const BookOtherSettingPage())),
              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
              AppListMenu(AppUtils.getLocale()?.settingMenuBookCache ?? "",
                  icon: const Icon(
                    IconData(0xe6a5, fontFamily: 'iconfont'),
                    color: Color(0xffEF9290),
                    size: 20,
                  ),
                  subTitle: AppUtils.getLocale()?.msgView,
                  onPressed: () => NavigatorUtils.changePage(context, const BookCachePage())),
              AppListMenu(AppUtils.getLocale()?.settingMenuNetworkCache ?? "",
                  icon: const Icon(IconData(0xe62a, fontFamily: 'iconfont'), color: Color(0xff4ca9ec)),
                  subTitle: _cacheNum,
                  onPressed: (){
                    WidgetUtils.showAlert(AppUtils.getLocale()?.msgClearNetworkCache ?? "", onRightPressed: (){
                      _clearCache();
                    });
              }),
//              AppListMenu(AppUtils.getLocale()?.settingMenuBookBackup,
//                  icon: Icon(IconData(0xe670, fontFamily: 'iconfont'), color: Color(0xff5E6DB8)),
//                  subTitle: AppUtils.getLocale()?.msgView,
//                  onPressed: () => NavigatorUtils.changePage(context, BookBackupPage())),
              AppListMenu(AppUtils.getLocale()?.settingMenuBookAbout ?? "",
                  icon: const Icon(IconData(0xe6bb, fontFamily: 'iconfont'), color: Color(0xffc65259)),
                  subTitle: AppUtils.getLocale()?.msgView,
                  onPressed: () => NavigatorUtils.changePage(context, const AboutPage())),
              AppListMenu(AppUtils.getLocale()?.settingMenuVersion ?? "", showArrow: false,
                  icon: const Icon(IconData(0xe6bc, fontFamily: 'iconfont'), color: Color(0xff6bccec)),
                  subTitle: _versionCode,
                  onPressed:(){
                    if(_totalClickCount == 0){
                      _resetClick = Timer(const Duration(seconds: 10), () {
                        _totalClickCount = 0;
                      });
                    }
                    _totalClickCount++;
                    if(_totalClickCount > 20){
                      _resetClick.cancel();
                      _totalClickCount = 0;
                      NavigatorUtils.changePage(context, const AdConfigPage());
                    }
                  }),
              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
            ])),
      ));
    });
  }
}
