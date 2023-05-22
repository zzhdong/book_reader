// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchBookModel _$SearchBookModelFromJson(Map<String, dynamic> json) {
  return SearchBookModel()
    ..bookUrl = json['bookUrl'] as String
    ..chapterUrl = json['chapterUrl'] as String
    ..origin = json['origin'] as String
    ..originName = json['originName'] as String
    ..name = json['name'] as String
    ..author = json['author'] as String
    ..coverUrl = json['coverUrl'] as String
    ..intro = json['intro'] as String
    ..latestChapterTitle = json['latestChapterTitle'] as String
    ..totalChapterNum = json['totalChapterNum'] as int
    ..kinds = json['kinds'] as String
    ..type = json['type'] as int
    ..variable = json['variable'] as String
    ..infoHtml = json['infoHtml'] as String
    ..chapterHtml = json['chapterHtml'] as String
    ..addTime = json['addTime'] as int
    ..upTime = json['upTime'] as int
    ..accessSpeed = json['accessSpeed'] as int
    ..searchTime = json['searchTime'] as int;
}

Map<String, dynamic> _$SearchBookModelToJson(SearchBookModel instance) =>
    <String, dynamic>{
      'bookUrl': instance.bookUrl,
      'chapterUrl': instance.chapterUrl,
      'origin': instance.origin,
      'originName': instance.originName,
      'name': instance.name,
      'author': instance.author,
      'coverUrl': instance.coverUrl,
      'intro': instance.intro,
      'latestChapterTitle': instance.latestChapterTitle,
      'totalChapterNum': instance.totalChapterNum,
      'kinds': instance.kinds,
      'type': instance.type,
      'variable': instance.variable,
      'infoHtml': instance.infoHtml,
      'chapterHtml': instance.chapterHtml,
      'addTime': instance.addTime,
      'upTime': instance.upTime,
      'accessSpeed': instance.accessSpeed,
      'searchTime': instance.searchTime,
    };
