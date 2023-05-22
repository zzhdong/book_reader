import 'dart:math';

class TxtChar{

  //字符数据
  int charData = ' '.codeUnits[0];
  //字符宽度
  double charWidth = 0;
  //当前字符位置
  int index = 0;
  //当前字符是否被选中
  bool selected = false;

  //记录文字的左上右上左下右下四个点坐标
  late Point topLeftPosition;        //左上
  late Point topRightPosition;       //右上
  late Point bottomLeftPosition;     //左下
  late Point bottomRightPosition;    //右下

  void setCharData(int value) => charData = value;

  int getCharData() => charData;

  void setCharWidth(double value) => charWidth = value;

  double getCharWidth() => charWidth;

  void setIndex(int value) => index = value;

  int getIndex() => index;

  void setSelected(bool value) => selected = value;

  bool getSelected() => selected;

  void setTopLeftPosition(Point value) => topLeftPosition = value;

  Point getTopLeftPosition() => topLeftPosition;

  void setTopRightPosition(Point value) => topRightPosition = value;

  Point getTopRightPosition() => topRightPosition;

  void setBottomLeftPosition(Point value) => bottomLeftPosition = value;

  Point getBottomLeftPosition() => bottomLeftPosition;

  void setBottomRightPosition(Point value) => bottomRightPosition = value;

  Point getBottomRightPosition() => bottomRightPosition;

  @override
  String toString() {
    return ('''
        ShowChar [chardata=$charData, Selected=$selected, TopLeftPosition=$topLeftPosition, TopRightPosition=$topRightPosition, 
        BottomLeftPosition=$bottomLeftPosition, BottomRightPosition=$bottomRightPosition, charWidth=$charWidth, Index=$index]
    ''');
  }
}