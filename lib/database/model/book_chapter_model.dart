import 'package:json_annotation/json_annotation.dart';
import 'package:book_reader/database/model/base_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';

part 'book_chapter_model.g.dart';

//章节列表
@JsonSerializable()
class BookChapterModel extends BaseChapterModel {

  @JsonKey(defaultValue: "")
  String fullUrl = "";                 //当前章节对应的文章地址-完整

  @JsonKey(defaultValue: 0)
  int chapterStart = 0;               //章节内容在文章中的起始位置(本地)
  @JsonKey(defaultValue: 0)
  int chapterEnd = 0;                 //章节内容在文章中的终止位置(本地)

  BookChapterModel();

  factory BookChapterModel.fromJson(Map<String, dynamic> json) => _$BookChapterModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookChapterModelToJson(this);

  BookChapterModel clone() {
    return BookChapterModel.fromJson(toJson());
  }

  Future<bool> getHasCache(BookModel bookModel) async {
    return await BookUtils.isChapterCached(bookModel.name, origin, this);
  }
}