
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/module/book/analyze/analyze_rule.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/utils/regex_utils.dart';
import 'package:book_reader/utils/string_utils.dart';

class AnalyzeByRegex {

  // 纯java模式正则表达式获取书籍详情信息
  static Future<void> getInfoOfRegex(String res, List<String> regs, int index,
      BookModel bookModel, AnalyzeRule analyzer, BookSourceModel bookSourceModel, String tag) async {
    RegExp exp = RegexUtils.getRegExp(regs[index]);
    Iterable<Match> matches = exp.allMatches(res);
    String baseUrl = bookModel.bookUrl;
    // 判断规则是否有效,当搜索列表规则无效时跳过详情页处理
    if (!exp.hasMatch(res)) {
      MessageEventBus.handleBookSourceDebugEvent(0, "└详情预处理失败,跳过详情页解析");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取目录网址");
      bookModel.chapterUrl = baseUrl;
      bookModel.chapterUrl = res;
      MessageEventBus.handleBookSourceDebugEvent(0, "└$baseUrl");
      return;
    }
    // 判断索引的规则是最后一个规则
    if (index + 1 == regs.length) {
      // 获取规则列表
      Map<String, String> ruleMap = <String, String>{};
      ruleMap["BookName"] = bookSourceModel.ruleBookName;
      ruleMap["BookAuthor"] = bookSourceModel.ruleBookAuthor;
      ruleMap["BookKind"] = bookSourceModel.ruleBookKind;
      ruleMap["LastChapter"] = bookSourceModel.ruleBookLastChapter;
      ruleMap["Introduce"] = bookSourceModel.ruleIntroduce;
      ruleMap["CoverUrl"] = bookSourceModel.ruleCoverUrl;
      ruleMap["ChapterUrl"] = bookSourceModel.ruleChapterUrl;
      // 分离规则参数
      List<String> ruleName = [];
      List<List<String>> ruleParams = []; // 创建规则参数容器
      List<List<int>> ruleTypes = []; // 创建规则类型容器
      List<bool> hasVarParams = []; // 创建put&get标志容器
      for (String key in ruleMap.keys) {
        String val = ruleMap[key] ?? "";
        ruleName.add(key);
        hasVarParams.add(!StringUtils.isEmpty(val) && (val.contains("@put") || val.contains("@get")));
        List<String> ruleParam = [];
        List<int> ruleType = [];
        AnalyzeByRegex.splitRegexRule(val, ruleParam, ruleType);
        ruleParams.add(ruleParam);
        ruleTypes.add(ruleType);
      }
      // 提取规则内容
      Map<String, String> ruleVal = <String, String>{};
      String infoVal = "";
      for (int i = ruleParams.length; i-- > 0;) {
        List<String> ruleParam = ruleParams[i];
        List<int> ruleType = ruleTypes[i];
        infoVal = "";
        for (int j = ruleParam.length; j-- > 0;) {
          int regType = ruleType[j];
          if (regType > 0) {
            infoVal = (matches.elementAt(0).group(regType) ?? "") + infoVal;
          } else {
            infoVal = ruleParam[j] + infoVal;
          }
        }
        ruleVal[ruleName[i]] = hasVarParams[i] ? AnalyzeByRegex.checkKeys(infoVal.toString(), analyzer) : infoVal.toString();
      }
      // 保存详情信息
      if (!StringUtils.isEmpty(ruleVal["BookName"] ?? "")) bookModel.name = ruleVal["BookName"] ?? "";
      if (!StringUtils.isEmpty(ruleVal["BookAuthor"] ?? "")) bookModel.author = ruleVal["BookAuthor"] ?? "";
      if (!StringUtils.isEmpty(ruleVal["LastChapter"] ?? "")) bookModel.latestChapterTitle = ruleVal["LastChapter"] ?? "";
      if (!StringUtils.isEmpty(ruleVal["Introduce"] ?? "")) bookModel.intro = ruleVal["Introduce"] ?? "";
      if (!StringUtils.isEmpty(ruleVal["BookKind"] ?? "")) bookModel.kinds = ruleVal["BookKind"] ?? "";
      if (!StringUtils.isEmpty(ruleVal["CoverUrl"] ?? "")) bookModel.coverUrl = ruleVal["CoverUrl"] ?? "";
      if (!StringUtils.isEmpty(ruleVal["ChapterUrl"] ?? "")) {
        bookModel.chapterUrl = await ToolsPlugin.getAbsoluteURL(baseUrl, ruleVal["ChapterUrl"] ?? "");
      } else {
        bookModel.chapterUrl = baseUrl;
      }
      //如果目录页和详情页相同,暂存页面内容供获取目录用
      if (bookModel.chapterUrl == baseUrl) {
        bookModel.chapterHtml = res;
      }
      // 输出调试信息
      MessageEventBus.handleBookSourceDebugEvent(0, "└详情预处理完成");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取书籍名称");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${bookModel.name}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取作者名称");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${bookModel.author}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取分类信息");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${bookModel.kinds}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取最新章节");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${bookModel.getLatestChapterTitle()}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取简介内容");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${bookModel.intro}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取封面网址");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${bookModel.coverUrl}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取目录网址");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${bookModel.chapterUrl}");
      MessageEventBus.handleBookSourceDebugEvent(0, "✓详情页解析完成");
    } else {
      String result = "";
      for (var match in matches) {
        result += match.group(0) ?? "";
      }
      await getInfoOfRegex(
          result.toString(),
          regs,
          ++index,
          bookModel,
          analyzer,
          bookSourceModel,
          tag);
    }
  }

  // 拆分正则表达式替换规则(如:$\d{1,2}或${name}) /*注意:千万别用正则表达式拆分字符串,效率太低了!*/
  static void splitRegexRule(String str, final List<String> ruleParam, final List<int> ruleType) {
    if (StringUtils.isEmpty(str)) {
      ruleParam.add("");
      ruleType.add(0);
      return;
    }
    int index = 0,
        start = 0,
        len = str.length;
    while (index < len) {
      if (str[index] == '\$') {
        if (str[index + 1] == '{') {
          if (index > start) {
            ruleParam.add(str.substring(start, index));
            ruleType.add(0);
            start = index;
          }
          for (index += 2; index < len; index++) {
            if (str[index] == '}') {
              ruleParam.add(str.substring(start + 2, index));
              ruleType.add(-1);
              start = ++index;
              break;
            } else if (str[index] == '\$' || str[index] == '@') {
              break;
            }
          }
        } else if ((str.codeUnitAt(index + 1) >= 0x30) && (str.codeUnitAt(index + 1) <= 0x39)) {
          if (index > start) {
            ruleParam.add(str.substring(start, index));
            ruleType.add(0);
            start = index;
          }
          if ((index + 2 < len) && (str.codeUnitAt(index + 2) >= 0x30) && (str.codeUnitAt(index + 2) <= 0x39)) {
            ruleParam.add(str.substring(start, index + 3));
            ruleType.add(string2Int(ruleParam[ruleParam.length - 1]));
            start = index += 3;
          } else {
            ruleParam.add(str.substring(start, index + 2));
            ruleType.add(string2Int(ruleParam[ruleParam.length - 1]));
            start = index += 2;
          }
        } else {
          ++index;
        }
      } else {
        ++index;
      }
    }
    if (index > start) {
      ruleParam.add(str.substring(start, index));
      ruleType.add(0);
    }
  }

  // 存取字符串中的put&get参数
  static String checkKeys(String str, AnalyzeRule analyzer) {
    if (str.contains("@put:{")) {
      RegExp exp = RegExp("@put:\\{([^,]*):([^\\}]*)\\}");
      Iterable<Match> matches = exp.allMatches(str);
      for (var match in matches) {
        str = str.replaceAll(match.group(0) ?? "", "");
        analyzer.put(match.group(1) ?? "", match.group(2) ?? "");
      }
    }
    if (str.contains("@get:{")) {
      RegExp exp = RegExp("@get:\\{([^\\}]*)\\}");
      Iterable<Match> matches = exp.allMatches(str);
      for (var match in matches) {
        str = str.replaceAll(match.group(0) ?? "", analyzer.get(match.group(1) ?? "") ?? "");
      }
    }
    return str;
  }

  //String数字转int数字的高效方法(利用ASCII值判断)
  static int string2Int(String s) {
    int r = 0;
    int n;
    for (int i = 0, l = s.length; i < l; i++) {
      n = s.codeUnitAt(i);
      if (n >= 0x30 && n <= 0x39) {
        r = r * 10 + (n - 0x30); //'0-9'的ASCII值为0x30-0x39
      }
    }
    return r;
  }

}