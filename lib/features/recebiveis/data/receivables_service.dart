import 'dart:typed_data';

import 'package:organizagrana/features/recebiveis/data/receivables_api_client.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_draft.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_sort.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_update.dart';
import 'package:organizagrana/features/recebiveis/domain/receivables_page_result.dart';

class ReceivablesService {
  ReceivablesService(this._apiClient);

  final ReceivablesApiClient _apiClient;

  Future<ReceivablesPageResult> listPage({
    required int page,
    required int perPage,
    bool withDiscarded = false,
    ReceivableSortField sortBy = ReceivableSortField.dueDate,
    ReceivableSortDirection sortDirection = ReceivableSortDirection.desc,
    String? borderoId,
  }) async {
    try {
      return await _apiClient.listPage(
        page: page,
        perPage: perPage,
        withDiscarded: withDiscarded,
        sortBy: sortBy,
        sortDirection: sortDirection,
        borderoId: borderoId,
      );
    } on ReceivablesApiClientException catch (e) {
      throw ReceivableFailure(
        type: e.type,
        message: _messageFor(e.type),
      );
    }
  }

  Future<Receivable> getById(String id) async {
    try {
      return await _apiClient.getById(id);
    } on ReceivablesApiClientException catch (e) {
      throw ReceivableFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  Future<Receivable> create(ReceivableDraft draft) async {
    try {
      return await _apiClient.create(draft);
    } on ReceivablesApiClientException catch (e) {
      throw ReceivableFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  Future<void> update(String id, ReceivableUpdate update) async {
    try {
      await _apiClient.update(id, update);
    } on ReceivablesApiClientException catch (e) {
      throw ReceivableFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  Future<void> updateDraft(String id, ReceivableDraft draft) async {
    try {
      await _apiClient.updateDraft(id, draft);
    } on ReceivablesApiClientException catch (e) {
      throw ReceivableFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  Future<void> changeStatus(String id, ReceivableStatus status) async {
    try {
      await _apiClient.changeStatus(id, status);
    } on ReceivablesApiClientException catch (e) {
      throw ReceivableFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  Future<void> delete(String id) async {
    try {
      await _apiClient.delete(id);
    } on ReceivablesApiClientException catch (e) {
      throw ReceivableFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  Future<Uint8List> exportCsv({
    bool withDiscarded = false,
    ReceivableSortField sortBy = ReceivableSortField.dueDate,
    ReceivableSortDirection sortDirection = ReceivableSortDirection.asc,
  }) async {
    try {
      return await _apiClient.exportCsv(
        withDiscarded: withDiscarded,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );
    } on ReceivablesApiClientException catch (e) {
      throw ReceivableFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  String _messageFor(ReceivableFailureType type) => switch (type) {
        ReceivableFailureType.invalidInput => 'Dados inválidos para o recebível.',
        ReceivableFailureType.network => 'Falha de rede ao conectar no servidor.',
        ReceivableFailureType.unauthorized => 'Sessão expirada. Faça login novamente.',
        ReceivableFailureType.server => 'Falha no servidor.',
        ReceivableFailureType.invalidResponse => 'Resposta inválida da API.',
      };
}
