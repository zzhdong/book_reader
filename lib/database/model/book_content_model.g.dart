// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_content_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookContentModel _$BookContentModelFromJson(Map<String, dynamic> json) {
  return BookContentModel()
    ..chapterUrl = json['chapterUrl'] as String
    ..bookUrl = json['bookUrl'] as String
    ..origin = json['origin'] as String
    ..chapterIndex = json['chapterIndex'] as int
    ..chapterContent = json['chapterContent'] as String
    ..nextContentUrl = json['nextContentUrl'] as String;
}

Map<String, dynamic> _$BookContentModelToJson(BookContentModel instance) =>
    <String, dynamic>{
      'chapterUrl': instance.chapterUrl,
      'bookUrl': instance.bookUrl,
      'origin': instance.origin,
      'chapterIndex': instance.chapterIndex,
      'chapterContent': instance.chapterContent,
      'nextContentUrl': instance.nextContentUrl,
    };
