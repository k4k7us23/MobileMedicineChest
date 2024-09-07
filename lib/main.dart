import 'package:flutter/material.dart';
import 'package:medicine_chest/data/database_creator.dart';
import 'package:medicine_chest/data/medicine/medicine_pack_storage_impl.dart';
import 'package:medicine_chest/data/medicine/medicine_storage_impl.dart';
import 'package:medicine_chest/data/scheme/scheme_storage_impl.dart';
import 'package:medicine_chest/ui/add_sheme/add_scheme.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';
import 'package:medicine_chest/ui/medicine_list/medicine_list.dart';
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
  final schemeStorageImpl = SchemeStorageImpl(database);

  runApp(MyApp(
    medicinePackStorageImpl: medicinePackStorageImpl,
    medicineStorageImpl: medicineStorageImpl,
    schemeStorageImpl: schemeStorageImpl,
    ));
}

class MyApp extends StatelessWidget {
  final MedicinePackStorage medicinePackStorageImpl;
  final MedicineStorageImpl medicineStorageImpl;
  final SchemeStorageImpl schemeStorageImpl;

  const MyApp(
      {super.key,
      required this.medicinePackStorageImpl,
      required this.medicineStorageImpl,
      required this.schemeStorageImpl,
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: AddSchemePage(medicineStorageImpl, schemeStorageImpl),
    );
  }
}
