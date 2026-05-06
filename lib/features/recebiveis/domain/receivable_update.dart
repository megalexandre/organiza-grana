import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';

class ReceivableUpdate {
  const ReceivableUpdate({required this.status, this.notes});

  final ReceivableStatus status;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'status': status.toJson(),
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}
