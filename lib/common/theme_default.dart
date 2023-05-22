import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/theme_model.dart';
import 'package:flutter/material.dart';

///默认主题
class ThemeDefault {
  static const int primaryColorValue = 0xFF5E6DB8;

  static MaterialColor primarySwatch = const MaterialColor(primaryColorValue,
    <int, Color>{
      50: Color.fromRGBO(94, 109, 184, .1),
      100: Color.fromRGBO(94, 109, 184, .2),
      200: Color.fromRGBO(94, 109, 184, .3),
      300: Color.fromRGBO(94, 109, 184, .4),
      400: Color.fromRGBO(94, 109, 184, .5),
      500: Color.fromRGBO(94, 109, 184, .6),
      600: Color.fromRGBO(94, 109, 184, .7),
      700: Color.fromRGBO(94, 109, 184, .8),
      800: Color.fromRGBO(94, 109, 184, .9),
      900: Color.fromRGBO(94, 109, 184, 1),
    },
  );

  static ThemeData globalTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: primarySwatch,
    //设置默认字体
    fontFamily: AppConfig.DEF_FONT_FAMILY,
  );

  static ThemeModel theme = ThemeModel(
      primary: const Color(primaryColorValue),
      body: Body(
        background: const Color(0xfff0f0f0),
        fontColor: const Color(0xff111111),
        checkboxBorder: const Color(0xffaaaaaa),
        btnPress: const Color(0xfff5f5f5),
        btnUnPress: const Color(0xffffffff),
        inputBackground: const Color(0xffffffff),
        inputTextBorder: const Color(0xffdddddd),
        inputText: const Color(0xff555555),
        inputTextHigh: const Color(0xffffffff),
        folderColor: const Color(0xff46c68d),
        folderColorNormal: const Color(0xff999999),
        loadingBase: const Color(0xffca8d70).withOpacity(0.8),
        loadingHigh: Colors.white70,
        loadingBody: Colors.black87,
        headerTitle: const Color(0xffffffff),
        headerBtn: const Color(0xffffffff),
        shadow: const Color(0xff999999),
      ),
      tabMenu: TabMenu(
        background: const Color(0xffffffff),
        border: const Color(0xffdddddd),
        activeTint: const Color(0xff5E6DB8),
        inactiveTint: const Color(0xff999999),
        headerSel: Colors.pinkAccent,
        headerUnSel: Colors.white,
      ),
      popMenu: PopMenu(
        background: const Color(0xfffafafa),
        border: const Color(0xffdddddd),
        title: const Color(0xfff9f9f9),
        titleText: const Color(0xff232323),
      ),
      bottomMenu: BottomMenu(
        border: const Color(0xffcccccc),
      ),
      dropDownMenu: DropDownMenu(
        background: const Color.fromRGBO(255, 255, 255, 1),
        icon: const Color(0xff666666),
        line: const Color(0xffdddddd),
      ),
      listMenu: ListMenu(
        bigTitle: const Color(0xff232323),
        title: const Color(0xff323232),
        content: const Color(0xff999999),
        arrow: const Color(0xffbbbbbb),
      ),
      listSlideMenu: ListSlideMenu(
        textDefault: const Color(0xffcccccc),
        iconDefault: const Color(0xff333333),
        textRed: const Color(0xffff6559),
        iconRed: const Color(0xffffffff),
        textBlue: const Color(0xff4ca9ec),
        iconBlue: const Color(0xffffffff),
        textGreen: const Color(0xff46c68d),
        iconGreen: const Color(0xffffffff),
      ),
      bookList: BookList(
        noDataIconBg: const Color(0xffdddddd),
        noDataIcon: const Color(0xffcccccc),
        noDataText: const Color(0xFF818181).withOpacity(0.7),
        title: const Color(0xff333333),
        author: const Color(0xff994723),
        desc: const Color(0xff999999),
        subDesc: const Color(0xff777777),
        boxTitle: const Color(0xEEFFFFFF),
        arrowImage: const Color(0xff666666),
        headerText: const Color(0xff333333),
        footerText: const Color(0xff333333),
      ),
      searchBox: SearchBox(
        background: const Color(0xffffffff),
        icon: const Color(0xffaaaaaa),
        input: const Color(0xff323232),
        placeholder: const Color(0xffbbbbbb),
        cancel: const Color(0xffffffff),
        clear: const Color(0xff666666),
        historyBorder: const Color(0xffcccccc),
        historyText: const Color(0xff555555),
        historyIcon: const Color(0xff555555),
        historyKey: const Color(0xff232323),
      ),
      bookDetail: BookDetail(
        background: const Color(0xffffffff),
        title: const Color(0xff232323),
        box: const Color(0xffffffff),
        intro: const Color(0xff333333),
        btnBackground: const Color(0xffffffff),
      ),
      bookChapter: BookChapter(
        itemBackground: const Color(0xffffffff),
        itemBorder: const Color(0xffe6e6e6),
        itemText: const Color(0xff999999),
        itemTextCurrent: const Color(0xffff5e4e),
        itemTextCache: const Color(0xff666666),
      ),
      readPage: ReadPage(
        menuBaseColor: const Color(0xffaaaaaa),
        menuLineColor: const Color(0xff888888),
        menuBtnBorder: const Color(0xff666666),
        menuBtnText: const Color(0xffbbbbbb),
        menuBtnTextPress: const Color(0xffffffff),
        menuBtnPressBg: const Color(0xff444444),
        menuIconHighBrightness: const Color(0xffeeeeee),
      ),
      bookSource: BookSource(
        title: const Color(0xff232323),
        info: const Color(0xff444444),
        header: Colors.black12,
        headerText: const Color(0xff666666),
      ));
}
