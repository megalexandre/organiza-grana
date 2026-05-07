import 'package:organizagrana/features/holidays/domain/calendar_day.dart';

class CalendarMonth {
  const CalendarMonth({
    required this.year,
    required this.month,
    required this.days,
  });

  final int year;
  final int month;
  final List<CalendarDay> days;

  factory CalendarMonth.fromJson(Map<String, dynamic> json) {
    final year = json['year'] as int;
    final month = json['month'] as int;

    final apiDays = (json['days'] as List)
        .map((d) => CalendarDay.fromJson(d as Map<String, dynamic>))
        .toList();

    final apiDayMap = {for (final d in apiDays) d.date.day: d};
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final days = List.generate(daysInMonth, (i) {
      final dayNum = i + 1;
      if (apiDayMap.containsKey(dayNum)) return apiDayMap[dayNum]!;
      final date = DateTime(year, month, dayNum);
      final isWeekend = date.weekday >= DateTime.saturday;
      return CalendarDay(
        date: date,
        weekend: isWeekend,
        holiday: false,
        businessDay: !isWeekend,
      );
    });

    return CalendarMonth(year: year, month: month, days: days);
  }
}
