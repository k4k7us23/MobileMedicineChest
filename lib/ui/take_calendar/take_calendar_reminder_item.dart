import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_item.dart';

class TakeCalendarReminderItemWidget extends StatelessWidget {
  final TakeMedicineReminder _takeMedicineReminder;

  TakeCalendarReminderItemWidget(this._takeMedicineReminder, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(Icons.schedule)),
      _mainColumn(context),
      Spacer(),
      Padding(
          key: ValueKey("take_medicine_reminder_item_time"),
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: _timeWidget()),
    ]);
  }

  Widget _mainColumn(BuildContext context) {
    return Column(
      key: ValueKey("take_medicine_reminder_item_mainColumn"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _takeMedicineReminder.medicine.getPrintedName(),
        ),
        _takeTextWidget(context),
      ],
    );
  }

  Widget _takeTextWidget(BuildContext context) {
    String takeAmountString;
    Color textColor;

    ColorScheme scheme = Theme.of(context).colorScheme;
    if (_takeMedicineReminder.haveBeenTaken) {
      takeAmountString = "Принято";
      textColor = Colors.green;
    } else {
      takeAmountString =
          "Принять в количестве: ${_takeMedicineReminder.oneTakeAmount.toStringAsFixed(2)}";
      textColor = scheme.primary;
    }

    return Text(
      takeAmountString,
      style: TextStyle(color: textColor),
    );
  }

  Widget _timeWidget() {
    final timeNF = NumberFormat("00");
    final timeOfDay = _takeMedicineReminder.timeOfDay;
    final timeString =
        "${timeNF.format(timeOfDay.hour)}:${timeNF.format(timeOfDay.minute)}";

    return Text(timeString, style: TextStyle(fontWeight: FontWeight.bold));
  }
}
