import 'dart:convert';

import 'package:medicine_chest/data/medicine/medicine_pack_storage_impl.dart';
import 'package:medicine_chest/data/medicine/medicine_storage_impl.dart';
import 'package:medicine_chest/entities/take_record.dart';
import 'package:medicine_chest/ui/dependencies/take_record_storage.dart';
import 'package:sqflite/sqflite.dart';

class TakeRecordStorageImpl extends TakeRecordStorage {
  static const _tableName = "take_record";

  final Future<Database> _db;
  MedicinePackStorageImpl _medicinePackStorageImpl;

  TakeRecordStorageImpl(this._db, this._medicinePackStorageImpl);

  static onDatabaseCreate(Database db) {
    db.execute("""
      CREATE TABLE $_tableName(
      id INTEGER PRIMARY_KEY,
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

    await _medicinePackStorageImpl.applyMedicineTake(record.takeAmountByPack, txn);

    return txn.insert(_tableName, values);
  }

  String _getTakeAmountJson(TakeRecord record) {
    Map<String, double> amountByPackId = {};
    record.takeAmountByPack.forEach((pack, amount) {
      amountByPackId[pack.id.toString()] = amount;
    });
    return jsonEncode(amountByPackId);
  }
}
