# Organiza Grana — Guia para Agentes de IA

## Visão geral

Aplicativo Flutter multiplataforma (Android, iOS, Web, Linux, Windows, macOS) para controle financeiro pessoal. Linguagem padrão do projeto: **português brasileiro**.

## Stack

| Camada | Tecnologia |
|---|---|
| UI | Flutter + Material 3 |
| Navegação | `go_router` (ShellRoute + NoTransitionPage) |
| HTTP | `http` (cliente manual, sem Dio) |
| Storage local | `shared_preferences` |
| Localização | `flutter_localizations` + `intl` (apenas `pt`) |
| Injeção de dependência | Manual, sem framework |

## Estrutura de pastas

```
lib/
  app/                          # Bootstrap: app.dart, app_router.dart, app_theme.dart, auth_session_controller.dart
  features/
    auth/
      data/                     # AuthService, AuthStorage, AuthApiClient, AuthAccessTokenProvider
      domain/                   # AuthFailure, AuthResult, AuthTokens, LoginAttempt, UserProfile
      presentation/
        pages/                  # LoginPage
        widgets/                # LoginBrandContent
    recebiveis/
      data/                     # ReceivablesService, HttpReceivablesApiClient
      domain/                   # Receivable, ReceivableStatus, ReceivableFailure, ReceivablesPageResult, ReceivablesPagination
      presentation/
        pages/                  # RecebiveisPage
        widgets/                # ReceivableCard, ReceivablesFilterBar, AddReceivableDialog
    dashboard/
      presentation/pages/       # DashboardPage
  shared/
    layout/                     # AdaptiveMenuScaffold, LayoutPage, SurfacePanel, top_bar/, side_menu/, footer/
    network/                    # AccessTokenProvider, HttpApiClient, ApiEndpoints
    validators/                 # AppValidators
  l10n/                         # AppLocalizations (gerado), AppLocalizationsPt, app_pt.arb
  main.dart
```

## Padrões arquiteturais

### Injeção de dependência manual

Dependências são criadas em `app.dart` e passadas para baixo via construtores. Não existe ServiceLocator nem Provider.

`AuthStorage` é criado uma única vez em `app.dart` e compartilhado com `AuthService` (via `AuthSessionController`) e com `HttpReceivablesApiClient` (via `AuthStorageAccessTokenProvider`). Nunca instanciar `AuthStorage` em dois lugares.

### Camadas por feature

- **domain**: modelos puros em Dart, sem dependência de Flutter. Enums com getters de negócio (ex.: `ReceivableStatus.canReceive`, `ReceivableStatus.badgeColor`).
- **data**: clientes HTTP e serviços. Lançam exceções tipadas (`ReceivableFailure`, `AuthFailure`).
- **presentation**: widgets e páginas. Recebem serviços via construtor, nunca importam `data/` de outras features.

### Responsividade

Breakpoints padrão:
```dart
const double _kTabletBreakpoint  = 600;
const double _kDesktopBreakpoint = 1024;
```

Use `LayoutBuilder` na raiz do `Scaffold.body` para selecionar layouts `_MobileLayout`, `_TabletLayout`, `_DesktopLayout`.

Centralização vertical em telas com scroll:
```dart
LayoutBuilder(builder: (_, bc) => SingleChildScrollView(
  child: ConstrainedBox(
    constraints: BoxConstraints(minHeight: bc.maxHeight),
    child: Center(child: content),
  ),
))
```

### Cores — sem hardcode

Todas as cores vêm de `Theme.of(context).colorScheme`. Tokens usados: `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`, `surface`, `onSurface`, `onSurfaceVariant`, `surfaceContainerLow`.

Para opacidade, usar `color.withValues(alpha: 0.8)` — nunca `Color(0xFF...)`.

### Localização (l10n)

Strings de validação e UI ficam em `lib/l10n/app_pt.arb`. Após editar o `.arb`:
- Atualizar `app_localizations.dart` (getter abstrato)
- Atualizar `app_localizations_pt.dart` (implementação)

`flutter gen-l10n` não é executado automaticamente; as atualizações são feitas manualmente nos três arquivos.

### Validadores

Usar `AppValidators` (em `shared/validators/`) passando `AppLocalizations l10n`. Nunca retornar strings hardcoded em validators.

## Comandos úteis

```bash
# Rodar no emulador Android
flutter emulators --launch Pixel_6
flutter run -d Pixel_6

# Rodar no Chrome (desabilitando CORS para dev)
flutter run -d chrome --web-browser-flag="--disable-web-security"

# Build APK release
flutter build apk --release --dart-define=API_BASE_URL=https://app.project-deploy.shop/api/api

# Build web + deploy Docker
flutter build web
docker build -t alexandreqrz/app-panel-web:latest . && docker push alexandreqrz/app-panel-web:latest

# Build Linux bundle
flutter build linux --release
```

## WireMock (testes de integração)

```bash
# Subir via Docker (ver docker/)
# Painel de mapeamentos
http://localhost:8080/__admin/mappings
```

## Design

- **Sem cantos arredondados**: não usar `BorderRadius` em nenhum widget de UI (cards, botões, dialogs, badges, inputs, etc.). Usar `BorderRadius.zero` ou `RoundedRectangleBorder()` quando necessário sobrescrever o tema.

## Convenções de código

- Sem comentários explicativos — nomes de identificadores devem ser autoexplicativos.
- Sem `const` em widgets que recebem valores não-constantes (ex.: `NoTransitionPage` com filho não-const).
- Parâmetros `_` simples em callbacks que ignoram argumentos (não `__`).
- Formatadores de moeda/data como `static final` dentro do widget que os usa.
- Lógica de negócio (ex.: `canReceive`) fica no domínio (enum/model), não na apresentação.
