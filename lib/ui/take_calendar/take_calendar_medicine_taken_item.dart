import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_chest/entities/take_record.dart';
import 'package:medicine_chest/ui/shared/delete_confitmation_dialog.dart';
import 'package:medicine_chest/ui/shared/delete_or_edit_dialog.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_item.dart';

class TakeCalendarMedicineTakenItemWidget extends StatelessWidget {
  final MedicineTaken _medicineTaken;
  Function(TakeRecord takeRecord)? onDeleteConfirmed = null;

  TakeCalendarMedicineTakenItemWidget(this._medicineTaken,
      {this.onDeleteConfirmed, super.key});

  @override
  Widget build(BuildContext context) {
    final content =
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(Icons.medication)),
      _mainColumn(context),
      Spacer(),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: _timeWidget()),
    ]);
    return InkWell(
        onTap: () {
          showDeleteOrEditDialog(context, showEdit: false, onDelete: () {
            onDeleteClicked(context);
          });
        },
        child: content);
  }

  void onDeleteClicked(BuildContext context) {
    showDeleteConfirmationDialog(context,
        title: "Удаление записи о приеме лекарства",
        bodyText:
            "Вы собираетесь удалить запись о приеме ${_medicineTaken.takeRecord.medicine.name}"
            " в количестве ${_medicineTaken.takeRecord.getTakenAmount().toStringAsFixed(2)}",
        onConfirmed: () {
      onDeleteConfirmed?.call(_medicineTaken.takeRecord);
    });
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

    takeAmountString =
        "Принято в количестве ${_medicineTaken.takeRecord.getTakenAmount().toStringAsFixed(2)}";
    textColor = Colors.green;

    return Text(
      takeAmountString,
      style: TextStyle(color: textColor),
    );
  }

  Widget _timeWidget() {
    final timeNF = NumberFormat("00");
    final timeOfDay = _medicineTaken.takeRecord.takeTime;
    final timeString =
        "${timeNF.format(timeOfDay.hour)}:${timeNF.format(timeOfDay.minute)}";

    return Text(timeString, style: TextStyle(fontWeight: FontWeight.bold));
  }
}
