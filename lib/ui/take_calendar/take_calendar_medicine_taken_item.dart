import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_item.dart';

class TakeCalendarMedicineTakenItemWidget extends StatelessWidget {
  final MedicineTaken _medicineTaken;

  TakeCalendarMedicineTakenItemWidget(this._medicineTaken, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(Icons.medication)),
      _mainColumn(context),
      Spacer(),
      Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: _timeWidget()), 
    ]);
  }

  Widget _mainColumn(BuildContext context) {
  
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _medicineTaken.takeRecord.medicine.getPrintedName(),
        ),
        _takeTextWidget(context),
      ],
    );
  }

  Widget _takeTextWidget(BuildContext context) {
    String takeAmountString;
    Color textColor;

    takeAmountString = "Принято в количестве ${_medicineTaken.takeRecord.getTakenAmount().toStringAsFixed(2)}";
    textColor = Colors.green;

    return Text(takeAmountString, style: TextStyle(color: textColor),);
  }

  Widget _timeWidget() {
    final timeNF = NumberFormat("00");
    final timeOfDay = _medicineTaken.takeRecord.takeTime;
    final timeString =
        "${timeNF.format(timeOfDay.hour)}:${timeNF.format(timeOfDay.minute)}";

    return Text(timeString, style: TextStyle(fontWeight: FontWeight.bold));
  }
}
