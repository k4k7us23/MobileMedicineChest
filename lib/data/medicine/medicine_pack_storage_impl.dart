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
        .query(_tableName, where: 'medicine_id = ?', whereArgs: [medicine.id]);
    List<MedicinePack> result = [];
    for (var data in medicinePacks) {
      var pack = _convertToMedicinePack(data);
      pack.medicine = medicine;
      result.add(pack);
    }
    return result;
  }

  MedicinePack _convertToMedicinePack(Map<String, Object?> data) {
    return MedicinePack(
        id: data['id'] as int,
        leftAmount: data['left_amount'] as double,
        expirationTime: DateTime.fromMillisecondsSinceEpoch(
            data['expiration_time'] as int));
  }
}
