import 'package:sqflite/sqflite.dart';
import 'package:task_continuation/util/date_format.dart';

final String tableName = 'Task';
final String columnId = 'id';
final String columnTask = 'task';
final String columnContinuousCount = 'continuous_count';
final String columnTargetCount = 'target_count';
final String columnLastDate = 'last_date';
final String columnAchievement = 'achievement';

class Task {

  int id;
  String task;
  int continuousCount;
  int targetCount;
  DateTime lastDate;
  bool achievement;

  Map<String, Object> toMap() {
    var map = <String, Object> {
      columnTask: task,
      columnContinuousCount: continuousCount,
      columnTargetCount: targetCount,
      columnLastDate: lastDate == null ? null : lastDate.formatToSystemString(),
      columnAchievement: achievement == true ? 1 : 0
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Task();

  Task.fromMap(Map<String, Object> map) {
    id = map[columnId] as int;
    task = map[columnTask] as String;
    continuousCount = map[columnContinuousCount] as int;
    targetCount = map[columnTargetCount] as int;
    if (map[columnLastDate] == null) {
      lastDate = null;
    } else if (map[columnLastDate] is String){
      lastDate = map[columnLastDate] is String ? DateTime.parse(map[columnLastDate] as String) : lastDate = map[columnLastDate] as DateTime;
    }
    achievement = map[columnAchievement] == 1;
  }
}

class TaskProvider {

  Database db;

  Future open() async {
    var databasesPath = await getDatabasesPath();
    var path = '$databasesPath/app.db';
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
          create table if not exists $tableName (
          $columnId integer primary key autoincrement,
          $columnTask text not null,
          $columnContinuousCount integer not null,
          $columnTargetCount integer not null,
          $columnLastDate text,
          $columnAchievement integer not null)
          ''');
        });
  }

  Future<Task> insert(Task task) async {
    task.id = await db.insert(tableName, task.toMap());
    return task;
  }

  Future<List<Task>> getNotAchievedTasks() async {
    List<Map<String, Object>> maps = await db.query(tableName,
        where: '$columnAchievement = ?',
        whereArgs: [0],
        columns: [columnId, columnAchievement, columnTask, columnLastDate, columnContinuousCount, columnTargetCount]
    );
    var result = <Task>[];
    if (maps.isNotEmpty) {
      maps.forEach((element) { result.add(Task.fromMap(element)); });
    }
    return result;
  }

  Future<List<Task>> getAchievedTasks() async {
    List<Map<String, Object>> maps = await db.query(tableName,
        where: '$columnAchievement = ?',
        whereArgs: [1],
        columns: [columnId, columnAchievement, columnTask, columnLastDate, columnContinuousCount, columnTargetCount]
    );
    var result = <Task>[];
    if (maps.isNotEmpty) {
      maps.forEach((element) { result.add(Task.fromMap(element)); });
    }
    return result;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Task todo) async {
    return await db.update(tableName, todo.toMap(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();
}