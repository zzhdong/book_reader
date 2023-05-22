import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/module/web/app_web_server.dart';
import 'package:book_reader/plugin/device_plugin.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class WebServerPage extends StatefulWidget {
  const WebServerPage({super.key});

  @override
  _WebServerPageState createState() => _WebServerPageState();
}

class _WebServerPageState extends AppState<WebServerPage> {
  String _addr = "";
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    DevicePlugin.keepOn(true);
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.wifi) {
        _startOrStop();
      }
    });
  }

  @override
  void dispose() async {
    DevicePlugin.keepOn(false);
    AppWebServer.stopServer();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _startOrStop() async {
    if (!AppWebServer.isRunning) {
      var connectivityResult = await (_connectivity.checkConnectivity());
      if (connectivityResult != ConnectivityResult.wifi) {
        ToastUtils.showToast("请切换到WIFI后再启动服务！");
        return;
      }
    }
    if (AppWebServer.isRunning) {
      await AppWebServer.stopServer();
      _addr = "";
    } else {
      await AppWebServer.startServer();
      _addr = "http://${await ToolsPlugin.getIpAddress()}:${AppParams.getInstance().getWebPort()}/";
      if (!AppWebServer.isRunning) {
        ToastUtils.showToast("启动WEB服务失败！");
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(AppUtils.getLocale()?.webServerTitle ?? ""), backgroundColor: const Color(0xff696d70), elevation: 0),
        backgroundColor: store.state.theme.body.background,
        body: Column(children: <Widget>[
          Container(
            color: const Color(0xff696d70),
            alignment: Alignment.center,
            child: const Icon(IconData(0xe6ae, fontFamily: 'iconfont'), color: Colors.white, size: 160),
          ),
          Container(
            color: const Color(0xff696d70),
            alignment: Alignment.center,
            height: 25,
            child: Text(AppWebServer.isRunning ? AppUtils.getLocale()?.webServerInfo1 ?? "" : AppUtils.getLocale()?.webServerInfo4 ?? "", style: TextStyle(color: Colors.white, fontSize: AppWebServer.isRunning ? 18 : 16)),
          ),
          Container(
            color: const Color(0xff696d70),
            alignment: Alignment.center,
            child: Text(AppWebServer.isRunning ? AppUtils.getLocale()?.webServerInfo2 ?? "" : "", style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          Container(
            color: const Color(0xff696d70),
            height: 20,
          ),
          Expanded(
            child: Visibility(
                visible: AppWebServer.isRunning,
                child: Column(children: <Widget>[
                  Container(height: 60),
                  Container(
                    alignment: Alignment.center,
                    child: Text(AppUtils.getLocale()?.webServerInfo3 ?? "", style: TextStyle(color: WidgetUtils.gblStore?.state.theme.body.inputText.withOpacity(0.9), fontSize: 16)),
                  ),
                  Container(height: 20),
                  Container(
                    alignment: Alignment.center,
                    width: 260,
                    height: 40,
                    decoration: BoxDecoration(
                      color: WidgetUtils.gblStore?.state.theme.body.inputText.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(_addr, style: TextStyle(color: WidgetUtils.gblStore?.state.theme.body.inputTextHigh, fontSize: 14)),
                  ),
                ])),
          ),
          AppTouchEvent(
            isTransparent: true,
            child: Container(
                alignment: Alignment.center,
                width: 260,
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: WidgetUtils.gblStore!.state.theme.body.inputTextBorder),
                  color: WidgetUtils.gblStore?.state.theme.body.inputBackground,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  Icon(IconData(AppWebServer.isRunning ? 0xe68c : 0xe699, fontFamily: 'iconfont'), color: WidgetUtils.gblStore?.state.theme.body.inputText.withOpacity(0.7), size: 20),
                  Container(width: 10),
                  Text(AppWebServer.isRunning ? AppUtils.getLocale()?.webServerStop ?? "" : AppUtils.getLocale()?.webServerStart ?? "", style: TextStyle(color: WidgetUtils.gblStore?.state.theme.body.inputText, fontSize: 14)),
                ])),
            onTap: () => _startOrStop(),
          ),
          Container(height: 70),
        ]),
      );
    });
  }
}
