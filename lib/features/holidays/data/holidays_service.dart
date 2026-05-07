import 'package:organizagrana/features/holidays/data/holidays_api_client.dart';
import 'package:organizagrana/features/holidays/domain/calendar_month.dart';
import 'package:organizagrana/features/holidays/domain/holidays_failure.dart';
import 'package:organizagrana/features/holidays/domain/holiday_override.dart';

class HolidaysService {
  HolidaysService(this._apiClient);

  final HolidaysApiClient _apiClient;

  Future<CalendarMonth> getCalendar(int year, int month) async {
    try {
      return await _apiClient.getCalendar(year, month);
    } on HolidaysApiClientException catch (e) {
      throw HolidaysFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  Future<HolidayOverride> createOverride(DateTime date, bool holiday, String? name) async {
    try {
      return await _apiClient.createOverride(date, holiday, name);
    } on HolidaysApiClientException catch (e) {
      throw HolidaysFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  Future<HolidayOverride> updateOverride(String id, bool? holiday, String? name) async {
    try {
      return await _apiClient.updateOverride(id, holiday, name);
    } on HolidaysApiClientException catch (e) {
      throw HolidaysFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  Future<void> deleteOverride(String id) async {
    try {
      await _apiClient.deleteOverride(id);
    } on HolidaysApiClientException catch (e) {
      throw HolidaysFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  String _messageFor(HolidaysFailureType type) => switch (type) {
        HolidaysFailureType.network => 'Falha de rede ao conectar no servidor.',
        HolidaysFailureType.unauthorized => 'Sessão expirada. Faça login novamente.',
        HolidaysFailureType.server => 'Falha no servidor.',
        HolidaysFailureType.invalidResponse => 'Resposta inválida da API.',
      };
}
