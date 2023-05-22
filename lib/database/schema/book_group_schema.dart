import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/base_schema.dart';
import 'package:book_reader/database/model/book_group_model.dart';
import 'package:sqflite/sqflite.dart';
import 'book_schema.dart';

class BookGroupSchema extends BaseSchema {
  final String tableName = 'BookGroup';

  String columnGroupId = "groupId";
  String columnGroupName = "groupName";
  String columnTotalNum = "totalNum";
  String columnCreateDate = "createDate";
  String columnIsTop = "isTop";

  static BookGroupSchema getInstance = BookGroupSchema();

  @override
  getTableName() {
    return tableName;
  }

  @override
  createTableSql() {
    return '''
      CREATE TABLE $tableName ( 
        $columnGroupId INTEGER PRIMARY KEY, 
        $columnGroupName TEXT,
        $columnTotalNum INTEGER,
        $columnCreateDate INTEGER,
        $columnIsTop INTEGER)
      ''';
  }

  /// 获取需要查询的字段
  _getAllColumns() {
    return [
      columnGroupId,
      columnGroupName,
      columnTotalNum,
      columnCreateDate,
      columnIsTop
    ];
  }

  Future<List<BookGroupModel>> getAllGroups() async {
    Database db = await getDataBase();
    List<BookGroupModel> resultList = [];
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnIsTop DESC, $columnGroupId ASC");
    for(Map<String, dynamic> map in maps){
      resultList.add(BookGroupModel.fromJson(map));
    }
    return resultList;
  }

  Future<List<Map<String, String>>> getAllGroupsDict() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnIsTop DESC, $columnGroupId ASC");
    List<Map<String, String>> dict = [];
    for(Map<String, dynamic> map in maps){
      dict.add( {"ID": map['groupId'].toString(), "NAME": map['groupName']});
    }
    return dict;
  }

  Future<BookGroupModel?> getById(int groupId) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnGroupId = ?", whereArgs: [groupId]);
    if (maps.isNotEmpty) {
      BookGroupModel model = BookGroupModel.fromJson(maps.first);
      return model;
    } else {
      return null;
    }
  }

  ///删除
  Future<int> delete(BookGroupModel? model) async {
    if(model == null) return 0;
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('删除【BookGroupModel】: ${model.toJson().toString()}');
    return await db.delete(tableName, where: "$columnGroupId = ?", whereArgs: [model.groupId]);
  }

  ///删除所有
  Future<int> deleteAll() async {
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('删除所有【BookGroupModel】');
    return await db.delete(tableName);
  }

  ///插入到数据库
  Future save(BookGroupModel? model) async {
    if(model == null) return;
    Database db = await getDataBase();
    BookGroupModel? tmpModel = await getById(model.groupId);
    //不存在，则插入数据库
    if (tmpModel == null) {
      if(AppConfig.APP_DEBUG_DATABASE) print('新增【BookGroupModel】: ${model.toJson().toString()}');
      await db.insert(tableName, model.toJson());
    } else {
      //更新数据库
      if(AppConfig.APP_DEBUG_DATABASE) print('更新【BookGroupModel】: ${model.toJson().toString()}');
      await db.update(tableName, model.toJson(), where: '$columnGroupId = ?', whereArgs: [model.groupId]);
    }
  }

  ///创建默认分组
  Future initDefaultGroup() async {
    Database db = await getDataBase();
    BookGroupModel? tmpModel = await getById(0);
    //不存在，则插入数据库
    if (tmpModel == null) {
      BookGroupModel model = BookGroupModel()
        ..groupId = 0
        ..groupName = "默认分组"
        ..isTop = 1;
      if(AppConfig.APP_DEBUG_DATABASE) print('新增【BookGroupModel】: ${model.toJson().toString()}');
      await db.insert(tableName, model.toJson());
    }
  }

  ///获取id最大值
  Future<int> getMaxGroupId() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>>? list = await db.rawQuery("select MAX($columnGroupId) as maxId from $tableName");
    if(list.isNotEmpty) {
      return list[0]["maxId"] + 1;
    } else {
      return 1;
    }
  }

  ///重新计算分组
  Future calGroup() async {
    Database db = await getDataBase();
    List<BookGroupModel> list = await getAllGroups();
    for(BookGroupModel obj in list){
      obj.totalNum = await BookSchema.getInstance.getCountByGroupId(obj.groupId);
      await db.update(tableName, obj.toJson(), where: '$columnGroupId = ?', whereArgs: [obj.groupId]);
    }
  }
}
