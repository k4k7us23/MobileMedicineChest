import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayTimeMomentsSelector extends StatefulWidget {
  ValueSetter<List<int>> _dayTimeMomentsUpdated;
  List<int> initialDayTimeMoments = [];

  DayTimeMomentsSelector(this._dayTimeMomentsUpdated,
      {this.initialDayTimeMoments = const [], super.key});

  @override
  State<StatefulWidget> createState() {
    return DayTimeMomentsState(
        this._dayTimeMomentsUpdated, this.initialDayTimeMoments);
  }
}

class DayTimeMomentsState extends State<DayTimeMomentsSelector> {
  static const int _minutesInHour = 60;
  static final NumberFormat timeMomentNumberFormat = NumberFormat("00");

  ValueSetter<List<int>> _dayTimeMomentsUpdated;
  final List<int> _dayTimeMoments;

  DayTimeMomentsState(this._dayTimeMomentsUpdated, this._dayTimeMoments);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: _buildTitle(context));
          } else if (index == _dayTimeMoments.length + 1) {
            return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildAddButton(context));
          } else {
            return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                child: _buildTimeMoment(_dayTimeMoments[index - 1]));
          }
        },
        itemCount: _dayTimeMoments.length + 2,
        physics: NeverScrollableScrollPhysics());
  }

  String _getTimeMomentString(int minuteOfDay) {
    var hour = minuteOfDay ~/ _minutesInHour;
    var minute = minuteOfDay % _minutesInHour;

    var hourS = timeMomentNumberFormat.format(hour);
    var minuteS = timeMomentNumberFormat.format(minute);
    return "$hourS:$minuteS";
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      "Время приема лекарства",
      style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    var actionColor = Theme.of(context).colorScheme.primary;
    return TextButton(
        key: ValueKey("scheme_add_time_btn"),
        onPressed: () => {_onAddTimeMomentPressed(context)},
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.add, color: actionColor),
          SizedBox(width: 8),
          Text('Добавить', style: TextStyle(fontSize: 16, color: actionColor)),
        ]));
  }

  void _onAddTimeMomentPressed(BuildContext context) async {
    TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (timeOfDay != null) {
      var minuteOfDay = timeOfDay.hour * _minutesInHour + timeOfDay.minute;
      _addDayTimeMoment(minuteOfDay);
    }
  }

  void _addDayTimeMoment(int dayTimeMoment) {
    setState(() {
      _dayTimeMoments.add(dayTimeMoment);
      _dayTimeMoments.sort();
      final moments = Set<int>();
      _dayTimeMoments.retainWhere((moment) => moments.add(moment));

      _dayTimeMomentsUpdated.call([..._dayTimeMoments]);
    });
  }

  void _removeDayTimeMoment(int dayTimeMoment) {
    setState(() {
      _dayTimeMoments.remove(dayTimeMoment);
      _dayTimeMomentsUpdated.call([..._dayTimeMoments]);
    });
  }

  Widget _buildTimeMoment(int minuteOfDay) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Expanded(child: Container()),
              IconButton(
                  onPressed: () => {_removeDayTimeMoment(minuteOfDay)},
                  icon: Icon(Icons.delete))
            ],
          ),
          Text(
            _getTimeMomentString(minuteOfDay),
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      Divider(),
    ]);
  }
}
