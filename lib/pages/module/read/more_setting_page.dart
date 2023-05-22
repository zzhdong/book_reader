import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_indicator/home_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/pages/menu/menu_dict.dart';
import 'package:book_reader/plugin/device_plugin.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/dict_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_list_menu.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';

class MoreSettingPage extends StatefulWidget {
  const MoreSettingPage({super.key});

  @override
  _MoreSettingPageState createState() => _MoreSettingPageState();
}

class _MoreSettingPageState extends AppState<MoreSettingPage> {
  final List<Map<String, String>> _boldList = [];

  @override
  void initState() {
    super.initState();
    for (int i = 1; i < 10; i++) {
      _boldList.add({"ID": i.toString(), "NAME": i.toString()});
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(AppUtils.getLocale()?.bookMoreSettingTitle ?? "")),
        backgroundColor: store.state.theme.body.background,
        body: AppScrollView(
            showBar: false,
            child: Column(children: <Widget>[
              AppListMenu(AppUtils.getLocale()?.bookMoreSettingBold ?? "",
                  subTitle: DictUtils.getDictValue(_boldList, BookParams.getInstance().getTextBold().toString()),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          MenuDict(dictTitle: AppUtils.getLocale()?.bookMoreSettingBold ?? "", dictList: _boldList, onPress: (value){
                            setState(() {
                              BookParams.getInstance().setTextBold(StringUtils.stringToInt(value, def: 4));
                            });
                            Future.delayed(const Duration(milliseconds: 600), ()=>MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_READ_UPDATE_UI, ""));
                          }),
                    );
              }),
              AppListMenu(AppUtils.getLocale()?.bookMoreSettingIndent ?? "",
                  subTitle: DictUtils.getDictValue(
                      DictUtils.getBookIndentList(), BookParams.getInstance().getIndent().toString()), onPressed: () {
                    showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          MenuDict(dictTitle: AppUtils.getLocale()?.bookMoreSettingIndent ?? "", dictList: DictUtils.getBookIndentList(), onPress: (value){
                            setState(() {
                              BookParams.getInstance().setIndent(StringUtils.stringToInt(value, def: 2));
                            });
                            Future.delayed(const Duration(milliseconds: 600), ()=>MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_READ_UPDATE_UI, ""));
                          }),
                    );
              }),
              AppListMenu(
                AppUtils.getLocale()?.bookMoreSettingTimeout ?? "",
                customWidget: CupertinoSwitch(
                  value: BookParams.getInstance().getCanLockScreen(),
                  onChanged: (bool value) {
                    setState(() {
                      BookParams.getInstance().setCanLockScreen(value);
                      DevicePlugin.keepOn(value);
                    });
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
              ScreenUtils.isIPhoneX()
                  ? AppListMenu(
                      AppUtils.getLocale()?.bookMoreSettingHomeIndicator ?? "",
                      customWidget: CupertinoSwitch(
                        value: BookParams.getInstance().getHideHomeIndicator(),
                        onChanged: (bool value) {
                          setState(() {
                            BookParams.getInstance().setHideHomeIndicator(value);
                            if (value) {
                              HomeIndicator.hide();
                            } else {
                              HomeIndicator.show();
                            }
                          });
                        },
                        activeColor: store.state.theme.primary,
                      ),
                    )
                  : Container(),
              AppListMenu(
                AppUtils.getLocale()?.bookMoreSettingShowTitle ?? "",
                customWidget: CupertinoSwitch(
                  value: BookParams.getInstance().getShowTitle(),
                  onChanged: (bool value) {
                    setState(() {
                      BookParams.getInstance().setShowTitle(value);
                    });
                    Future.delayed(const Duration(milliseconds: 600), ()=>MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_READ_UPDATE_UI, ""));
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
              AppListMenu(
                AppUtils.getLocale()?.bookMoreSettingShowTime ?? "",
                customWidget: CupertinoSwitch(
                  value: BookParams.getInstance().getShowTime(),
                  onChanged: (bool value) {
                    setState(() {
                      BookParams.getInstance().setShowTime(value);
                    });
                    Future.delayed(const Duration(milliseconds: 600), ()=>MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_READ_UPDATE_UI, ""));
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
              AppListMenu(
                AppUtils.getLocale()?.bookMoreSettingShowBattery ?? "",
                customWidget: CupertinoSwitch(
                  value: BookParams.getInstance().getShowBattery(),
                  onChanged: (bool value) {
                    setState(() {
                      BookParams.getInstance().setShowBattery(value);
                    });
                    Future.delayed(const Duration(milliseconds: 600), ()=>MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_READ_UPDATE_UI, ""));
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
              AppListMenu(
                AppUtils.getLocale()?.bookMoreSettingShowPage ?? "",
                customWidget: CupertinoSwitch(
                  value: BookParams.getInstance().getShowPage(),
                  onChanged: (bool value) {
                    setState(() {
                      BookParams.getInstance().setShowPage(value);
                    });
                    Future.delayed(const Duration(milliseconds: 600), ()=>MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_READ_UPDATE_UI, ""));
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
              AppListMenu(
                AppUtils.getLocale()?.bookMoreSettingShowProcess ?? "",
                customWidget: CupertinoSwitch(
                  value: BookParams.getInstance().getShowProcess(),
                  onChanged: (bool value) {
                    setState(() {
                      BookParams.getInstance().setShowProcess(value);
                    });
                    Future.delayed(const Duration(milliseconds: 600), ()=>MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_READ_UPDATE_UI, ""));
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
              AppListMenu(
                AppUtils.getLocale()?.bookMoreSettingShowChapterIndex ?? "",
                customWidget: CupertinoSwitch(
                  value: BookParams.getInstance().getShowChapterIndex(),
                  onChanged: (bool value) {
                    setState(() {
                      BookParams.getInstance().setShowChapterIndex(value);
                    });
                    Future.delayed(const Duration(milliseconds: 600), ()=>MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_READ_UPDATE_UI, ""));
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
            ])),
      );
    });
  }
}
