// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookGroupModel _$BookGroupModelFromJson(Map<String, dynamic> json) {
  return BookGroupModel()
    ..groupId = json['groupId'] as int
    ..groupName = json['groupName'] as String
    ..totalNum = json['totalNum'] as int
    ..createDate = json['createDate'] as int
    ..isTop = json['isTop'] as int;
}

Map<String, dynamic> _$BookGroupModelToJson(BookGroupModel instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'totalNum': instance.totalNum,
      'createDate': instance.createDate,
      'isTop': instance.isTop,
    };
