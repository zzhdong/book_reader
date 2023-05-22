import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/dict_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

//自动翻页设置界面
class MenuBottomReadAloud extends StatefulWidget {
  final BookModel bookModel;

  final List<BookChapterModel> chapterModelList;

  final Function? onPress;

  const MenuBottomReadAloud(this.bookModel, this.chapterModelList, {super.key, this.onPress});

  @override
  MenuBottomReadAloudStatus createState() => MenuBottomReadAloudStatus();
}

class MenuBottomReadAloudStatus extends State<MenuBottomReadAloud> {
  FlutterTts flutterTts = FlutterTts();
  double _bottomWidgetHeight = -(210 + ScreenUtils.getViewPaddingBottom());
  bool _isRunning = false;
  bool _isExist = true;
  int _paragraphLength = 1;
  String _currentSpeak = "";
  bool _isInit = true;
  Timer? _countdownTimer;
  int _currentSecond = 0;

  @override
  void initState() {
    super.initState();
    //初始化阅读速度和语言
    flutterTts.setSpeechRate(BookParams.getInstance().getReadAloudRate().toDouble() / 10);
    flutterTts.setLanguage(BookParams.getInstance().getReadAloudVoiceType());
    //TTS监听事件
    flutterTts.setCompletionHandler(() {
      print("############## TTS Completion ############");
      _paragraphLength += _currentSpeak.length;
      if(widget.onPress != null) widget.onPress!("StartReadAloud", [_isInit, _paragraphLength]);
    });
    flutterTts.setErrorHandler((msg) {
      print("############## TTS Error ############");
      stopPlay();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  bool getIsExist() => _isExist;

  void toggleMenu() {
    setState(() {
      _bottomWidgetHeight = _bottomWidgetHeight == 0 ? -(210 + ScreenUtils.getViewPaddingBottom()) : 0;
      if (isDisplay()) _isExist = false;
    });
  }

  bool isDisplay() {
    return _bottomWidgetHeight == 0;
  }

  //开始播放
  void startPlay(String content){
    print("当前朗读内容：$content");
    _currentSpeak = content;
    if(StringUtils.isNotEmpty(content)) {
      flutterTts.speak(content);
    }
    else {
      stopPlay();
    }
  }

  //停止播放
  void stopPlay(){
    _isRunning = false;
    flutterTts.stop();
    setState(() {});
  }

  //重置播放索引
  void resetPlayIndex(bool restart){
    _paragraphLength = 1;
    _currentSpeak = "";
    _isInit = true;
    if(restart) {
      if (widget.onPress != null) {
        widget.onPress!("StartReadAloud", [_isInit, _paragraphLength]);
      }
    }
  }

  //启动定时器
  void _startCountdownTimer() {
    _currentSecond = BookParams.getInstance().getReadAloudTiming() * 60;
    _countdownTimer?.cancel();
    callback(timer) => {
      setState(() {
        if (_currentSecond < 1) {
          _countdownTimer?.cancel();
          stopPlay();
        } else {
          _currentSecond = _currentSecond - 1;
        }
      })
    };
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), callback);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.fastLinearToSlowEaseIn,
      duration: const Duration(milliseconds: 1000),
      bottom: _bottomWidgetHeight,
      width: ScreenUtils.getScreenWidth(),
      child: getReadBottomMenu(widget.bookModel, onClick: (String key, List<dynamic> valueList) {
        if (key == "OnChangeEnd") {
          stopPlay();
          flutterTts.setSpeechRate(BookParams.getInstance().getReadAloudRate().toDouble() / 10);
        } else if (key == "ReadAloudIsLocal") {
          if(valueList[0] as bool){
            BookParams.getInstance().setReadAloudIsLocal(valueList[0] as bool);
            WidgetUtils.showActionSheet(AppUtils.getLocale()?.readMenuReadAloudLocal ?? "", DictUtils.getLocalReadAloudList(), (value) {
              BookParams.getInstance().setReadAloudVoiceType(value);
              flutterTts.setLanguage(value);
              stopPlay();
            });
            setState(() {});
          }else{
            ToastUtils.showToast(AppUtils.getLocale()?.readMenuReadAloudNotSupport ?? "");
          }
        } else if (key == "ReadAloudTiming") {
          int type = valueList[0] as int;
          BookParams.getInstance().setReadAloudTimingType(type);
          if (type == 1) {
            BookParams.getInstance().setReadAloudTiming(15);
          } else if (type == 2) {
            BookParams.getInstance().setReadAloudTiming(30);
          } else if (type == 3) {
            BookParams.getInstance().setReadAloudTiming(60);
          } else {
            List<Map<String, String>> tmpList = [];
            for (int i = 1; i < 121; i++) {
              tmpList.add({"ID": i.toString(), "NAME": "$i${AppUtils.getLocale()?.readMenuReadAloudMinute}"});
            }
            WidgetUtils.showActionSheet(AppUtils.getLocale()?.readMenuReadAloudChoose ?? "", tmpList, (value) {
              BookParams.getInstance().setReadAloudTiming(StringUtils.stringToInt(value));
              stopPlay();
            });
          }
          setState(() {});
        } else if (key == "ExitReadAloud") {
          resetPlayIndex(false);
          stopPlay();
          _isExist = true;
          toggleMenu();
          if(widget.onPress != null) widget.onPress!("ExitReadAloud", []);
        } else if (key == "StartReadAloud") {
          _isRunning = !_isRunning;
          if(_isRunning){
            _startCountdownTimer();
            if(widget.onPress != null) widget.onPress!("StartReadAloud", [_isInit, _paragraphLength]);
            _isInit = false;
          }
          else {
            stopPlay();
          }
          setState(() {});
        }
      }),
    );
  }

//底部菜单栏
  Widget getReadBottomMenu(final BookModel bookModel, {Function? onClick}) {
    return Container(
        height: (210 + ScreenUtils.getViewPaddingBottom()),
        color: const Color.fromRGBO(0, 0, 0, 0.8),
        padding: EdgeInsets.only(bottom: ScreenUtils.getViewPaddingBottom()),
        child: Column(
          children: [
            Container(height: 9),
            Row(children: <Widget>[
              Container(width: 14),
              Text("${AppUtils.getLocale()?.readMenuReadAloudRate}：",
                  style: TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
              Expanded(
                child: Slider(
                    value: BookParams.getInstance().getReadAloudRate().toDouble(),
                    min: 1,
                    max: 10,
                    activeColor: WidgetUtils.gblStore!.state.theme.primary,
                    inactiveColor: WidgetUtils.gblStore!.state.theme.readPage.menuBaseColor,
                    divisions: 9,
                    label: BookParams.getInstance().getReadAloudRate().toString(),
                    onChanged: (value) {
                      setState(() {
                        BookParams.getInstance().setReadAloudRate(value.toInt());
                      });
                    },
                    onChangeEnd: (endValue) {
                      if (onClick != null) onClick("OnChangeEnd", [endValue]);
                    }),
              ),
              Container(width: 14),
            ]),
            Container(height: 9),
            Row(
              children: <Widget>[
                Container(width: 14),
                Text("${AppUtils.getLocale()?.readMenuReadAloudVoice}：",
                    style: TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                Container(width: 14),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("ReadAloudIsLocal", [true]);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 70,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            color: BookParams.getInstance().getReadAloudIsLocal()
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Text(AppUtils.getLocale()?.readMenuReadAloudVoice1 ?? "",
                              style: TextStyle(
                                  color: BookParams.getInstance().getReadAloudIsLocal()
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                      : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                  fontSize: 14)),
                        ))),
                Container(width: 14),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("ReadAloudIsLocal", [false]);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 70,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            color: !BookParams.getInstance().getReadAloudIsLocal()
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Text(AppUtils.getLocale()?.readMenuReadAloudVoice2 ?? "",
                              style: TextStyle(
                                  color: !BookParams.getInstance().getReadAloudIsLocal()
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                      : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                  fontSize: 14)),
                        ))),
                Container(width: 14),
              ],
            ),
            Container(height: 14),
            Row(
              children: <Widget>[
                Container(width: 14),
                Text("${AppUtils.getLocale()?.readMenuReadAloudTiming}：",
                    style: TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                Container(width: 14),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("ReadAloudTiming", [1]);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 70,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            color: BookParams.getInstance().getReadAloudTimingType() == 1
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Text(_isRunning && BookParams.getInstance().getReadAloudTimingType() == 1 ? StringUtils.getFormatMinuteBySecond(_currentSecond) : "15分钟",
                              style: TextStyle(
                                  color: BookParams.getInstance().getReadAloudTimingType() == 1
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                      : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                  fontSize: 14)),
                        ))),
                Container(width: 14),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("ReadAloudTiming", [2]);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 70,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            color: BookParams.getInstance().getReadAloudTimingType() == 2
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Text(_isRunning && BookParams.getInstance().getReadAloudTimingType() == 2 ? StringUtils.getFormatMinuteBySecond(_currentSecond) : "30分钟",
                              style: TextStyle(
                                  color: BookParams.getInstance().getReadAloudTimingType() == 2
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                      : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                  fontSize: 14)),
                        ))),
                Container(width: 14),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("ReadAloudTiming", [3]);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 70,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            color: BookParams.getInstance().getReadAloudTimingType() == 3
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Text(_isRunning && BookParams.getInstance().getReadAloudTimingType() == 3 ? StringUtils.getFormatMinuteBySecond(_currentSecond) : "60分钟",
                              style: TextStyle(
                                  color: BookParams.getInstance().getReadAloudTimingType() == 3
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                      : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                  fontSize: 14)),
                        ))),
                Container(width: 14),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("ReadAloudTiming", [4]);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 70,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            color: BookParams.getInstance().getReadAloudTimingType() == 4
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Text(_isRunning && BookParams.getInstance().getReadAloudTimingType() == 4 ? StringUtils.getFormatMinuteBySecond(_currentSecond) : "自定义",
                              style: TextStyle(
                                  color: BookParams.getInstance().getReadAloudTimingType() == 4
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                      : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                  fontSize: 14)),
                        ))),
                Container(width: 14),
              ],
            ),
            Container(height: 14),
            Row(
              children: <Widget>[
                Container(width: 14),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("ExitReadAloud", []);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.elliptical(3, 3), bottomLeft: Radius.elliptical(3, 3)),
                          ),
                          child: Text(AppUtils.getLocale()?.readMenuReadAloudExist ?? "",
                              style: TextStyle(
                                  color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                  fontSize: 14)),
                        ))),
                Container(width: 14),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("StartReadAloud", []);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.elliptical(3, 3), bottomRight: Radius.elliptical(3, 3)),
                          ),
                          child: Text(_isRunning ? AppUtils.getLocale()?.appButtonPause ?? "" : AppUtils.getLocale()?.appButtonPlay ?? "",
                              style: TextStyle(
                                  color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                        ))),
                Container(width: 14),
              ],
            ),
          ],
        ));
  }
}
