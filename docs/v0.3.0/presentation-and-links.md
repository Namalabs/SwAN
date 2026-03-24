# Presentation & deep links

## Modals

```swift
engine.present(.settings, as: .sheet)
engine.present(.checkout, as: .fullScreenCover)  // not on macOS
engine.dismiss()
```

One modal at a time; a new present replaces the current.

**Guarded modal** (middleware runs, same rules as `navigate(to:)`):

```swift
engine.navigate(presenting: .shareSheet(id: "42"), as: .sheet)
```

**SwiftUI** — attach near the root (same `engine` you pass into `NavigationStackView`):

```swift
struct RootView: View {
    @State var engine = NavigationEngine<AppRoute, AppMenu>(initialMenu: .home)

    var body: some View {
        NavigationStackView(engine: engine) { /* ... */ } destination: { /* ... */ }
            .modalPresenter(engine: engine) { route in
                switch route {
                case .settings: SettingsView()
                case .shareSheet(let id): ShareView(id: id)
                default: EmptyView()
                }
            }
    }
}
```

---

## Modal configuration (0.3.0)

Use `ModalConfiguration` for fine-grained control over sheet presentation:

```swift
let config = ModalConfiguration(
    style: .sheet,
    detents: [.medium, .large],
    selectedDetent: .medium,
    isDismissDisabled: false,
    showDragIndicator: true
)
engine.present(.settings, configuration: config)
```

| Property | Type | Default | Description |
|:---|:---|:---|:---|
| `style` | `PresentationStyle` | `.sheet` | `.sheet` or `.fullScreenCover` |
| `detents` | `Set<ModalDetent>` | `[.large]` | Allowed sheet heights |
| `selectedDetent` | `ModalDetent?` | `nil` | Initially selected detent |
| `isDismissDisabled` | `Bool` | `false` | Prevents interactive dismiss |
| `showDragIndicator` | `Bool?` | `nil` | Show/hide drag indicator (`nil` = system default) |

`ModalPresenter` applies `.presentationDetents`, `.presentationDragIndicator`, and `.interactiveDismissDisabled` automatically when `engine.modalConfiguration` is set.

The basic `present(_:as:)` API continues to work unchanged — `modalConfiguration` is `nil` in that case.

---

## Detour navigation (0.3.0)

Present a temporary destination that preserves the user's entire navigation context. When dismissed, the prior state is restored exactly.

```swift
// Deep link arrives while user is mid-flow
engine.presentDetour(.messageDetail(id: "42"))

// Multi-step detour
engine.presentDetour(path: [.inbox, .messageDetail(id: "42")])

// User finishes — restore prior state
engine.dismissDetour()
```

**How it works:**

1. `presentDetour` saves a **snapshot** of all stacks, active menu, modal state, and modal configuration.
2. The detour route is presented as a `.fullScreenCover`.
3. `dismissDetour` restores the snapshot — the user returns to their exact prior screen.

**Properties:**

| Property / Method | Description |
|:---|:---|
| `isDetourActive` | `true` while a detour is presented |
| `presentDetour(_:)` | Save state, present single-route detour |
| `presentDetour(path:)` | Save state, present multi-step detour |
| `dismissDetour()` | Restore prior state |

**Errors:**

- Calling `presentDetour` while a detour is active sets `.detourAlreadyActive`.
- Calling `dismissDetour` with no active detour sets `.noActiveDetour`.

**Use cases:** push notifications, deep links, any interruption where the user should return to where they were.

---

## Deep links

### 1. Parser

```swift
struct AppDeepLinkParser: DeepLinkParser {
    func parse(_ url: URL) -> DeepLinkResult<AppRoute, AppMenu>? {
        guard url.scheme == "myapp", url.host == "item" else { return nil }
        let id = url.pathComponents.dropFirst().first ?? "0"
        return DeepLinkResult(menu: .home, stack: [.home, .detail(id: id)])
    }
}
```

### 2. Pipeline + open URL

```swift
let pipeline = DeepLinkPipeline(parser: AppDeepLinkParser())

// After engine exists (e.g. .onAppear of root)
engine.configurePipeline(pipeline)
```

```swift
ContentView()
    .onOpenURL { url in
        _ = engine.handle(url: url)
    }
```

`handle(url:)` returns `Bool` (whether it applied). If there is **no pipeline yet** or **middleware blocks** the parsed route, the URL may be stored in `deferredURL` — call **`processDeferredURL()`** when ready.

### 3. Optional: modal from URL

```swift
return DeepLinkResult(
    menu: .home,
    stack: [.home],
    presentedRoute: .shareSheet(id: id),
    presentationStyle: .sheet
)
```

### 4. Deep link as detour (0.3.0)

To preserve the user's context while showing a deep link destination, use detour navigation instead of direct application:

```swift
func handleDeepLink(_ route: AppRoute) {
    engine.presentDetour(route)
    // User reads the content, taps back → dismissDetour()
    // Returns to exact prior screen
}
```

---

## Push notifications

```swift
let router = NotificationRouter<AppRoute, AppMenu>(urlKey: "deep_link")

func didReceive(userInfo: [AnyHashable: Any]) {
    _ = router.handleNotification(payload: userInfo, engine: engine, pipeline: pipeline)
}
```

Payload must contain a string URL under `urlKey` (default `"url"`).

---

## Sharing URLs (optional)

**`RouteSerializer`** — **you** implement it to turn `menu + stack` into a `URL` (share sheets, universal links). The engine does **not** call it automatically.

**Parsing helpers:** `URLParsingHelpers.decompose(_:)`, `pathSegments(from:)`, `queryParameters(from:)`, etc.
