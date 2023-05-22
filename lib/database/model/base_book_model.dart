import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/utils/regex_utils.dart';
import 'package:book_reader/utils/string_utils.dart';

abstract class BaseBookModel{

  @JsonKey(defaultValue: "")
  String bookUrl = "";                                          // 书籍详情页Url(本地书源存储完整文件路径)
  @JsonKey(defaultValue: "")
  String chapterUrl = "";                                       // 章节目录地址,本地目录正则

  @JsonKey(defaultValue: AppConfig.BOOK_LOCAL_TAG)
  String origin = AppConfig.BOOK_LOCAL_TAG;                     // 书源URL(默认BOOK_LOCAL_TAG)
  @JsonKey(defaultValue: "")
  String originName = "";                                       // 书源名称 or 本地书籍文件名

  @JsonKey(defaultValue: "")
  String name = "";                                             // 书籍名称(书源获取)
  @JsonKey(defaultValue: "")
  String author = "";                                           // 作者名称(书源获取)
  @JsonKey(defaultValue: "")
  String coverUrl = "";                                         // 封面Url(书源获取)
  @JsonKey(defaultValue: "")
  String intro = "";                                            // 简介内容(书源获取)
  @JsonKey(defaultValue: "")
  String latestChapterTitle = "";                               // 最新章节标题
  @JsonKey(defaultValue: 0)
  int totalChapterNum = 0;                                      // 书籍目录总数

  @JsonKey(defaultValue: "")
  String kinds = "";                                            // 分类信息(书源获取)

  @JsonKey(defaultValue: 0)
  int type = 0;                                                 // 0:text 1:audio

  @JsonKey(defaultValue: "")
  String variable = "";                                         // 自定义书籍变量信息(用于书源规则检索书籍信息)

  @JsonKey(defaultValue: "")
  String infoHtml = "";                                         // 详情HTML内容
  @JsonKey(defaultValue: "")
  String chapterHtml = "";                                      // 章节HTML内容

  /// ################## 不需要写入数据库的内容 ######################## ///
  @JsonKey(ignore: true)
  String kind = "";                                             // 分类
  @JsonKey(ignore: true)
  String totalWords = "";                                       // 字数
  @JsonKey(ignore: true)
  String serializeState = "";                                   // 书籍连载状态
  @JsonKey(ignore: true)
  String updateTime = "";                                       // 更新时间
  @JsonKey(ignore: true)
  Map<String, dynamic> variableMap = <String, dynamic>{};

  bool isEpub() => (origin == AppConfig.BOOK_LOCAL_TAG) && RegExp(".*\\.epub\$").hasMatch(bookUrl.toLowerCase());

  bool isTxt() => (origin == AppConfig.BOOK_LOCAL_TAG) && RegExp(".*\\.txt\$").hasMatch(bookUrl.toLowerCase());

  bool isAudio() => type == 1;

  String getLatestChapterTitle() => latestChapterTitle;

  //author.replaceAll(RegExp("作\\s*者[\\s:：]*"), "").replaceAll(RegExp("\\s+"), " ").trim();
  String getRealAuthor() => author.replaceAll(AppConfig.gblAuthorPattern, "");

  void putVariable(String key, String value) {
    variableMap[key] = value;
    variable = jsonEncode(variableMap);
  }

  Map<String, dynamic> getVariableMap() {
    if (variableMap.isEmpty && !StringUtils.isEmpty(variable)) {
      variableMap = StringUtils.decodeJson(variable);
    }
    return variableMap;
  }

  void genKindList(){
    if (StringUtils.isEmpty(kinds)) return;
    for (String subKind in kinds.split(RegExp("[,|\n]"))) {
      if(RegexUtils.isDateTime(subKind)){
        updateTime = subKind;
      } else if (RegexUtils.isContainNumber(subKind) && StringUtils.isEmpty(totalWords)) {
        if (RegexUtils.isFloat(subKind)) {
          int words = StringUtils.stringToInt(subKind);
          if (words > 0) {
            totalWords = "${words.toString()}字";
            if (words > 10000) {
              totalWords = "${(words * 1.0 / 10000).toStringAsFixed(2)}万字";
            }
          }
        } else {
          totalWords = subKind;
        }
      } else if (RegExp(".*[连载|完结].*").hasMatch(subKind)) {
        serializeState = subKind;
      } else if (StringUtils.isEmpty(kind) && !StringUtils.isEmpty(subKind)) {
        kind = subKind;
      } else if (StringUtils.isEmpty(serializeState) && !StringUtils.isEmpty(subKind)) {
        serializeState = subKind;
      }
    }
  }

  String getKindString(bool addPrefix){
    if(kind == "") genKindList();
    String ret = "";
    if(!StringUtils.isEmpty(kind)) ret += "$kind | ";
    if(!StringUtils.isEmpty(serializeState)) ret += "$serializeState | ";
    if(!StringUtils.isEmpty(totalWords)) ret += "$totalWords | ";
    if(!StringUtils.isEmpty(updateTime)) ret += "$updateTime | ";
    if(ret.length > 2) ret = ret.substring(0, ret.length - 2);
    if(addPrefix && ret != "") ret = " | $ret";
    return ret;
  }

  String getKindNoTime(bool addPrefix){
    if(kind == "") genKindList();
    String ret = "";
    if(!StringUtils.isEmpty(kind)) ret += "$kind | ";
    if(!StringUtils.isEmpty(serializeState)) ret += "$serializeState | ";
    if(!StringUtils.isEmpty(totalWords)) ret += "$totalWords | ";
    if(ret.length > 2) return ret.substring(0, ret.length - 2);
    if(addPrefix) ret = " | $ret";
    return ret;
  }
}