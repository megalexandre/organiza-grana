import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class ReceivableDraft {
  const ReceivableDraft({
    required this.amountCents,
    required this.dueDate,
    this.changeDate,
    this.status = ReceivableStatus.awaiting,
  });

  final int amountCents;
  final DateTime dueDate;
  final DateTime? changeDate;
  final ReceivableStatus status;

  Map<String, dynamic> toJson() {
    return {
      'amount_cents': '$amountCents',
      'due_date': formatDateIso(dueDate),
      'status': status.toJson(),
      if (changeDate != null) 'change_date': formatDateIso(changeDate!),
    };
  }
}
