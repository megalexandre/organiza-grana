import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';

class ReceivableDraft {
  const ReceivableDraft({
    required this.amount,
    required this.dueDate,
    this.status = ReceivableStatus.awaiting,
  });

  final double amount;
  final DateTime dueDate;

  Map<String, dynamic> toJson() {
    return {
      'amount': amount.toStringAsFixed(2).replaceAll('.', ','),
      'due_date': dueDate.toIso8601String().split('T').first,
    };
  }
  final ReceivableStatus status;
}

