import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivables_pagination.dart';

class ReceivablesPageResult {
  const ReceivablesPageResult({
    required this.items,
    required this.pagination,
  });

  final List<Receivable> items;
  final ReceivablesPagination pagination;
}