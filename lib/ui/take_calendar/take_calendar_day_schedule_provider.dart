import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';
import 'package:medicine_chest/entities/scheme.dart';
import 'package:medicine_chest/entities/take_record.dart';
import 'package:medicine_chest/entities/take_schedule.dart';
import 'package:medicine_chest/ui/dependencies/scheme_storage.dart';
import 'package:medicine_chest/ui/dependencies/take_record_storage.dart';
import 'package:medicine_chest/ui/take_calendar/take_calendar_item.dart';

class TakeCalendarDayScheduleProvider {
  SchemeStorage _schemeStorage;
  TakeRecordStorage _takeRecordStorage;

  static final VALID_TIME_DIFFERENCE = Duration(hours: 2);

  TakeCalendarDayScheduleProvider(this._schemeStorage, this._takeRecordStorage);

  Future<List<TakeCalendarItem>> getSchedule(DateTime day) async {
    List<Scheme> schemes = await _schemeStorage.getSchemesForDay(day);
    List<TakeRecord> takeRecords = await _takeRecordStorage.getTakeRecordForDay(day);

    takeRecords.sort((t1, t2) => t1.takeTime.compareTo(t2.takeTime));

    Map<int, double> leftAmount = {};
    for (var takeRecord in takeRecords) {
      final takenAmount = takeRecord.getTakenAmount();
      leftAmount[takeRecord.id] = takenAmount;
    }

    List<TakeMedicineReminder> reminders = [];
    for (var scheme in schemes) {
      TakeSchedule schedule = scheme.takeSchedule;
      List<DateTime> takeMoments = schedule.getTakeMomentsForDay(day);
      for (var takeMoment in takeMoments) {
        final time = TimeOfDay.fromDateTime(takeMoment);
        bool haveBeenTaken = _haveTaken(leftAmount, takeRecords, scheme.oneTakeAmount, takeMoment);
        reminders.add(TakeMedicineReminder(scheme.medicine, scheme.oneTakeAmount, time , haveBeenTaken));
      }
    }

    List<TakeCalendarItem> result = [...reminders];
    for (var takeRecord in takeRecords) {
      result.add(MedicineTaken(takeRecord));
    }
    result.sort((item1, item2) => item1.getTimeOfDay().compareTo(item2.getTimeOfDay()));

    return result;
  }

  bool _haveTaken(Map<int, double> leftAmountByTakeId, List<TakeRecord> takeRecords, double needAmount, DateTime shouldTakeMoment) {
    Map<int, double> taken = {};
    double totalTaken = 0;
    for (var takeRecord in takeRecords) {
      var takeTime = takeRecord.takeTime;
      var diff = takeTime.difference(shouldTakeMoment).abs();
      if (diff.compareTo(VALID_TIME_DIFFERENCE) <= 0) {
        var curTakeAmount = leftAmountByTakeId[takeRecord.id] ?? 0.0;
        var curRemoveAmount = min(curTakeAmount, needAmount - totalTaken);
        taken[takeRecord.id] = curRemoveAmount;
        leftAmountByTakeId[takeRecord.id] = curTakeAmount - curRemoveAmount;

        totalTaken += curRemoveAmount;
      }
    }
    
    bool haveTaken = totalTaken >= needAmount;
    if (haveTaken) {
      return true;
    } else {
      taken.forEach((id, amount) {
        leftAmountByTakeId[id] = (leftAmountByTakeId[id]??0) + amount;
      });
      return false;
    }
  }
}

extension on TimeOfDay {
  compareTo(TimeOfDay timeOfDay) {
    var thisMinutes = hour * 60 + minute;
    var otherMinutes = timeOfDay.hour * 60 + timeOfDay.minute;

    return thisMinutes.compareTo(otherMinutes);
  }
}
