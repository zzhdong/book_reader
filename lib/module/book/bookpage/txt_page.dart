import 'dart:core';
import 'package:book_reader/module/book/bookpage/txt_line.dart';

class TxtPage{

  late int position;

  late String title;

  //当前 lines 中为 title 的行数。
  int titleLines = 0;

  final List<String> _lines = [];

  //存放每个字的位置
  late List<TxtLine> txtLists;

  late String content;

  late bool hasBookMark;

  TxtPage(this.position);

  int getPosition() => position;

  void setTitle(String value) => title = value;

  String getTitle() => title;

  void setTitleLines(int value) => titleLines = value;

  int getTitleLines() => titleLines;

  List<TxtLine> getTxtLists() => txtLists;

  void setTxtLists(List<TxtLine> value){
    txtLists = [];
    for(TxtLine obj in value){
      txtLists.add(obj);
    }
  }

  String getContent(){
    StringBuffer sb = StringBuffer();
    for (String str in _lines) {
      sb.write(str);
    }
    return sb.toString();
  }

  void addLine(String line) {
    _lines.add(line);
  }

  void addLines(List<String> lines) {
    _lines.addAll(lines);
  }

  String getLine(int i){
    return _lines[i];
  }

  List<String> getLines(){
    return _lines;
  }

  int size(){
    return _lines.length;
  }
}