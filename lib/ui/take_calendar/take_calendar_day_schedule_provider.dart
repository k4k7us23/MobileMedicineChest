import 'package:flutter/material.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';
import 'package:medicine_chest/entities/take_record.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_item.dart';

class TakeCalendarDayScheduleProvider {

  Future<List<TakeCalendarItem>> getSchedule(DateTime day) async{
    var medicine = Medicine(id: 1, name: "Витамин C", releaseForm: MedicineReleaseForm.tablet);
    return [
      TakeMedicineReminder(medicine, 1.0, TimeOfDay.now(), false), 
      TakeMedicineReminder(medicine, 1.0, TimeOfDay.now(), true),
      MedicineTaken(TakeRecord(1, medicine, DateTime.now(), {MedicinePack(id: 1, medicine: medicine, leftAmount: 2.0,expirationTime: DateTime.now()) : 1.0})),
    ];
  }
}