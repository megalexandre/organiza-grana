class Receivable {
  const Receivable({
    required this.id,
    required this.value,
    required this.receiptDate,
  });

  final String id;
  final double value;
  final DateTime receiptDate;

  factory Receivable.fromJson(Map<String, dynamic> json) => Receivable(
        id: json['id'] as String,
        value: (json['value'] as num).toDouble(),
        receiptDate: DateTime.parse(json['receipt_date'] as String),
      );
}
