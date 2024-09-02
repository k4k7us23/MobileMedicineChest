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
    return db.insert(_tableName, values, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
