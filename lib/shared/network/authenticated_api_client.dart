import 'package:organizagrana/shared/network/http_api_client.dart';

mixin AuthenticatedApiClient {
  HttpApiClient get httpClient;

  Future<T> guarded<T>(
    Future<T> Function() fn,
    Exception Function(ApiFailureType) toException,
  ) async {
    try {
      return await fn();
    } on ApiException catch (e) {
      throw toException(e.type);
    }
  }
}
