import 'package:organizagrana/features/holidays/domain/holiday_override.dart';

class CalendarDay {
  const CalendarDay({
    required this.date,
    required this.weekend,
    required this.holiday,
    required this.businessDay,
    this.holidayName,
    this.overrideId,
    this.override,
  });

  final DateTime date;
  final bool weekend;
  final bool holiday;
  final bool businessDay;
  final String? holidayName;

  // ID do override — presente quando existe um override para esse dia,
  // mesmo que o objeto completo não esteja disponível na resposta.
  final String? overrideId;

  // Objeto completo retornado quando a API embute o override no dia.
  final HolidayOverride? override;

  bool get hasOverride => overrideId != null;

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'] as String);

    HolidayOverride? override;
    String? overrideId;

    final rawOverride = json['override'];
    if (rawOverride is Map<String, dynamic>) {
      override = HolidayOverride.fromJson(rawOverride, fallbackDate: date);
      overrideId = override.id;
    } else {
      // Fallback: API retorna apenas o ID como string
      overrideId = json['override_id'] as String?;
    }

    return CalendarDay(
      date: date,
      weekend: json['weekend'] as bool? ?? false,
      holiday: json['holiday'] as bool? ?? false,
      businessDay: json['business_day'] as bool? ?? false,
      holidayName: json['holiday_name'] as String?,
      overrideId: overrideId,
      override: override,
    );
  }
}
