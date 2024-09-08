import 'package:medicine_chest/data/medicine/medicine_pack_storage_impl.dart';
import 'package:medicine_chest/data/medicine/medicine_storage_impl.dart';
import 'package:medicine_chest/data/scheme/scheme_storage_impl.dart';
import 'package:medicine_chest/data/take_record/take_record_storage_impl.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseCreator {

  static int DATABASE_VERSION = 1;

  Database db;

  DatabaseCreator(this.db);

  void create() {
    MedicineStorageImpl.onDatabaseCreate(db);
    MedicinePackStorageImpl.onDatabaseCreate(db);
    SchemeStorageImpl.onDatabaseCreate(db);
    TakeRecordStorageImpl.onDatabaseCreate(db);
  }

}