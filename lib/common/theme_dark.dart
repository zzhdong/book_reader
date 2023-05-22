import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/theme_model.dart';
import 'package:flutter/material.dart';

/// 夜间主题
class ThemeDark {
  static const int primaryColorValue = 0xFF3C3C3C;

  static const MaterialColor primarySwatch = MaterialColor(primaryColorValue,
    <int, Color>{
      50: Color.fromRGBO(60, 60, 60, .1),
      100: Color.fromRGBO(60, 60, 60, .2),
      200: Color.fromRGBO(60, 60, 60, .3),
      300: Color.fromRGBO(60, 60, 60, .4),
      400: Color.fromRGBO(60, 60, 60, .5),
      500: Color.fromRGBO(60, 60, 60, .6),
      600: Color.fromRGBO(60, 60, 60, .7),
      700: Color.fromRGBO(60, 60, 60, .8),
      800: Color.fromRGBO(60, 60, 60, .9),
      900: Color.fromRGBO(60, 60, 60, 1),
    },
  );

  static ThemeData globalTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: primarySwatch,
    //设置默认字体
    fontFamily: AppConfig.DEF_FONT_FAMILY,
  );

  static ThemeModel theme = ThemeModel(
      primary: const Color(primaryColorValue),
      body: Body(
        background: const Color(0xff222222),
        fontColor: const Color(0xffcccccc),
        checkboxBorder: const Color(0xffaaaaaa),
        btnPress: const Color(0xff383838),
        btnUnPress: const Color(0xff282828),
        inputBackground: const Color(0xff555555),
        inputTextBorder: const Color(0xff666666),
        inputText: const Color(0xff999999),
        inputTextHigh: const Color(0xffdddddd),
        folderColor: const Color(0xff46c68d),
        folderColorNormal: const Color(0xff999999),
        loadingBase: const Color(0xffca8d70).withOpacity(0.8),
        loadingHigh: Colors.white70,
        loadingBody: const Color(0xffdddddd),
        headerTitle: const Color(0xffb1b1b1),
        headerBtn: const Color(0xffb1b1b1),
        shadow: const Color(0xff393939),
      ),
      tabMenu: TabMenu(
        background: const Color(0xff323232),
        border: const Color(0xff1e1e1e),
        activeTint: const Color(0xffb1b1b1),
        inactiveTint: const Color(0xff9b9b9b),
        headerSel: Colors.pinkAccent,
        headerUnSel: const Color(0xffdddddd),
      ),
      popMenu: PopMenu(
        background: const Color(0xff404040),
        border: const Color(0xff555555),
        title: const Color(0xff444444),
        titleText: const Color(0xff888888),
      ),
      bottomMenu: BottomMenu(
        border: const Color(0xff666666),
      ),
      dropDownMenu: DropDownMenu(
        background: const Color(0xff333333).withOpacity(0.8),
        icon: const Color(0xffaaaaaa),
        line: const Color(0xff666666),
      ),             //主题颜色
      listMenu: ListMenu(
        bigTitle: const Color(0xffcccccc),
        title: const Color(0xff949494),
        content: const Color(0xff808080),
        arrow: const Color(0xffc1c1c1),
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
        noDataIconBg: const Color(0xff888888),
        noDataIcon: const Color(0xffaaaaaa),
        noDataText: const Color(0xff888888).withOpacity(0.7),
        title: const Color(0xff969696),
        author: const Color(0xff838da8),
        desc: const Color(0xff696969),
        subDesc: const Color(0xff777777),
        boxTitle: const Color(0xEE969696),
        arrowImage: const Color(0xffaaaaaa),
        headerText: const Color(0xff999999),
        footerText: const Color(0xff999999),
      ),
      searchBox: SearchBox(
        background: const Color(0xff555555),
        icon: const Color(0xff787878),
        input: const Color(0xff999999),
        placeholder: const Color(0xff787878),
        cancel: const Color(0xffb1b1b1),
        clear: const Color(0xff666666),
        historyBorder: const Color(0xff333333),
        historyText: const Color(0xff888888),
        historyIcon: const Color(0xff888888),
        historyKey: const Color(0xffcccccc),
      ),
      bookDetail: BookDetail(
        background: const Color(0xff282828),
        title: const Color(0xffcccccc),
        box: const Color(0xff282828),
        intro: const Color(0xffaaaaaa),
        btnBackground: const Color(0xff323232),
      ),
      bookChapter: BookChapter(
        itemBackground: const Color(0xff282828),
        itemBorder: const Color(0xff222222),
        itemText: const Color(0xff666666),
        itemTextCurrent: const Color(0xffff5e4e),
        itemTextCache: const Color(0xff999999),
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
        title: const Color(0xff888888),
        info: const Color(0xff777777),
        header: const Color(0xff999999),
        headerText: const Color(0xff232323),
      ));
}
