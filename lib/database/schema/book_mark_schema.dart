import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/base_schema.dart';
import 'package:book_reader/database/model/book_mark_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:sqflite/sqflite.dart';

class BookMarkSchema extends BaseSchema {
  final String tableName = 'BookMark';

  String columnId = "id";
  String columnBookUrl = "bookUrl";
  String columnBookName = "bookName";
  String columnChapterName = "chapterName";
  String columnChapterIndex = "chapterIndex";
  String columnChapterPos = "chapterPos";
  String columnContent = "content";

  static BookMarkSchema getInstance = BookMarkSchema();

  @override
  getTableName() {
    return tableName;
  }

  @override
  createTableSql() {
    return '''
      CREATE TABLE $tableName ( 
        $columnId INTEGER PRIMARY KEY, 
        $columnBookUrl TEXT,
        $columnBookName TEXT,
        $columnChapterName TEXT,
        $columnChapterIndex INTEGER,
        $columnChapterPos INTEGER,
        $columnContent TEXT)
      ''';
  }

  /// 获取需要查询的字段
  _getAllColumns() {
    return [
      columnId,
      columnBookUrl,
      columnBookName,
      columnChapterName,
      columnChapterIndex,
      columnChapterPos,
      columnContent
    ];
  }

  Future<BookMarkModel?> getById(int? id) async {
    if(id == null) return BookMarkModel();
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnId = ?", whereArgs: [id]);
    if (maps.isNotEmpty) {
      return BookMarkModel.fromJson(maps.first);
    } else
      return null;
  }

  Future<BookMarkModel?> getByBookShelf(BookModel? book) async {
    if(book == null) return BookMarkModel();
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnBookUrl = ? and $columnChapterIndex = ? and $columnChapterPos = ? ",
        whereArgs: [book.bookUrl, book.getChapterIndex(), book.getDurChapterPos()]);
    if (maps.isNotEmpty) {
      return BookMarkModel.fromJson(maps.first);
    } else
      return null;
  }

  Future<bool> hasBookMark(String bookUrl, int durChapter, int durChapterPage) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> list = await db.rawQuery("select count(*) as count from $tableName where $columnBookUrl = '$bookUrl' and $columnChapterIndex = $durChapter and $columnChapterPos = $durChapterPage ");
    if(list.isNotEmpty) {
      return list[0]["count"] > 0;
    } else {
      return false;
    }
  }

  Future<List<BookMarkModel>> getByBookUrlOrName(String bookUrl, String name) async {
    List<BookMarkModel> resultList = [];
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnBookUrl = ? or $columnBookName = ? ",
        whereArgs: [bookUrl, name]);
    for(Map<String, dynamic> map in maps){
      resultList.add(BookMarkModel.fromJson(map));
    }
    return resultList;
  }

  ///插入到数据库
  Future<int> save(BookMarkModel? model) async {
    if(model == null) return 0;
    Database db = await getDataBase();
    BookMarkModel? obj = await getById(model.id);
    if(obj == null){
      if(AppConfig.APP_DEBUG_DATABASE) print('新增【BookMarkSchema】: ${model.toJson().toString()}');
      model.id = DateTime.now().millisecondsSinceEpoch;
      return await db.insert(tableName, model.toJson());
    }else{
      if(AppConfig.APP_DEBUG_DATABASE) print('更新【BookMarkSchema】: ${model.toJson().toString()}');
      return await db.update(tableName, model.toJson(), where: '$columnId = ?', whereArgs: [model.id]);
    }
  }

  ///删除
  Future<int> delete(BookMarkModel? model) async {
    if(model == null) return 0;
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('删除【BookMarkSchema】:${model.toJson().toString()}');
    return await db.delete(tableName, where: "$columnId = ?", whereArgs: [model.id]);
  }
}