import 'dart:math';

import 'package:medicine_chest/entities/every_day_schedule.dart';
import 'package:test/test.dart';

var _beginOfSepetember9 = DateTime(2024, 9, 7, 0, 0);
var _endOfSeptember11 = DateTime(2024, 9, 11, 23, 59, 59, 999, 999);
var _timeMoments = [3600 * 14, 3600 * 16 + 60 * 20]; // 14:00, 16:20


EveryDaySchedule _create() {
  var middleOfSeptember9 = DateTime(2024, 9, 7, 12, 0);
  var middleOfSeptember11 = DateTime(2024, 9, 11, 12, 0);
  return EveryDaySchedule.create(_timeMoments, middleOfSeptember9, middleOfSeptember11);
}

void main() {
  test('EveryDaySchedule getFirstTakeDay() and getLastTakeDay() behaivor', () {
    var schedule = _create();

    expect(schedule.getFirstTakeDay(), _beginOfSepetember9);
    expect(schedule.getLastTakeDay(), _endOfSeptember11);
  });

  test('EveryDaySchedule getTakeMoments() out of range', () {
    var schedule = _create();

    var dayBefore = _beginOfSepetember9.subtract(Duration(days: 1));
    expect(schedule.getTakeMomentsForDay(dayBefore), []);

    var dayAfter = _endOfSeptember11.add(Duration(days: 1)); 
    expect(schedule.getTakeMomentsForDay(dayAfter), []);
  });

  test('EveryDaySchedule getTakeMoments normalBehaivor', () {
    var september10Begin = DateTime(2024, 9, 10);
    var september10MiddleOfTheDay = september10Begin.add(Duration(hours: 12));

    var schedule = _create();
    var expectedMoment1 = september10Begin.add(Duration(hours: 14));
    var expectedMoment2 = september10Begin.add(Duration(hours: 16, minutes: 20));

    expect(schedule.getTakeMomentsForDay(september10MiddleOfTheDay), [expectedMoment1, expectedMoment2]);
  });
}
