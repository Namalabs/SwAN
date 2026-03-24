# Navigation

## Engine

```swift
let engine = NavigationEngine<AppRoute, AppMenu>(
    initialMenu: .home,
    preserveStackOnSwitch: true  // default; false = clear target tab’s stack on switch
)
```

**Useful state:** `stacks`, `activeMenu`, `activeStack`, `presentedRoute`, `presentationStyle`, `pendingRoute`, `deferredURL`, `lastError`, `onError`, `logger`, `activeStackBinding`.

---

## Stack operations (no middleware)

```swift
engine.push(.detail(id: "1"))
engine.pop()
engine.popToRoot()
engine.popTo(.home)           // sets lastError if missing
engine.switchMenu(to: .profile)
engine.replace(stack: [.home, .detail(id: "1")], for: .home)
engine.reset(menu: .profile)
engine.resetAll()
```

---

## Guarded navigation (`navigate(to:)`)

Runs middleware, then pushes or sets error / pending route:

```swift
engine.navigate(to: .detail(id: "42"))
```

| Result | Effect |
|:---|:---|
| `.allow` | Push |
| `.reject` | `lastError`, original route in `pendingRoute` |
| `.redirect` | Push redirect target, original in `pendingRoute` |

```swift
if let pending = engine.pendingRoute {
    engine.clearPendingRoute()
    engine.navigate(to: pending)
}
```

---

## Middleware

```swift
engine.addMiddleware(authGuard)
engine.removeAllMiddleware()
```

**Auth guard (built-in):**

```swift
let guard = AuthGuardMiddleware<AppRoute, AppMenu>(
    authProvider: myAuth,
    loginRoute: .login
) { route in
    switch route { case .profile, .settings: true; default: false }
}
engine.addMiddleware(guard)
```

**Custom** — conform to `NavigationMiddleware`:

```swift
struct LogMiddleware<R: Routable, M: MenuIdentifiable>: NavigationMiddleware {
    func evaluate(_ route: R, context: NavigationContext<R, M>) -> MiddlewareResult<R> {
        print("→ \(route)")
        return .allow
    }
}
```

Return `.allow`, `.reject(NavigationError)`, or `.redirect(AppRoute)`. Context: `NavigationContext(currentStack:activeMenu:presentedRoute:)`.

---

## TabView

```swift
TabView(selection: Binding(
    get: { engine.activeMenu },
    set: { engine.switchMenu(to: $0) }
)) {
    NavigationStackView(engine: engine) { HomeView() } destination: { dest(for: $0) }
        .tag(AppMenu.home)
    NavigationStackView(engine: engine) { ProfileView() } destination: { dest(for: $0) }
        .tag(AppMenu.profile)
}
.modalPresenter(engine: engine) { dest(for: $0) }
```

Same `engine`, different `.tag` / root — stacks stay separate.

---

## Helpers

**`NavigationStackView`** — `NavigationStack(path: activeStackBinding)` + destinations.

**`.routeDestination(for:)`** — same as attaching `navigationDestination(for:)` to a view:

```swift
SomeView()
    .routeDestination(for: AppRoute.self) { route in
        switch route {
        case .detail(let id): Text("Detail \(id)")
        default: EmptyView()
        }
    }
```

**`FlowSwitchView`** — top-level UI by app phase (you own `currentFlow`, not the engine):

```swift
enum AppFlow: FlowIdentifiable { case onboarding, main }

@Observable
class AppModel {
    var flow: AppFlow = .onboarding
}

FlowSwitchView(flow: model.flow) { flow in
    switch flow {
    case .onboarding: OnboardingView()
    case .main: MainTabView()
    }
}
```

System back / swipe updates the bound stack automatically.
