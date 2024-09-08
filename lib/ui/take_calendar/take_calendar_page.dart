import 'package:flutter/material.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_day_schedule.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_day_schedule_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class TakeCalendarPage extends StatefulWidget {
  const TakeCalendarPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return TakeCalendarPageState();
  }
}

class TakeCalendarPageState extends State<TakeCalendarPage> {
  DateTime _selectedDay = DateTime.now();

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
      currentDay: _selectedDay,
      focusedDay: _selectedDay,
      calendarFormat: CalendarFormat.week,
      headerStyle: HeaderStyle(formatButtonVisible: false),
      onDaySelected: (selectedDay, focusedDay) => {
        setState(() {
          _selectedDay = selectedDay;
        })
      },
    );
  }

  Widget _dayItemsList() {
    return TakeCalendarDayScheduleWidget(_selectedDay, TakeCalendarDayScheduleProvider()); // todo receive provider from outside
  }

  void _onAddClicked() {
    // TODO open take medicine page
  }
}
