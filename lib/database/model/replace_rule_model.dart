import 'package:book_reader/utils/string_utils.dart';

class ReplaceRuleModel {

  int id = 0;

  String replaceSummary = "";                //描述

  String regex = "";                         //替换规则

  String replacement = "";                   //替换为

  String? useTo = "";                          //作用于

  int enable = 1;

  int isRegex = 1;

  int serialNumber = 0;

  ReplaceRuleModel();

  factory ReplaceRuleModel.fromJson(Map<String, dynamic> json){
    return ReplaceRuleModel()
      ..id = json['id'] as int
      ..replaceSummary = json['replaceSummary'] as String
      ..regex = json['regex'] as String
      ..replacement = json['replacement'] as String
      ..useTo = json['useTo'] as String?
      ..enable = StringUtils.objToInt(json['enable'], def: 1)
      ..isRegex = StringUtils.objToInt(json['isRegex'], def: 1)
      ..serialNumber = json['serialNumber'] as int;
  }

  Map<String, dynamic> toJson() =>
      <String, dynamic>{
        'id': id,
        'replaceSummary': replaceSummary,
        'regex': regex,
        'replacement': replacement,
        'useTo': useTo,
        'enable': enable,
        'isRegex': isRegex,
        'serialNumber': serialNumber,
      };

  ReplaceRuleModel clone() {
    return ReplaceRuleModel.fromJson(toJson());
  }

  int getId() => id;
  void setId(int id) => id = id;

  String getReplaceSummary() => replaceSummary;
  void setReplaceSummary(String replaceSummary) => replaceSummary = replaceSummary;

  String getRegex() => regex;
  void setRegex(String regex) => regex = regex;

  String getReplacement() => replacement;
  void setReplacement(String replacement) => replacement = replacement;

  String? getUseTo() => useTo;
  void setUseTo(String useTo) => useTo = useTo;

  bool getEnable() => enable == 1;
  void setEnable(bool enable) => this.enable = enable ? 1 : 0;

  bool getIsRegex() => isRegex == 1;
  void setIsRegex(bool isRegex) => this.isRegex = isRegex ? 1 : 0;

  int getSerialNumber() => serialNumber;
  void setSerialNumber(int serialNumber) => serialNumber = serialNumber;

  String getFixedRegex() {
    if (getIsRegex()) {
      return regex;
    } else {
      return regex;
    }
  }
}
