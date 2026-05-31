import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';

class Receivable {
  const Receivable({
    required this.id,
    required this.amountCents,
    required this.dueDate,
    required this.awaitingDays,
    required this.status,
    this.changeDate,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.notes,
    this.sequenceNumber,
  });

  final String id;
  final int amountCents;
  final DateTime dueDate;
  final int awaitingDays;
  final ReceivableStatus status;
  final DateTime? changeDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? notes;
  final int? sequenceNumber;

  double get value => amountCents / 100;

  factory Receivable.fromJson(Map<String, dynamic> json) {
    return Receivable(
      id: json['id'].toString(),
      amountCents: json['amount_cents'] as int,
      dueDate: DateTime.parse(json['due_date'] as String),
      awaitingDays: json['awaiting_days'] as int,
      status: ReceivableStatus.fromJson(json['status']) ?? ReceivableStatus.awaiting,
      changeDate: _parseDate(json['change_date']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      deletedAt: _parseDate(json['deleted_at']),
      notes: json['notes'] as String?,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  Receivable copyWith({ReceivableStatus? status}) {
    return Receivable(
      id: id,
      amountCents: amountCents,
      dueDate: dueDate,
      awaitingDays: awaitingDays,
      status: status ?? this.status,
      changeDate: changeDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      notes: notes,
      sequenceNumber: sequenceNumber,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
