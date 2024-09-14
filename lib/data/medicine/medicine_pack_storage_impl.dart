import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';
import 'package:sqflite/sqlite_api.dart';

class MedicinePackStorageImpl implements MedicinePackStorage {
  static const String _tableName = "medicine_pack";

  static onDatabaseCreate(Database db) {
    db.execute("""CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY,
        medicine_id INTEGER,
        left_amount REAL,
        expiration_time INTEGER,
        active INTEGER DEFAULT 1,
        FOREIGN KEY(medicine_id) REFERENCES medicine(id)
      );""");
  }

  final Future<Database> _db;

  MedicinePackStorageImpl(this._db);

  @override
  Future<int> saveMedicinePack(MedicinePack pack) async {
    final db = await _db;

    var values = {
      'medicine_id': pack.medicine!.id,
      'left_amount': pack.leftAmount,
      'expiration_time': pack.expirationTime.millisecondsSinceEpoch,
    };

    if (pack.id != MedicinePack.NO_ID) {
      values['id'] = pack.id;
    }
    return db.insert(_tableName, values,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<MedicinePack>> getMedicinePacksByMedicine(Medicine medicine) async {
    final db = await _db;
    final List<Map<String, Object?>> medicinePacks = await db
        .query(_tableName, where: 'medicine_id = ? AND active = 1', whereArgs: [medicine.id]);
    List<MedicinePack> result = [];
    for (var data in medicinePacks) {
      var pack = _convertToMedicinePack(data);
      pack.medicine = medicine;
      result.add(pack);
    }
    return result;
  }

  Future<MedicinePack?> getById(int packId) async {
     final db = await _db;
     return db.transaction((txn) async {
        return await _getMedicinePackById(packId, txn);
     });
  }

  Future<MedicinePack?> _getMedicinePackById(int packId, Transaction txn) async {
    List<Map<String, Object?>> medicinePacks = await txn.query(_tableName, where: 'id = ?', whereArgs: [packId]);
    var data = medicinePacks.firstOrNull;
    if (data != null) {
      return _convertToMedicinePack(data);
    } else {
      return null;
    }
  }


  Future<void> applyMedicineTake(Map<MedicinePack, double> amount, Transaction txn) async {
    for (var pack in amount.keys) {
      var packAmount = amount[pack]!;
      MedicinePack? actualPack = await _getMedicinePackById(pack.id, txn);
      if (actualPack != null) {
        double newAmount = actualPack.leftAmount - packAmount;
        final values = {
          "left_amount": newAmount
        };
        txn.update(_tableName, values, where: "id = ?", whereArgs: [actualPack.id]);
      }
    }
  }

  MedicinePack _convertToMedicinePack(Map<String, Object?> data) {
    return MedicinePack(
        id: data['id'] as int,
        leftAmount: data['left_amount'] as double,
        expirationTime: DateTime.fromMillisecondsSinceEpoch(
            data['expiration_time'] as int));
  }
  
  @override
  Future<void> deleteMedicinePack(MedicinePack pack) async {
    final db = await _db;
    final values = {
      "active": 0,
    };
    await db.update(_tableName, values, where: "id = ?", whereArgs: [pack.id]) ;
  }
}
