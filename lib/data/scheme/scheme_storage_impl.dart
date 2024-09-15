import 'dart:convert';

import 'package:medicine_chest/data/medicine/medicine_storage_impl.dart';
import 'package:medicine_chest/entities/every_day_schedule.dart';
import 'package:medicine_chest/entities/scheme.dart';
import 'package:medicine_chest/entities/take_schedule.dart';
import 'package:medicine_chest/notifications/notification_manager.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';
import 'package:medicine_chest/ui/dependencies/scheme_storage.dart';
import 'package:sqflite/sqflite.dart';

class SchemeStorageImpl extends SchemeStorage {
  static const _tableName = "scheme";

  final Future<Database> _db;
  MedicineStorageImpl _medicineStorageImpl;
  NotificationManager _notificationManager;

  SchemeStorageImpl(this._db, this._medicineStorageImpl, this._notificationManager);

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
      "medicineId": scheme.medicine.id,
      "oneTakeAmount": scheme.oneTakeAmount,
      "fromTime": scheme.takeSchedule.getFirstTakeDay().millisecondsSinceEpoch,
      "toTime": scheme.takeSchedule.getLastTakeDay().millisecondsSinceEpoch,
      "scheduleParams": _buildScheduleParams(scheme.takeSchedule),
    };

    if (scheme.id != Scheme.NO_ID) {
      values["id"] = scheme.id;
    }

    _notificationManager.setupNotificationsForScheme(scheme);

    return db.insert(_tableName, values,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  String _buildScheduleParams(TakeSchedule schedule) {
    if (schedule is EveryDaySchedule) {
      EveryDaySchedule everyDaySchedule = schedule;
      return jsonEncode(everyDaySchedule.toJson());
    } else {
      throw Exception("Unsupported schedule type.");
    }
  }

  EveryDaySchedule? _createScheduleFromParams(String json) {
    var jsonMap = jsonDecode(json);
    return EveryDaySchedule.fromJson(jsonMap);
  }

  @override
  Future<List<Scheme>> getActiveOrFutureSchemes() async {
    final db = await _db;
    final currentTimeInMillis = DateTime.now().millisecondsSinceEpoch;

    final List<Map<String, Object?>> schemeMaps = await db.query(_tableName,
        where:
            "($currentTimeInMillis >= fromTime AND $currentTimeInMillis <= toTime) OR $currentTimeInMillis < fromTime",
        orderBy: "fromTime");

    List<Scheme> schemes = [];
    for (var shemeMap in schemeMaps) {
      Scheme? scheme = await _createSchemeFromMap(shemeMap);
      if (scheme != null) {
        schemes.add(scheme);
      }
    }

    return schemes;
  }

  Future<Scheme?> _createSchemeFromMap(Map<String, Object?> data) async {
    var medicineId = data["medicineId"] as int;
    var medicine = await _medicineStorageImpl.getMedicineById(medicineId);
    if (medicine == null) {
      return null;
    }

    var jsonParamsString = data["scheduleParams"] as String;
    TakeSchedule? schedule = _createScheduleFromParams(jsonParamsString);
    if (schedule == null) {
      return null;
    }

    return Scheme(
        data["id"] as int, medicine, data["oneTakeAmount"] as double, schedule);
  }

  @override
  Future<List<Scheme>> getSchemesForDay(DateTime day) async {
    final db = await _db;

    final timeInMillis = day.millisecondsSinceEpoch;

    final List<Map<String, Object?>> schemeMaps = await db.query(_tableName,
        where: "($timeInMillis >= fromTime AND $timeInMillis <= toTime)",
        orderBy: "fromTime");

    List<Scheme> schemes = [];
    for (var shemeMap in schemeMaps) {
      Scheme? scheme = await _createSchemeFromMap(shemeMap);
      if (scheme != null) {
        schemes.add(scheme);
      }
    }

    return schemes;
  }
  
  @override
  Future<void> deleteScheme(Scheme scheme) async {
    final db = await _db;
    _notificationManager.cancelNotificationForScheme(scheme);
    await db.delete(_tableName, where: "id = ?", whereArgs: [scheme.id]);
  }
  
  @override
  Future<Scheme?> getById(int id) async {
    final db = await _db;

    final List<Map<String, Object?>> schemeMaps = await db.query(_tableName,
        where: "id = ?", whereArgs: [id]);
    
    Map<String, Object?>? schemeData = schemeMaps.firstOrNull;
    if (schemeData == null) {
      return null;
    } else {
      return await _createSchemeFromMap(schemeData);
    }
  }
}
