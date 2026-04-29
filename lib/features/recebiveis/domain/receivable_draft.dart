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
      'due_date': _formatDate(dueDate),
      'status': 'awaiting',
      if (changeDate != null) 'change_date': _formatDate(changeDate!),
    };
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}'
      '-${date.month.toString().padLeft(2, '0')}'
      '-${date.day.toString().padLeft(2, '0')}';
}
