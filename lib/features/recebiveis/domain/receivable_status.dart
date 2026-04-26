enum ReceivableStatus {
  awaiting(0, 'Aguardando'),
  inAnalysis(1, 'Em análise'),
  inTransaction(2, 'Em transação'),
  paid(3, 'Pago'),
  overdue(4, 'Vencido');

  const ReceivableStatus(this.value, this.label);

  final int value;
  final String label;

  static ReceivableStatus? fromJson(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) {
      return ReceivableStatus.values.where((s) => s.value == raw).firstOrNull;
    }
    final str = raw.toString().toLowerCase();
    return switch (str) {
      'awaiting' => ReceivableStatus.awaiting,
      'in_analysis' => ReceivableStatus.inAnalysis,
      'in_transaction' => ReceivableStatus.inTransaction,
      'paid' => ReceivableStatus.paid,
      'overdue' => ReceivableStatus.overdue,
      _ => null,
    };
  }

  String toJson() => switch (this) {
        ReceivableStatus.awaiting => 'awaiting',
        ReceivableStatus.inAnalysis => 'in_analysis',
        ReceivableStatus.inTransaction => 'in_transaction',
        ReceivableStatus.paid => 'paid',
        ReceivableStatus.overdue => 'overdue',
      };
}
