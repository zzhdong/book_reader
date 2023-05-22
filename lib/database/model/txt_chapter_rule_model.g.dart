// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'txt_chapter_rule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TxtChapterRuleModel _$TxtChapterRuleModelFromJson(Map<String, dynamic> json) {
  return TxtChapterRuleModel(
    name: json['name'] as String,
    rule: json['rule'] as String,
    serialNumber: json['serialNumber'] as int,
    enable: json['enable'] as int,
  );
}

Map<String, dynamic> _$TxtChapterRuleModelToJson(
        TxtChapterRuleModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'rule': instance.rule,
      'serialNumber': instance.serialNumber,
      'enable': instance.enable,
    };
