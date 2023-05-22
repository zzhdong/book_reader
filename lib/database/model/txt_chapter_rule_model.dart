import 'package:json_annotation/json_annotation.dart';

part 'txt_chapter_rule_model.g.dart';

@JsonSerializable()
class TxtChapterRuleModel implements Comparable<TxtChapterRuleModel> {
  @JsonKey(defaultValue: "")
  String name = "";
  @JsonKey(defaultValue: "")
  String rule = "";
  @JsonKey(defaultValue: 0)
  int serialNumber = 0;
  @JsonKey(defaultValue: 0)
  int enable = 0;

  TxtChapterRuleModel({required String name, required String rule, required int serialNumber, required int enable}) {
    this.name = name;
    this.rule = rule;
    this.serialNumber = serialNumber;
    this.enable = enable;
  }

  factory TxtChapterRuleModel.fromJson(Map<String, dynamic> json) => _$TxtChapterRuleModelFromJson(json);

  Map<String, dynamic> toJson() => _$TxtChapterRuleModelToJson(this);

  TxtChapterRuleModel clone() {
    return TxtChapterRuleModel.fromJson(toJson());
  }

  String getName() => name;
  void setName(String name) => this.name = name;

  String getRule() => rule;
  void setRule(String rule) => this.rule = rule;

  int getSerialNumber() => serialNumber;
  void setSerialNumber(int serialNumber) => this.serialNumber = serialNumber;

  bool getEnable() => enable == 1;
  void setEnable(int enable) => this.enable = enable;

  @override
  int compareTo(TxtChapterRuleModel other) {
    bool b = (name == other.name) &&
        (rule == other.rule) &&
        (serialNumber == other.serialNumber) &&
        (enable == other.enable);
    if (b) {
      return 1;
    } else {
      return 0;
    }
  }
}
