import 'package:organizagrana/shared/utils/app_formats.dart';

class ReceivableDraft {
  const ReceivableDraft({
    required this.amountCents,
    required this.dueDate,
    this.changeDate,
  });

  final int amountCents;
  final DateTime dueDate;
  final DateTime? changeDate;

  Map<String, dynamic> toJson() {
    return {
      'amount_cents': '$amountCents',
      'due_date': formatDateIso(dueDate),
      'status': 'awaiting',
      if (changeDate != null) 'change_date': formatDateIso(changeDate!),
    };
  }
}
