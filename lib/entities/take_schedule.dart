abstract class TakeSchedule {
   DateTime getFirstTakeDay();
   DateTime getLastTakeDay();

   List<DateTime> getTakeMomentsForDay(DateTime day);
}