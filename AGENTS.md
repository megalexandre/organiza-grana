# Organiza Grana — Guia para Agentes de IA


## Padrões arquiteturais

### Injeção de dependência manual

Dependências são criadas em `app.dart` e passadas para baixo via construtores. Não existe ServiceLocator nem Provider.

`AuthStorage` é criado uma única vez em `app.dart` e compartilhado com `AuthService` e com os API clients (via `AuthStorageAccessTokenProvider`). Nunca instanciar `AuthStorage` em dois lugares.

`AuthService` é extraído como variável nomeada em `app.dart` para ser reutilizado como `tokenRefresher` no `HttpApiClient`. Não criar uma segunda instância.

O `HttpApiClient` compartilhado (com `tokenRefresher` injetado) é passado para `HttpReceivablesApiClient` e `HttpBorderoApiClient`. O `HttpAuthApiClient` cria o seu próprio `HttpApiClient` interno sem refresher — isso é correto, pois o client de auth É o mecanismo de refresh.

### Retry automático em 401

`HttpApiClient` aceita um `TokenRefresher` opcional (`Future<String?> Function()`). Quando recebe 401, chama o refresher uma vez e refaz a requisição com o novo token. Se o refresh falhar ou não houver refresher, propaga `ApiException(ApiFailureType.unauthorized)`.

`AuthService.refreshAccessToken()` é o método público exposto para ser usado como `tokenRefresher`.

### Tratamento de erros

Padrão consistente em todas as features: **lançar exceção tipada**. Nunca retornar um objeto `Result` nos serviços.

- `ReceivableFailure` — lançado por todos os métodos de `ReceivablesService`
- `BorderoFailure` — lançado por `BorderoService`
- `AuthResult` — exceção: `AuthService.login()` retorna `AuthResult` por ter fluxo diferente (erro de validação antes da chamada de rede)

### Navegação

Rotas centralizadas em `AppRouter` como constantes estáticas:
```dart
AppRouter.dashboardPath
AppRouter.recebiveisPath
AppRouter.borderoPath
```

Para navegar pelo ID do item de menu, usar `AppRouter.pathForItem(itemId)`. Nunca hardcodar paths de rota fora de `app_router.dart`.

### Menu de navegação

Itens de menu configurados em `assets/config/nav_menu.json`. Ao adicionar uma nova rota:
1. Adicionar entrada no JSON (`id`, `label`, `icon`)
2. Adicionar constante de path em `AppRouter`
3. Adicionar `GoRoute` dentro do `ShellRoute`
4. Adicionar case em `AppRouter.pathForItem()`
5. Adicionar ícone em `LayoutMenuItem._iconMap` se necessário

### Camadas por feature

- **domain**: modelos puros em Dart, sem dependência de Flutter. Enums com getters de negócio (ex.: `ReceivableStatus.canReceive`, `ReceivableStatus.badgeColor`).
- **data**: clientes HTTP e serviços. Lançam exceções tipadas. Nunca retornam `Result`.
- **presentation**: widgets e páginas. Recebem serviços via construtor, nunca importam `data/` de outras features.

### Utilitários compartilhados

`lib/shared/utils/app_formats.dart` contém:
- `currencyFormat` — moeda em Real brasileiro
- `dateFormat` — `dd/MM/yyyy`
- `dateTimeFormat` — `dd/MM/yyyy HH:mm`
- `formatDateIso(DateTime)` — formata para `YYYY-MM-DD` (usado em `toJson()` de modelos de input)

Nunca duplicar `_formatDate` em modelos de domínio — usar `formatDateIso` do utils.

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

Todas as cores vêm de `Theme.of(context).colorScheme`. **Nunca usar cores absolutas** como `Colors.white`, `Colors.black`, `Colors.grey`, `Colors.red`, `Colors.blue`, etc. — nem mesmo para fundos, divisores ou sombras.

Mapeamento de substituições comuns:

| Proibido | Usar |
|---|---|
| `Colors.white` | `colorScheme.surface` |
| `Colors.black` | `colorScheme.onSurface` |
| `Colors.grey` | `colorScheme.onSurface.withValues(alpha: 0.45)` |
| `Colors.transparent` | `Colors.transparent` ✅ (único permitido) |

Para opacidade, usar `color.withValues(alpha: 0.8)` — nunca `Color(0xFF...)` ou `color.withOpacity()`.

Tokens usados no projeto: `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`, `surface`, `onSurface`, `onSurfaceVariant`, `surfaceContainerLow`, `shadow`.

### Localização (l10n)

Strings de validação e UI ficam em `lib/l10n/app_pt.arb`. Após editar o `.arb`:
- Atualizar `app_localizations.dart` (getter abstrato)
- Atualizar `app_localizations_pt.dart` (implementação)

`flutter gen-l10n` não é executado automaticamente; as atualizações são feitas manualmente nos três arquivos.

### Validadores

Usar `AppValidators` (em `shared/validators/`) passando `AppLocalizations l10n`. Nunca retornar strings hardcoded em validators.

## Linting

`analysis_options.yaml` herda `flutter_lints` e adiciona:
```yaml
linter:
  rules:
    - avoid_print
    - prefer_const_constructors
    - prefer_final_fields
    - avoid_redundant_argument_values
    - always_use_package_imports
    - prefer_single_quotes
```

Rodar `flutter analyze lib/` antes de qualquer commit. Zero issues esperado.

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
- `formatDateIso` de `app_formats.dart` para serialização de datas em JSON — nunca métodos `_formatDate` locais.
- Lógica de negócio (ex.: `canReceive`) fica no domínio (enum/model), não na apresentação.
