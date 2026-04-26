class ReceivablesPagination {
  const ReceivablesPagination({
    required this.currentPage,
    required this.perPage,
    required this.totalPages,
    required this.totalCount,
  });

  final int currentPage;
  final int perPage;
  final int totalPages;
  final int totalCount;

  bool get hasPreviousPage => currentPage > 1;
  bool get hasNextPage => currentPage < totalPages;

  factory ReceivablesPagination.fromJson(Map<String, dynamic> json) {
    return ReceivablesPagination(
      currentPage: _readInt(json['current_page']) ?? 1,
      perPage: _readInt(json['per_page']) ?? 10,
      totalPages: _readInt(json['total_pages']) ?? 1,
      totalCount: _readInt(json['total_count']) ?? 0,
    );
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}