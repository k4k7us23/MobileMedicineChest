import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';
import 'package:sqflite/sqlite_api.dart';

class MedicineStorageImpl implements MedicineStorage {
  
  static const String _tableName = "medicine";
  
  final Future<Database> _db;

  MedicineStorageImpl(this._db);

  static onDatabaseCreate(Database db) {
    db.execute("""CREATE TABLE $_tableName(
      id INTEGER PRIMARY KEY,
      name TEXT,
      releaseForm INTEGER,
      dosage REAL); """);
  }

  @override
  Future<int> saveMedicine(Medicine medicine) async {
    final db = await _db;
    var values = {
      'name' : medicine.name,
      'releaseForm': _encodeReleaseForm(medicine.releaseForm),
      'dosage': medicine.dosage
    };

    if (medicine.id != Medicine.NO_ID) {
      values['id'] = medicine.id;
    }

    return db.insert(_tableName, values, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  int _encodeReleaseForm(MedicineReleaseForm releaseForm) {
    switch(releaseForm) {
      case MedicineReleaseForm.tablet: return 1;
      case MedicineReleaseForm.injection: return 2;
      case MedicineReleaseForm.liquid: return 3;
      case MedicineReleaseForm.powder: return 4;
      case MedicineReleaseForm.other: return 5;
    }
  }
}
