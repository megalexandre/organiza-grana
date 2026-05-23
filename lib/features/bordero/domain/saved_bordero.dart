class SavedBordero {
  const SavedBordero({
    required this.id,
    required this.changeDate,
    required this.monthlyRatePercent,
    required this.totalAmountCents,
    required this.totalProceedsCents,
    required this.totalInterestAmountCents,
    required this.averageDays,
    required this.createdAt,
  });

  final String id;
  final DateTime changeDate;
  final double monthlyRatePercent;
  final int totalAmountCents;
  final int totalProceedsCents;
  final int totalInterestAmountCents;
  final double averageDays;
  final DateTime createdAt;

  double get totalAmount => totalAmountCents / 100;
  double get totalProceeds => totalProceedsCents / 100;
  double get totalInterestAmount => totalInterestAmountCents / 100;
  double get discountPercent =>
      totalAmountCents > 0 ? (totalInterestAmountCents / totalAmountCents) * 100 : 0;

  factory SavedBordero.fromJson(Map<String, dynamic> json) {
    return SavedBordero(
      id: json['id'] as String,
      changeDate: DateTime.parse(json['change_date'] as String),
      monthlyRatePercent: _readDouble(json['monthly_rate_percent']) ?? 0,
      totalAmountCents: json['total_amount_cents'] as int,
      totalProceedsCents: json['total_proceeds_cents'] as int,
      totalInterestAmountCents: json['total_interest_amount_cents'] as int,
      averageDays: _readDouble(json['average_days']) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static double? _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
