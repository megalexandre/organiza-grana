import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_summary.dart';
import 'package:organizagrana/features/recebiveis/domain/receivables_pagination.dart';

class ReceivablesPageResult {
  const ReceivablesPageResult({
    required this.items,
    required this.summary,
    required this.pagination,
  });

  final List<Receivable> items;
  final ReceivablesPagination pagination;
  final ReceivablesSummary summary;

  factory ReceivablesPageResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['receivables'] as List? ?? [];
    return ReceivablesPageResult(
      items: rawItems.whereType<Map<String, dynamic>>().map(Receivable.fromJson).toList(),
      pagination: ReceivablesPagination.fromJson(json['pagination'] ?? {}),
      summary: ReceivablesSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

