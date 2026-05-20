import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';

class ReceivableStatusCount {
  const ReceivableStatusCount({required this.status, required this.count});

  final ReceivableStatus status;
  final int count;

  factory ReceivableStatusCount.fromJson(Map<String, dynamic> json) =>
      ReceivableStatusCount(
        status: ReceivableStatus.fromJson(json['status'])!,
        count: json['count'] as int,
      );
}
