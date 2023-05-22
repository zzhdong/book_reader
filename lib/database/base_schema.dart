import 'dart:async';

import 'package:book_reader/database/sql_manager.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

///基类
abstract class BaseSchema {
  bool isTableExits = false;

  createTableSql();

  getTableName();

  Future<Database> getDataBase() async {
    return await open();
  }

  ///如果数据库不存在，则创建数据库
  @mustCallSuper
  prepare(name, String createSql) async {
    isTableExits = await SqlManager.isTableExits(name);
    if (!isTableExits) {
      Database db = await SqlManager.getCurrentDatabase();
      return await db.execute(createSql);
    }
  }

  @mustCallSuper
  open() async {
    if (!isTableExits) {
      await prepare(getTableName(), createTableSql());
    }
    return await SqlManager.getCurrentDatabase();
  }
}
