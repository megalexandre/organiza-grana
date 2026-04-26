import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';

class ReceivableResult {
  const ReceivableResult._({required this.isSuccess, this.failure});

  const ReceivableResult.success() : this._(isSuccess: true);

  const ReceivableResult.failure(ReceivableFailure failure)
      : this._(isSuccess: false, failure: failure);

  final bool isSuccess;
  final ReceivableFailure? failure;
}
