import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';
import 'package:sqflite/sqflite.dart';

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
      'name': medicine.name,
      'releaseForm': _encodeReleaseForm(medicine.releaseForm),
      'dosage': medicine.dosage
    };

    if (medicine.id != Medicine.NO_ID) {
      values['id'] = medicine.id;
    }

    return db.insert(_tableName, values,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  int _encodeReleaseForm(MedicineReleaseForm releaseForm) {
    switch (releaseForm) {
      case MedicineReleaseForm.tablet:
        return 1;
      case MedicineReleaseForm.injection:
        return 2;
      case MedicineReleaseForm.liquid:
        return 3;
      case MedicineReleaseForm.powder:
        return 4;
      case MedicineReleaseForm.other:
        return 5;
    }
  }

  MedicineReleaseForm? _decodeReleaseForm(int value) {
    switch (value) {
      case 1:
        return MedicineReleaseForm.tablet;
      case 2:
        return MedicineReleaseForm.injection;
      case 3:
        return MedicineReleaseForm.liquid;
      case 4:
        return MedicineReleaseForm.powder;
      case 5:
        return MedicineReleaseForm.other;
      default:
        return null;
    }
  }

  @override
  Future<List<Medicine>> getMedicines() async {
    final db = await _db;

    final List<Map<String, Object?>> medicineMaps =
        await db.query(_tableName, orderBy: 'name ASC');
    return medicineMaps.map(_convertToMedicine).nonNulls.toList();
  }

  Medicine? _convertToMedicine(Map<String, Object?> data) {
    var releaseForm = _decodeReleaseForm(data["releaseForm"] as int);
    if (releaseForm != null) {
      return Medicine(
          id: data["id"] as int,
          name: data["name"] as String,
          releaseForm: releaseForm);
    } else {
      return null;
    }
  }

  @override
  Future<bool> hasAnyMedicines() async {
    final db = await _db;

    var count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_tableName'));
    return count != null && count > 0;
  }

  @override
  Future<Medicine?> getMedicineById(int id, {Transaction? txn = null}) async {
    List<Map<String, Object?>> medicineMaps;
    if (txn == null) {
      final db = await _db;
      medicineMaps = await db.query(
        _tableName,
        where: "id = ?",
        whereArgs: [id],
      );
    } else {
      medicineMaps = await txn.query(
        _tableName,
        where: "id = ?",
        whereArgs: [id],
      );
    }

    if (medicineMaps.isEmpty) {
      return null;
    } else {
      Map<String, Object?> data = medicineMaps[0];
      return _convertToMedicine(data);
    }
  }
}
