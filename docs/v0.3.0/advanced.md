# Advanced topics

## Path navigation (0.3.0)

Navigate through a multi-step path in one middleware-aware call:

```swift
// Append to the active stack (middleware evaluates last route)
engine.navigate(path: [.catalog, .category("shoes"), .product("nike-1")])

// Replace the active stack entirely
engine.navigate(replacing: [.home, .settings, .advancedSettings])
```

Middleware evaluates only the **last** route in the path. If rejected, the entire batch is aborted and the last route is stored as `pendingRoute`.

For non-guarded stack replacement, the existing `replace(stack:for:)` still works.

---

## Cross-tab navigation (0.3.0)

Navigate to a route on a different tab in one call:

```swift
// Switch to profile tab and push settings
engine.navigate(to: .settings, in: .profile)

// Switch to home tab and set up a full path
engine.navigate(path: [.productList, .product("123")], in: .home)

// With explicit navigation mode
engine.navigate(to: .settings, in: .profile, mode: .popToExisting)
```

Middleware evaluates the target route in the context of the **target** menu's stack (not the current one). Respects `dismissModalOnNavigation` and `defaultNavigationMode`.

For manual cross-tab, the existing `switchMenu(to:)` + `push(_:)` pattern still works.

---

## Async navigation

```swift
await engine.navigate(loading: .loadingPlaceholder) {
    let item = try await api.load()
    return [.list, .detail(id: item.id)]
}
```

Pushes placeholder -> awaits -> **replaces whole stack** for that menu on success. Overlapping calls: last wins. Away during load -> `lastError` `.asyncNavigationCancelled`; throw -> `.asyncNavigationFailed`.

---

## Persistence

```swift
let data = try engine.saveState()   // throws — encoding
UserDefaults.standard.set(data, forKey: "nav")

if let data = UserDefaults.standard.data(forKey: "nav") {
    engine.restore(from: data)   // never throws; bad data -> `.stateRestorationFailed`
}
```

**Persisted:** `stacks`, `activeMenu`, `presentedRoute`, `presentationStyle`, `modalConfiguration`, schema `version`.

**Not persisted:** `pendingRoute`, `deferredURL`, `lastError`, detour snapshots.

`NavigationState` uses `decodeIfPresent` for `modalConfiguration` so pre-0.3.0 data is restored without error.

---

## Coordinators (optional)

```swift
@Observable
final class AppCoordinator: Coordinator {
    let engine = NavigationEngine<AppRoute, AppMenu>(initialMenu: .home)

    @ViewBuilder
    func destination(for route: AppRoute) -> some View {
        switch route {
        case .home: HomeView()
        case .detail(let id): DetailView(id: id)
        case .settings: SettingsView()
        }
    }

    func start() {
        engine.push(.home)
    }
}
```

- **`AppCoordinating`** — adds `FlowIdentifiable`, `currentFlow`, `flowView(for:)`, `resolveInitialFlow()`.
- **`FlowCoordinating`** — sub-flow with `finish()`; share parent `engine` (no nested `NavigationStack`).

---

## Errors

Navigation mutations **do not throw** — use `lastError` and optional **`onError`**:

```swift
engine.onError = { error in
    switch error {
    case .unauthorized: /* show login */
    case .invalidDeepLink: /* toast */
    default: break
    }
}

engine.clearError()
```

All error cases:

| Case | Description |
|:---|:---|
| `.routeNotFound` | Route could not be resolved |
| `.unauthorized` | Auth guard rejected the route |
| `.invalidDeepLink` | Deep link URL could not be parsed |
| `.stateRestorationFailed` | Failed to decode persisted state |
| `.invalidMenu` | Referenced a menu that does not exist |
| `.asyncNavigationCancelled` | Async navigation was superseded |
| `.asyncNavigationFailed` | Async resolve closure threw an error |
| `.deepLinkFailed(String)` | Deep link failed with a diagnostic reason |
| `.modalPresentationRejected` | Middleware rejected a guarded modal |
| `.pathNavigationRejected` | Middleware rejected a path navigation |
| `.detourAlreadyActive` | Attempted to present a detour while one is active |
| `.noActiveDetour` | Attempted to dismiss a detour when none is active |
| `.custom(String)` | App-defined error |

**`saveState()` throws** (encoding). **`restore(from:)`** does not.

`MiddlewareChain` can evaluate middleware outside the engine (e.g. tests).

---

## Global error handler (0.3.0)

For centralized error handling across multiple engines:

```swift
NavigationErrorHandler.shared.setHandler { error in
    analytics.track("nav_error", error: error)
}

engine.reportsToGlobalHandler = true
```

The per-engine `onError` callback and `lastError` continue to work independently. The global handler receives errors **in addition** to the per-engine callback.

```swift
NavigationErrorHandler.shared.removeHandler()
```

---

## Logger

```swift
engine.logger = NavigationLogger()  // DEBUG on by default; release off unless isEnabled
```

The logger traces: push, pop, popToRoot, menu switch, present, dismiss, auto-dismiss, path, cross-tab, detour present/dismiss, deep link, restore, async start/resolve/fail, and errors.
