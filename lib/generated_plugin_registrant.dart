//
// Generated file. Do not edit.
//

// ignore_for_file: lines_longer_than_80_chars

//import 'package:connectivity_for_web/connectivity_for_web.dart';
//import 'package:file_picker/src/file_picker_web.dart';
import 'package:flutter_tts/flutter_tts_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
//import 'package:video_player_web/video_player_web.dart';
//import 'package:wakelock_web/wakelock_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  //ConnectivityPlugin.registerWith(registrar);
  //FilePickerWeb.registerWith(registrar);
  FlutterTtsPlugin.registerWith(registrar);
  SharedPreferencesPlugin.registerWith(registrar);
  UrlLauncherPlugin.registerWith(registrar);
  //VideoPlayerPlugin.registerWith(registrar);
  //WakelockWeb.registerWith(registrar);
  registrar.registerMessageHandler();
}
