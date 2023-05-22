import 'package:flutter/material.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_dashed_rect.dart';
import 'package:book_reader/widget/app_touch_event.dart';

class MenuNotice extends StatefulWidget {
  final Function? onPress;

  const MenuNotice({super.key, this.onPress});

  @override
  MenuNoticeStatus createState() => MenuNoticeStatus();
}

class MenuNoticeStatus extends State<MenuNotice> {
  @override
  Widget build(BuildContext context) {
    if (BookParams.getInstance().getIsFirstRead()) {
      return AnimatedPositioned(
        curve: Curves.fastLinearToSlowEaseIn,
        duration: const Duration(milliseconds: 1000),
        width: ScreenUtils.getScreenWidth(),
        height: ScreenUtils.getScreenHeight() + ScreenUtils.getViewPaddingBottom(),
        child: AppTouchEvent(
            isTransparent: true,
            onTap: () {
              WidgetUtils.showAlert(AppUtils.getLocale()?.readMenuNoticeInfo ?? "",
                  leftBtnText: AppUtils.getLocale()?.readMenuNoticeBtn1 ?? "",
                  rightBtnText: AppUtils.getLocale()?.readMenuNoticeBtn2 ?? "", onLeftPressed: () {
                BookParams.getInstance().setIsFirstRead(false);
                setState(() {});
              });
            },
            child: Container(
                color: const Color.fromRGBO(0, 0, 0, 0.5),
                padding: EdgeInsets.only(bottom: ScreenUtils.getViewPaddingBottom()),
                child: Row(
                  children: [
                    SizedBox(
                      width: BookParams.getInstance().getClickLeftArea(),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                        const Icon(IconData(0xe69d, fontFamily: 'iconfont'), color: Colors.white, size: 26),
                        Container(height: 15),
                        Text(
                            BookParams.getInstance().getClickAllNext()
                                ? AppUtils.getLocale()?.readMenuNotice3 ?? ""
                                : AppUtils.getLocale()?.readMenuNotice1 ?? "",
                            style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ]),
                    ),
                    SizedBox(
                      height: ScreenUtils.getScreenHeight(),
                      child: AppDashedRect(color: Colors.white),
                    ),
                    Expanded(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                        const Icon(IconData(0xe687, fontFamily: 'iconfont'), color: Colors.white, size: 26),
                        Container(height: 15),
                        Text(AppUtils.getLocale()?.readMenuNotice2 ?? "", style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ]),
                    ),
                    SizedBox(
                      height: ScreenUtils.getScreenHeight(),
                      child: AppDashedRect(color: Colors.white),
                    ),
                    SizedBox(
                      width: BookParams.getInstance().getClickRightArea(),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                        const Icon(IconData(0xe6a1, fontFamily: 'iconfont'), color: Colors.white, size: 26),
                        Container(height: 15),
                        Text(AppUtils.getLocale()?.readMenuNotice3 ?? "", style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ]),
                    ),
                  ],
                ))),
      );
    } else {
      return Container();
    }
  }
}
