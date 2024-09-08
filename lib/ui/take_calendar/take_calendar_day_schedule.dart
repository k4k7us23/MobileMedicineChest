import 'package:flutter/material.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_day_schedule_provider.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_item.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_medicine_taken_item.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_reminder_item.dart';

class TakeCalendarDayScheduleWidget extends StatefulWidget{

  final DateTime _dayTime;
  final TakeCalendarDayScheduleProvider _provider;

  TakeCalendarDayScheduleWidget(this._dayTime, this._provider, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _TakeCalendarDayScheduleState(_dayTime, _provider);
  }

}

class _TakeCalendarDayScheduleState extends State<TakeCalendarDayScheduleWidget> {
  
  final DateTime _dayTime;
  final TakeCalendarDayScheduleProvider _provider;

  _TakeCalendarDayScheduleState(this._dayTime, this._provider);

  List<TakeCalendarItem>? _items = null;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void loadItems() async {
    setState(() {
      _items = null;
    });

    List<TakeCalendarItem> loadedItems = await _provider.getSchedule(_dayTime);
    setState(() {
      _items = loadedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items == null ) {
      return _loader();
    } else {
      return _mainContent(_items!);
    }
  }

  Widget _mainContent(List<TakeCalendarItem> calendarItems) {
    return ListView.builder(itemBuilder:(context, index) {
      final item = calendarItems[index];
      if (item is TakeMedicineReminder) {
        return Column(
          children: [
            TakeCalendarReminderItemWidget(item), 
            Divider()
          ],
        );
      } else if (item is MedicineTaken) {
        return Column(children: [TakeCalendarMedicineTakenItemWidget(item), Divider()]);
      } else {
        throw Exception("Unknown TakeCalendarItem type");
      }
    }, 
    itemCount: calendarItems.length,
    scrollDirection: Axis.vertical,
    shrinkWrap: true
    );
  }

  Widget _loader() {
    return CircularProgressIndicator(value: null);
  }

}