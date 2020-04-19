import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/standalone.dart';

int getDaysByMonth(int month) {
  switch (month) {
    case DateTime.january:
      return 31;
    case DateTime.february:
      return 28;
    case DateTime.march:
      return 31;
    case DateTime.april:
      return 30;
    case DateTime.may:
      return 31;
    case DateTime.june:
      return 30;
    case DateTime.july:
      return 31;
    case DateTime.august:
      return 31;
    case DateTime.september:
      return 30;
    case DateTime.october:
      return 31;
    case DateTime.november:
      return 30;
    case DateTime.december:
      return 31;
  }
  return 30;
}

Map<String, String> getHistoricalDates([int monthPlus = 0]) {
  initializeTimeZones();
  var currentDate = DateTime.now();
  var month = currentDate.month + monthPlus;
  var year = currentDate.year - 1;
  var days = getDaysByMonth(month);
  var startDateTZ = TZDateTime.local(year, month, 1);
  var endDateTZ = TZDateTime.local(year, month, days);
  var startDate =
      DateTime(startDateTZ.year, startDateTZ.month, startDateTZ.day);
  var endDate = DateTime(endDateTZ.year, endDateTZ.month, endDateTZ.day);
  var dateFormat = DateFormat("yyyy-MM-dd");
  var startDateString = dateFormat.format(startDate);
  var endDateString = dateFormat.format(endDate);
  return {"startDate": startDateString, "endDate": endDateString};
}
