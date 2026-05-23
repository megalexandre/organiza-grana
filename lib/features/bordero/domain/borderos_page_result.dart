import 'package:organizagrana/features/bordero/domain/borderos_pagination.dart';
import 'package:organizagrana/features/bordero/domain/saved_bordero.dart';

class BorderosPageResult {
  const BorderosPageResult({
    required this.items,
    required this.pagination,
  });

  final List<SavedBordero> items;
  final BorderosPagination pagination;

  factory BorderosPageResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    return BorderosPageResult(
      items: rawItems.whereType<Map<String, dynamic>>().map(SavedBordero.fromJson).toList(),
      pagination: BorderosPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}
