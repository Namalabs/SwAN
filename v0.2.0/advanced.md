# Advanced topics

## Async navigation

```swift
await engine.navigate(loading: .loadingPlaceholder) {
    let item = try await api.load()
    return [.list, .detail(id: item.id)]
}
```

Pushes placeholder → awaits → **replaces whole stack** for that menu on success. Overlapping calls: last wins. Away during load → `lastError` `.asyncNavigationCancelled`; throw → `.asyncNavigationFailed`.

---

## Persistence

```swift
let data = try engine.saveState()   // throws — encoding
UserDefaults.standard.set(data, forKey: "nav")

if let data = UserDefaults.standard.data(forKey: "nav") {
    engine.restore(from: data)   // never throws; bad data → `.stateRestorationFailed`
}
```

Persists stacks, `activeMenu`, modal fields, schema `version`. Does **not** persist `pendingRoute`, `deferredURL`, `lastError`.

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

**`saveState()` throws** (encoding). **`restore(from:)`** does not.

`MiddlewareChain` can evaluate middleware outside the engine (e.g. tests).

---

## Logger

```swift
engine.logger = NavigationLogger()  // DEBUG on by default; release off unless isEnabled
```
