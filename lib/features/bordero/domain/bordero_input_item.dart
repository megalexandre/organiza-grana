import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoInputItem {
  const BorderoInputItem({
    required this.amountCents,
    required this.dueDate,
    required this.awaitingDays,
  });

  final int amountCents;
  final DateTime dueDate;
  final int awaitingDays;

  double get value => amountCents / 100;

  Map<String, dynamic> toJson() => {
        'amount_cents': amountCents,
        'due_date': formatDateIso(dueDate),
        'awaiting_days': awaitingDays,
      };
}
