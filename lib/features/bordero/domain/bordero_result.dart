import 'package:organizagrana/features/bordero/domain/bordero_result_item.dart';

class BorderoResult {
  const BorderoResult({
    required this.items,
    required this.totalAmountCents,
    required this.totalProceedsCents,
    required this.totalInterestAmountCents,
    required this.averageDays,
  });

  final List<BorderoResultItem> items;
  final int totalAmountCents;
  final int totalProceedsCents;
  final int totalInterestAmountCents;
  final double averageDays;

  double get totalAmount => totalAmountCents / 100;
  double get totalProceeds => totalProceedsCents / 100;
  double get totalInterestAmount => totalInterestAmountCents / 100;

  factory BorderoResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(BorderoResultItem.fromJson)
            .toList()
        : <BorderoResultItem>[];

    return BorderoResult(
      items: items,
      totalAmountCents: json['total_amount_cents'] as int,
      totalProceedsCents: json['total_proceeds_cents'] as int,
      totalInterestAmountCents: json['total_interest_amount_cents'] as int,
      averageDays: (json['average_days'] as num).toDouble(),
    );
  }
}
