import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TodoDatabase {
  ///CREATE DATABASE
  Future<Database> createDB() async {
    Database db = await openDatabase(
      join(await getDatabasesPath(), "TodoDB.db"),
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE Todo(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            date TEXT
          )
          ''');
      },
    );
    return db;
  }

  //GET DATA
  Future<List<Map>> getTodoItems() async {
    Database localDb = await createDB();
    List<Map> list = await localDb.query("Todo");
    return list;
  }

  //ADD DATA
  Future<void> insertTodoItem(Map<String, dynamic> obj) async {
    Database localdb = await createDB();

    await localdb.insert(
      "Todo",
      obj,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //UPDATE DATA
  Future<void> updateTodoItem(Map<String, dynamic> obj) async {
    Database localDb = await createDB();
    await localDb.update("Todo", obj, where: "id=?", whereArgs: [obj['id']]);
  }

  //DELETE DATA
  Future<void> deleteTodoItem(int index) async {
    Database db = await createDB();
    await db.delete("Todo", where: "id=?", whereArgs: [index]);
  }
}
