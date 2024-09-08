import 'package:flutter/material.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/take_record.dart';

abstract class TakeCalendarItem {}

class TakeMedicineReminder extends TakeCalendarItem {
  Medicine medicine;
  double oneTakeAmount;
  TimeOfDay timeOfDay;
  bool haveBeenTaken;

  TakeMedicineReminder(this.medicine, this.oneTakeAmount, this.timeOfDay, this.haveBeenTaken);
}

class MedicineTaken extends TakeCalendarItem {
  TakeRecord takeRecord;

  MedicineTaken(this.takeRecord);
}