import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/dialog/app_custom_dialog.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class AppLocalizations extends StatefulWidget {
  final Widget child;

  const AppLocalizations({super.key, required this.child});

  @override
  State<AppLocalizations> createState() {
    return _AppLocalizations();
  }
}

class _AppLocalizations extends State<AppLocalizations> {
  late StreamSubscription _streamSubscription;

  @override
  Widget build(BuildContext context) {
    //初始化全局context
    WidgetUtils.gblBuildContext = context;
    AppCustomDialog.init(context);
    return StoreBuilder<GlobalState>(builder: (context, store) {
      ///通过 StoreBuilder 和 Localizations 实现实时多语言切换
      return Localizations.override(
        context: context,
        locale: store.state.locale,
        child: widget.child,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _streamSubscription = MessageEventBus.globalEventBus.on<MessageEvent>().listen((event) {
//      onHandleGlobalEvent(event.code, event.message);
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  onHandleGlobalEvent(int code, message) {
    switch (code) {
      case MessageCode.NETWORK_ERROR_401:
        ToastUtils.showToast(AppUtils.getLocale()?.networkError_401 ?? "");
        break;
      case MessageCode.NETWORK_ERROR_403:
        ToastUtils.showToast(AppUtils.getLocale()?.networkError_403 ?? "");
        break;
      case MessageCode.NETWORK_ERROR_404:
        ToastUtils.showToast(AppUtils.getLocale()?.networkError_404 ?? "");
        break;
      case MessageCode.NETWORK_TIMEOUT:
        ToastUtils.showToast(AppUtils.getLocale()?.networkErrorTimeout ?? "");
        break;
      case MessageCode.NETWORK_ERROR:
        ToastUtils.showToast(AppUtils.getLocale()?.networkError ?? "");
        break;
      default:
        ToastUtils.showToast("${AppUtils.getLocale()?.msgErrorUnknown}:$message");
        break;
    }
  }
}