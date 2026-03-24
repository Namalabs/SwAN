# API reference

Compact index — details in guides above. Source: `Sources/SwAN/`.

## Protocols

| Protocol | Purpose |
|:---|:---|
| `Routable` | Route enum |
| `MenuIdentifiable` | Tab enum (one stack per case) |
| `FlowIdentifiable` | Optional app phase enum |
| `AuthStateProviding` | `isAuthenticated` for guards |
| `NavigationMiddleware` | `evaluate` → `MiddlewareResult` |
| `DeepLinkParser` | `parse(URL) -> DeepLinkResult?` |
| `RouteSerializer` | `serialize(menu:stack:) -> URL?` (yours) |

## `NavigationEngine`

**Mutations:** `push`, `pop`, `popTo`, `popToRoot`, `reset`, `resetAll`, `switchMenu`, `replace`, `present`, `dismiss`, `navigate(to:)`, `navigate(presenting:as:)`, `navigate(loading:resolve:)` (async).

**Pipeline:** `configurePipeline`, `handle(url:)`, `processDeferredURL()`.

**Middleware:** `addMiddleware`, `removeAllMiddleware`.

**State:** `saveState() throws`, `restore(from:)`, `clearPendingRoute()`, `clearError()`, `activeStackBinding`.

## Types

`DeepLinkPipeline`, `DeepLinkResult`, `NotificationRouter`, `URLParsingHelpers`, `MiddlewareChain`, `AuthGuardMiddleware`, `NavigationContext`, `MiddlewareResult`, `NavigationError`, `NavigationState`, `PresentationStyle`, `NavigationLogger`, `NavigationStackView`, `FlowSwitchView`, `RouteDestinationModifier` / `.routeDestination(for:)`, `.modalPresenter`.
