import 'package:http/http.dart' as http;
import 'package:organizagrana/app/app_router.dart';
import 'package:organizagrana/app/auth_session_controller.dart';
import 'package:organizagrana/features/auth/data/auth_access_token_provider.dart';
import 'package:organizagrana/features/auth/data/auth_api_client.dart';
import 'package:organizagrana/features/auth/data/auth_service.dart';
import 'package:organizagrana/features/auth/data/auth_storage.dart';
import 'package:organizagrana/features/bordero/data/bordero_api_client.dart';
import 'package:organizagrana/features/bordero/data/bordero_service.dart';
import 'package:organizagrana/features/dashboard/data/dashboard_api_client.dart';
import 'package:organizagrana/features/dashboard/data/dashboard_service.dart';
import 'package:organizagrana/features/holidays/data/holidays_api_client.dart';
import 'package:organizagrana/features/holidays/data/holidays_service.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_api_client.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_service.dart';
import 'package:organizagrana/shared/network/http_api_client.dart';

/// Composition root da aplicação: monta a sessão e o roteador com todos os
/// serviços conectados. Usado tanto pelo app real ([MainApp]) quanto pelos
/// testes de integração — que injetam um [http.Client] mockado via [httpClient].
class AppDependencies {
  AppDependencies._({required this.session, required this.router});

  final AuthSessionController session;
  final AppRouter router;

  factory AppDependencies.create({http.Client? httpClient}) {
    final authStorage = AuthStorage();
    final tokenProvider = AuthStorageAccessTokenProvider(authStorage);

    // O cliente de auth não tem refresher — ele é quem autentica/renova.
    final authApiClient = HttpAuthApiClient(
      tokenProvider,
      httpClient: HttpApiClient(httpClient: httpClient),
    );
    final authService = AuthService(authStorage, apiClient: authApiClient);
    final session = AuthSessionController(authService: authService);

    // As features compartilham um cliente com refresh automático de token.
    final featureHttpApiClient = HttpApiClient(
      httpClient: httpClient,
      bearerTokenProvider: tokenProvider.readAccessToken,
      tokenRefresher: authService.refreshAccessToken,
    );

    final router = AppRouter(
      session,
      receivablesService: ReceivablesService(
        HttpReceivablesApiClient(tokenProvider, httpClient: featureHttpApiClient),
      ),
      borderoService: BorderoService(
        HttpBorderoApiClient(tokenProvider, httpClient: featureHttpApiClient),
      ),
      holidaysService: HolidaysService(
        HttpHolidaysApiClient(tokenProvider, httpClient: featureHttpApiClient),
      ),
      dashboardService: DashboardService(
        HttpDashboardApiClient(tokenProvider, httpClient: featureHttpApiClient),
      ),
    );

    return AppDependencies._(session: session, router: router);
  }
}
