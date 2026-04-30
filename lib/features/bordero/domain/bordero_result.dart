import 'package:organizagrana/features/bordero/domain/bordero_result_item.dart';

class BorderoResult {
  const BorderoResult({
    required this.items,
    required this.totalAmountCents,
    required this.averageDays,
  });

  final List<BorderoResultItem> items;
  final int totalAmountCents;
  final double averageDays;

  double get totalAmount => totalAmountCents / 100;

  double get totalInterestAmount =>
      items.fold(0.0, (sum, item) => sum + item.interestAmount);

  double get totalProceeds =>
      items.fold(0.0, (sum, item) => sum + item.proceeds);

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
      averageDays: (json['average_days'] as num).toDouble(),
    );
  }
}
