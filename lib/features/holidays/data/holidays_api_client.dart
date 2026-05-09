import 'package:organizagrana/features/holidays/domain/calendar_month.dart';
import 'package:organizagrana/features/holidays/domain/holidays_failure.dart';
import 'package:organizagrana/features/holidays/domain/holiday_override.dart';
import 'package:organizagrana/shared/network/access_token_provider.dart';
import 'package:organizagrana/shared/network/api_endpoints.dart';
import 'package:organizagrana/shared/network/http_api_client.dart';

abstract class HolidaysApiClient {
  Future<CalendarMonth> getCalendar(int year, int month);
  Future<HolidayOverride> createOverride(DateTime date, bool holiday, String? name);
  Future<HolidayOverride> updateOverride(String id, bool? holiday, String? name);
  Future<void> deleteOverride(String id);
}

class HolidaysApiClientException implements Exception {
  const HolidaysApiClientException(this.type);

  final HolidaysFailureType type;
}

class HttpHolidaysApiClient implements HolidaysApiClient {
  HttpHolidaysApiClient(this._accessTokenProvider, {HttpApiClient? httpClient})
      : _httpClient = httpClient ?? HttpApiClient();

  final AccessTokenProvider _accessTokenProvider;
  final HttpApiClient _httpClient;

  @override
  Future<CalendarMonth> getCalendar(int year, int month) async {
    final token = await _readToken();
    try {
      final response = await _httpClient.getJson(
        ApiEndpoints.holidays.calendar(year, month),
        bearerToken: token,
      );
      return CalendarMonth.fromJson(response);
    } on ApiException catch (e) {
      throw HolidaysApiClientException(_mapFailure(e.type));
    }
  }

  @override
  Future<HolidayOverride> createOverride(DateTime date, bool holiday, String? name) async {
    final token = await _readToken();
    try {
      final body = <String, dynamic>{
        'date': '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'holiday': holiday,
        if (name != null && name.isNotEmpty) 'name': name,
      };
      final response = await _httpClient.postJson(
        ApiEndpoints.holidays.createOverride,
        body,
        bearerToken: token,
      );
      return HolidayOverride.fromJson(response);
    } on ApiException catch (e) {
      throw HolidaysApiClientException(_mapFailure(e.type));
    }
  }

  @override
  Future<HolidayOverride> updateOverride(String id, bool? holiday, String? name) async {
    final token = await _readToken();
    try {
      final body = <String, dynamic>{
        'holiday': ?holiday,
        if (name != null && name.isNotEmpty) 'name': name,
      };
      final response = await _httpClient.patchJson(
        ApiEndpoints.holidays.updateOverride(id),
        body,
        bearerToken: token,
      );
      return HolidayOverride.fromJson(response);
    } on ApiException catch (e) {
      throw HolidaysApiClientException(_mapFailure(e.type));
    }
  }

  @override
  Future<void> deleteOverride(String id) async {
    final token = await _readToken();
    try {
      await _httpClient.deleteVoid(
        ApiEndpoints.holidays.deleteOverride(id),
        bearerToken: token,
      );
    } on ApiException catch (e) {
      throw HolidaysApiClientException(_mapFailure(e.type));
    }
  }

  Future<String> _readToken() async {
    final token = await _accessTokenProvider.readAccessToken();
    if (token == null || token.isEmpty) {
      throw const HolidaysApiClientException(HolidaysFailureType.unauthorized);
    }
    return token;
  }

  HolidaysFailureType _mapFailure(ApiFailureType type) => switch (type) {
        ApiFailureType.network => HolidaysFailureType.network,
        ApiFailureType.unauthorized => HolidaysFailureType.unauthorized,
        ApiFailureType.server => HolidaysFailureType.server,
        ApiFailureType.invalidResponse => HolidaysFailureType.invalidResponse,
      };
}
