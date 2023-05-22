// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookModel _$BookModelFromJson(Map<String, dynamic> json) {
  return BookModel()
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
    ..customTag = json['customTag'] as String
    ..customCoverUrl = json['customCoverUrl'] as String
    ..customIntro = json['customIntro'] as String
    ..charset = json['charset'] as String
    ..bookGroup = json['bookGroup'] as int
    ..latestChapterTime = json['latestChapterTime'] as int
    ..lastCheckTime = json['lastCheckTime'] as int
    ..lastCheckCount = json['lastCheckCount'] as int
    ..durChapterTitle = json['durChapterTitle'] as String
    ..durChapterIndex = json['durChapterIndex'] as int
    ..durChapterPos = json['durChapterPos'] as int
    ..durChapterTime = json['durChapterTime'] as int
    ..useReplaceRule = json['useReplaceRule'] as int
    ..allowUpdate = json['allowUpdate'] as int
    ..hasUpdate = json['hasUpdate'] as int
    ..serialNumber = json['serialNumber'] as int
    ..isTop = json['isTop'] as int
    ..isEnd = json['isEnd'] as int;
}

Map<String, dynamic> _$BookModelToJson(BookModel instance) => <String, dynamic>{
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
      'customTag': instance.customTag,
      'customCoverUrl': instance.customCoverUrl,
      'customIntro': instance.customIntro,
      'charset': instance.charset,
      'bookGroup': instance.bookGroup,
      'latestChapterTime': instance.latestChapterTime,
      'lastCheckTime': instance.lastCheckTime,
      'lastCheckCount': instance.lastCheckCount,
      'durChapterTitle': instance.durChapterTitle,
      'durChapterIndex': instance.durChapterIndex,
      'durChapterPos': instance.durChapterPos,
      'durChapterTime': instance.durChapterTime,
      'useReplaceRule': instance.useReplaceRule,
      'allowUpdate': instance.allowUpdate,
      'hasUpdate': instance.hasUpdate,
      'serialNumber': instance.serialNumber,
      'isTop': instance.isTop,
      'isEnd': instance.isEnd,
    };
