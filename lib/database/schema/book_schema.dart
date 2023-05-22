import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/base_schema.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:sqflite/sqflite.dart';

class BookSchema extends BaseSchema {
  final String tableName = 'Book';

  String columnBookUrl = "bookUrl";
  String columnChapterUrl = "chapterUrl";
  String columnOrigin = "origin";
  String columnOriginName = "originName";
  String columnName = "name";
  String columnAuthor = "author";
  String columnCoverUrl = "coverUrl";
  String columnIntro = "intro";
  String columnLatestChapterTitle = "latestChapterTitle";
  String columnTotalChapterNum = "totalChapterNum";
  String columnKinds = "kinds";
  String columnType = "type";
  String columnVariable = "variable";
  String columnInfoHtml = "infoHtml";
  String columnChapterHtml = "chapterHtml";
  String columnCustomTag = "customTag";
  String columnCustomCoverUrl = "customCoverUrl";
  String columnCustomIntro = "customIntro";
  String columnCharset = "charset";
  String columnBookGroup = "bookGroup";
  String columnLatestChapterTime = "latestChapterTime";
  String columnLastCheckTime = "lastCheckTime";
  String columnLastCheckCount = "lastCheckCount";
  String columnDurChapterTitle = "durChapterTitle";
  String columnDurChapterIndex = "durChapterIndex";
  String columnDurChapterPos = "durChapterPos";
  String columnDurChapterTime = "durChapterTime";
  String columnUseReplaceRule = "useReplaceRule";
  String columnAllowUpdate = "allowUpdate";
  String columnHasUpdate = "hasUpdate";
  String columnSerialNumber = "serialNumber";
  String columnIsTop = "isTop";
  String columnIsEnd = "isEnd";

  static BookSchema getInstance = BookSchema();

  @override
  getTableName() {
    return tableName;
  }

  @override
  createTableSql() {
    return '''
      CREATE TABLE $tableName ( 
        $columnBookUrl TEXT PRIMARY KEY, 
        $columnChapterUrl TEXT,
        $columnOrigin TEXT,
        $columnOriginName TEXT,
        $columnName TEXT,
        $columnAuthor TEXT,
        $columnCoverUrl TEXT,
        $columnIntro TEXT,
        $columnLatestChapterTitle TEXT,
        $columnTotalChapterNum INTEGER,
        $columnKinds TEXT,
        $columnType INTEGER,
        $columnVariable TEXT,
        $columnInfoHtml TEXT,
        $columnChapterHtml TEXT,
        $columnCustomTag TEXT,
        $columnCustomCoverUrl TEXT,
        $columnCustomIntro TEXT,
        $columnCharset TEXT,
        $columnBookGroup INTEGER,
        $columnLatestChapterTime INTEGER,
        $columnLastCheckTime INTEGER,
        $columnLastCheckCount INTEGER,
        $columnDurChapterTitle TEXT,
        $columnDurChapterIndex INTEGER,
        $columnDurChapterPos INTEGER,
        $columnDurChapterTime INTEGER,
        $columnUseReplaceRule INTEGER,
        $columnAllowUpdate INTEGER,
        $columnHasUpdate INTEGER,
        $columnSerialNumber INTEGER,
        $columnIsTop INTEGER,
        $columnIsEnd INTEGER)
      ''';
  }

  /// 获取需要查询的字段
  _getAllColumns() {
    return [
      columnBookUrl,
      columnChapterUrl,
      columnOrigin,
      columnOriginName,
      columnName,
      columnAuthor,
      columnCoverUrl,
      columnIntro,
      columnLatestChapterTitle,
      columnTotalChapterNum,
      columnKinds,
      columnType,
      columnVariable,
      columnInfoHtml,
      columnChapterHtml,
      columnCustomTag,
      columnCustomCoverUrl,
      columnCustomIntro,
      columnCharset,
      columnBookGroup,
      columnLatestChapterTime,
      columnLastCheckTime,
      columnLastCheckCount,
      columnDurChapterTitle,
      columnDurChapterIndex,
      columnDurChapterPos,
      columnDurChapterTime,
      columnUseReplaceRule,
      columnAllowUpdate,
      columnHasUpdate,
      columnSerialNumber,
      columnIsTop,
      columnIsEnd
    ];
  }

  Future<List<BookModel>> getAllBooks() async {
    Database db = await getDataBase();
    List<BookModel> resultList = [];
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns());
    for(Map<String, dynamic> map in maps){
      resultList.add(BookModel.fromJson(map));
    }
    return resultList;
  }

  Future<BookModel?> getByBookUrl(String? bookUrl) async {
    if(bookUrl == null) return BookModel();
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnBookUrl = ?", whereArgs: [bookUrl]);
    if (maps.isNotEmpty) {
      BookModel model = BookModel.fromJson(maps.first);
      return model;
    } else {
      return null;
    }
  }

  Future<List<BookModel>> getBooksByGroup(int? bookGroup) async {
    List<BookModel> resultList = [];
    if(bookGroup == null) return resultList;
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnBookGroup = ?", whereArgs: [bookGroup], orderBy: "$columnIsTop DESC, $columnDurChapterTime DESC");
    for(Map<String, dynamic> map in maps){
      resultList.add(BookModel.fromJson(map));
    }
    return resultList;
  }

  ///删除
  Future<int> delete(BookModel? model) async {
    if(model == null) return 0;
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('删除【BookShelfSchema】: ${model.toJson().toString()}');
    return await db.delete(tableName, where: "$columnBookUrl = ?", whereArgs: [model.bookUrl]);
  }

  ///删除所有
  Future<int> deleteAll() async {
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('删除所有【BookShelfSchema】');
    return await db.delete(tableName);
  }


  ///插入到数据库
  Future save(BookModel? model) async {
    if(model == null) return;
    Database db = await getDataBase();
    BookModel? tmpModel = await getByBookUrl(model.bookUrl);
    //不存在，则插入数据库
    if (tmpModel == null) {
      if(AppConfig.APP_DEBUG_DATABASE) print('新增【BookShelfSchema】: ${model.toJson().toString()}');
      await db.insert(tableName, model.toJson());
    } else {
      //更新数据库
      if(AppConfig.APP_DEBUG_DATABASE) print('更新【BookShelfSchema】: ${model.toJson().toString()}');
      await db.update(tableName, model.toJson(), where: '$columnBookUrl = ?', whereArgs: [model.bookUrl]);
    }
  }

  ///更新归属组
  Future updateGroupToDefault(int groupId) async {
    Database db = await getDataBase();
    return await db.rawUpdate("update $tableName set $columnBookGroup = 0 WHERE $columnBookGroup = $groupId");
  }

  Future<int> getCountByGroupId(int groupId) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> list = await db.rawQuery("select count(*) as count from $tableName where $columnBookGroup = $groupId");
    if(list.isNotEmpty) {
      return list[0]["count"];
    } else {
      return 0;
    }
  }

  ///更新SerialNumber
  Future updateSerialNumber(String bookUrl, int serialNumber) async {
    Database db = await getDataBase();
    return await db.rawUpdate("update $tableName set $columnSerialNumber = $serialNumber WHERE $columnBookUrl = '$bookUrl'");
  }

  Future<int> getCountByBookName(String? bookName) async {
    if(bookName == null) return 0;
    Database db = await getDataBase();
    List<Map<String, dynamic>> list = await db.rawQuery("select count(*) as count from $tableName where $columnName = '$bookName'");
    if(list.isNotEmpty) {
      return list[0]["count"];
    } else {
      return 0;
    }
  }

  ///清空书籍封面
  Future clearBookCover(String bookUrl) async {
    Database db = await getDataBase();
    return await db.rawUpdate("update $tableName set $columnCoverUrl = '' WHERE $columnBookUrl = '$bookUrl'");
  }
}
