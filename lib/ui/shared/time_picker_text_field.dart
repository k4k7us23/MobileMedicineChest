import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimePickerTextField extends StatefulWidget {
  final String? label;
  final TimeOfDay? initalTime;
  final ValueSetter<TimeOfDay>? timeSetted;

  TimePickerTextField({super.key, this.label, this.initalTime, this.timeSetted});

  @override
  State<StatefulWidget> createState() {
    return TimePickerTextFieldState.create(label, timeSetted, initalTime);
  }
}

class TimePickerTextFieldState extends State<TimePickerTextField> {
  final String? _label;
  final ValueSetter<TimeOfDay>? _onTimeSetted;
  TimeOfDay _selectedTime;

  TimePickerTextFieldState._internal(this._label, this._onTimeSetted, this._selectedTime);

  factory TimePickerTextFieldState.create(String? label, ValueSetter<TimeOfDay>? onTimeSetted, TimeOfDay? initalTime) {
      TimeOfDay selectedTime = initalTime ?? TimeOfDay.now();
      return TimePickerTextFieldState._internal(label, onTimeSetted, selectedTime);
  }

  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textFieldController.text = _formatTime(_selectedTime);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: _textFieldController,
        onTap: () async {
          TimeOfDay? timeOfDay = await showTimePicker(context: context, initialTime: _selectedTime);
          setState(() {
            if (timeOfDay != null) {
              _selectedTime = timeOfDay;
              _textFieldController.text = _formatTime(_selectedTime);
              _onTimeSetted?.call(timeOfDay);
            }
          });
        },
        readOnly: true,
        decoration:
            InputDecoration(border: UnderlineInputBorder(), labelText: _label));
  }

  String _formatTime(TimeOfDay? timeOfDay) {
    if (timeOfDay != null) {
      var partFormat = NumberFormat("00");
      final hourString = partFormat.format(timeOfDay.hour);
      final minutesString = partFormat.format(timeOfDay.minute);
      return "$hourString:$minutesString";
    } else {
      return "";
    }
  }
}
 