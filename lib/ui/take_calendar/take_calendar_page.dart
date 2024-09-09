import 'package:flutter/material.dart';
import 'package:medicine_chest/entities/take_record.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';
import 'package:medicine_chest/ui/dependencies/take_record_storage.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_day_schedule.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_day_schedule_provider.dart';
import 'package:medicine_chest/ui/take_medicine/take_medicine.dart';
import 'package:table_calendar/table_calendar.dart';

class TakeCalendarPage extends StatefulWidget {
  TakeCalendarDayScheduleProvider _scheduleProvider;
  MedicineStorage _medicineStorage;
  MedicinePackStorage _medicinePackStorage;
  TakeRecordStorage _takeRecordStorage;

  TakeCalendarPage(this._scheduleProvider, this._medicineStorage, this._medicinePackStorage, this._takeRecordStorage, {super.key});

  @override
  State<StatefulWidget> createState() {
    return TakeCalendarPageState(_scheduleProvider, _medicineStorage, _medicinePackStorage, _takeRecordStorage);
  }
}

class TakeCalendarPageState extends State<TakeCalendarPage> {
  TakeCalendarDayScheduleProvider _scheduleProvider;
   MedicineStorage _medicineStorage;
  MedicinePackStorage _medicinePackStorage;
  TakeRecordStorage _takeRecordStorage;

  TakeCalendarPageState(this._scheduleProvider, this._medicineStorage, this._medicinePackStorage, this._takeRecordStorage);

  CurrentDayModel _currentDayModel = CurrentDayModel(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Календарь приема"),
      ),
      body: _mainContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_onAddClicked()},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _mainContent() {
    return Column(
      children: [
        _calendar(),
        Divider(),
        _dayItemsList(),
      ],
    );
  }

  Widget _calendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      currentDay: _currentDayModel.getDayTime(),
      focusedDay: _currentDayModel.getDayTime(),
      calendarFormat: CalendarFormat.week,
      headerStyle: HeaderStyle(formatButtonVisible: false),
      onDaySelected: (selectedDay, focusedDay) => {
        setState(() {
          _currentDayModel.setDayTime(selectedDay);
        })
      },
    );
  }

  Widget _dayItemsList() {
    return TakeCalendarDayScheduleWidget(_currentDayModel, _scheduleProvider); // todo receive provider from outside
  }

  void _onAddClicked() async {
    bool? newTakeAdded = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TakeMedicinePage(_medicineStorage, _medicinePackStorage, _takeRecordStorage))
    );
    if (newTakeAdded == true) {
      setState(() {
        _currentDayModel.setDayTime(_currentDayModel.getDayTime()); // reloading events;
      });
    }
  }
}
