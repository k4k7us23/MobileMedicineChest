import 'package:medicine_chest/entities/take_schedule.dart';
import 'package:medicine_chest/utils/date_utils.dart';

class EveryDaySchedule extends TakeSchedule {
  static const int _secondsInsideHour = 60 * 60;
  static const int _secondsInsideMinute = 60;

  List<int> _timeMoments; // seconds inside the day;
  DateTime _startTime;
  DateTime _endTime;

  EveryDaySchedule._internal(this._timeMoments, this._startTime, this._endTime);

  factory EveryDaySchedule.create(
      List<int> timeMoments, DateTime startTime, DateTime endTime) {
    return EveryDaySchedule._internal(
        timeMoments, toBeginOfTheDay(startTime), toEndOfTheDay(endTime));
  }

  factory EveryDaySchedule.fromJson(Map<String, dynamic> json) {
    List<int> timeMoments = List<int>.from(json["timeMoments"]);
    DateTime startTime =
        DateTime.fromMillisecondsSinceEpoch(json["startTime"] as int);
    DateTime endTime =
        DateTime.fromMillisecondsSinceEpoch(json["endTime"] as int);
    return EveryDaySchedule.create(timeMoments, startTime, endTime);
  }

  Map<String, dynamic> toJson() {
    return {
      "timeMoments": _timeMoments,
      "startTime": _startTime.millisecondsSinceEpoch,
      "endTime": _endTime.millisecondsSinceEpoch,
    };
  }

  @override
  DateTime getFirstTakeDay() {
    return _startTime;
  }

  @override
  DateTime getLastTakeDay() {
    return _endTime;
  }

  @override
  List<DateTime> getTakeMomentsForDay(DateTime day) {
    if (day.isBefore(_startTime) || day.isAfter(_endTime)) {
      return List.empty();
    } else {
      List<DateTime> result = [];
      DateTime beginOfTheDay = toBeginOfTheDay(day);
      for (var timeMoment in _timeMoments) {
        var hour = timeMoment ~/ _secondsInsideHour;
        var secondsOffsetFromHour = timeMoment % _secondsInsideHour;
        var minutes = secondsOffsetFromHour ~/ _secondsInsideMinute;

        DateTime dateTimeMoment = beginOfTheDay.copyWith(
          hour: hour,
          minute: minutes,
        );
        result.add(dateTimeMoment);
      }
      return result;
    }
  }

  int getTakeTimesPerDay() {
    return _timeMoments.length;
  }
}
