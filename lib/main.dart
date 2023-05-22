import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_indicator/home_indicator.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/theme_dark.dart';
import 'package:book_reader/common/theme_default.dart';
import 'package:book_reader/localizations/app_localizations_delegate.dart';
import 'package:book_reader/localizations/fallback_cupertino_localisations_delegate.dart';
import 'package:book_reader/pages/home_page.dart';
import 'package:book_reader/pages/welcome_page.dart';
import 'package:book_reader/plugin/device_plugin.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_localizations.dart';
import 'package:redux/redux.dart';

///程序启动引导页
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await AppUtils.initSystemInfo();
  // 显示状态栏
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  // 显示iPhoneX底部横条
  HomeIndicator.show();
  // 取消屏幕常亮
  DevicePlugin.keepOn(false);
  // 初始化广告平台
  Admob.initialize();
  // 启动强制竖屏
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(MainApp());
    PaintingBinding.instance.imageCache.maximumSize = 100;
  });
}

class MainApp extends StatelessWidget {
  /// 创建Store，引用 GlobalState 中的 appReducer 实现 Reducer 方法
  /// initialState 初始化 State
  final store = Store<GlobalState>(
    appReducer,

    ///初始化数据
    initialState: GlobalState(theme: AppUtils.getAppTheme(1), locale: const Locale('zh', 'CH')),
  );

  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 预加载图片
    precacheImage(const AssetImage("assets/images/splash.png"), context);
    /// 通过 StoreProvider 应用 store
    return StoreProvider(
      store: store,
      child: StoreBuilder<GlobalState>(builder: (context, store) {
        WidgetUtils.gblStore = store;
        return MaterialApp(
            debugShowCheckedModeBanner: false, //隐藏右上角debug图标
            //多语言实现代理
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              AppLocalizationsDelegate.delegate,
              const FallbackCupertinoLocalisationsDelegate(), //加入这个, 防止CupertinoAlertDialog出错
            ],
            locale: store.state.locale,
            supportedLocales: [store.state.locale],
            theme: AppParams.getInstance().getAppTheme() == 2 ? ThemeDark.globalTheme : ThemeDefault.globalTheme,
            routes: {
              WelcomePage.name: (context) {
                store.state.platformLocale = Localizations.localeOf(context);
                return const WelcomePage();
              },
            },
            //在routes中根据路由名称找不到路由的时候，则使用这里进行路由跳转
            onGenerateRoute: (RouteSettings setting) {
              //setting.isInitialRoute; bool类型 是否初始路由
              //setting.name; 要跳转的路由名key
              return PageRouteBuilder(
                  pageBuilder: (BuildContext context, _, __) {
                    return const AppLocalizations(
                      child: HomePage(),
                    );
                  },
                  opaque: false,
                  //跳转动画
                  transitionDuration: const Duration(milliseconds: 1000),
                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ));
            });
      }),
    );
  }
}
