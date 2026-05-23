import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';

class SavedBorderoItem {
  const SavedBorderoItem({
    required this.id,
    required this.amountCents,
    required this.dueDate,
    required this.awaitingDays,
  });

  final String id;
  final int amountCents;
  final DateTime dueDate;
  final int awaitingDays;

  BorderoInputItem toInputItem() => BorderoInputItem(
        amountCents: amountCents,
        dueDate: dueDate,
        awaitingDays: awaitingDays,
      );

  factory SavedBorderoItem.fromJson(Map<String, dynamic> json) {
    return SavedBorderoItem(
      id: json['id'].toString(),
      amountCents: json['amount_cents'] as int,
      dueDate: DateTime.parse(json['due_date'] as String),
      awaitingDays: (json['awaiting_days'] as int?) ?? 2,
    );
  }
}
