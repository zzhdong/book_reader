import 'dart:async';
import 'dart:convert';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/base_schema.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:book_reader/database/schema/search_book_schema.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';

/// 书架
class BookSourceSchema extends BaseSchema {
  final String tableName = 'BookSource';

  final String columnBookSourceUrl = "bookSourceUrl";
  final String columnBookSourceName = "bookSourceName";
  final String columnBookSourceGroup = "bookSourceGroup";
  final String columnEnable = "enable";
  final String columnSearchForDetail = "searchForDetail";

  final String columnRuleFindUrl = "ruleFindUrl";
  final String columnRuleFindList = "ruleFindList";
  final String columnRuleFindName = "ruleFindName";
  final String columnRuleFindAuthor = "ruleFindAuthor";
  final String columnRuleFindKind = "ruleFindKind";
  final String columnRuleFindLastChapter = "ruleFindLastChapter";
  final String columnRuleFindIntroduce = "ruleFindIntroduce";
  final String columnRuleFindCoverUrl = "ruleFindCoverUrl";
  final String columnRuleFindNoteUrl = "ruleFindNoteUrl";

  final String columnRuleSearchUrl = "ruleSearchUrl";
  final String columnRuleBookUrlPattern = "ruleBookUrlPattern";
  final String columnRuleSearchList = "ruleSearchList";
  final String columnRuleSearchName = "ruleSearchName";
  final String columnRuleSearchAuthor = "ruleSearchAuthor";
  final String columnRuleSearchKind = "ruleSearchKind";
  final String columnRuleSearchLastChapter = "ruleSearchLastChapter";
  final String columnRuleSearchIntroduce = "ruleSearchIntroduce";
  final String columnRuleSearchCoverUrl = "ruleSearchCoverUrl";
  final String columnRuleSearchNoteUrl = "ruleSearchNoteUrl";

  final String columnRuleBookInfoInit = "ruleBookInfoInit";
  final String columnRuleChapterName = "ruleChapterName";
  final String columnRuleBookAuthor = "ruleBookAuthor";
  final String columnRuleBookKind = "ruleBookKind";
  final String columnRuleBookLastChapter = "ruleBookLastChapter";
  final String columnRuleIntroduce = "ruleIntroduce";
  final String columnRuleCoverUrl = "ruleCoverUrl";
  final String columnRuleChapterUrl = "ruleChapterUrl";

  final String columnRuleChapterUrlNext = "ruleChapterUrlNext";
  final String columnRuleChapterList = "ruleChapterList";
  final String columnRuleBookName = "ruleBookName";
  final String columnRuleContentUrl = "ruleContentUrl";

  final String columnRuleBookContent = "ruleBookContent";
  final String columnRuleContentUrlNext = "ruleContentUrlNext";

  final String columnSerialNumber = "serialNumber";
  final String columnWeight = "weight";
  final String columnBookSourceType = "bookSourceType";
  final String columnLoginUrl = "loginUrl";
  final String columnHttpUserAgent = "httpUserAgent";

  final String columnIsTop = "isTop";
  final String columnSaveTime = "saveTime";

  static BookSourceSchema getInstance = BookSourceSchema();

  @override
  getTableName() {
    return tableName;
  }

  BookSourceModel fromMap(Map map) {
    BookSourceModel model = BookSourceModel();
    model.bookSourceUrl = map[columnBookSourceUrl] ?? "";
    model.bookSourceGroup = map[columnBookSourceGroup] ?? "";
    model.bookSourceName = map[columnBookSourceName] ?? "";
    if (map[columnEnable] is bool) {
      model.enable = map[columnEnable] ? 1 : 0;
    } else {
      model.enable = map[columnEnable] == 1 ? 1 : 0;
    }
    if (map[columnSearchForDetail] is bool) {
      model.searchForDetail = map[columnSearchForDetail] ? 1 : 0;
    } else {
      model.searchForDetail = map[columnSearchForDetail] == 1 ? 1 : 0;
    }

    model.ruleFindUrl = map[columnRuleFindUrl] ?? "";
    model.ruleFindList = map[columnRuleFindList] ?? "";
    model.ruleFindName = map[columnRuleFindName] ?? "";
    model.ruleFindAuthor = map[columnRuleFindAuthor] ?? "";
    model.ruleFindKind = map[columnRuleFindKind] ?? "";
    model.ruleFindLastChapter = map[columnRuleFindLastChapter] ?? "";
    model.ruleFindIntroduce = map[columnRuleFindIntroduce] ?? "";
    model.ruleFindCoverUrl = map[columnRuleFindCoverUrl] ?? "";
    model.ruleFindNoteUrl = map[columnRuleFindNoteUrl] ?? "";

    model.ruleSearchUrl = map[columnRuleSearchUrl] ?? "";
    model.ruleBookUrlPattern = map[columnRuleBookUrlPattern] ?? "";
    model.ruleSearchList = map[columnRuleSearchList] ?? "";
    model.ruleSearchName = map[columnRuleSearchName] ?? "";
    model.ruleSearchAuthor = map[columnRuleSearchAuthor] ?? "";
    model.ruleSearchKind = map[columnRuleSearchKind] ?? "";
    model.ruleSearchLastChapter = map[columnRuleSearchLastChapter] ?? "";
    model.ruleSearchIntroduce = map[columnRuleSearchIntroduce] ?? "";
    model.ruleSearchCoverUrl = map[columnRuleSearchCoverUrl] ?? "";
    model.ruleSearchNoteUrl = map[columnRuleSearchNoteUrl] ?? "";

    model.ruleBookInfoInit = map[columnRuleBookInfoInit] ?? "";
    model.ruleBookName = map[columnRuleBookName] ?? "";
    model.ruleBookAuthor = map[columnRuleBookAuthor] ?? "";
    model.ruleBookKind = map[columnRuleBookKind] ?? "";
    model.ruleBookLastChapter = map[columnRuleBookLastChapter] ?? "";
    model.ruleIntroduce = map[columnRuleIntroduce] ?? "";
    model.ruleCoverUrl = map[columnRuleCoverUrl] ?? "";
    model.ruleChapterUrl = map[columnRuleChapterUrl] ?? "";

    model.ruleChapterUrlNext = map[columnRuleChapterUrlNext] ?? "";
    model.ruleChapterList = map[columnRuleChapterList] ?? "";
    model.ruleChapterName = map[columnRuleChapterName] ?? "";
    model.ruleContentUrl = map[columnRuleContentUrl] ?? "";

    model.ruleBookContent = map[columnRuleBookContent] ?? "";
    model.ruleContentUrlNext = map[columnRuleContentUrlNext] ?? "";

    model.serialNumber = map[columnSerialNumber] ?? 0;
    model.weight = map[columnWeight] ?? 0;
    model.bookSourceType = map[columnBookSourceType] ?? "";
    model.loginUrl = map[columnLoginUrl] ?? "";
    model.httpUserAgent = map[columnHttpUserAgent] ?? "";

    if (map[columnIsTop] == null) {
      model.isTop = 0;
    } else {
      model.isTop = map[columnIsTop] ?? 0;
    }
    if (map[columnSaveTime] == null) {
      model.saveTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      model.saveTime = map[columnSaveTime] ?? DateTime.now().millisecondsSinceEpoch;
    }
    return model;
  }

  Map<String, dynamic> toMap(BookSourceModel model) {
    Map<String, dynamic> map = {
      columnBookSourceUrl: model.bookSourceUrl,
      columnBookSourceGroup: model.bookSourceGroup,
      columnBookSourceName: model.bookSourceName,
      columnEnable: model.enable,
      columnSearchForDetail: model.searchForDetail,
      columnRuleFindUrl: model.ruleFindUrl,
      columnRuleFindList: model.ruleFindList,
      columnRuleFindName: model.ruleFindName,
      columnRuleFindAuthor: model.ruleFindAuthor,
      columnRuleFindKind: model.ruleFindKind,
      columnRuleFindLastChapter: model.ruleFindLastChapter,
      columnRuleFindIntroduce: model.ruleFindIntroduce,
      columnRuleFindCoverUrl: model.ruleFindCoverUrl,
      columnRuleFindNoteUrl: model.ruleFindNoteUrl,
      columnRuleSearchUrl: model.ruleSearchUrl,
      columnRuleBookUrlPattern: model.ruleBookUrlPattern,
      columnRuleSearchList: model.ruleSearchList,
      columnRuleSearchName: model.ruleSearchName,
      columnRuleSearchAuthor: model.ruleSearchAuthor,
      columnRuleSearchKind: model.ruleSearchKind,
      columnRuleSearchLastChapter: model.ruleSearchLastChapter,
      columnRuleSearchIntroduce: model.ruleSearchIntroduce,
      columnRuleSearchCoverUrl: model.ruleSearchCoverUrl,
      columnRuleSearchNoteUrl: model.ruleSearchNoteUrl,
      columnRuleBookInfoInit: model.ruleBookInfoInit,
      columnRuleBookName: model.ruleBookName,
      columnRuleBookAuthor: model.ruleBookAuthor,
      columnRuleBookKind: model.ruleBookKind,
      columnRuleBookLastChapter: model.ruleBookLastChapter,
      columnRuleIntroduce: model.ruleIntroduce,
      columnRuleCoverUrl: model.ruleCoverUrl,
      columnRuleChapterUrl: model.ruleChapterUrl,
      columnRuleChapterUrlNext: model.ruleChapterUrlNext,
      columnRuleChapterList: model.ruleChapterList,
      columnRuleChapterName: model.ruleChapterName,
      columnRuleContentUrl: model.ruleContentUrl,
      columnRuleBookContent: model.ruleBookContent,
      columnRuleContentUrlNext: model.ruleContentUrlNext,
      columnSerialNumber: model.serialNumber,
      columnWeight: model.weight,
      columnLoginUrl: model.loginUrl,
      columnBookSourceType: model.bookSourceType,
      columnHttpUserAgent: model.httpUserAgent,
      columnIsTop: model.isTop,
      columnSaveTime: model.saveTime
    };
    if (model.bookSourceUrl.isNotEmpty) {
      map[columnBookSourceUrl] = model.bookSourceUrl;
    }
    return map;
  }

  @override
  createTableSql() {
    return '''
      CREATE TABLE $tableName ( 
        $columnBookSourceUrl TEXT PRIMARY KEY, 
        $columnBookSourceGroup TEXT,
        $columnBookSourceName TEXT,
        $columnEnable INTEGER,
        $columnSearchForDetail INTEGER,
        $columnRuleFindUrl TEXT,
        $columnRuleFindList TEXT,
        $columnRuleFindName TEXT,
        $columnRuleFindAuthor TEXT,
        $columnRuleFindKind TEXT,
        $columnRuleFindLastChapter TEXT,
        $columnRuleFindIntroduce TEXT,
        $columnRuleFindCoverUrl TEXT,
        $columnRuleFindNoteUrl TEXT,
        $columnRuleSearchUrl TEXT,
        $columnRuleBookUrlPattern TEXT,
        $columnRuleSearchList TEXT,
        $columnRuleSearchName TEXT,
        $columnRuleSearchAuthor TEXT,
        $columnRuleSearchKind TEXT,
        $columnRuleSearchLastChapter TEXT,
        $columnRuleSearchIntroduce TEXT,
        $columnRuleSearchCoverUrl TEXT,
        $columnRuleSearchNoteUrl TEXT,
        $columnRuleBookInfoInit TEXT,
        $columnRuleBookName TEXT,
        $columnRuleBookAuthor TEXT,
        $columnRuleBookKind TEXT,
        $columnRuleBookLastChapter TEXT,
        $columnRuleIntroduce TEXT,
        $columnRuleCoverUrl TEXT,
        $columnRuleChapterUrl TEXT,
        $columnRuleChapterUrlNext TEXT,
        $columnRuleChapterList TEXT,
        $columnRuleChapterName TEXT,
        $columnRuleContentUrl TEXT,
        $columnRuleBookContent TEXT,
        $columnRuleContentUrlNext TEXT,
        $columnSerialNumber INTEGER,
        $columnWeight INTEGER,
        $columnBookSourceType TEXT,
        $columnLoginUrl TEXT,
        $columnHttpUserAgent TEXT,
        $columnIsTop INTEGER,
        $columnSaveTime INTEGER)
      ''';
  }

  /// 获取需要查询的字段
  _getAllColumns() {
    return [
      columnBookSourceUrl,
      columnBookSourceGroup,
      columnBookSourceName,
      columnEnable,
      columnSearchForDetail,
      columnRuleFindUrl,
      columnRuleFindList,
      columnRuleFindName,
      columnRuleFindAuthor,
      columnRuleFindKind,
      columnRuleFindLastChapter,
      columnRuleFindIntroduce,
      columnRuleFindCoverUrl,
      columnRuleFindNoteUrl,
      columnRuleSearchUrl,
      columnRuleBookUrlPattern,
      columnRuleSearchList,
      columnRuleSearchName,
      columnRuleSearchAuthor,
      columnRuleSearchKind,
      columnRuleSearchLastChapter,
      columnRuleSearchIntroduce,
      columnRuleSearchCoverUrl,
      columnRuleSearchNoteUrl,
      columnRuleBookInfoInit,
      columnRuleBookName,
      columnRuleBookAuthor,
      columnRuleBookKind,
      columnRuleBookLastChapter,
      columnRuleIntroduce,
      columnRuleCoverUrl,
      columnRuleChapterUrl,
      columnRuleChapterUrlNext,
      columnRuleChapterList,
      columnRuleChapterName,
      columnRuleContentUrl,
      columnRuleBookContent,
      columnRuleContentUrlNext,
      columnSerialNumber,
      columnWeight,
      columnBookSourceType,
      columnLoginUrl,
      columnHttpUserAgent,
      columnIsTop,
      columnSaveTime
    ];
  }

  Future<BookSourceModel?> getByBookSourceUrl(String? bookSourceUrl) async {
    if (bookSourceUrl == null) return BookSourceModel();
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnBookSourceUrl = ?", whereArgs: [bookSourceUrl]);
    if (maps.isNotEmpty) {
      BookSourceModel model = fromMap(maps.first);
      return model;
    } else {
      return null;
    }
  }

  ///插入到数据库
  Future<int> saveBookSource(BookSourceModel? model) async {
    if (model == null) return 0;
    Database db = await getDataBase();
    if (AppConfig.APP_DEBUG_DATABASE) print('新增【BookSourceSchema】: ${toMap(model).toString()}');
    return await db.insert(tableName, toMap(model));
  }

  ///插入到数据库
  Future<int> updateBookSource(BookSourceModel? model, {BookSourceModel? oldModel}) async {
    if (model == null) return 0;
    Database db = await getDataBase();
    model.saveTime = DateTime.now().millisecondsSinceEpoch;
    if (oldModel != null && oldModel.bookSourceUrl != model.bookSourceUrl) {
      //删除旧书源，创建新书源
      await delBookSource(oldModel);
      return await saveBookSource(model);
    } else {
      if (AppConfig.APP_DEBUG_DATABASE) print('更新【BookSourceSchema】: ${toMap(model).toString()}');
      return await db.update(tableName, toMap(model), where: '$columnBookSourceUrl = ?', whereArgs: [model.bookSourceUrl]);
    }
  }

  ///删除
  Future<int> delBookSource(BookSourceModel? model) async {
    if (model == null) return 0;
    Database db = await getDataBase();
    if (AppConfig.APP_DEBUG_DATABASE) print('删除【BookSourceSchema】: ${toMap(model).toString()}');
    //删除保存后的搜索内容
    await SearchBookSchema.getInstance.deleteByOrigin(model.bookSourceUrl);
    return await db.delete(tableName, where: "$columnBookSourceUrl = ?", whereArgs: [model.bookSourceUrl]);
  }

  ///删除
  Future<int> delBookSourceByUrl(String bookSourceUrl) async {
    Database db = await getDataBase();
    if (AppConfig.APP_DEBUG_DATABASE) print('删除【BookSourceSchema】: $bookSourceUrl');
    //删除保存后的搜索内容
    await SearchBookSchema.getInstance.deleteByOrigin(bookSourceUrl);
    return await db.delete(tableName, where: "$columnBookSourceUrl = ?", whereArgs: [bookSourceUrl]);
  }

  ///更新状态
  Future<int> setEnableStatus(String bookSourceUrl, int enable) async {
    Database db = await getDataBase();
    if (AppConfig.APP_DEBUG_DATABASE) print('更新状态【BookSourceSchema】: $bookSourceUrl | ${enable.toString()}');
    return await db.update(tableName, {columnEnable: enable}, where: "$columnBookSourceUrl = ?", whereArgs: [bookSourceUrl]);
  }

  /// 书源列表
  Future<List<BookSourceModel>> getBookSourceList(int? page, {String? groupName}) async {
    page ??= 1;
    Database db = await getDataBase();
    List<BookSourceModel> resultList = [];
    List<Map<String, dynamic>> maps = [];
    if (page == -1) {
      if (groupName == null) {
        maps = await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC");
      } else if (groupName == AppConfig.BOOKSOURCE_SEARCH_FOR_DETAIL) {
        maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnSearchForDetail = ?", whereArgs: [1], orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC");
      } else {
        maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnBookSourceGroup = ?", whereArgs: [groupName], orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC");
      }
    } else {
      if (groupName == null) {
        maps = await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC", offset: page * AppConfig.APP_LIST_PAGE_SIZE, limit: AppConfig.APP_LIST_PAGE_SIZE);
      } else if (groupName == AppConfig.BOOKSOURCE_SEARCH_FOR_DETAIL) {
        maps = await db.query(tableName,
            columns: _getAllColumns(), where: "$columnSearchForDetail = ?", whereArgs: [1], orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC", offset: page * AppConfig.APP_LIST_PAGE_SIZE, limit: AppConfig.APP_LIST_PAGE_SIZE);
      } else {
        maps = await db.query(tableName,
            columns: _getAllColumns(),
            where: "$columnBookSourceGroup = ?",
            whereArgs: [groupName],
            orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC",
            offset: page * AppConfig.APP_LIST_PAGE_SIZE,
            limit: AppConfig.APP_LIST_PAGE_SIZE);
      }
    }
    for (Map<String, dynamic> map in maps) {
      resultList.add(fromMap(map));
    }
    return BookUtils.bookSourceOrder(resultList);
  }

  //根据书籍名称查询
  Future<List<BookSourceModel>> getByBookSourceListLikeName(String? bookSourceName, {String? groupName}) async {
    List<BookSourceModel> resultList = [];
    if (bookSourceName == null) return resultList;
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = [];
    if (groupName == null) {
      maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnBookSourceName LIKE ?", whereArgs: ["%$bookSourceName%"], orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC");
    } else if (groupName == AppConfig.BOOKSOURCE_SEARCH_FOR_DETAIL) {
      maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnBookSourceName LIKE ? and $columnSearchForDetail = ?", whereArgs: ["%$bookSourceName%", 1], orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC");
    } else {
      maps =
          await db.query(tableName, columns: _getAllColumns(), where: "$columnBookSourceName LIKE ? and $columnBookSourceGroup = ?", whereArgs: ["%$bookSourceName%", groupName], orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC");
    }
    for (Map<String, dynamic> map in maps) {
      resultList.add(fromMap(map));
    }
    return BookUtils.bookSourceOrder(resultList);
  }

  //根据书籍名称查询
  Future<List<BookSourceModel>> getByBookSourceGroup() async {
    List<BookSourceModel> resultList = [];
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), groupBy: columnBookSourceGroup, orderBy: "$columnBookSourceGroup ASC");
    for (Map<String, dynamic> map in maps) {
      resultList.add(fromMap(map));
    }
    return BookUtils.bookSourceOrder(resultList);
  }

  //根据书籍名称查询
  Future<List<BookSourceModel>> getByBookSourceGroupByName(String? groupName) async {
    List<BookSourceModel> resultList = [];
    if (groupName == null) return resultList;
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnBookSourceGroup = ?", whereArgs: [groupName], groupBy: columnBookSourceGroup, orderBy: "$columnBookSourceGroup ASC");
    for (Map<String, dynamic> map in maps) {
      resultList.add(fromMap(map));
    }
    return BookUtils.bookSourceOrder(resultList);
  }

  //根据书籍名称查询
  Future<List<BookSourceModel>> getByBookSourceGroupByLikeName(String? groupName) async {
    List<BookSourceModel> resultList = [];
    if (groupName == null) return resultList;
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnBookSourceGroup LIKE ?", whereArgs: ["%$groupName%"], groupBy: columnBookSourceGroup, orderBy: "$columnBookSourceGroup ASC");
    for (Map<String, dynamic> map in maps) {
      resultList.add(fromMap(map));
    }
    return BookUtils.bookSourceOrder(resultList);
  }

  /// 获取已勾选的书源列表
  Future<List<BookSourceModel>> getBookSourceListByEnable({String? groupName}) async {
    Database db = await getDataBase();
    List<BookSourceModel> resultList = [];
    List<Map<String, dynamic>> maps = [];
    if (groupName == null) {
      maps = await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC", where: "$columnEnable = ?", whereArgs: [1]);
    } else if (groupName == AppConfig.BOOKSOURCE_SEARCH_FOR_DETAIL) {
      maps = await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC", where: "$columnEnable = ? and $columnSearchForDetail = ?", whereArgs: [1, 1]);
    } else {
      maps = await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC", where: "$columnEnable = ? and $columnBookSourceGroup = ?", whereArgs: [1, groupName]);
    }
    for (Map<String, dynamic> map in maps) {
      resultList.add(fromMap(map));
    }
    return BookUtils.bookSourceOrder(resultList);
  }

  /// 导出已勾选的书源列表
  Future<List<String>> exportBookSourceListBySelect(List<String> idList) async {
    Database db = await getDataBase();
    List<String> resultList = [];
    List<Map<String, dynamic>> maps = [];
    for (String id in idList) {
      maps.addAll(await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC", where: "$columnBookSourceUrl  = ?", whereArgs: [id]));
    }
    for (Map<String, dynamic> map in maps) {
      Map tmpMap = Map.from(map);
      if (tmpMap[columnEnable] == 1) {
        tmpMap[columnEnable] = true;
      } else {
        tmpMap[columnEnable] = false;
      }
      resultList.add(jsonEncode(tmpMap));
    }
    return resultList;
  }

  /// 获取用于搜索详情的书源(searchForDetail优先排在前面)
  Future<List<BookSourceModel>> getToSearchDetailList() async {
    Database db = await getDataBase();
    List<BookSourceModel> resultList1 = [];
    List<BookSourceModel> resultList2 = [];
    List<Map<String, dynamic>> maps1 = await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC", where: "$columnEnable = ? and $columnSearchForDetail = ?", whereArgs: [1, 1]);
    List<Map<String, dynamic>> maps2 = await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnIsTop DESC, $columnSaveTime DESC, $columnWeight DESC", where: "$columnEnable = ? and $columnSearchForDetail = ?", whereArgs: [1, 0]);
    for (Map<String, dynamic> map in maps1) {
      resultList1.add(fromMap(map));
    }
    for (Map<String, dynamic> map in maps2) {
      resultList2.add(fromMap(map));
    }
    List<BookSourceModel> retBookSource = [];
    retBookSource.addAll(BookUtils.bookSourceOrder(resultList1));
    retBookSource.addAll(BookUtils.bookSourceOrder(resultList2));
    return retBookSource;
  }
}
