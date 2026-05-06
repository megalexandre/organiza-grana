class ReceivablesSummary {
  const ReceivablesSummary({
    required this.count,
    required this.totalAmountCents,
  });

  final int count;
  final int totalAmountCents;

  double get totalAmount => totalAmountCents / 100;

  factory ReceivablesSummary.fromJson(Map<String, dynamic> json) {
    return ReceivablesSummary(
      count: _readInt(json['count']) ?? 0,
      totalAmountCents: _readInt(json['total_amount_cents']) ?? 0,
    );
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}