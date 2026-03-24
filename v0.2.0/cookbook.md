# Cookbook

Short answers with code where it helps.

## Single tab (no `TabView`)

One menu case + one stack:

```swift
enum AppMenu: MenuIdentifiable {
    case main
}

NavigationStackView(engine: engine) {
    HomeView()
} destination: { route in
    DestinationView(route: route)
}
```

---

## Login gate

1. Register middleware once.  
2. Use **`navigate(to:)`** for protected routes (not `push`).

```swift
struct Auth: AuthStateProviding {
    var isAuthenticated: Bool
}

let auth = Auth(isAuthenticated: false)
let authGuard = AuthGuardMiddleware<AppRoute, AppMenu>(
    authProvider: auth,
    loginRoute: .login
) { route in
    if case .profile = route { return true }
    if case .settings = route { return true }
    return false
}
engine.addMiddleware(authGuard)

// UI
Button("Profile") { engine.navigate(to: .profile) }
```

After login:

```swift
if let pending = engine.pendingRoute {
    engine.clearPendingRoute()
    engine.navigate(to: pending)
}
```

---

## Logout

```swift
engine.resetAll()
engine.push(.login)
```

---

## Open URL after splash

```swift
.onAppear {
    engine.configurePipeline(pipeline)
    _ = engine.processDeferredURL()
}
```

---

## Load then show

**Simple** — fetch, then push:

```swift
Task {
    let item = try await api.load(id: "42")
    engine.push(.detail(id: item.id))
}
```

**Full stack replace + loading UI** — [Advanced — Async navigation](/v0.2.0/advanced.md#async-navigation).
