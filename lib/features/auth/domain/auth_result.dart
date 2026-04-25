import 'package:organizagrana/features/auth/domain/auth_failure.dart';

class AuthResult {
  final bool isSuccess;
  final AuthFailure? failure;

  const AuthResult._({required this.isSuccess, this.failure});

  const AuthResult.success() : this._(isSuccess: true);

  const AuthResult.failure(AuthFailure failure)
      : this._(isSuccess: false, failure: failure);
}
