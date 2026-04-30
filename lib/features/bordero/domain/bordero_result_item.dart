class BorderoResultItem {
  const BorderoResultItem({
    required this.amountCents,
    required this.dueDate,
    required this.totalDays,
    required this.interestRatePercent,
    required this.interestAmountCents,
    required this.proceedsCents,
  });

  final int amountCents;
  final DateTime dueDate;
  final int totalDays;
  final double interestRatePercent;
  final int interestAmountCents;
  final int proceedsCents;

  double get value => amountCents / 100;
  double get interestAmount => interestAmountCents / 100;
  double get proceeds => proceedsCents / 100;

  factory BorderoResultItem.fromJson(Map<String, dynamic> json) {
    return BorderoResultItem(
      amountCents: json['amount_cents'] as int,
      dueDate: DateTime.parse(json['due_date'] as String),
      totalDays: json['total_days'] as int,
      interestRatePercent: (json['interest_rate_percent'] as num).toDouble(),
      interestAmountCents: json['interest_amount_cents'] as int,
      proceedsCents: json['proceeds_cents'] as int,
    );
  }
}
