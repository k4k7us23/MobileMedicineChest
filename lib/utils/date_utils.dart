

DateTime toBeginOfTheDay(DateTime dateTime) {
  return dateTime.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
}

DateTime toEndOfTheDay(DateTime dateTime) {
  return dateTime.copyWith(hour: 23, minute: 59, second: 59, millisecond: 999, microsecond: 999);
}