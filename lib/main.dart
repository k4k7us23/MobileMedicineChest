import 'package:flutter/material.dart';
import 'package:medicine_chest/data/database_creator.dart';
import 'package:medicine_chest/data/medicine/medicine_pack_storage_impl.dart';
import 'package:medicine_chest/data/medicine/medicine_storage_impl.dart';
import 'package:medicine_chest/data/scheme/scheme_storage_impl.dart';
import 'package:medicine_chest/data/take_record/take_record_storage_impl.dart';
import 'package:medicine_chest/ui/add_sheme/add_scheme.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';
import 'package:medicine_chest/ui/medicine_list/medicine_list.dart';
import 'package:medicine_chest/ui/root/root_page.dart';
import 'package:medicine_chest/ui/schemes_list/scheme_list.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_day_schedule_provider.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_page.dart';
import 'package:medicine_chest/ui/take_medicine/take_medicine.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(join(await getDatabasesPath(), 'medicine.db'),
      onCreate: (db, version) {
    var dbCreator = DatabaseCreator(db);
    dbCreator.create();
  }, version: DatabaseCreator.DATABASE_VERSION);

  final medicineStorageImpl = MedicineStorageImpl(database);
  final medicinePackStorageImpl = MedicinePackStorageImpl(database);
  final schemeStorageImpl = SchemeStorageImpl(database, medicineStorageImpl);
  final takeRecordStorageImpl = TakeRecordStorageImpl(
      database, medicineStorageImpl, medicinePackStorageImpl);
  final dayScheduleProvider =
      TakeCalendarDayScheduleProvider(schemeStorageImpl, takeRecordStorageImpl);

  runApp(MyApp(
    medicinePackStorageImpl: medicinePackStorageImpl,
    medicineStorageImpl: medicineStorageImpl,
    schemeStorageImpl: schemeStorageImpl,
    takeRecordStorageImpl: takeRecordStorageImpl,
    scheduleProvider: dayScheduleProvider,
  ));
}

class MyApp extends StatelessWidget {
  final MedicinePackStorage medicinePackStorageImpl;
  final MedicineStorageImpl medicineStorageImpl;
  final SchemeStorageImpl schemeStorageImpl;
  final TakeRecordStorageImpl takeRecordStorageImpl;
  final TakeCalendarDayScheduleProvider scheduleProvider;

  const MyApp({
    super.key,
    required this.medicinePackStorageImpl,
    required this.medicineStorageImpl,
    required this.schemeStorageImpl,
    required this.takeRecordStorageImpl,
    required this.scheduleProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
          useMaterial3: true,
        ),
        home: RootPage(
          medicineStorageImpl: medicineStorageImpl,
          medicinePackStorageImpl: medicinePackStorageImpl,
          schemeStorageImpl: schemeStorageImpl,
          takeRecordStorageImpl: takeRecordStorageImpl,
          scheduleProvider: scheduleProvider,
        )
        //home: TakeCalendarPage(scheduleProvider, medicineStorageImpl, medicinePackStorageImpl, takeRecordStorageImpl),
        //home: SchemeListPage(medicineStorageImpl, schemeStorageImpl),
        //home: MedicinesListPage(medicineStorageImpl, medicinePackStorageImpl),
        );
  }
}
