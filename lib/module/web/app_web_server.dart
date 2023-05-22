import 'dart:io';

import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/module/web/app_web_socket_server.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/utils/string_utils.dart';

class AppWebServer {
  static bool isRunning = false;
  //HTTP服务
  static HttpServer? _httpServer;
  //WebSocket服务
  static HttpServer? _webSocketHttpServer;
  //用于处理书源调试
  static AppWebSocketServer? _appWebSocketServer;

  static Future startServer() async {
    if (isRunning) return;
    if (_httpServer != null) {
      await _httpServer?.close(force: true);
    }
    if (_appWebSocketServer != null) {
      await _appWebSocketServer?.stop(_webSocketHttpServer!);
    }
    String ipAddr = await ToolsPlugin.getIpAddress();
    if (StringUtils.isNotEmpty(ipAddr)) {
      try {
        // 启动HTTP服务
        _httpServer = await HttpServer.bind(ipAddr, AppParams.getInstance().getWebPort());
        //启动WebSocket服务
        _webSocketHttpServer = await HttpServer.bind(ipAddr, AppParams.getInstance().getWebPort() + 1);
        _appWebSocketServer = AppWebSocketServer(_webSocketHttpServer!, 1000 * 30);
        isRunning = true;
      } catch (error) {
        print(error);
        stopServer();
      }
    } else {
      stopServer();
    }
  }

  static Future stopServer() async{
    isRunning = false;
    await _httpServer?.close(force: true);
    if (_webSocketHttpServer != null) {
      await _appWebSocketServer?.stop(_webSocketHttpServer!);
    }
  }
}
