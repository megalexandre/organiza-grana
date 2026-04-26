class Receivable {
  const Receivable({
    required this.id,
    required this.value,
    required this.receiptDate,
    this.status,
  });

  final String id;
  final double value;
  final DateTime receiptDate;
  final String? status;

  factory Receivable.fromJson(Map<String, dynamic> json) {
    final rawDate = (json['receipt_date'] ?? json['receiptDate'])?.toString();
    final parsedDate = rawDate != null
        ? DateTime.tryParse(rawDate)
        : null;

    final value = (json['value'] as num?)?.toDouble() ?? 0;

    return Receivable(
      id: (json['id'] ?? '${value}_$rawDate').toString(),
      value: value,
      receiptDate: parsedDate ?? DateTime.now(),
      status: json['status']?.toString(),
    );
  }
}
