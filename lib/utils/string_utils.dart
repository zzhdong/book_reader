import 'dart:convert';
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';
import 'package:book_reader/utils/regex_utils.dart';

class StringUtils {
  static final Map<dynamic, int> _chnMap = getChnMap();

  //时间常量
  static const double limitTimeMillis = 1000.0;
  static const double limitTimeSeconds = 60 * limitTimeMillis;
  static const double limitTimeMinutes = 60 * limitTimeSeconds;
  static const double limitTimeHours = 24 * limitTimeMinutes;
  static const double limitTimeDays = 30 * limitTimeHours;
  static const double limitTimeMonths = 12 * limitTimeDays;

  static bool isBlank(String? s) => s == null || s.trim().isEmpty;

  static bool isNotBlank(String? s) => s != null && s.trim().isNotEmpty;

  static bool isEmpty(String? s) => s == null || s.isEmpty;

  static bool isNotEmpty(String? s) => s != null && s.isNotEmpty;

  static String hideNumber(String phoneNo, {int start = 3, int end = 7, String replacement = '****'}) =>
      phoneNo.replaceRange(start, end, replacement);

  static String toFirstCapital(String str) => str.substring(0, 1).toUpperCase() + str.substring(1);

  // 文本反转
  static String reverse(String? text) {
    if (text == null) {
      return "";
    }
    if (text.length < 2) {
      return text;
    }
    return String.fromCharCodes(text.codeUnits.reversed);
  }

  //将文本中的半角字符，转换成全角字符
  static String halfToFull(String input) {
    List<int> c = input.codeUnits;
    List<int> retList = [];
    for (int i = 0; i < c.length; i++) {
      //半角空格
      if (c[i] == 32) {
        retList.add(12288);
        continue;
      }
      //根据实际情况，过滤不需要转换的符号
      //if (c[i] == 46){
      //  retList.add(c[i]);
      //  continue;
      //}
      if (c[i] > 32 && c[i] < 127) {
        //其他符号都转换为全角
        retList.add(c[i] + 65248);
      } else {
        retList.add(c[i]);
      }
    }
    return String.fromCharCodes(retList);
  }

  //功能：字符串全角转换为半角
  static String fullToHalf(String input) {
    List<int> c = input.codeUnits;
    List<int> retList = [];
    for (int i = 0; i < c.length; i++) {
      //全角空格
      if (c[i] == 12288) {
        retList.add(32);
        continue;
      }
      if (c[i] > 65280 && c[i] < 65375) {
        retList.add(65248 - c[i]);
      } else {
        retList.add(c[i]);
      }
    }
    return String.fromCharCodes(c);
  }

  static Map<dynamic, int> getChnMap() {
    Map<dynamic, int> map = <dynamic, int>{};
    List<int> codeUnitsList = "零一二三四五六七八九十".codeUnits;
    for (int i = 0; i <= 10; i++) {
      map[codeUnitsList[i]] = i;
    }
    codeUnitsList = "〇壹贰叁肆伍陆柒捌玖拾".codeUnits;
    for (int i = 0; i <= 10; i++) {
      map[codeUnitsList[i]] = i;
    }
    map['两'] = 2;
    map['百'] = 100;
    map['佰'] = 100;
    map['千'] = 1000;
    map['仟'] = 1000;
    map['万'] = 10000;
    map['亿'] = 100000000;
    return map;
  }

  static int chineseNumToInt(String chNum, {int def = 0}) {
    int result = 0;
    int tmp = 0;
    int billion = 0;
    List<int> cn = [];
    List<int> codeUnitsList = chNum.codeUnits;
    for (int val in codeUnitsList) {
      cn.add(val);
    }
    // "一零二五" 形式
    if (cn.length > 1 && RegExp("^[〇零一二三四五六七八九壹贰叁肆伍陆柒捌玖]\$").hasMatch(chNum)) {
      for (int i = 0; i < cn.length; i++) {
        cn[i] = 48 + _chnMap[cn[i]]!;
      }
      return StringUtils.stringToInt(String.fromCharCodes(cn));
    }
    // "一千零二十五", "一千二" 形式
    try {
      for (int i = 0; i < cn.length; i++) {
        int tmpNum = _chnMap[cn[i]]!;
        if (tmpNum == 100000000) {
          result += tmp;
          result *= tmpNum;
          billion = billion * 100000000 + result;
          result = 0;
          tmp = 0;
        } else if (tmpNum == 10000) {
          result += tmp;
          result *= tmpNum;
          tmp = 0;
        } else if (tmpNum >= 10) {
          if (tmp == 0) tmp = 1;
          result += tmpNum * tmp;
          tmp = 0;
        } else {
          if (i >= 2 && i == cn.length - 1 && _chnMap[cn[i - 1]]! > 10) {
            double tmpVal = (tmpNum * _chnMap[cn[i - 1]]! / 10);
            tmp = tmpVal.toInt();
          } else {
            tmp = tmp * 10 + tmpNum;
          }
        }
      }
      result += tmp + billion;
      return result;
    } catch (e) {
      return def;
    }
  }

  static int stringToInt(String str, {int def = 0}) {
    if (!isBlank(str)) {
      String num = fullToHalf(str).replaceAll(RegExp("\\s"), "");
      try {
        return int.parse(num);
      } catch (e) {
        return chineseNumToInt(num, def: def);
      }
    }
    return def;
  }

  static int objToInt(dynamic obj, {int def = 0}) {
    if (obj == null) return def;
    if (obj is String) {
      return stringToInt(obj, def: def);
    } else if (obj is bool) {
      if (obj) {
        return 1;
      } else {
        return 0;
      }
    } else if (obj is int) {
      return obj;
    } else if (obj is double) {
      return obj.toInt();
    } else {
      return stringToInt(obj.toString());
    }
  }

  static double compareTwoStrings(String first, String second) {
    first = first.replaceAll(RegExp(r'\s+\b|\b\s'), ''); // remove all whitespace
    second = second.replaceAll(RegExp(r'\s+\b|\b\s'), ''); // remove all whitespace
    if (first.isEmpty && second.isEmpty) {
      return 1;
    }
    if (first.isEmpty || second.isEmpty) {
      return 0;
    }
    if (first == second) {
      return 1;
    }
    if (first.length == 1 && second.length == 1) {
      return 0;
    }
    if (first.length < 2 || second.length < 2) {
      return 0;
    }
    final Map<String, int> firstBigrams = <String, int>{};
    for (int i = 0; i < first.length - 1; i++) {
      final String bigram = first.substring(i, i + 2);
      final int count = firstBigrams.containsKey(bigram) ? firstBigrams[bigram]! + 1 : 1;
      firstBigrams[bigram] = count;
    }
    int intersectionSize = 0;
    for (int i = 0; i < second.length - 1; i++) {
      final String bigram = second.substring(i, i + 2);
      final int count = firstBigrams.containsKey(bigram) ? firstBigrams[bigram]! : 0;
      if (count > 0) {
        firstBigrams[bigram] = count - 1;
        intersectionSize++;
      }
    }
    return (2.0 * intersectionSize) / (first.length + second.length - 2);
  }

  static BestMatch findBestMatch(String mainString, List<String> targetStrings) {
    final List<Rating> ratings = <Rating>[];
    int bestMatchIndex = 0;
    for (int i = 0; i < targetStrings.length; i++) {
      final String currentTargetString = targetStrings[i];
      final double currentRating = compareTwoStrings(mainString, currentTargetString);
      ratings.add(Rating(target: currentTargetString, rating: currentRating));
      if (currentRating > ratings[bestMatchIndex].rating) {
        bestMatchIndex = i;
      }
    }
    final Rating bestMatch = ratings[bestMatchIndex];
    return BestMatch(ratings: ratings, bestMatch: bestMatch, bestMatchIndex: bestMatchIndex);
  }

  static String escape(String src) {
    int i;
    int j;
    StringBuffer tmp = StringBuffer();
    for (i = 0; i < src.length; i++) {
      j = src.codeUnitAt(i);
      if (isDigit(String.fromCharCode(j)) || isLowerCase(String.fromCharCode(j)) || isUpperCase(String.fromCharCode(j))) {
        tmp.write(String.fromCharCode(j));
      } else if (j < 256) {
        tmp.write("%");
        if (j < 16) tmp.write("0");
        tmp.write(j.toRadixString(16));
      } else {
        tmp.write("%u");
        tmp.write(j.toRadixString(16));
      }
    }
    return tmp.toString();
  }

  static bool isDigit(String s) {
    if (s.isEmpty) {
      return false;
    }
    if (s.length > 1) {
      for (var r in s.runes) {
        if (r ^ 0x30 > 9) {
          return false;
        }
      }
      return true;
    } else {
      return s.runes.first ^ 0x30 <= 9;
    }
  }

  static bool isLowerCase(String s) {
    return s == s.toLowerCase();
  }

  static bool isUpperCase(String s) {
    return s == s.toUpperCase();
  }

  static bool isJsonType(String str) {
    bool result = false;
    if (!isBlank(str)) {
      str = str.trim();
      if (str.startsWith("{") && str.endsWith("}")) {
        result = true;
      } else if (str.startsWith("[") && str.endsWith("]")) {
        result = true;
      }
    }
    return result;
  }

  static bool isJsonObject(String text) {
    bool result = false;
    if (!isBlank(text)) {
      text = text.trim();
      if (text.startsWith("{") && text.endsWith("}")) {
        result = true;
      }
    }
    return result;
  }

  static bool isJsonArray(String text) {
    bool result = false;
    if (!isBlank(text)) {
      text = text.trim();
      if (text.startsWith("[") && text.endsWith("]")) {
        result = true;
      }
    }
    return result;
  }

  static bool isTrimEmpty(String? text) {
    if (text == null) return true;
    if (text.isEmpty) return true;
    return text.trim().isEmpty;
  }

  static bool startWithIgnoreCase(String? src, String? obj) {
    if (src == null || obj == null) return false;
    if (obj.length > src.length) return false;
    return src.substring(0, obj.length).toLowerCase() == obj.toLowerCase();
  }

  static bool endWithIgnoreCase(String? src, String? obj) {
    if (src == null || obj == null) return false;
    if (obj.length > src.length) return false;
    return src.substring(src.length - obj.length).toLowerCase() == obj.toLowerCase();
  }

  static String getBaseUrl(String? url) {
    if (url == null || !url.startsWith("http")) return "";
    int index = url.indexOf("/", 9);
    if (index == -1) {
      return url;
    }
    return url.substring(0, index);
  }

  // 移除字符串首尾空字符的高效方法(利用ASCII值判断,包括全角空格)
  static String trim(String s) {
    if (isBlank(s)) return "";
    int start = 0, len = s.length;
    int end = len - 1;
    while ((start < end) && ((s.codeUnitAt(start) <= 0x20) || (String.fromCharCode(s.codeUnitAt(start)) == '　'))) {
      ++start;
    }
    while ((start < end) && ((s.codeUnitAt(end) <= 0x20) || (String.fromCharCode(s.codeUnitAt(end)) == '　'))) {
      --end;
    }
    if (end < len) ++end;
    return ((start > 0) || (end < len)) ? s.substring(start, end) : s;
  }

  static String repeat(String str, int n) {
    String result = "";
    for (int i = 0; i < n; i++) {
      result += str;
    }
    return result;
  }

  static String formatHtmlString(String html) {
    if (isBlank(html)) return "";
    return html
        .replaceAll("　", "") //替换全角的空格键
//        .replaceAll(RegExp("<(br[\\s/]*|/*p.*?|/*div.*?)>", caseSensitive: false), "") // 替换特定标签为换行符
        .replaceAll(RegExp("<(br[\\s/]*|/?p[^>]*|/?div[^>]*)>", caseSensitive: false), "\n") // 替换特定标签为换行符
        .replaceAll(RegExp("<[script>]*.*?>|&nbsp;"), "") // 删除script标签对和空格转义符
        .replaceAll(RegExp("\\s*\\n+\\s*"), "") // 移除空行,并增加段前缩进2个汉字
        .replaceAll(RegExp("^[\\n\\s]+"), "") //移除开头空行,并增加段前缩进2个汉字
        .replaceAll(RegExp("[\\n\\s]+\$"), "") //移除尾部空行
        .trim();
  }

  static String formatContent(String html) {
    if (isBlank(html)) return "";
    return html
//        .replaceAll(RegExp("<(br[\\s/]*|/*p.*?|/*div.*?)>", caseSensitive: false), "\n") // 替换特定标签为换行符
        .replaceAll(RegExp("<(br[\\s/]*|/?p[^>]*|/?div[^>]*)>", caseSensitive: false), "\n") // 替换特定标签为换行符
        //.replaceAll(RegExp("<[script>]*.*?>|&nbsp;"), "")       // 删除script标签对和空格转义符
        .replaceAll(RegExp("<[script>]*[\\s\\S]*?>|&nbsp;"), "")  // 删除script标签对和空格转义符 [\s\S]匹配换行符
        .replaceAll("</?[a-zA-Z][^>]*>", "")                          // 删除标签对
        .replaceAll(RegExp("\\s*\\n+\\s*"), "\n　　") // 移除空行,并增加段前缩进2个汉字
        .replaceAll(RegExp("^[\\n\\s]+"), "　　") //移除开头空行,并增加段前缩进2个汉字
        .replaceAll(RegExp("[\\n\\s]+\$"), ""); //移除尾部空行
  }

  static String strJoin(List<String> listData, String delimiter) {
    String retVal = "";
    for (String str in listData) {
      retVal += str + delimiter;
    }
    if (retVal != "") retVal = retVal.substring(0, retVal.length - 1);
    return retVal;
  }

  static String getHrefTag(String url) {
    return "<a href='$url'>$url</a>";
  }

  static String getHrefTagList(List<String> urlList) {
    String retUrl = "[";
    for (String url in urlList) {
      retUrl += "<a href='$url'>$url</a>,";
    }
    if (retUrl.length > 1) retUrl = retUrl.substring(0, retUrl.length - 1);
    return "$retUrl]";
  }

  /// 字符串缩进
  static String getTextIndent(String str) {
    if (isBlank(str)) return "";
    str = str.trim();
    var array = str.split("\n");
    String retVal = "";
    for (int i = 0; i < array.length; i++) {
      if (isBlank(array[i])) continue;
      //去除空格键和全角空格键、html标签
      if (i == array.length - 1) {
        retVal += "　　${array[i].replaceAll("　", "").replaceAll(RegExp("\\s+"), "").replaceAll(RegExp("<[^>]*>"), "")}";
      } else {
        retVal += "　　${array[i].replaceAll("　", "").replaceAll(RegExp("\\s+"), "").replaceAll(RegExp("<[^>]*>"), "")}\n";
      }
    }
    return retVal;
  }

  ///日期格式转换
  static String getTimeStr(DateTime? date) {
    if (date == null) return "";
    int subTime = DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;
    if (subTime < limitTimeMillis) {
      return "刚刚";
    } else if (subTime < limitTimeSeconds) {
      return "${(subTime / limitTimeMillis).round()}秒前";
    } else if (subTime < limitTimeMinutes) {
      return "${(subTime / limitTimeSeconds).round()}分钟前";
    } else if (subTime < limitTimeHours) {
      return "${(subTime / limitTimeMinutes).round()}小时前";
    } else if (subTime < limitTimeDays) {
      return "${(subTime / limitTimeHours).round()}天前";
    } else if (subTime < limitTimeMonths) {
      return "${(subTime / limitTimeDays).round()}个月前";
    } else {
      return "${DateTime.now().year - date.year}年前";
    }
  }

  ///日期格式转换
  static String getFormatMinuteBySecond(int second) {
    int minute = (second / 60).floor();
    int retSecond = second % 60;
    final formatter = NumberFormat("00");
    return "${formatter.format(minute)}:${formatter.format(retSecond)}";
  }

  //判断内容是否有完整的<html>和</html>标签
  static String complementHtml(String html) {
    bool hasBegin = RegexUtils.hasHtmlBeginTag(html);
    bool hasEnd = RegexUtils.hasHtmlEndTag(html);
    if (hasBegin && !hasEnd) {
      return "$html</html>";
    } else if (!hasBegin && hasEnd) {
      return "<html>$html";
    } else if (!hasBegin && !hasEnd && html.contains("<!doctype html>")) {
      return "<html lang=\"\">$html</html>";
    }
    return html;
  }

  //将不标准的json转换
  static dynamic decodeJson(String jsonStr) {
    if (isBlank(jsonStr)) return "";
    dynamic decodeObj;
    try {
      decodeObj = json.decode(jsonStr);
    } catch (e) {
      try {
        print("json 转换失败，数据：$jsonStr");
        jsonStr = jsonStr.replaceAll("'", "\"");
        decodeObj = json.decode(jsonStr);
      } catch (e) {
        print("json 二次转换失败，数据：$jsonStr");
        //存在这种情况：{Referer:'http://m.xs63.com/search'}
        jsonStr = jsonStr
            .replaceAll("\"", "")
            .replaceAll("'", "")
            .replaceAll("https://", "zhangzhangzhangzhang")
            .replaceAll("http://", "asdfasdfasdfasdfasdf");
        try {
          RegExp exp = RegExp("([^\\:\\{\\}\\[\\]\\,]+)\:([^\\:\\,\\{\\}\\[\\]]*)");
          jsonStr = jsonStr.replaceAllMapped(exp, (Match m) => "\"${m[1]?.trim()}\":\"${m[2]?.trim()}\"");
          jsonStr = jsonStr.replaceAll("zhangzhangzhangzhang", "https://").replaceAll("asdfasdfasdfasdfasdf", "http://");
          decodeObj = json.decode(jsonStr);
        } catch (e) {
          print("json 三次转换失败，数据：$jsonStr");
          decodeObj = jsonStr;
        }
      }
    }
    return decodeObj;
  }

  //补存Table标签
  static dom.Element? addTableTag(final String rule, final String html, {String parentTag = ""}) {
    try {
      if (rule.contains("tr") ||
          rule.contains("td") ||
          rule.contains("tbody") ||
          rule.contains("th") ||
          rule.contains("tfoot") ||
          rule.contains("thead")) {
        String result = html;
        if (!RegExp("<table(\"[^\"]*\"|'[^']*'|[^'\">])*>").hasMatch(html)) {
          result = "<table>$result";
        }
        if (!RegExp("</table(\"[^\"]*\"|'[^']*'|[^'\">])*>").hasMatch(html)) {
          result = "$result</table>";
        }
        if (!isBlank(parentTag)) {
          return dom.Element.html("<$parentTag>$result</$parentTag>");
        } else {
          return dom.Element.html(result);
        }
      } else if (!isBlank(parentTag)) {
        return dom.Element.html("<$parentTag>$html</$parentTag>");
      } else {
        return dom.Element.html(html);
      }
    } catch (e) {
      return dom.Document.html(html).documentElement;
    }
  }

  //交换值
  static void swap(List<dynamic> list, int i, int j) {
    var temp = list[i];
    list[i] = list[j];
    list[j] = temp;
  }

  // 获取所有匹配的内容
  static List<Map<String, String>> getAllMatchList(String content, String matchVal) {
    List<Map<String, String>> retList = [];
    if (StringUtils.isEmpty(content)) return retList;
    int index = content.indexOf(matchVal);
    if (index == -1) {
      return retList;
    } else {
      int startPosition = 0, endPosition = 0;
      if (index - 10 < 0) {
        startPosition = 0;
      } else {
        startPosition = index - 10;
      }
      if (index + matchVal.length + 10 > content.length - 1) {
        endPosition = content.length;
      } else {
        endPosition = index + matchVal.length + 10;
      }
      retList.add({
        "contentStart": content.substring(startPosition, index).replaceAll("\r", "").replaceAll("\n", ""),
        "contentKey": matchVal,
        "contentEnd": content.substring(index + matchVal.length, endPosition).replaceAll("\r", "").replaceAll("\n", ""),
        "contentIndex": index.toString(),
      });
      String newContent = content.substring(endPosition);
      retList.addAll(getAllMatchList(newContent, matchVal));
      return retList;
    }
  }

  static String ruleReplaceFirst(String ruleStr, String replaceRegex, String replacement){
    if(replacement.contains("\$")){
      RegExp exp = RegexUtils.getRegExp(replaceRegex);
      ruleStr = exp.firstMatch(ruleStr)!.group(0)!.replaceFirstMapped(exp, (Match m){
        String tmpReplacement = replacement;
        for(int i = 1; i <= m.groupCount; i++){
          tmpReplacement = tmpReplacement.replaceAll("\$$i", m[i] ?? "");
        }
        if(tmpReplacement.contains("\$")) {
          return "";
        } else {
          return tmpReplacement;
        }
      });
    }else {
      ruleStr = ruleStr.replaceFirst(replaceRegex, replacement);
    }
    return ruleStr;
  }

  static String ruleReplaceAll(String ruleStr, String replaceRegex, String replacement){
    if(replacement.contains("\$")){
      RegExp exp = RegexUtils.getRegExp(replaceRegex);
      ruleStr = ruleStr.replaceAllMapped(exp, (Match m){
        String tmpReplacement = replacement;
        for(int i = 1; i <= m.groupCount; i++){
          tmpReplacement = tmpReplacement.replaceAll("\$$i", m[i] ?? "");
        }
        if(tmpReplacement.contains("\$")) {
          return "";
        } else {
          return tmpReplacement;
        }
      });
    }else {
      ruleStr = ruleStr.replaceAll(replaceRegex, replacement);
    }
    return ruleStr;
  }
}

class Rating {
  Rating({required this.target, required this.rating});

  String target;
  double rating;
}

class BestMatch {
  BestMatch({required this.ratings, required this.bestMatch, required this.bestMatchIndex});

  /// similarity rating for each target string
  List<Rating> ratings;

  /// specifies which target string was most similar to the main string
  Rating bestMatch;

  /// which specifies the index of the bestMatch in the targetStrings array
  int bestMatchIndex;
}
