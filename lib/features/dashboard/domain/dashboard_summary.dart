/// Resumo financeiro exibido nos KPIs do dashboard.
class DashboardSummary {
  const DashboardSummary({
    required this.totalAmountCents,
    required this.totalProceedsCents,
    required this.receivablesCount,
    required this.averageAwaitingDays,
  });

  /// Soma do valor bruto dos recebíveis ativos (em centavos).
  final int totalAmountCents;

  /// Soma do valor líquido a receber, já descontado o juro (em centavos).
  final int totalProceedsCents;

  /// Quantidade de recebíveis ativos.
  final int receivablesCount;

  /// Prazo médio de espera, em dias.
  final double averageAwaitingDays;

  double get totalAmount => totalAmountCents / 100;
  double get totalProceeds => totalProceedsCents / 100;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalAmountCents: _readInt(json['total_amount_cents']) ?? 0,
      totalProceedsCents: _readInt(json['total_proceeds_cents']) ?? 0,
      receivablesCount: _readInt(json['receivables_count']) ?? 0,
      averageAwaitingDays: _readDouble(json['average_awaiting_days']) ?? 0,
    );
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
