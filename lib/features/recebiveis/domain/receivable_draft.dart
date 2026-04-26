class ReceivableDraft {
  const ReceivableDraft({
    required this.value,
    required this.receiptDate,
    this.status = 'awating',
  });

  final double value;
  final DateTime receiptDate;
  final String status;
}