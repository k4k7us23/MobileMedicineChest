import 'package:flutter/material.dart';
import 'package:medicine_chest/data/database_creator.dart';
import 'package:medicine_chest/data/medicine/medicine_pack_storage_impl.dart';
import 'package:medicine_chest/data/medicine/medicine_storage_impl.dart';
import 'package:medicine_chest/data/scheme/scheme_storage_impl.dart';
import 'package:medicine_chest/data/take_record/take_record_storage_impl.dart';
import 'package:medicine_chest/ui/add_sheme/add_scheme.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';
import 'package:medicine_chest/ui/medicine_list/medicine_list.dart';
import 'package:medicine_chest/ui/schemes_list/scheme_list.dart';
import 'package:medicine_chest/ui/take_medicine/take_medicine.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'medicine.db'),
    onCreate: (db, version) {
      var dbCreator = DatabaseCreator(db);
      dbCreator.create();
    },
    version: DatabaseCreator.DATABASE_VERSION
  );

  final medicineStorageImpl = MedicineStorageImpl(database);
  final medicinePackStorageImpl = MedicinePackStorageImpl(database);
  final schemeStorageImpl = SchemeStorageImpl(database, medicineStorageImpl);
  final takeRecordStorageImpl = TakeRecordStorageImpl(database, medicinePackStorageImpl);

  runApp(MyApp(
    medicinePackStorageImpl: medicinePackStorageImpl,
    medicineStorageImpl: medicineStorageImpl,
    schemeStorageImpl: schemeStorageImpl,
    takeRecordStorageImpl:  takeRecordStorageImpl,
    ));
}

class MyApp extends StatelessWidget {
  final MedicinePackStorage medicinePackStorageImpl;
  final MedicineStorageImpl medicineStorageImpl;
  final SchemeStorageImpl schemeStorageImpl;
  final TakeRecordStorageImpl takeRecordStorageImpl;

  const MyApp(
      {super.key,
      required this.medicinePackStorageImpl,
      required this.medicineStorageImpl,
      required this.schemeStorageImpl,
      required this.takeRecordStorageImpl,
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: TakeMedicinePage(medicineStorageImpl, medicinePackStorageImpl, takeRecordStorageImpl),
    );
  }
}
