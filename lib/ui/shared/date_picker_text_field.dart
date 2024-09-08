import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerTextField extends StatefulWidget {
  final String? label;
  final DateTime? initialDate;
  final DateTime? minDateTime;
  final DateTime? maxDateTime;
  final ValueSetter<DateTime>? dateTimeSetted;

  const DatePickerTextField(
      {super.key,
      this.label,
      this.initialDate,
      this.minDateTime,
      this.maxDateTime,
      this.dateTimeSetted});

  @override
  State<StatefulWidget> createState() {
    return DatePickerTextFieldState(
        label: label,
        selectedDate: initialDate,
        minDateTime: minDateTime,
        dateTimeSetted: dateTimeSetted);
  }
}

class DatePickerTextFieldState extends State<DatePickerTextField> {
  DateTime? minDateTime;
  DateTime? maxDateTime;
  final String? label;
  final ValueSetter<DateTime>? dateTimeSetted;

  DateTime? selectedDate;

  DatePickerTextFieldState(
      {this.label, this.selectedDate, this.minDateTime, this.dateTimeSetted, this.maxDateTime});

  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textFieldController.text = _formatDateTime(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: _textFieldController,
        onTap: () async {
          DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: _getMinDateTime(),
              lastDate: maxDateTime ?? DateTime(2200, 0));
          setState(() {
            if (picked != null) {
              selectedDate = picked;
              _textFieldController.text = _formatDateTime(picked);
              dateTimeSetted?.call(picked);
            }
          });
        },
        readOnly: true,
        decoration:
            InputDecoration(border: UnderlineInputBorder(), labelText: label));
  }

  DateTime _getMinDateTime() {
    if (minDateTime == null) {
      return DateTime(2000, 0);
    } else {
      return minDateTime!;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    return (dateTime != null) ? DateFormat("dd.MM.yyyy").format(dateTime) : "";
  }
}
