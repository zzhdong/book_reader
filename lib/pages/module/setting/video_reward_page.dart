import 'dart:async';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/ad_manager.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_list_menu.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class VideoRewardPage extends StatefulWidget {
  const VideoRewardPage({super.key});

  @override
  _VideoRewardPageState createState() => _VideoRewardPageState();
}

class _VideoRewardPageState extends AppState<VideoRewardPage> {

  String _remainTime = "0小时";
  AdmobReward? _rewardAd;
  Timer? _timerRefresh;

  @override
  void initState() {
    super.initState();
    _reloadTime();
    _timerRefresh = Timer.periodic(const Duration(seconds: 60), (timer) => _reloadTime());
  }

  void _reloadTime(){
    DateTime lastTime = DateTime.fromMillisecondsSinceEpoch(AppParams.getInstance().getLastVideoReward());
    Duration duration = DateTime.now().difference(lastTime);
    if(duration.inDays == 0 && duration.inHours < AppConfig.VIDEO_REMOVE_AD_TIME){
      setState(() {
        _remainTime = "${AppConfig.VIDEO_REMOVE_AD_TIME - 1 - duration.inHours}小时${59 - duration.inMinutes % 60}分";
      });
    }
  }

  @override
  void dispose() {
    _timerRefresh?.cancel();
    _rewardAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(AppUtils.getLocale()?.settingMenuReward ?? "")),
        backgroundColor: store.state.theme.body.background,
        body: AppScrollView(
            showBar: false,
            child: Column(children: <Widget>[
              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
              AppTouchEvent(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Text(AppUtils.getLocale()?.rewardTime ?? "", overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 16.0, color: store.state.theme.listMenu.title, fontFamily: AppConfig.DEF_FONT_FAMILY))),
                      ),
                      Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Text(_remainTime, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold, color: store.state.theme.listMenu.title, fontFamily: AppConfig.DEF_FONT_FAMILY))),
                    ],
                  ),
                ),
              ),
              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
              AppTouchEvent(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(15, 20, 10, 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(AppUtils.getLocale()?.rewardDesc ?? "", style: TextStyle(fontSize: 16.0, color: store.state.theme.listMenu.title, fontFamily: AppConfig.DEF_FONT_FAMILY)),
                      ),
                    ],
                  ),
                ),
              ),
              AppTouchEvent(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(15, 0, 10, 20),
                  child: Row(
                    children: <Widget>[
                      Text(AppUtils.getLocale()?.rewardDescInfo1 ?? "", style: TextStyle(fontSize: 16.0, color: store.state.theme.listMenu.title, fontFamily: AppConfig.DEF_FONT_FAMILY)),
                      Text("${AppConfig.VIDEO_REMOVE_AD_TIME}", style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: store.state.theme.listMenu.title, fontFamily: AppConfig.DEF_FONT_FAMILY)),
                      Text(AppUtils.getLocale()?.rewardDescInfo2 ?? "", style: TextStyle(fontSize: 16.0, color: store.state.theme.listMenu.title, fontFamily: AppConfig.DEF_FONT_FAMILY)),
                    ],
                  ),
                ),
              ),
              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
              AppListMenu(AppUtils.getLocale()?.rewardButton ?? "",
                  icon: const Icon(IconData(0xe6c2, fontFamily: 'iconfont'), color: Color(0xff4ca9ec)),
                  subTitle: AppUtils.getLocale()?.rewardButtonView,
                  onPressed: () => _showVideoReward()),
            ])),
      );
    });
  }

  void _showVideoReward(){
    if(AppParams.getInstance().isVideoReward()){
      ToastUtils.showToast("已处于激励去广告中！");
      return;
    }
    ToolsPlugin.showLoading();
    _rewardAd = AdmobReward(
      adUnitId: AdManager.rewardedAdUnitId,
      listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
        print("激励视频加载结果：$event");
        switch (event) {
          case AdmobAdEvent.loaded:
            ToolsPlugin.hideLoading();
            _rewardAd?.show();
            break;
          case AdmobAdEvent.failedToLoad:
            ToolsPlugin.hideLoading();
            ToastUtils.showToast("获取激励视频失败，请稍后再试！");
            break;
          case AdmobAdEvent.rewarded:
            AppParams.getInstance().setLastVideoReward(DateTime.now().millisecondsSinceEpoch);
            _reloadTime();
            ToastUtils.showToast("成功获取去广告时长！");
            break;
          default:
        }
      },
    );
    _rewardAd?.load();
  }
}
