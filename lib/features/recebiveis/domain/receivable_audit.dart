class ReceivableAudit {
  const ReceivableAudit({
    required this.id,
    required this.receivableId,
    required this.event,
    required this.changes,
    required this.createdAt,
    this.whodunnit,
    this.receivableAmountCents,
    this.receivableDueDate,
    this.receivableSequenceNumber,
  });

  final String id;
  final String receivableId;
  final String event;
  final Map<String, dynamic> changes;
  final DateTime createdAt;
  final String? whodunnit;
  final int? receivableAmountCents;
  final DateTime? receivableDueDate;
  final int? receivableSequenceNumber;

  bool get isCreate => event == 'create';
  bool get isUpdate => event == 'update';
  bool get isDestroy => event == 'destroy';

  bool get isStatusChange => isUpdate && changes.containsKey('status');

  factory ReceivableAudit.fromJson(Map<String, dynamic> json) {
    final rawChanges = json['changes'];
    final Map<String, dynamic> changes;
    if (rawChanges is Map<String, dynamic>) {
      changes = rawChanges;
    } else {
      changes = {};
    }

    return ReceivableAudit(
      id: json['id'].toString(),
      receivableId: json['receivable_id'].toString(),
      event: json['event'] as String,
      changes: changes,
      createdAt: DateTime.parse(json['created_at'] as String),
      whodunnit: json['whodunnit']?.toString(),
      receivableAmountCents: json['receivable_amount_cents'] as int?,
      receivableDueDate: json['receivable_due_date'] != null
          ? DateTime.tryParse(json['receivable_due_date'].toString())
          : null,
      receivableSequenceNumber: json['receivable_sequence_number'] as int?,
    );
  }
}

class ReceivableAuditPageResult {
  const ReceivableAuditPageResult({
    required this.audits,
    required this.total,
    required this.page,
    required this.perPage,
  });

  final List<ReceivableAudit> audits;
  final int total;
  final int page;
  final int perPage;

  bool get hasMore => audits.length >= perPage;

  factory ReceivableAuditPageResult.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    return ReceivableAuditPageResult(
      audits: (json['versions'] as List<dynamic>)
          .map((e) => ReceivableAudit.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: pagination['total'] as int? ?? 0,
      page: pagination['page'] as int? ?? 1,
      perPage: pagination['per_page'] as int? ?? 30,
    );
  }
}
