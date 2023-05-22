import 'dart:async';
import 'dart:io';
import 'package:share_extend/share_extend.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:sqflite/sqflite.dart';

/// 数据库管理
class SqlManager {
  static const _VERSION = 1;

  static const _NAME = "${AppConfig.APP_NAME}.db";

  static Database? _database;

  ///初始化
  static init() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + _NAME;
    if (Platform.isIOS) {
      path = "$databasesPath/$_NAME";
    }
    _database = await openDatabase(path, version: _VERSION, onCreate: (Database db, int version) async {});
  }

  static exportDbFile() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + _NAME;
    if (Platform.isIOS) {
      path = "$databasesPath/$_NAME";
    }
    ShareExtend.share(path, "file");
  }

  /// 表是否存在
  static isTableExits(String tableName) async {
    await getCurrentDatabase();
    var res = await _database?.rawQuery("select * from Sqlite_master where type = 'table' and name = '$tableName'");
    return res != null && res.isNotEmpty;
  }

  ///获取当前数据库对象
  static Future<Database> getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database!;
  }

  ///关闭
  static close() {
    _database?.close();
  }
}
