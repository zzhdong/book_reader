import 'dart:async';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/ad_manager.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:flutter/material.dart';

///欢迎页
class WelcomePage extends StatefulWidget {
  static const String name = "/";

  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  final AssetImage _splashImage = const AssetImage('assets/images/splash.png');

  // 插屏广告
  late AdmobInterstitial _interstitialAd;
  late Timer _toHomeTimer;

  @override
  void initState() {
    super.initState();
    _initSystem();
  }

  void _initSystem() async{
    //判断网络是否可用
    if(AppParams.getInstance().getOpenAd() && !AppParams.getInstance().isVideoReward() && await (Connectivity().checkConnectivity()) != ConnectivityResult.none){
      //开启广告静音
      await ToolsPlugin.setAdMuted();
      //添加插屏广告
      _interstitialAd = AdmobInterstitial(
        adUnitId: AdManager.interstitialAdUnitId,
        listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
          _onInterstitialAdEvent(event);
        },
      );
      _interstitialAd.load();
      // 一段时间都没有加载广告，则直接进入主界面
      _toHomeTimer = Timer(const Duration(seconds: 3), () => NavigatorUtils.goHome(context));
    }else{
      Future.delayed(const Duration(milliseconds: 1000), () {
        NavigatorUtils.goHome(context);
      });
    }
  }

  void _onInterstitialAdEvent(AdmobAdEvent event) async{
    switch (event) {
      case AdmobAdEvent.loaded:
        _toHomeTimer.cancel();
        NavigatorUtils.goHome(context);
        //广告加载成功，则显示广告，同时跳转到主页
        _interstitialAd.show();
        //关闭广告静音
        //await ToolsPlugin.setAdUnMuted();
        break;
      case AdmobAdEvent.opened:
        break;
      case AdmobAdEvent.closed:
        break;
      case AdmobAdEvent.failedToLoad:
        _toHomeTimer.cancel();
        //广告加载失败，延迟跳转到主页
        Future.delayed(const Duration(milliseconds: 1000), () {
          NavigatorUtils.goHome(context);
        });
        break;
      case AdmobAdEvent.rewarded:
        break;
      default:
    }
  }

  @override
  void dispose() {
    //关闭广告
    _interstitialAd.dispose();
    _toHomeTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(
      builder: (context, store) {
        return Scaffold(
          body: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: Image(
              image: _splashImage,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
