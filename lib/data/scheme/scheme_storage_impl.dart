import 'dart:convert';

import 'package:medicine_chest/entities/every_day_schedule.dart';
import 'package:medicine_chest/entities/scheme.dart';
import 'package:medicine_chest/entities/take_schedule.dart';
import 'package:medicine_chest/ui/dependencies/scheme_storage.dart';
import 'package:sqflite/sqflite.dart';

class SchemeStorageImpl extends SchemeStorage {

  static const _tableName = "scheme";

  final Future<Database> _db;

  SchemeStorageImpl(this._db);

  static onDatabaseCreate(Database db) {
    db.execute("""
      CREATE TABLE $_tableName(
      id INTEGER PRIMARY KEY,
      medicineId INTEGER,
      oneTakeAmount REAL,
      fromTime INTEGER,
      toTime INTEGER,
      scheduleParams TEXT,
      FOREIGN KEY(medicineId) REFERENCES medicine(id)
      )
    """);
  }

  @override
  Future<int> saveScheme(Scheme scheme) async {
    Database db = await _db;
    var values = {
      "medicineId " : scheme.medicine.id,
      "oneTakeAmount": scheme.oneTakeAmount,
      "fromTime": scheme.takeSchedule.getFirstTakeDay().millisecond,
      "toTime": scheme.takeSchedule.getLastTakeDay().millisecond,
      "scheduleParams": buildScheduleParams(scheme.takeSchedule),
    };

    return db.insert(_tableName, values, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  String buildScheduleParams(TakeSchedule schedule) {
    if (schedule is EveryDaySchedule) {
      EveryDaySchedule everyDaySchedule = schedule;  
      return jsonEncode(everyDaySchedule.toJson());
    } else {
      throw Exception("Unsupported schedule type.");
    }
  }

}