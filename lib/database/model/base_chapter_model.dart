import 'package:json_annotation/json_annotation.dart';
import 'package:book_reader/common/app_config.dart';

abstract class BaseChapterModel{

  @JsonKey(defaultValue: "")
  String chapterUrl = "";                                       // 章节目录地址,本地目录正则
  @JsonKey(defaultValue: "")
  String bookUrl = "";                                          // 书籍详情页Url(本地书源存储完整文件路径)

  @JsonKey(defaultValue: AppConfig.BOOK_LOCAL_TAG)
  String origin = AppConfig.BOOK_LOCAL_TAG;                     // 书源URL(默认BOOK_LOCAL_TAG)
  @JsonKey(defaultValue: "")
  String originName = "";                                       // 书源名称 or 本地书籍文件名

  @JsonKey(defaultValue: "")
  String chapterTitle = "";                                     // 章节标题
  @JsonKey(defaultValue: 0)
  int chapterIndex = 0;                                         // 章节序号

  @JsonKey(defaultValue: "")
  String resourceUrl = "";                                      // 音频真实URL

  @JsonKey(defaultValue: "")
  String variable = "";                                         // 自定义变量信息

  int getChapterIndex() => chapterIndex;
}