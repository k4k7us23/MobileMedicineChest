import 'package:flutter/material.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';
import 'package:medicine_chest/ui/dependencies/scheme_storage.dart';
import 'package:medicine_chest/ui/dependencies/take_record_storage.dart';
import 'package:medicine_chest/ui/medicine_list/medicine_list.dart';
import 'package:medicine_chest/ui/schemes_list/scheme_list.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_day_schedule_provider.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_page.dart';

enum Page { calendar, schedules, medicines }

class RootPage extends StatefulWidget {
  final MedicinePackStorage medicinePackStorageImpl;
  final MedicineStorage medicineStorageImpl;
  final SchemeStorage schemeStorageImpl;
  final TakeRecordStorage takeRecordStorageImpl;
  final TakeCalendarDayScheduleProvider scheduleProvider;

  RootPage(
      {super.key, required this.medicinePackStorageImpl,
      required this.medicineStorageImpl,
      required this.schemeStorageImpl,
      required this.takeRecordStorageImpl,
      required this.scheduleProvider});

  @override
  State<StatefulWidget> createState() {
    return RootMedicinePageState(
        medicinePackStorageImpl: medicinePackStorageImpl,
        medicineStorageImpl: medicineStorageImpl,
        schemeStorageImpl: schemeStorageImpl,
        takeRecordStorageImpl: takeRecordStorageImpl,
        scheduleProvider: scheduleProvider);
  }
}

class RootMedicinePageState extends State<RootPage> {
  final MedicinePackStorage medicinePackStorageImpl;
  final MedicineStorage medicineStorageImpl;
  final SchemeStorage schemeStorageImpl;
  final TakeRecordStorage takeRecordStorageImpl;
  final TakeCalendarDayScheduleProvider scheduleProvider;

  var _page = Page.calendar;

  RootMedicinePageState(
      {required this.medicinePackStorageImpl,
      required this.medicineStorageImpl,
      required this.schemeStorageImpl,
      required this.takeRecordStorageImpl,
      required this.scheduleProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  Widget _body() {
    switch (_page) {
      case Page.calendar:
        return TakeCalendarPage(scheduleProvider, medicineStorageImpl,
            medicinePackStorageImpl, takeRecordStorageImpl);
      case Page.schedules:
        return SchemeListPage(medicineStorageImpl, schemeStorageImpl);
      case Page.medicines:
        return MedicinesListPage(medicineStorageImpl, medicinePackStorageImpl);
    }
  }

  int _getSelectedIndex() {
    switch (_page) {
      case Page.calendar:
        return 0;
      case Page.schedules:
        return 1;
      case Page.medicines:
        return 2;
    }
  }

  Widget _bottomNavigationBar(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            key: ValueKey("calendar_page"),
            icon: Icon(Icons.calendar_month),
            label: 'Календарь',
          ),
          BottomNavigationBarItem(
            key: ValueKey("schemes_page"),
            icon: Icon(Icons.receipt),
            label: 'Схемы приема',
          ),
          BottomNavigationBarItem(
            key: ValueKey("medicines_page"),
            icon: Icon(Icons.medication),
            label: 'Лекарства',
          ),
        ],
        currentIndex: _getSelectedIndex(),
        selectedItemColor: colorScheme.primary,
        onTap: (value) {
          setState(() {
            if (value == 0) {
              _page = Page.calendar;
            } else if (value == 1) {
              _page = Page.schedules;
            } else if (value == 2) {
              _page = Page.medicines;
            } 
          });
        },
      );
  }
}
