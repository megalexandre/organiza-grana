import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';

class ReceivableDraft {
  const ReceivableDraft({
    required this.value,
    required this.receiptDate,
    this.status = ReceivableStatus.awaiting,
  });

  final double value;
  final DateTime receiptDate;
  final ReceivableStatus status;
}