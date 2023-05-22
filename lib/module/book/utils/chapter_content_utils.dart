import 'package:lpinyin/lpinyin.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/database/model/replace_rule_model.dart';
import 'package:book_reader/database/schema/replace_rule_schema.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/utils/string_utils.dart';

class ChapterContentUtils {

  List<ReplaceRuleModel> replaceRuleModelList = [];

  ChapterContentUtils(){
    ReplaceRuleSchema.getInstance.getReplaceRuleListByEnable().then((List<ReplaceRuleModel> list){
      replaceRuleModelList = list;
    });
  }

  ///替换净化
  String replaceContent(String bookName, String bookTag, String content) {
    if (!AppParams.getInstance().getReplaceEnableDefault()) return _toTraditional(content);
    if (replaceRuleModelList.isEmpty) return _toTraditional(content);
    //替换
    for (ReplaceRuleModel replaceRule in replaceRuleModelList) {
      if (_isUseTo(replaceRule.getUseTo() ?? "", bookTag, bookName)) {
        try {
          content = content.replaceAll(replaceRule.getFixedRegex(), replaceRule.getReplacement()).trim();
        } catch (e) {}
      }
    }
    return _toTraditional(content);
  }

  /// 转繁体
  String _toTraditional(String content) {
    int convertCTS = BookParams.getInstance().getTextConvert();
    switch (convertCTS) {
      case 0:
        break;
      case 1:
        content = ChineseHelper.convertToSimplifiedChinese(content);
        break;
      case 2:
        content = ChineseHelper.convertToTraditionalChinese(content);
        break;
    }
    return content;
  }

  ///替换净化
  Future<String> replaceContentAsync(String bookName, String bookTag, String content) async{
    if (!AppParams.getInstance().getReplaceEnableDefault()) return await _toTraditionalAsync(content);
    if (replaceRuleModelList.isEmpty) return await _toTraditionalAsync(content);
    //替换
    for (ReplaceRuleModel replaceRule in replaceRuleModelList) {
      if (_isUseTo(replaceRule.getUseTo() ?? "", bookTag, bookName)) {
        try {
          content = content.replaceAll(replaceRule.getFixedRegex(), replaceRule.getReplacement()).trim();
        } catch (e) {}
      }
    }
    return await _toTraditionalAsync(content);
  }

  Future<String> _toTraditionalAsync(String content) async{
    int convertCTS = BookParams.getInstance().getTextConvert();
    switch (convertCTS) {
      case 0:
        break;
      case 1:
        content = await ToolsPlugin.toSimplifiedChinese(content);
        break;
      case 2:
        content = await ToolsPlugin.toTraditionalChinese(content);
        break;
    }
    return content;
  }

  bool _isUseTo(String useTo, String bookTag, String bookName) {
    return StringUtils.isEmpty(useTo) || useTo.contains(bookTag) || useTo.contains(bookName);
  }
}
