import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';

class Receivable {
  const Receivable({
    required this.id,
    required this.value,
    required this.receiptDate,
    this.amountCents,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final double value;
  final DateTime receiptDate;
  final int? amountCents;
  final ReceivableStatus? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  factory Receivable.fromJson(Map<String, dynamic> json) {
    final rawDate =
        (json['due_date'] ?? json['receipt_date'] ?? json['receiptDate'])
            ?.toString();
    final parsedDate = rawDate != null ? DateTime.tryParse(rawDate) : null;
    final amountCents = _readInt(json['amount_cents']);
    final value = _readAmount(json['amount']) ??
        (json['value'] as num?)?.toDouble() ??
        ((amountCents ?? 0) / 100);

    return Receivable(
      id: (json['id'] ?? '${value}_$rawDate').toString(),
      value: value,
      receiptDate: parsedDate ?? DateTime.now(),
      amountCents: amountCents,
      status: ReceivableStatus.fromJson(json['status']),
      createdAt: _readDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _readDateTime(json['updated_at'] ?? json['updatedAt']),
      deletedAt: _readDateTime(json['deleted_at'] ?? json['deletedAt']),
    );
  }

  static double? _readAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _readDateTime(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
