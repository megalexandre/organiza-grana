import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';

class SavedBorderoItem {
  const SavedBorderoItem({
    required this.id,
    required this.amountCents,
    required this.dueDate,
    this.interestAmountCents,
    this.proceedsCents,
    this.depositDate,
    this.settlementDate,
    this.totalDays,
  });

  final String id;
  final int amountCents;
  final DateTime dueDate;
  final int? interestAmountCents;
  final int? proceedsCents;
  final DateTime? depositDate;
  final DateTime? settlementDate;
  final int? totalDays;

  BorderoInputItem toInputItem() => BorderoInputItem(
        amountCents: amountCents,
        dueDate: dueDate,
      );

  factory SavedBorderoItem.fromJson(Map<String, dynamic> json) {
    return SavedBorderoItem(
      id: json['id'].toString(),
      amountCents: json['amount_cents'] as int,
      dueDate: DateTime.parse(json['due_date'] as String),
      interestAmountCents: json['interest_amount_cents'] as int?,
      proceedsCents: json['proceeds_cents'] as int?,
      depositDate: json['deposit_date'] != null
          ? DateTime.parse(json['deposit_date'] as String)
          : null,
      settlementDate: json['settlement_date'] != null
          ? DateTime.parse(json['settlement_date'] as String)
          : null,
      totalDays: json['total_days'] as int?,
    );
  }
}
