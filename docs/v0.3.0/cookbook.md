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

## Avoid duplicate screens

Set the default mode so any `navigate(to:)` pops back instead of pushing a duplicate:

```swift
engine.defaultNavigationMode = .popToExisting

// Stack is [.home, .profile, .settings]
engine.navigate(to: .profile)  // pops to .profile instead of pushing again
```

Or per-call:

```swift
engine.navigate(to: .profile, mode: .popToExisting)
```

---

## Half-height settings sheet

```swift
engine.present(.settings, configuration: ModalConfiguration(
    detents: [.medium, .large],
    selectedDetent: .medium,
    showDragIndicator: true
))
```

---

## Non-dismissible modal

```swift
engine.present(.onboarding, configuration: ModalConfiguration(
    isDismissDisabled: true
))
```

---

## Clean modal on navigation

Enable auto-dismiss so any push/switch automatically clears the modal:

```swift
engine.dismissModalOnNavigation = true

engine.present(.login, as: .sheet)
engine.push(.home)  // sheet dismissed automatically
```

---

## Jump to another tab's screen

```swift
// From any tab, go to profile's settings
engine.navigate(to: .settings, in: .profile)

// Set up a full path on a different tab
engine.navigate(path: [.productList, .product("123")], in: .home)
```

---

## Deep link without losing context

Use a detour so the user returns to where they were:

```swift
func handlePushNotification(_ route: AppRoute) {
    engine.presentDetour(route)
}

// In the detour view
Button("Done") {
    engine.dismissDetour()
}
```

---

## Multi-step deep link as detour

```swift
engine.presentDetour(path: [.inbox, .thread("42"), .messageDetail(id: "99")])

// User navigates through the thread, then taps "Done"
engine.dismissDetour()  // back to exact prior screen
```

---

## Build a breadcrumb path

```swift
engine.navigate(path: [.catalog, .category("shoes"), .product("nike-1")])
// Stack: current + [.catalog, .category("shoes"), .product("nike-1")]
// User can navigate back through each step
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

## Centralized error logging

```swift
NavigationErrorHandler.shared.setHandler { error in
    Crashlytics.recordError(error)
}

// Every engine that opts in reports to this handler
engine1.reportsToGlobalHandler = true
engine2.reportsToGlobalHandler = true
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

**Full stack replace + loading UI** — [Advanced — Async navigation](/v0.3.0/advanced.md#async-navigation).
