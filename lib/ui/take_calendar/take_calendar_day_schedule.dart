import 'package:flutter/material.dart';
import 'package:medicine_chest/entities/take_record.dart';
import 'package:medicine_chest/ui/dependencies/take_record_storage.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_day_schedule_provider.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_item.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_medicine_taken_item.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_reminder_item.dart';

class CurrentDayModel with ChangeNotifier {

  DateTime _dayTime;

  CurrentDayModel(this._dayTime);

  void setDayTime(DateTime newDateTime) {
    _dayTime = newDateTime;
    notifyListeners();
  }

  DateTime getDayTime() {
    return _dayTime;
  }
}

class TakeCalendarDayScheduleWidget extends StatefulWidget{

  final CurrentDayModel currentDayModel;
  final TakeCalendarDayScheduleProvider _provider;
  final TakeRecordStorage _takeRecordStorage;

  TakeCalendarDayScheduleWidget(this.currentDayModel, this._provider, this._takeRecordStorage, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _TakeCalendarDayScheduleState(currentDayModel, _provider, _takeRecordStorage);
  }
}

class _TakeCalendarDayScheduleState extends State<TakeCalendarDayScheduleWidget> {
  
  final CurrentDayModel _currentDayModel;
  final TakeCalendarDayScheduleProvider _provider;
  final TakeRecordStorage _takeRecordStorage;

  _TakeCalendarDayScheduleState(this._currentDayModel, this._provider, this._takeRecordStorage);

  List<TakeCalendarItem>? _items = null;

  @override
  void initState() {
    super.initState();
    _currentDayModel.addListener(() => loadItems());
    loadItems();
  }

  void loadItems() async {
    setState(() {
      _items = null;
    });

    List<TakeCalendarItem> loadedItems = await _provider.getSchedule(_currentDayModel.getDayTime());
    setState(() {
      _items = loadedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items == null ) {
      return _loader();
    } else if (_items!.isNotEmpty) {
      return _mainContent(_items!);
    } else {
      return _emptyText();
    }
  }

  Widget _emptyText() {
    return Text("В этот день нет событий");
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
        return Column(children: [
          TakeCalendarMedicineTakenItemWidget(item, onDeleteConfirmed: onTakeRecordDeleteConfirmed,),
          Divider()
        ]);
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

  void onTakeRecordDeleteConfirmed(TakeRecord takeRecord) async {
    await _takeRecordStorage.deleteTakeRecord(takeRecord);
    loadItems();
  }

}