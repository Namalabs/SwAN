# API reference

Compact index — details in guides above. Source: `Sources/SwAN/`.

## Protocols

| Protocol | Purpose |
|:---|:---|
| `Routable` | Route enum (`Hashable`, `Sendable`, `Codable`) |
| `MenuIdentifiable` | Tab enum (one stack per case; `CaseIterable`, `Codable`) |
| `FlowIdentifiable` | Optional app phase enum |
| `AuthStateProviding` | `isAuthenticated` for guards |
| `NavigationMiddleware` | `evaluate` -> `MiddlewareResult` |
| `DeepLinkParser` | `parse(URL) -> DeepLinkResult?` |
| `RouteSerializer` | `serialize(menu:stack:) -> URL?` (yours) |
| `Coordinator` | `engine` + `destination(for:)` + `start()` |
| `AppCoordinating` | `currentFlow` + `resolveInitialFlow()` + `flowView(for:)` |
| `FlowCoordinating` | `finish()` |

## `NavigationEngine` — Methods

### Stack operations (no middleware)

| Method | Description |
|:---|:---|
| `push(_:)` | Push route onto active stack |
| `pop()` | Pop top route |
| `popToRoot()` | Clear active stack |
| `popTo(_:)` | Pop to a specific route |
| `switchMenu(to:)` | Switch active tab |
| `replace(stack:for:)` | Replace a menu's entire stack |
| `reset(menu:)` | Clear a specific menu's stack |
| `resetAll()` | Clear all stacks, modals, errors |

### Guarded navigation (runs middleware)

| Method | Description |
|:---|:---|
| `navigate(to:)` | Push through middleware (uses `defaultNavigationMode`) |
| `navigate(to:mode:)` | Push through middleware with explicit `NavigationMode` |
| `navigate(presenting:as:)` | Present modal through middleware |
| `navigate(path:)` | Append multi-step path through middleware |
| `navigate(replacing:)` | Replace active stack through middleware |
| `navigate(to:in:)` | Cross-tab push through middleware |
| `navigate(to:in:mode:)` | Cross-tab push with explicit mode |
| `navigate(path:in:)` | Cross-tab path through middleware |
| `navigate(loading:resolve:)` | Async navigation with loading state |

### Modal presentation

| Method | Description |
|:---|:---|
| `present(_:as:)` | Present route as modal |
| `present(_:configuration:)` | Present route with `ModalConfiguration` |
| `dismiss()` | Dismiss current modal |

### Detour navigation (0.3.0)

| Method | Description |
|:---|:---|
| `presentDetour(_:)` | Save state, present single-route detour |
| `presentDetour(path:)` | Save state, present multi-step detour |
| `dismissDetour()` | Restore prior state |

### Deep links

| Method | Description |
|:---|:---|
| `handle(url:)` | Process a deep link URL |
| `configurePipeline(_:)` | Set the deep link pipeline |
| `processDeferredURL()` | Retry a previously deferred URL |

### Middleware

| Method | Description |
|:---|:---|
| `addMiddleware(_:)` | Add a middleware to the chain |
| `removeAllMiddleware()` | Remove all middleware |

### Persistence

| Method | Description |
|:---|:---|
| `saveState()` | Serialize navigation state to `Data` (throws) |
| `restore(from:)` | Restore navigation state from `Data` (never throws) |

### Other

| Method | Description |
|:---|:---|
| `clearPendingRoute()` | Clear the pending route |
| `clearError()` | Clear the last error |

## `NavigationEngine` — Properties

| Property | Type | Default | Description |
|:---|:---|:---|:---|
| `activeMenu` | `M` | — | Currently active tab |
| `activeStack` | `[R]` | — | Current tab's route stack (computed) |
| `activeStackBinding` | `Binding<[R]>` | — | Binding for `NavigationStack` |
| `stacks` | `[M: [R]]` | — | All per-menu stacks |
| `presentedRoute` | `R?` | `nil` | Currently presented modal route |
| `presentationStyle` | `PresentationStyle?` | `nil` | Style of the current modal |
| `modalConfiguration` | `ModalConfiguration?` | `nil` | Rich modal config |
| `pendingRoute` | `R?` | `nil` | Route rejected by middleware |
| `deferredURL` | `URL?` | `nil` | Deep link URL awaiting processing |
| `lastError` | `NavigationError?` | `nil` | Most recent error |
| `isDetourActive` | `Bool` | `false` | Whether a detour is presented |
| `preserveStackOnSwitch` | `Bool` | `true` | Keep stacks when switching tabs |
| `defaultNavigationMode` | `NavigationMode` | `.push` | Default for `navigate(to:)` |
| `dismissModalOnNavigation` | `Bool` | `false` | Auto-dismiss modal on navigation |
| `reportsToGlobalHandler` | `Bool` | `false` | Forward errors to global handler |
| `logger` | `NavigationLogger?` | `nil` | Debug logger |
| `onError` | `((NavigationError) -> Void)?` | `nil` | Per-engine error callback |

## Types

| Type | Description |
|:---|:---|
| `NavigationMode` | `.push`, `.popToExisting` |
| `PresentationStyle` | `.sheet`, `.fullScreenCover` |
| `ModalConfiguration` | Detents, drag indicator, dismiss control |
| `ModalDetent` | `.medium`, `.large` |
| `MiddlewareResult` | `.allow`, `.reject(error)`, `.redirect(route)` |
| `NavigationContext` | `currentStack`, `activeMenu`, `presentedRoute` |
| `NavigationError` | Non-throwing error cases |
| `NavigationErrorHandler` | Global singleton error handler |
| `NavigationState` | Codable state snapshot |
| `DetourSnapshot` | Saved engine state during detour |
| `DeepLinkResult` | Parsed deep link output |
| `DeepLinkPipeline` | URL -> middleware -> engine |
| `NotificationRouter` | Push notification -> deep link |
| `URLParsingHelpers` | URL decomposition utilities |
| `AuthGuardMiddleware` | Built-in auth guard |
| `MiddlewareChain` | Ordered middleware evaluation |
| `NavigationLogger` | Console logger |

## SwiftUI Views & Modifiers

| Type | Description |
|:---|:---|
| `NavigationStackView` | Pre-wired `NavigationStack` bound to the engine |
| `FlowSwitchView` | Switches views based on `FlowIdentifiable` |
| `.modalPresenter(engine:content:)` | ViewModifier for sheet/cover from engine state |
| `.routeDestination(for:destination:)` | Convenience `.navigationDestination(for:)` |
