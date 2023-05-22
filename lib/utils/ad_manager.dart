import 'dart:io';

class AdManager {

  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2487114308020672~7834660433";
    } else if (Platform.isIOS) {
      return "ca-app-pub-2487114308020672~3471731839";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  // 横幅-用于阅读页
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2487114308020672/2458759415";
    } else if (Platform.isIOS) {
      return "ca-app-pub-2487114308020672/7131296319";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  // 插屏-用于启动页
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2487114308020672/8257881002";
    } else if (Platform.isIOS) {
      return "ca-app-pub-2487114308020672/5670627564";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  // 激励视频
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2487114308020672/6944799333";
    } else if (Platform.isIOS) {
      return "ca-app-pub-2487114308020672/5495329757";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}