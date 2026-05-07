class HolidayOverride {
  const HolidayOverride({
    required this.id,
    required this.date,
    required this.holiday,
    this.name,
  });

  final String id;
  final DateTime date;
  final bool holiday;
  final String? name;

  factory HolidayOverride.fromJson(
    Map<String, dynamic> json, {
    DateTime? fallbackDate,
  }) =>
      HolidayOverride(
        id: json['id'] as String,
        date: json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : fallbackDate!,
        holiday: json['holiday'] as bool? ?? false,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'date':
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'holiday': holiday,
        if (name != null) 'name': name,
      };
}
