// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_mark_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookMarkModel _$BookMarkModelFromJson(Map<String, dynamic> json) {
  return BookMarkModel()
    ..id = json['id'] as int
    ..bookUrl = json['bookUrl'] as String
    ..bookName = json['bookName'] as String
    ..chapterName = json['chapterName'] as String
    ..chapterIndex = json['chapterIndex'] as int
    ..chapterPos = json['chapterPos'] as int
    ..content = json['content'] as String;
}

Map<String, dynamic> _$BookMarkModelToJson(BookMarkModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookUrl': instance.bookUrl,
      'bookName': instance.bookName,
      'chapterName': instance.chapterName,
      'chapterIndex': instance.chapterIndex,
      'chapterPos': instance.chapterPos,
      'content': instance.content,
    };
