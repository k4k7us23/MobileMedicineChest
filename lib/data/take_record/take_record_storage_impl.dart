import 'dart:convert';

import 'package:medicine_chest/data/medicine/medicine_pack_storage_impl.dart';
import 'package:medicine_chest/data/medicine/medicine_storage_impl.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';
import 'package:medicine_chest/entities/take_record.dart';
import 'package:medicine_chest/ui/dependencies/take_record_storage.dart';
import 'package:medicine_chest/utils/date_utils.dart';
import 'package:sqflite/sqflite.dart';

class TakeRecordStorageImpl extends TakeRecordStorage {
  static const _tableName = "take_record";

  final Future<Database> _db;
  MedicinePackStorageImpl _medicinePackStorageImpl;
  MedicineStorageImpl _medicineStorageImpl;

  TakeRecordStorageImpl(this._db, this._medicineStorageImpl, this._medicinePackStorageImpl);

  static onDatabaseCreate(Database db) {
    db.execute("""
      CREATE TABLE $_tableName(
      id INTEGER PRIMARY KEY,
      medicineId INTEGER,
      takeTime INTEGER,
      takeAmountByPackJson TEXT,
      FOREIGN KEY(medicineId) REFERENCES medicine(id)
      )
    """);
  }

  @override
  Future<int> saveTakeRecord(TakeRecord record) async {
    Database db = await _db;
    return db.transaction((txn) async {
      return await _saveTake(record, txn);
    });
  }

  Future<int> _saveTake(TakeRecord record, Transaction txn) async {
    var values = {
      "medicineId": record.medicine.id,
      "takeTime": record.takeTime.millisecondsSinceEpoch,
      "takeAmountByPackJson": _getTakeAmountJson(record)
    };
    if (record.id != TakeRecord.NO_ID) {
      values["id"] = record.id;
    }

    await _medicinePackStorageImpl.applyMedicineTake(
        record.takeAmountByPack, txn);

    return txn.insert(_tableName, values);
  }

  String _getTakeAmountJson(TakeRecord record) {
    Map<String, double> amountByPackId = {};
    record.takeAmountByPack.forEach((pack, amount) {
      amountByPackId[pack.id.toString()] = amount;
    });
    return jsonEncode(amountByPackId);
  }

  Future<Map<MedicinePack, double>> _getTakeAmountByJson(String json) async {
    Map<String, dynamic> decodedMap = jsonDecode(json);
    Map<MedicinePack, double> result = {};
    for (var key in decodedMap.keys) {
      var value = decodedMap[key];
      var packId = int.tryParse(key);
      if (packId != null) {
        MedicinePack? medicinePack = await _medicinePackStorageImpl.getById(packId);
        if (medicinePack != null) {
          if (value is double) {
            result[medicinePack] = value;
          }
        }
      }
    }
    return result;
  }

  @override
  Future<List<TakeRecord>> getTakeRecordForDay(DateTime day) async {
    Database db = await _db;

    DateTime beginOfTheDay = toBeginOfTheDay(day);
    DateTime endOfTheDay = toEndOfTheDay(day);

    final beginTS = beginOfTheDay.millisecondsSinceEpoch;
    final endTS = endOfTheDay.millisecondsSinceEpoch;

    final List<Map<String, Object?>> schemeMaps = await db.query(_tableName,
        where: "takeTime >= $beginTS AND takeTime <= $endTS",
        orderBy: "takeTime");

    List<TakeRecord> result = [];
    for (var data in schemeMaps) {
      TakeRecord? converted = await _convertToTakeRecord(data);
      if (converted != null) {
        result.add(converted);
      }
    }
    return result;
  }

  Future<TakeRecord?> _convertToTakeRecord(Map<String, Object?> data) async {
    var medicine = await _medicineStorageImpl.getMedicineById(data["medicineId"] as int);
    if (medicine == null) {
      return null;
    } else {
      final takeAmountByPack = await _getTakeAmountByJson(data["takeAmountByPackJson"] as String);

      return TakeRecord(
        data["id"] as int,
        medicine,
        DateTime.fromMillisecondsSinceEpoch(data["takeTime"] as int), takeAmountByPack);
    }
  }
}
