import 'dart:math';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/module/book/bookpage/txt_page.dart';

class TxtChapter{

  int position;
  //书页列表
  List<TxtPage> txtPageList = [];
  //每一页的总字数
  List<int> txtPageLengthList = [];
  //每一段的总字数
  List<int> paragraphLengthList = [];

  ChapterLoadStatus status = ChapterLoadStatus.LOADING;

  String msg = "";

  TxtChapter(this.position);

  int getPosition() => position;

  List<TxtPage> getTxtPageList() => txtPageList;

  List<int> getTxtPageLengthList() => txtPageLengthList;

  List<int> getParagraphLengthList() => paragraphLengthList;

  void setStatus(ChapterLoadStatus value) => status = value;

  ChapterLoadStatus getStatus() => status;

  void setMsg(String value) => msg = value;

  String getMsg() => msg;

  int getPageSize() => txtPageList.length;

  void addPage(TxtPage txtPage) {
    txtPageList.add(txtPage);
  }

  TxtPage? getPage(int page){
    if(txtPageList.isNotEmpty){
      return txtPageList[max(0, min(page, txtPageList.length - 1))];
    }else {
      return null;
    }
  }

  int getPageLength(int position){
    if (position >= 0 && position < txtPageLengthList.length) {
      return txtPageLengthList[position];
    } else {
      return -1;
    }
  }

  void addTxtPageLength(int length) {
    txtPageLengthList.add(length);
  }

  void addParagraphLength(int length) {
    paragraphLengthList.add(length);
  }

  int getParagraphIndex(int length) {
    for(int i = 0; i < paragraphLengthList.length; i++){
      if ((i == 0 || paragraphLengthList[i - 1] < length) && length <= paragraphLengthList[i]) {
        return i;
      }
    }
    return -1;
  }
}