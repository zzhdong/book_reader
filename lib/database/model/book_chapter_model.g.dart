// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_chapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookChapterModel _$BookChapterModelFromJson(Map<String, dynamic> json) {
  return BookChapterModel()
    ..chapterUrl = json['chapterUrl'] as String
    ..bookUrl = json['bookUrl'] as String
    ..origin = json['origin'] as String
    ..originName = json['originName'] as String
    ..chapterTitle = json['chapterTitle'] as String
    ..chapterIndex = json['chapterIndex'] as int
    ..resourceUrl = json['resourceUrl'] as String
    ..variable = json['variable'] as String
    ..fullUrl = json['fullUrl'] as String
    ..chapterStart = json['chapterStart'] as int
    ..chapterEnd = json['chapterEnd'] as int;
}

Map<String, dynamic> _$BookChapterModelToJson(BookChapterModel instance) =>
    <String, dynamic>{
      'chapterUrl': instance.chapterUrl,
      'bookUrl': instance.bookUrl,
      'origin': instance.origin,
      'originName': instance.originName,
      'chapterTitle': instance.chapterTitle,
      'chapterIndex': instance.chapterIndex,
      'resourceUrl': instance.resourceUrl,
      'variable': instance.variable,
      'fullUrl': instance.fullUrl,
      'chapterStart': instance.chapterStart,
      'chapterEnd': instance.chapterEnd,
    };
