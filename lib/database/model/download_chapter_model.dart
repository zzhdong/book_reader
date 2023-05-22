import 'package:json_annotation/json_annotation.dart';
import 'package:book_reader/database/model/base_chapter_model.dart';

part 'download_chapter_model.g.dart';

//章节列表
@JsonSerializable()
class DownloadChapterModel extends BaseChapterModel {

  @JsonKey(defaultValue: "")
  String bookName = "";

  DownloadChapterModel();
  
  factory DownloadChapterModel.fromJson(Map<String, dynamic> json) => _$DownloadChapterModelFromJson(json);

  Map<String, dynamic> toJson() => _$DownloadChapterModelToJson(this);

  DownloadChapterModel clone() {
    return DownloadChapterModel.fromJson(toJson());
  }
}
