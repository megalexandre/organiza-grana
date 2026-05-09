import 'package:organizagrana/features/holidays/domain/calendar_month.dart';
import 'package:organizagrana/features/holidays/domain/holidays_failure.dart';
import 'package:organizagrana/features/holidays/domain/holiday_override.dart';
import 'package:organizagrana/shared/network/access_token_provider.dart';
import 'package:organizagrana/shared/network/api_endpoints.dart';
import 'package:organizagrana/shared/network/authenticated_api_client.dart';
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

class HttpHolidaysApiClient with AuthenticatedApiClient implements HolidaysApiClient {
  HttpHolidaysApiClient(AccessTokenProvider provider, {HttpApiClient? httpClient})
      : httpClient = httpClient ?? HttpApiClient(bearerTokenProvider: provider.readAccessToken);

  @override
  final HttpApiClient httpClient;

  @override
  Future<CalendarMonth> getCalendar(int year, int month) => guarded(
        () => httpClient
            .getJson(ApiEndpoints.holidays.calendar(year, month))
            .then(CalendarMonth.fromJson),
        (type) => HolidaysApiClientException(_toFailureType(type)),
      );

  @override
  Future<HolidayOverride> createOverride(DateTime date, bool holiday, String? name) {
    final body = <String, dynamic>{
      'date': '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'holiday': holiday,
      if (name != null && name.isNotEmpty) 'name': name,
    };
    return guarded(
      () => httpClient
          .postJson(ApiEndpoints.holidays.createOverride, body)
          .then(HolidayOverride.fromJson),
      (type) => HolidaysApiClientException(_toFailureType(type)),
    );
  }

  @override
  Future<HolidayOverride> updateOverride(String id, bool? holiday, String? name) {
    final body = <String, dynamic>{
      'holiday': ?holiday,
      if (name != null && name.isNotEmpty) 'name': name,
    };
    return guarded(
      () => httpClient
          .patchJson(ApiEndpoints.holidays.updateOverride(id), body)
          .then(HolidayOverride.fromJson),
      (type) => HolidaysApiClientException(_toFailureType(type)),
    );
  }

  @override
  Future<void> deleteOverride(String id) => guarded(
        () => httpClient.deleteVoid(ApiEndpoints.holidays.deleteOverride(id)),
        (type) => HolidaysApiClientException(_toFailureType(type)),
      );

  HolidaysFailureType _toFailureType(ApiFailureType type) => switch (type) {
        ApiFailureType.network => HolidaysFailureType.network,
        ApiFailureType.unauthorized => HolidaysFailureType.unauthorized,
        ApiFailureType.server => HolidaysFailureType.server,
        ApiFailureType.invalidResponse => HolidaysFailureType.invalidResponse,
      };
}
