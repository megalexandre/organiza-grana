import 'package:organizagrana/features/auth/data/auth_storage.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_result.dart';
import 'package:organizagrana/shared/network/api_enpoints.dart';
import 'package:organizagrana/shared/network/http_api_client.dart';

class ReceivablesService {
  ReceivablesService(this._storage, {HttpApiClient? httpClient})
      : _httpClient = httpClient ?? HttpApiClient();

  final AuthStorage _storage;
  final HttpApiClient _httpClient;

  Future<List<Receivable>> list() async {
    final token = await _storage.readAccessToken();
    if (token == null || token.isEmpty) {
      throw const ReceivableFailure(
        type: ReceivableFailureType.unauthorized,
        message: 'Sessão expirada. Faça login novamente.',
      );
    }

    final uri = Uri.parse(ApiEndpoints.receivables.list);

    try {
      final response = await _httpClient.getJson(uri, bearerToken: token);
      final items = _extractListFromMap(response);
      return items.map(Receivable.fromJson).toList();
    } on ApiException catch (e) {
      if (e.type == ApiFailureType.invalidResponse) {
        try {
          final response = await _httpClient.getJsonList(uri, bearerToken: token);
          return response.map(Receivable.fromJson).toList();
        } on ApiException catch (fallbackError) {
          throw ReceivableFailure(
            type: _mapFailure(fallbackError.type),
            message: _messageFor(fallbackError.type),
          );
        }
      }

      throw ReceivableFailure(
        type: _mapFailure(e.type),
        message: _messageFor(e.type),
      );
    }
  }

  Future<ReceivableResult> create(double value, DateTime receiptDate) async {
    final token = await _storage.readAccessToken();
    if (token == null || token.isEmpty) {
      return const ReceivableResult.failure(
        ReceivableFailure(
          type: ReceivableFailureType.unauthorized,
          message: 'Sessão expirada. Faça login novamente.',
        ),
      );
    }

    try {
      await _httpClient.postJson(
        Uri.parse(ApiEndpoints.receivables.create),
        {
          'value': value,
          'receipt_date': _formatDate(receiptDate),
          'status': 'awating',
        },
        bearerToken: token,
      );
      return const ReceivableResult.success();
    } on ApiException catch (e) {
      return ReceivableResult.failure(ReceivableFailure(
        type: _mapFailure(e.type),
        message: _messageFor(e.type),
      ));
    }
  }

  List<Map<String, dynamic>> _extractListFromMap(Map<String, dynamic> response) {
    final candidates = [
      response['data'],
      response['items'],
      response['receivables'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate.whereType<Map<String, dynamic>>().toList();
      }
    }

    return const [];
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}'
      '-${date.month.toString().padLeft(2, '0')}'
      '-${date.day.toString().padLeft(2, '0')}';

  ReceivableFailureType _mapFailure(ApiFailureType type) => switch (type) {
        ApiFailureType.network => ReceivableFailureType.network,
        ApiFailureType.unauthorized => ReceivableFailureType.unauthorized,
        ApiFailureType.server => ReceivableFailureType.server,
        ApiFailureType.invalidResponse => ReceivableFailureType.invalidResponse,
      };

  String _messageFor(ApiFailureType type) => switch (type) {
        ApiFailureType.network => 'Falha de rede ao conectar no servidor.',
        ApiFailureType.unauthorized => 'Sessão expirada. Faça login novamente.',
        ApiFailureType.server => 'Falha no servidor.',
        ApiFailureType.invalidResponse => 'Resposta inválida da API.',
      };
}
