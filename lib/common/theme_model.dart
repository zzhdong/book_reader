import 'package:flutter/cupertino.dart';

class ThemeModel {
  ThemeModel({required this.primary, required this.body, required this.tabMenu, required this.popMenu, required this.bottomMenu, required this.dropDownMenu, required this.listMenu, required this.listSlideMenu,
      required this.bookList, required this.searchBox, required this.bookDetail, required this.bookChapter, required this.readPage, required this.bookSource});

  Color primary;

  Body body;

  TabMenu tabMenu;

  PopMenu popMenu;

  BottomMenu bottomMenu;

  DropDownMenu dropDownMenu;

  ListMenu listMenu;

  ListSlideMenu listSlideMenu;

  BookList bookList;

  SearchBox searchBox;

  BookDetail bookDetail;

  BookChapter bookChapter;

  ReadPage readPage;

  BookSource bookSource;
}

class Body{
  Body({required this.background, required this.fontColor, required this.checkboxBorder, required this.btnPress, required this.btnUnPress, required this.inputBackground, required this.inputTextBorder,
  required this.inputText, required this.inputTextHigh, required this.folderColor, required this.folderColorNormal, required this.loadingBase, required this.loadingHigh, required this.loadingBody,
  required this.headerTitle, required this.headerBtn, required this.shadow});

  Color background;
  Color fontColor;
  Color checkboxBorder;
  Color btnPress;
  Color btnUnPress;
  Color inputBackground;
  Color inputTextBorder;
  Color inputText;
  Color inputTextHigh;
  Color folderColor;
  Color folderColorNormal;
  Color loadingBase;
  Color loadingHigh;
  Color loadingBody;
  Color headerTitle;
  Color headerBtn;
  Color shadow;
}

class TabMenu{
  TabMenu({required this.background, required this.border, required this.activeTint, required this.inactiveTint, required this.headerSel, required this.headerUnSel});

  Color background;
  Color border;
  Color activeTint;
  Color inactiveTint;
  Color headerSel;
  Color headerUnSel;
}

class PopMenu{
  PopMenu({required this.background, required this.border, required this.title, required this.titleText});

  Color background;
  Color border;
  Color title;
  Color titleText;
}

class BottomMenu{
  BottomMenu({required this.border});

  Color border;
}

class DropDownMenu{
  DropDownMenu({required this.background, required this.icon, required this.line});

  Color background;
  Color icon;
  Color line;
}

class ListMenu{
  ListMenu({required this.bigTitle, required this.title, required this.content, required this.arrow});

  Color bigTitle;
  Color title;
  Color content;
  Color arrow;
}

class ListSlideMenu{
  ListSlideMenu({required this.textDefault, required this.iconDefault, required this.textRed, required this.iconRed, required this.textBlue, required this.iconBlue, required this.textGreen, required this.iconGreen});

  Color textDefault;
  Color iconDefault;
  Color textRed;
  Color iconRed;
  Color textBlue;
  Color iconBlue;
  Color textGreen;
  Color iconGreen;
}

class BookList{
  BookList({required this.noDataIconBg, required this.noDataIcon, required this.noDataText, required this.title, required this.author, required this.desc, required this.subDesc, required this.boxTitle,
    required this.arrowImage, required this.headerText, required this.footerText});

  Color noDataIconBg;
  Color noDataIcon;
  Color noDataText;
  Color title;
  Color author;
  Color desc;
  Color subDesc;
  Color boxTitle;
  Color arrowImage;
  Color headerText;
  Color footerText;
}

class SearchBox{
  SearchBox({required this.background, required this.icon, required this.input, required this.placeholder, required this.cancel, required this.clear,
    required this.historyBorder, required this.historyText, required this.historyIcon, required this.historyKey});

  Color background;
  Color icon;
  Color input;
  Color placeholder;
  Color cancel;
  Color clear;
  Color historyBorder;
  Color historyText;
  Color historyIcon;
  Color historyKey;
}

class BookDetail{
  BookDetail({required this.background, required this.title, required this.box, required this.intro, required this.btnBackground});

  Color background;
  Color title;
  Color box;
  Color intro;
  Color btnBackground;
}

class BookChapter{
  BookChapter({required this.itemBackground, required this.itemBorder, required this.itemText, required this.itemTextCurrent, required this.itemTextCache});

  Color itemBackground;
  Color itemBorder;
  Color itemText;
  Color itemTextCurrent;
  Color itemTextCache;
}

class ReadPage{
  ReadPage({required this.menuBaseColor, required this.menuLineColor, required this.menuBtnBorder, required this.menuBtnText, required this.menuBtnTextPress,
    required this.menuBtnPressBg, required this.menuIconHighBrightness});

  Color menuBaseColor;
  Color menuLineColor;
  Color menuBtnBorder;
  Color menuBtnText;
  Color menuBtnTextPress;
  Color menuBtnPressBg;
  Color menuIconHighBrightness;
}

class BookSource{
  BookSource({required this.title, required this.info, required this.header, required this.headerText});

  Color title;
  Color info;
  Color header;
  Color headerText;
}