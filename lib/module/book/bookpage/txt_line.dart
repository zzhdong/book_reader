import 'package:book_reader/module/book/bookpage/txt_char.dart';

class TxtLine{

  List<TxtChar>? charsData;

  List<TxtChar>? getCharsData() => charsData;

  void setCharsData(List<TxtChar> value) => charsData = value;

  String getLineData() {
    StringBuffer sb = StringBuffer();
    if (charsData == null) return sb.toString();
    for(TxtChar c in charsData!){
      sb.write(String.fromCharCode(c.charData));
    }
    return sb.toString();
  }

  @override
  String toString() {
    return "ShowLine [Linedata=${getLineData()}]";
  }
}