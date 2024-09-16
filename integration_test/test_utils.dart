import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_chest/data/database_creator.dart';
import 'package:medicine_chest/data/medicine/medicine_pack_storage_impl.dart';
import 'package:medicine_chest/data/medicine/medicine_storage_impl.dart';
import 'package:medicine_chest/data/scheme/scheme_storage_impl.dart';
import 'package:medicine_chest/data/take_record/take_record_storage_impl.dart';
import 'package:medicine_chest/main.dart';
import 'package:medicine_chest/notifications/notification_manager.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_day_schedule_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'test_dependenices.dart';

import 'package:timezone/data/latest_all.dart' as tz;

Future<TestDependenices> createTestApp(WidgetTester tester) async {
  tz.initializeTimeZones(); 

  final dbName = "test_medicine_${DateTime.now().millisecondsSinceEpoch}.db";
  final dbFile = File(join(await getDatabasesPath(), dbName));
  try {
    dbFile.deleteSync();
  } catch (e) {
    // ignored
  }

  final database = openDatabase(dbFile.path, onOpen: (db) {
    var dbCreator = DatabaseCreator(db);
    dbCreator.create();
  }, version: DatabaseCreator.DATABASE_VERSION);
  await database;

  final notificationManager = NotificationManager();

  final medicineStorageImpl = MedicineStorageImpl(database);
  final medicinePackStorageImpl =
      MedicinePackStorageImpl(database, medicineStorageImpl);
  final schemeStorageImpl =
      SchemeStorageImpl(database, medicineStorageImpl, notificationManager);
  final takeRecordStorageImpl = TakeRecordStorageImpl(
      database, medicineStorageImpl, medicinePackStorageImpl);
  final dayScheduleProvider =
      TakeCalendarDayScheduleProvider(schemeStorageImpl, takeRecordStorageImpl);

  await tester.pumpWidget(MyApp(
    medicinePackStorageImpl: medicinePackStorageImpl,
    medicineStorageImpl: medicineStorageImpl,
    schemeStorageImpl: schemeStorageImpl,
    takeRecordStorageImpl: takeRecordStorageImpl,
    scheduleProvider: dayScheduleProvider,
  ));

  return TestDependenices(
      medicineStorage: medicineStorageImpl,
      medicinePackStorage: medicinePackStorageImpl,
      schemeStorage: schemeStorageImpl,
      takeRecordStorage: takeRecordStorageImpl);
}

  Future<void> enterTime(WidgetTester tester, int hour, int minute) async {
    assert(hour >= 0 && hour < 24, 'Hour must be between 0 and 23');
    assert(minute >= 0 && minute < 60, 'Minute must be between 0 and 59');
    await tester.tap(find.byTooltip('Switch to text input mode'));
    await tester.pumpAndSettle();

    final inputs = find.byType(TextFormField);

    await tester.enterText(inputs.at(0), hour.toString());
    await tester.enterText(inputs.at(1), minute.toString());
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }
