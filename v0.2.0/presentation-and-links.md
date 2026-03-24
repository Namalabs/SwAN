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
        NavigationStackView(engine: engine) { /* … */ } destination: { /* … */ }
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
