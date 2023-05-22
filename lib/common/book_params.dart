import 'dart:math';
import 'dart:ui';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/plugin/device_plugin.dart';
import 'package:book_reader/utils/color_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';

//输出参数
class BookParams{
  // 默认边距宽度
  static const int DEF_MARGIN_WIDTH = 14;
  // 默认边距高度
  static const int DEF_MARGIN_HEIGHT = 3;
  // 默认边距高度
  static const int DEF_MARGIN_TIP_HEIGHT = 6;
  // 默认tip字体大小
  static const int DEF_TIP_SIZE = 12;
  // 默认最大滚动距离
  static const double DEF_MAX_SCROLL_OFFSET = 100;
  // 默认tip文字透明度
  static const double DEF_TIP_OPACITY = (180 / 255);
  
  // 仿真
  static const ANIMATION_SIMULATION = 1;
  // 滚动
  static const ANIMATION_SCROLL = 2;
  // 左右平移
  static const ANIMATION_MOVE = 3;
  // 左右覆盖
  static const ANIMATION_COVER = 4;
  // 垂直平移
  static const ANIMATION_MOVE_VERTICAL = 5;
  // 垂直覆盖
  static const ANIMATION_COVER_VERTICAL = 6;
  // 无动画
  static const ANIMATION_NONE = 7;
  // 其他
  static const ANIMATION_AUTO = 8;
  
  // 默认书籍主题
  static const int DEF_BOOK_THEME = 1;
  int _textThemeListIndex = DEF_BOOK_THEME;
  // 字体主题颜色列表
  late List<Map<String, dynamic>> textThemeList;
  // 背景颜色列表
  late List<Map<String, dynamic>> customBgColorList;
  // 字体颜色列表
  late List<Map<String, dynamic>> customTextColorList;
  // 自定义背景颜色
  late String _customBgColor;
  // 自定义字体颜色
  late String _customTextColor;
  // 保存白天的主题颜色
  int _dayThemeIndex = DEF_BOOK_THEME;

  // 屏幕方向 0:自动 1:竖屏 2:横屏
  late int _screenDirection;
  // 页面的翻页效果模式  1仿真、2滑动、3平移、4覆盖、5垂直平移、6垂直覆盖、7无、8自动
  late int _pageMode;
  // 是否隐藏状态栏
  late bool _hideStatusBar;
  // iPhoneX 是否隐藏底部横条
  late bool _hideHomeIndicator;
  // 是否隐藏底部导航栏
  late bool _hideNavigationBar;
  // 第一页是否显示章节标题
  late bool _showTitle;
  // 是否显示时间
  late bool _showTime;
  // 是否显示线条(分隔tip的线条)
  late bool _showLine;
  // 显示电池
  late bool _showBattery;
  // 显示电池
  late bool _showPage;
  // 显示电池
  late bool _showProcess;
  // 显示章节序号
  late bool _showChapterIndex;
  
  // 字体高度组合
  late int _fontGroup;
  // 字体大小
  late int _textSize;
  // 字体
  late String _fontFamily;
  // 加粗数值
  late int _textBold;
  // 繁简
  late int _textConvert;
  // 缩进
  late int _indent;
  // 阅读左边距
  late int _paddingLeft;
  // 阅读上边距
  late int _paddingTop;
  // 阅读右边距
  late int _paddingRight;
  // 阅读下边距
  late int _paddingBottom;
  // 左边距
  late int _tipPaddingLeft;
  // 上边距
  late int _tipPaddingTop;
  // 右边距
  late int _tipPaddingRight;
  // 下边距
  late int _tipPaddingBottom;
  // 字间距(范围1到10，步进1)
  late double _letterSpacing;
  // 行间距(字体*间距/2)(范围0到3，步进0.1)
  late double _lineSpacing;
  // 段间距(字体*段距/2)(范围0到3，步进0.1)
  late double _paragraphSpacing;
  
  // 屏幕亮度
  double? _brightness;
  late double _lastFollowSysBrightness;
  // 屏幕亮度是否跟随系统
  bool? _isBrightnessFollowSys;

  // 全屏点击翻页
  late bool _clickAllNext;
  // 点击区域
  late double _clickLeftArea;
  late double _clickRightArea;
  // 是否第一次进入阅读界面
  late bool _isFirstRead;
  // 是否禁止锁屏
  late bool _canLockScreen;

  // 翻页速度
  late int _autoTurnSpeed;
  late int _lastPageTurn;

  //语速
  late int _readAloudRate;
  //是否本地语音
  late bool _readAloudIsLocal;
  //语音类型
  late String _readAloudVoiceType;
  //定时播放时间 1.15 2.30 3.60 4.custom
  late int _readAloudTimingType;
  //定时播放时间
  late int _readAloudTiming;

  late bool _canSelectText;

  static BookParams? _bookParams;

  static BookParams getInstance() {
    if (_bookParams == null) {
      _bookParams = BookParams();
      _bookParams?.initTextThemeList();
      _bookParams?.updateReaderSettings();
    }
    return _bookParams!;
  }

  //阅读背景
  void initTextThemeList() {
    textThemeList = [];
    Map<String, dynamic> temp = <String, dynamic>{};
    temp["textBackground"] = const Color(0xff000000);
    temp["textColor"] = const Color(0xff8e8e8e);
    temp["textName"] = "文本";
    temp["isCustom"] = false;
    textThemeList.add(temp);

    temp = <String, dynamic>{};
    temp["textBackground"] = const Color(0xffffffff);
    temp["textColor"] = const Color(0xff000000);
    temp["textName"] = "文本";
    temp["isCustom"] = false;
    textThemeList.add(temp);

    temp = <String, dynamic>{};
    temp["textBackground"] = const Color(0xffd0dfcc);
    temp["textColor"] = const Color(0xff333333);
    temp["textName"] = "文本";
    temp["isCustom"] = false;
    textThemeList.add(temp);

    temp = <String, dynamic>{};
    temp["textBackground"] = const Color(0xffdadada);
    temp["textColor"] = const Color(0xff322b21);
    temp["textName"] = "文本";
    temp["isCustom"] = false;
    textThemeList.add(temp);

    temp = <String, dynamic>{};
    temp["textBackground"] = const Color(0xff919191);
    temp["textColor"] = const Color(0xff383838);
    temp["textName"] = "文本";
    temp["isCustom"] = false;
    textThemeList.add(temp);

    temp = <String, dynamic>{};
    temp["textBackground"] = const Color(0xffb1d2b5);
    temp["textColor"] = const Color(0xff2d362e);
    temp["textName"] = "文本";
    temp["isCustom"] = false;
    textThemeList.add(temp);

    temp = <String, dynamic>{};
    temp["textBackground"] = const Color(0xffb9c2a2);
    temp["textColor"] = const Color(0xff29301a);
    temp["textName"] = "文本";
    textThemeList.add(temp);

    temp = <String, dynamic>{};
    temp["textBackground"] = const Color(0xfff8f2e4);
    temp["textColor"] = const Color(0xff33312d);
    temp["textName"] = "文本";
    temp["isCustom"] = false;
    textThemeList.add(temp);

    temp = <String, dynamic>{};
    temp["textBackground"] = const Color(0xffdecbc7);
    temp["textColor"] = const Color(0xff494949);
    temp["textName"] = "文本";
    temp["isCustom"] = false;
    textThemeList.add(temp);

    temp = <String, dynamic>{};
    temp["textBackground"] = const Color(0xff302c28);
    temp["textColor"] = const Color(0xff83817e);
    temp["textName"] = "文本";
    textThemeList.add(temp);

    temp = <String, dynamic>{};
    temp["textBackground"] = const Color(0xff232e40);
    temp["textColor"] = const Color(0xff747b85);
    temp["textName"] = "文本";
    temp["isCustom"] = false;
    textThemeList.add(temp);

    temp = <String, dynamic>{};
    temp["textBackground"] = const Color(0xff282b35);
    temp["textColor"] = const Color(0xffa8a8a8);
    temp["textName"] = "文本";
    temp["isCustom"] = false;
    textThemeList.add(temp);

    //设置背景颜色
    customBgColorList = [];
    for(Map<String, dynamic> map in textThemeList){
      temp = <String, dynamic>{};
      temp["color"] = map["textBackground"];
      temp["isCustom"] = false;
      customBgColorList.add(temp);
    }

    //设置自定义字体颜色
    customTextColorList = [];
    for(Map<String, dynamic> map in textThemeList){
      temp = <String, dynamic>{};
      temp["color"] = map["textColor"];
      temp["isCustom"] = false;
      customTextColorList.add(temp);
    }

    //获取自定义主题
    for(int i = textThemeList.length; i < 100; i++){
      String bg = AppConfig.prefs.getString("textBackground_$i") ?? "";
      if(StringUtils.isEmpty(bg)) break;
      temp = <String, dynamic>{};
      temp["textBackground"] = ColorUtils.fromHex(AppConfig.prefs.getString("textBackground_$i") ?? "#ffffff");
      temp["textColor"] = ColorUtils.fromHex(AppConfig.prefs.getString("textColor_$i") ?? "#000000");
      temp["textName"] = AppConfig.prefs.getString("textName_$i") ?? "自定义";
      temp["isCustom"] = true;
      textThemeList.add(temp);
    }

    //获取自定义主题
    for(int i = customBgColorList.length; i < 100; i++){
      String bg = AppConfig.prefs.getString("customBgColor_$i") ?? "";
      if(StringUtils.isEmpty(bg)) break;
      temp = <String, dynamic>{};
      temp["color"] = ColorUtils.fromHex(AppConfig.prefs.getString("customBgColor_$i") ?? "#ffffff");
      temp["isCustom"] = true;
      customBgColorList.add(temp);
    }

    //获取自定义主题
    for(int i = customTextColorList.length; i < 100; i++){
      String bg = AppConfig.prefs.getString("customTextColor_$i") ?? "";
      if(StringUtils.isEmpty(bg)) break;
      temp = <String, dynamic>{};
      temp["color"] = ColorUtils.fromHex(AppConfig.prefs.getString("customTextColor_$i") ?? "#000000");
      temp["isCustom"] = true;
      customTextColorList.add(temp);
    }
  }

  void updateReaderSettings() {
    _customBgColor = AppConfig.prefs.getString("customBgColor") ?? "";
    _customTextColor = AppConfig.prefs.getString("customTextColor") ?? "";
    _dayThemeIndex = AppConfig.prefs.getInt("dayThemeIndex") ?? DEF_BOOK_THEME;

    _screenDirection = AppConfig.prefs.getInt("screenDirection") ?? 0;
    _pageMode = AppConfig.prefs.getInt("pageMode") ?? BookParams.ANIMATION_MOVE;
    _hideStatusBar = AppConfig.prefs.getBool("hideStatusBar") ?? true;
    _hideHomeIndicator = AppConfig.prefs.getBool("hideHomeIndicator") ?? true;
    _hideNavigationBar = AppConfig.prefs.getBool("hideNavigationBar") ?? false;
    _showTitle = AppConfig.prefs.getBool("showTitle") ?? true;
    _showTime = AppConfig.prefs.getBool("showTime") ?? true;
    _showLine = AppConfig.prefs.getBool("showLine") ?? false;
    _showBattery = AppConfig.prefs.getBool("showBattery") ?? true;
    _showPage = AppConfig.prefs.getBool("showPage") ?? true;
    _showProcess = AppConfig.prefs.getBool("showProcess") ?? true;
    _showChapterIndex = AppConfig.prefs.getBool("showChapterIndex") ?? true;

    _fontGroup = AppConfig.prefs.getInt("fontGroup") ?? 2;
    _textSize = AppConfig.prefs.getInt("textSize") ?? 19;
    _textBold = AppConfig.prefs.getInt("textBold") ?? 4;
    _fontFamily = AppConfig.prefs.getString("fontFamily") ?? AppConfig.DEF_FONT_FAMILY;
    _textConvert = AppConfig.prefs.getInt("textConvertInt") ?? 0;
    _indent = AppConfig.prefs.getInt("indent") ?? 2;

    _paddingLeft = AppConfig.prefs.getInt("paddingLeft") ?? DEF_MARGIN_WIDTH;
    _paddingTop = AppConfig.prefs.getInt("paddingTop") ?? 0;
    _paddingRight = AppConfig.prefs.getInt("paddingRight") ?? DEF_MARGIN_WIDTH;
    _paddingBottom = AppConfig.prefs.getInt("paddingBottom") ?? 0;
    _tipPaddingLeft = AppConfig.prefs.getInt("tipPaddingLeft") ?? DEF_MARGIN_WIDTH;
    _tipPaddingTop = AppConfig.prefs.getInt("tipPaddingTop") ?? 0;
    _tipPaddingRight = AppConfig.prefs.getInt("tipPaddingRight") ?? DEF_MARGIN_WIDTH;
    _tipPaddingBottom = AppConfig.prefs.getInt("tipPaddingBottom") ?? 0;

    _letterSpacing = AppConfig.prefs.getDouble("letterSpacing") ?? 0;
    _lineSpacing = AppConfig.prefs.getDouble("lineSpacing") ?? 0.5;
    _paragraphSpacing = AppConfig.prefs.getDouble("paragraphSpacing") ?? 0.5;

    _isBrightnessFollowSys = AppConfig.prefs.getBool("isBrightnessFollowSys") ?? true;
    // 获取屏幕亮度
    if(getBrightnessFollowSys()){
      DevicePlugin.brightness.then((double brightness){
        setBrightness(brightness * 100);
      });
    }
    _lastFollowSysBrightness = AppConfig.prefs.getDouble("lastFollowSysBrightness") ?? 90;

    _clickAllNext = AppConfig.prefs.getBool("clickAllNext") ?? false;
    _clickLeftArea = AppConfig.prefs.getDouble("clickLeftArea") ?? ScreenUtils.getScreenWidth() / 3;
    _clickRightArea = AppConfig.prefs.getDouble("clickRightArea") ?? ScreenUtils.getScreenWidth() / 3;
    _isFirstRead = AppConfig.prefs.getBool("isFirstRead") ?? true;
    _canLockScreen = AppConfig.prefs.getBool("canLockScreen") ?? false;

    _autoTurnSpeed = AppConfig.prefs.getInt("autoTurnSpeed") ?? 4;
    _lastPageTurn = AppConfig.prefs.getInt("lastPageTurn") ?? -1;
    //如果最后一次翻页模式不为原始值，则恢复最后一次翻页模式
    if(_lastPageTurn != -1) restoreAutoPageTurn();

    _readAloudRate = AppConfig.prefs.getInt("readAloudRate") ?? 5;
    _readAloudIsLocal = AppConfig.prefs.getBool("readAloudIsLocal") ?? true;
    _readAloudVoiceType = AppConfig.prefs.getString("readAloudVoiceType") ?? "zh-CN";
    _readAloudTimingType = AppConfig.prefs.getInt("readAloudTimingType") ?? 1;
    _readAloudTiming = AppConfig.prefs.getInt("readAloudTiming") ?? 15;

    _canSelectText = AppConfig.prefs.getBool("canSelectText") ?? true;
    initTextThemeListIndex();
  }

  void initTextThemeListIndex() {
    // 判断是是否夜间模式
    if (AppParams.getInstance().getAppTheme() == 2) {
      _textThemeListIndex = 0;
    } else {
      _textThemeListIndex = AppConfig.prefs.getInt("textThemeListIndex") ?? DEF_BOOK_THEME;
    }
  }

  int getTextThemeListIndex(){
    if(StringUtils.isNotEmpty(_customBgColor) || StringUtils.isNotEmpty(_customTextColor)) {
      return -1;
    } else {
      return _textThemeListIndex;
    }
  }

  Color getTextBackground(){
    if (AppParams.getInstance().getAppTheme() == 2) {
      return textThemeList[0]["textBackground"] as Color;
    } else {
      if(StringUtils.isEmpty(_customBgColor)) {
        return textThemeList[_textThemeListIndex]["textBackground"] as Color;
      } else {
        return ColorUtils.fromHex(_customBgColor);
      }
    }
  }

  Color getTextColor(){
    if (AppParams.getInstance().getAppTheme() == 2) {
      return textThemeList[0]["textColor"] as Color;
    } else {
      if(StringUtils.isEmpty(_customTextColor)) {
        return textThemeList[_textThemeListIndex]["textColor"] as Color;
      } else {
        return ColorUtils.fromHex(_customTextColor);
      }
    }
  }

  void setTextThemeListIndex(int textThemeListIndex) {
    _textThemeListIndex = textThemeListIndex;
    AppConfig.prefs.setInt("textThemeListIndex", textThemeListIndex);
    _customBgColor = "";
    _customTextColor = "";
    AppConfig.prefs.setString("customBgColor", "");
    AppConfig.prefs.setString("customTextColor", "");
  }

  void setDayTheme() {
    if (AppParams.getInstance().getAppTheme() == 2) {
      if(getTextThemeListIndex() == -1){

      }else{
        setDayThemeIndex(_textThemeListIndex);
        setTextThemeListIndex(0);
      }
    }else{
      if(getTextThemeListIndex() == -1){

      }else{
        if(_dayThemeIndex <=0 || _dayThemeIndex >= textThemeList.length ) {
          setTextThemeListIndex(1);
        } else {
          setTextThemeListIndex(_dayThemeIndex);
        }
      }
    }
  }

  int getDayThemeIndex() => _dayThemeIndex;
  void setDayThemeIndex(int dayThemeIndex) {
    _dayThemeIndex = dayThemeIndex;
    AppConfig.prefs.setInt("dayThemeIndex", _dayThemeIndex);
  }

  void delTextThemeList(int textThemeListIndex) {
    if((textThemeList.length - 1) == textThemeListIndex){
      AppConfig.prefs.setString("textBackground_$textThemeListIndex", "");
      AppConfig.prefs.setString("textColor_$textThemeListIndex", "");
      AppConfig.prefs.setString("textName_$textThemeListIndex", "");
    }else{
      for(int i = textThemeListIndex; i < (textThemeList.length - 1); i++){
        AppConfig.prefs.setString("textBackground_$i", AppConfig.prefs.getString("textBackground_${i + 1}") ?? "");
        AppConfig.prefs.setString("textColor_$i", AppConfig.prefs.getString("textColor_${i + 1}") ?? "");
        AppConfig.prefs.setString("textName_$i", AppConfig.prefs.getString("textName_${i + 1}") ?? "");
      }
      AppConfig.prefs.setString("textBackground_${textThemeList.length - 1}", "");
      AppConfig.prefs.setString("textColor_${textThemeList.length - 1}", "");
      AppConfig.prefs.setString("textName_${textThemeList.length - 1}", "");
    }
    //初始化颜色
    initTextThemeList();
  }

  void delCustomBgColor(int index) {
    if((customBgColorList.length - 1) == index){
      AppConfig.prefs.setString("customBgColor_$index", "");
    }else{
      for(int i = index; i < (customBgColorList.length - 1); i++){
        AppConfig.prefs.setString("customBgColor_$i", AppConfig.prefs.getString("customBgColor_${i + 1}") ?? "");
      }
      AppConfig.prefs.setString("customBgColor_${customBgColorList.length - 1}", "");
    }
    //初始化颜色
    initTextThemeList();
  }

  void delCustomTextColor(int index) {
    if((customTextColorList.length - 1) == index){
      AppConfig.prefs.setString("customTextColor_$index", "");
    }else{
      for(int i = index; i < (customTextColorList.length - 1); i++){
        AppConfig.prefs.setString("customTextColor_$i", AppConfig.prefs.getString("customTextColor_${i + 1}") ?? "");
      }
      AppConfig.prefs.setString("customTextColor_${customTextColorList.length - 1}", "");
    }
    //初始化颜色
    initTextThemeList();
  }

  void setCustomColor(String bgColor, String textColor){
    if(StringUtils.isNotEmpty(bgColor)){
      _customBgColor = bgColor;
      AppConfig.prefs.setString("customBgColor", _customBgColor);
    }
    if(StringUtils.isNotEmpty(textColor)){
      _customTextColor = textColor;
      AppConfig.prefs.setString("customTextColor", _customTextColor);
    }
    _textThemeListIndex = -1;
    AppConfig.prefs.setInt("textThemeListIndex", _textThemeListIndex);
  }

  void addColorTheme(String name, String bgColor, String textColor){
    AppConfig.prefs.setString("textBackground_${textThemeList.length}", bgColor);
    AppConfig.prefs.setString("textColor_${textThemeList.length}", textColor);
    AppConfig.prefs.setString("textName_${textThemeList.length}", name);
    setTextThemeListIndex(textThemeList.length);
    //初始化颜色
    initTextThemeList();
  }

  void addCustomBgColor(String color){
    setCustomColor(color, "");
    AppConfig.prefs.setString("customBgColor_${customBgColorList.length}", color);
    //初始化颜色
    initTextThemeList();
  }

  void addCustomTextColor(String color){
    setCustomColor("", color);
    AppConfig.prefs.setString("customTextColor_${customTextColorList.length}", color);
    //初始化颜色
    initTextThemeList();
  }

  String getCustomBgColor() => _customBgColor;

  String getCustomTextColor() => _customTextColor;

  int getScreenDirection() => _screenDirection;
  void setScreenDirection(int screenDirection) {
    _screenDirection = screenDirection;
    AppConfig.prefs.setInt("screenDirection", screenDirection);
  }

  int getPageMode() => _pageMode;
  void setPageMode(int pageMode) {
    _pageMode = pageMode;
    AppConfig.prefs.setInt("pageMode", pageMode);
  }

  bool getHideStatusBar() => _hideStatusBar;
  void setHideStatusBar(bool hideStatusBar) {
    _hideStatusBar = hideStatusBar;
    AppConfig.prefs.setBool("hideStatusBar", hideStatusBar);
  }

  bool getHideHomeIndicator() => _hideHomeIndicator;
  void setHideHomeIndicator(bool hideHomeIndicator) {
    _hideHomeIndicator = hideHomeIndicator;
    AppConfig.prefs.setBool("hideHomeIndicator", hideHomeIndicator);
  }

  bool getHideNavigationBar() => _hideNavigationBar;
  void setHideNavigationBar(bool hideNavigationBar) {
    _hideNavigationBar = hideNavigationBar;
    AppConfig.prefs.setBool("hideNavigationBar", hideNavigationBar);
  }

  bool getShowTitle() => _showTitle;
  void setShowTitle(bool showTitle) {
    _showTitle = showTitle;
    AppConfig.prefs.setBool("showTitle", showTitle);
  }

  bool getShowTime() => _showTime;
  void setShowTime(bool showTime) {
    _showTime = showTime;
    AppConfig.prefs.setBool("showTime", showTime);
  }

  bool getShowLine() => _showLine;
  void setShowLine(bool showLine) {
    _showLine = showLine;
    AppConfig.prefs.setBool("showLine", showLine);
  }

  bool getShowBattery() => _showBattery;
  void setShowBattery(bool showBattery) {
    _showBattery = showBattery;
    AppConfig.prefs.setBool("showBattery", showBattery);
  }

  bool getShowPage() => _showPage;
  void setShowPage(bool showPage) {
    _showPage = showPage;
    AppConfig.prefs.setBool("showPage", showPage);
  }

  bool getShowProcess() => _showProcess;
  void setShowProcess(bool showProcess) {
    _showProcess = showProcess;
    AppConfig.prefs.setBool("showProcess", showProcess);
  }

  bool getShowChapterIndex() => _showChapterIndex;
  void setShowChapterIndex(bool showChapterIndex) {
    _showChapterIndex = showChapterIndex;
    AppConfig.prefs.setBool("showChapterIndex", _showChapterIndex);
  }

  int getFontGroup() => _fontGroup;
  void setFontGroup(int fontGroup) {
    _fontGroup = fontGroup;
    AppConfig.prefs.setInt("fontGroup", fontGroup);
    if(fontGroup == 1){
      setLineSpacing(0);
      setParagraphSpacing(0);
    } else if(fontGroup == 2){
      setLineSpacing(0.5);
      setParagraphSpacing(0.5);
    } else if(fontGroup == 3){
      setLineSpacing(1);
      setParagraphSpacing(1);
    }
  }

  int getTextSize() => _textSize;
  void setTextSize(int textSize) {
    _textSize = textSize;
    AppConfig.prefs.setInt("textSize", textSize);
  }

  String getFontFamily() => _fontFamily;
  void setFontFamily(String fontFamily) {
    _fontFamily = fontFamily;
    AppConfig.prefs.setString("fontFamily", fontFamily);
  }

  FontWeight getTextBoldFontWeight(){
    if(_textBold == 1){
      return FontWeight.w100;
    }else if(_textBold == 2){
      return FontWeight.w200;
    }else if(_textBold == 3){
      return FontWeight.w300;
    }else if(_textBold == 4){
      return FontWeight.w400;
    }else if(_textBold == 5){
      return FontWeight.w500;
    }else if(_textBold == 6){
      return FontWeight.w600;
    }else if(_textBold == 7){
      return FontWeight.w700;
    }else if(_textBold == 8){
      return FontWeight.w800;
    }else if(_textBold == 9){
      return FontWeight.w900;
    }else{
      return FontWeight.w400;
    }
  }
  int getTextBold() => _textBold;
  void setTextBold(int textBold) {
    _textBold = textBold;
    AppConfig.prefs.setInt("textBold", textBold);
  }

  int getTextConvert() => _textConvert == -1 ? 2 : _textConvert;
  void setTextConvert(int textConvert) {
    _textConvert = textConvert;
    AppConfig.prefs.setInt("textConvertInt", textConvert);
  }

  int getIndent() => _indent;
  void setIndent(int indent) {
    _indent = indent;
    AppConfig.prefs.setInt("indent", indent);
  }

  int getPaddingLeft() => _paddingLeft;
  void setPaddingLeft(int paddingLeft) {
    _paddingLeft = paddingLeft;
    AppConfig.prefs.setInt("paddingLeft", paddingLeft);
  }

  int getPaddingTop() => _paddingTop;
  void setPaddingTop(int paddingTop) {
    _paddingTop = paddingTop;
    AppConfig.prefs.setInt("paddingTop", paddingTop);
  }

  int getPaddingRight() => _paddingRight;
  void setPaddingRight(int paddingRight) {
    _paddingRight = paddingRight;
    AppConfig.prefs.setInt("paddingRight", paddingRight);
  }

  int getPaddingBottom() => _paddingBottom;
  void setPaddingBottom(int paddingBottom) {
    _paddingBottom = paddingBottom;
    AppConfig.prefs.setInt("paddingBottom", paddingBottom);
  }

  int getTipPaddingLeft() => _tipPaddingLeft;
  void setTipPaddingLeft(int tipPaddingLeft) {
    _tipPaddingLeft = tipPaddingLeft;
    AppConfig.prefs.setInt("tipPaddingLeft", tipPaddingLeft);
  }

  int getTipPaddingTop() => _tipPaddingTop;
  void setTipPaddingTop(int tipPaddingTop) {
    _tipPaddingTop = tipPaddingTop;
    AppConfig.prefs.setInt("tipPaddingTop", tipPaddingTop);
  }

  int getTipPaddingRight() => _tipPaddingRight;
  void setTipPaddingRight(int tipPaddingRight) {
    _tipPaddingRight = tipPaddingRight;
    AppConfig.prefs.setInt("tipPaddingRight", tipPaddingRight);
  }

  int getTipPaddingBottom() => _tipPaddingBottom;
  void setTipPaddingBottom(int tipPaddingBottom) {
    _tipPaddingBottom = tipPaddingBottom;
    AppConfig.prefs.setInt("tipPaddingBottom", tipPaddingBottom);
  }

  double getLetterSpacing() => _letterSpacing;
  void setLetterSpacing(double letterSpacing) {
    _letterSpacing = letterSpacing;
    AppConfig.prefs.setDouble("letterSpacing", _letterSpacing);
  }

  double getLineSpacing() => _lineSpacing;
  void setLineSpacing(double lineSpacing) {
    _lineSpacing = (lineSpacing * pow(10, 1)).round() / pow(10, 1);
    AppConfig.prefs.setDouble("lineSpacing", _lineSpacing);
  }

  double getParagraphSpacing() => _paragraphSpacing;
  void setParagraphSpacing(double paragraphSpacing) {
    _paragraphSpacing = (paragraphSpacing * pow(10, 1)).round() / pow(10, 1);
    AppConfig.prefs.setDouble("paragraphSpacing", _paragraphSpacing);
  }

  double getBrightness() => _brightness ?? 90;
  void setBrightness(double brightness) {
    _brightness = brightness;
    AppConfig.prefs.setDouble("brightness", brightness);
    //设置非跟随系统时，最后的系统亮度
    if(!getBrightnessFollowSys()){
      _lastFollowSysBrightness = brightness;
      AppConfig.prefs.setDouble("lastFollowSysBrightness", brightness);
    }
    if(getBrightnessFollowSys()) {
      DevicePlugin.setBrightness(brightness / 100);
    }
  }

  bool getBrightnessFollowSys() => _isBrightnessFollowSys ?? true;
  void setBrightnessFollowSys(bool isBrightnessFollowSys) {
    _isBrightnessFollowSys = isBrightnessFollowSys;
    AppConfig.prefs.setBool("isBrightnessFollowSys", isBrightnessFollowSys);
    if(isBrightnessFollowSys){
      DevicePlugin.brightness.then((double brightness){
        setBrightness(brightness * 100);
      });
    }else{
      setBrightness(_lastFollowSysBrightness);
    }
  }

  bool getClickAllNext() => _clickAllNext;
  void setClickAllNext(bool clickAllNext) {
    _clickAllNext = clickAllNext;
    AppConfig.prefs.setBool("clickAllNext", clickAllNext);
  }

  double getClickLeftArea() => _clickLeftArea;
  void setClickLeftArea(double clickLeftArea) {
    _clickLeftArea = clickLeftArea;
    AppConfig.prefs.setDouble("clickLeftArea", _clickLeftArea);
  }

  double getClickRightArea() => _clickRightArea;
  void setClickRightArea(double clickRightArea) {
    _clickRightArea = clickRightArea;
    AppConfig.prefs.setDouble("clickRightArea", _clickRightArea);
  }

  bool getIsFirstRead() => _isFirstRead;
  void setIsFirstRead(bool isFirstRead) {
    _isFirstRead = isFirstRead;
    AppConfig.prefs.setBool("isFirstRead", isFirstRead);
  }

  bool getCanLockScreen() => _canLockScreen;
  void setCanLockScreen(bool canLockScreen) {
    _canLockScreen = canLockScreen;
    AppConfig.prefs.setBool("canLockScreen", canLockScreen);
  }

  int getAutoTurnSpeed() => _autoTurnSpeed;
  void setAutoTurnSpeed(int autoTurnSpeed) {
    _autoTurnSpeed = autoTurnSpeed;
    AppConfig.prefs.setInt("autoTurnSpeed", autoTurnSpeed);
  }

  void setAutoPageTurn() {
    //保存上一次的翻页模式
    _lastPageTurn = _pageMode;
    AppConfig.prefs.setInt("lastPageTurn", _lastPageTurn);
    setPageMode(ANIMATION_AUTO);
  }
  void restoreAutoPageTurn(){
    if(_lastPageTurn != -1){
      setPageMode(_lastPageTurn);
      _lastPageTurn = -1;
      AppConfig.prefs.setInt("lastPageTurn", _lastPageTurn);
    }
  }

  int getReadAloudRate() => _readAloudRate;
  void setReadAloudRate(int readAloudRate) {
    _readAloudRate = readAloudRate;
    AppConfig.prefs.setInt("readAloudRate", readAloudRate);
  }

  bool getReadAloudIsLocal() => _readAloudIsLocal;
  void setReadAloudIsLocal(bool readAloudIsLocal) {
    _readAloudIsLocal = readAloudIsLocal;
    AppConfig.prefs.setBool("readAloudIsLocal", readAloudIsLocal);
  }

  String getReadAloudVoiceType() => _readAloudVoiceType;
  void setReadAloudVoiceType(String readAloudVoiceType) {
    _readAloudVoiceType = readAloudVoiceType;
    AppConfig.prefs.setString("readAloudVoiceType", readAloudVoiceType);
  }

  int getReadAloudTimingType() => _readAloudTimingType;
  void setReadAloudTimingType(int readAloudTimingType) {
    _readAloudTimingType = readAloudTimingType;
    AppConfig.prefs.setInt("readAloudTimingType", readAloudTimingType);
  }

  int getReadAloudTiming() => _readAloudTiming;
  void setReadAloudTiming(int readAloudTiming) {
    _readAloudTiming = readAloudTiming;
    AppConfig.prefs.setInt("readAloudTiming", readAloudTiming);
  }

  bool isCanSelectText() => _canSelectText;
  void setCanSelectText(bool canSelectText) {
    _canSelectText = canSelectText;
    AppConfig.prefs.setBool("canSelectText", canSelectText);
  }
}