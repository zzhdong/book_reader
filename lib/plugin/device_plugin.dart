
import 'dart:async';

import 'package:flutter/services.dart';

class DevicePlugin {

  static const MethodChannel _channel = MethodChannel('device_plugin');

  static Future<double> get brightness async => (await _channel.invokeMethod('brightness')) as double;

  static Future<void> setBrightness(double brightness) =>_channel.invokeMethod('setBrightness',{"brightness" : brightness});

  static Future<bool> get isKeptOn async => (await _channel.invokeMethod('isKeptOn')) as bool;

  static Future<void> keepOn(bool on) => _channel.invokeMethod('keepOn', {"on" : on});

  static Future<bool> encodingIsUtf8(String filePath) async => (await _channel.invokeMethod('encodingIsUtf8', {"filePath" : filePath})) as bool;

  static Future<bool> writeFileByEncode(String filePath, String encode) async => (await _channel.invokeMethod('writeFileByEncode', {"filePath" : filePath, "encode" : encode})) as bool;
}