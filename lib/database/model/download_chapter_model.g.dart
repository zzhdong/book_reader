// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_chapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadChapterModel _$DownloadChapterModelFromJson(Map<String, dynamic> json) {
  return DownloadChapterModel()
    ..chapterUrl = json['chapterUrl'] as String
    ..bookUrl = json['bookUrl'] as String
    ..origin = json['origin'] as String
    ..originName = json['originName'] as String
    ..chapterTitle = json['chapterTitle'] as String
    ..chapterIndex = json['chapterIndex'] as int
    ..resourceUrl = json['resourceUrl'] as String
    ..variable = json['variable'] as String
    ..bookName = json['bookName'] as String;
}

Map<String, dynamic> _$DownloadChapterModelToJson(
        DownloadChapterModel instance) =>
    <String, dynamic>{
      'chapterUrl': instance.chapterUrl,
      'bookUrl': instance.bookUrl,
      'origin': instance.origin,
      'originName': instance.originName,
      'chapterTitle': instance.chapterTitle,
      'chapterIndex': instance.chapterIndex,
      'resourceUrl': instance.resourceUrl,
      'variable': instance.variable,
      'bookName': instance.bookName,
    };
