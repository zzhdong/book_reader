// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadBookModel _$DownloadBookModelFromJson(Map<String, dynamic> json) {
  return DownloadBookModel()
    ..id = json['id'] as String
    ..bookName = json['bookName'] as String
    ..bookUrl = json['bookUrl'] as String
    ..coverUrl = json['coverUrl'] as String
    ..downloadCount = json['downloadCount'] as int
    ..chapterStart = json['chapterStart'] as int
    ..chapterEnd = json['chapterEnd'] as int
    ..successCount = json['successCount'] as int
    ..isValid = json['isValid'] as int
    ..finalDate = json['finalDate'] as int;
}

Map<String, dynamic> _$DownloadBookModelToJson(DownloadBookModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookName': instance.bookName,
      'bookUrl': instance.bookUrl,
      'coverUrl': instance.coverUrl,
      'downloadCount': instance.downloadCount,
      'chapterStart': instance.chapterStart,
      'chapterEnd': instance.chapterEnd,
      'successCount': instance.successCount,
      'isValid': instance.isValid,
      'finalDate': instance.finalDate,
    };
