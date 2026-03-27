# Navigation

## Engine

```swift
let engine = NavigationEngine<AppRoute, AppMenu>(
    initialMenu: .home,
    preserveStackOnSwitch: true  // default; false = clear target tab's stack on switch
)
```

**Useful state:** `stacks`, `activeMenu`, `activeStack`, `presentedRoute`, `presentationStyle`, `modalConfiguration`, `pendingRoute`, `deferredURL`, `lastError`, `isDetourActive`, `onError`, `logger`, `activeStackBinding`.

**Configuration properties:**

| Property | Default | Description |
|:---|:---|:---|
| `preserveStackOnSwitch` | `true` | Keep stacks when switching tabs |
| `defaultNavigationMode` | `.push` | Default mode for `navigate(to:)` |
| `dismissModalOnNavigation` | `false` | Auto-dismiss modal on navigation |
| `reportsToGlobalHandler` | `false` | Forward errors to global handler |

---

## Stack operations (no middleware)

```swift
engine.push(.detail(id: "1"))
engine.pop()
engine.popToRoot()
engine.popTo(.home)               // sets lastError if missing
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

## Stack-aware navigation (0.3.0)

By default, `navigate(to:)` always pushes. With `.popToExisting`, the engine checks the active stack first:

```swift
// Per-call
engine.navigate(to: .profile, mode: .popToExisting)

// Or set the engine-wide default
engine.defaultNavigationMode = .popToExisting
engine.navigate(to: .profile)  // uses .popToExisting
```

**How it works:**

1. Middleware is evaluated normally.
2. If the route exists in the active stack, the engine pops to it (like `popTo`).
3. If the route does not exist, the engine pushes it (like `push`).

| `NavigationMode` | Behavior |
|:---|:---|
| `.push` | Always push (default, 0.2.x behavior) |
| `.popToExisting` | Pop to route if it exists, push otherwise |

---

## Auto-dismiss modal (0.3.0)

When enabled, `push`, `switchMenu`, `replace`, and all `navigate` variants automatically dismiss the presented modal before proceeding:

```swift
engine.dismissModalOnNavigation = true

engine.present(.login, as: .sheet)
engine.push(.settings)  // modal dismissed automatically, then .settings pushed
```

Defaults to `false` to preserve 0.2.x behavior. The logger emits `AUTO-DISMISS MODAL` when triggered.

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
        print("-> \(route)")
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
