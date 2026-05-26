import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoInputItem {
  const BorderoInputItem({
    required this.amountCents,
    required this.dueDate,
    this.status = ReceivableStatus.draft,
    this.interestAmountCents,
    this.proceedsCents,
    this.depositDate,
    this.settlementDate,
    this.totalDays,
  });

  final int amountCents;
  final DateTime dueDate;
  final ReceivableStatus status;
  final int? interestAmountCents;
  final int? proceedsCents;
  final DateTime? depositDate;
  final DateTime? settlementDate;
  final int? totalDays;

  double get value => amountCents / 100;

  Map<String, dynamic> toJson() => {
        'amount_cents': amountCents,
        'due_date': formatDateIso(dueDate),
      };
}
