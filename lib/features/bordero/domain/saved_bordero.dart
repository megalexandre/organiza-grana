class SavedBordero {
  const SavedBordero({
    required this.id,
    required this.changeDate,
    required this.totalAmountCents,
    required this.totalProceedsCents,
    required this.totalInterestAmountCents,
  });

  final String id;
  final DateTime changeDate;
  final int totalAmountCents;
  final int totalProceedsCents;
  final int totalInterestAmountCents;

  factory SavedBordero.fromJson(Map<String, dynamic> json) {
    return SavedBordero(
      id: json['id'] as String,
      changeDate: DateTime.parse(json['change_date'] as String),
      totalAmountCents: json['total_amount_cents'] as int,
      totalProceedsCents: json['total_proceeds_cents'] as int,
      totalInterestAmountCents: json['total_interest_amount_cents'] as int,
    );
  }
}
