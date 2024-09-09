import 'package:flutter/material.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/take_record.dart';

abstract class TakeCalendarItem {
  TimeOfDay getTimeOfDay();
}

class TakeMedicineReminder extends TakeCalendarItem {
  Medicine medicine;
  double oneTakeAmount;
  TimeOfDay timeOfDay;
  bool haveBeenTaken;

  TakeMedicineReminder(this.medicine, this.oneTakeAmount, this.timeOfDay, this.haveBeenTaken);
  
  @override
  TimeOfDay getTimeOfDay() {
    return timeOfDay;
  }

  
}

class MedicineTaken extends TakeCalendarItem {
  TakeRecord takeRecord;

  MedicineTaken(this.takeRecord);
  
  @override
  TimeOfDay getTimeOfDay() {
    return TimeOfDay.fromDateTime(takeRecord.takeTime);
  }
}