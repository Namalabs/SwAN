# SwAN — SwiftUI Advanced Navigation

![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange)
![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
![License: Binary use only](https://img.shields.io/badge/License-Binary%20use%20only-lightgrey)

`SwAN` is a type-safe, architecture-agnostic navigation library for SwiftUI. Instead of prescribing how you structure your app, it gives you a single `NavigationEngine` — one object that owns all navigation state and works wherever you put it: a plain `@State`, an `@Observable` model, a coordinator, or anything in between.

Define your routes as an enum, point the engine at your tabs, and you get programmatic control over stacks, modals, deep links, middleware, and persistence — with zero third-party dependencies.

**This repository** distributes SwAN as a **prebuilt XCFramework** via Swift Package Manager. SPM resolves this Git URL, downloads the binary from the release asset named in `Package.swift`, and links it into your app. Library **source code is not published** here.

## Why SwAN?

Most SwiftUI navigation libraries fall into one of two camps: lightweight wrappers that leave you managing `NavigationPath` yourself, or full coordinator frameworks that require you to adopt an entire architecture. SwAN sits in the middle.

| Concern | SwAN's approach |
|:---|:---|
| **Architecture** | Engine-centric — no mandatory coordinators, view factories, or class hierarchies. Use it with MVVM, MVC, TCA, or nothing at all. |
| **Middleware** | A composable chain that intercepts `navigate(to:)` calls. Auth guards, analytics, feature flags — plug them in or skip them with direct `push`. |
| **State ownership** | The engine is `@Observable` and `@MainActor`. SwiftUI reacts to changes automatically. No manual `@State` binding sync. |
| **Persistence** | `Codable` snapshots out of the box. Save before backgrounding, restore on launch — one line each way. |
| **Deep links** | A dedicated pipeline: parse a URL, run it through middleware, apply it to the engine. Deferred URLs handle the "app isn't ready yet" case. |
| **Concurrency** | Built for Swift 6 strict concurrency. Public API is `Sendable` and main-actor isolated where it matters; internal type erasure uses a single `@unchecked Sendable` wrapper. |

## Features

- Per-tab navigation stacks with full programmatic control
- Composable middleware chain for auth guards, analytics, and route interception
- Built-in deep link pipeline with deferred URL support
- Sheet and full-screen cover presentation with rich detent configuration
- Stack-aware navigation (`.popToExisting`) to avoid duplicate screens
- Auto-dismiss modals on navigation for clean state transitions
- Cross-tab and multi-step path navigation in single middleware-aware calls
- Context-preserving detour navigation for deep links and interruptions
- Global error handler for centralized error reporting across engines
- Async navigation with loading states
- `Codable` state persistence for save/restore across app launches
- Strict concurrency (`@MainActor`, `Sendable`, Swift 6 language mode)

## Requirements

- iOS 17+ / macOS 14+
- Swift 6.2+
- Xcode 16+
- No third-party dependencies

## Installation

**Xcode:** *File > Add Package Dependencies...* and paste **this distribution repository** URL (adjust org/repo if yours differs):

```
https://github.com/Namalabs/SwAN.git
```

**Package.swift:**

```swift
dependencies: [
    .package(url: "https://github.com/Namalabs/SwAN.git", from: "0.3.0")
]
```

SPM uses the `binaryTarget` in this repo’s `Package.swift`, which points at the **v0.3.0** release asset **`SwAN.xcframework.zip`**. Create that release on [Namalabs/SwAN](https://github.com/Namalabs/SwAN) after building the zip in your private repo (**maintainers:** see **`RELEASE_GUIDE.md`** at the root of the **private** SwAN source repository—this file is not shipped here). Until the asset is uploaded, `swift package resolve` and CI **Verify Swift package** will fail with a 404 — that is expected.

## Getting Started

### 1. Define your routes and menus

The snippets below share one `AppRoute` / `AppMenu` pair so you can copy them into a playground or sample app without fixing missing cases.

```swift
import SwAN

enum AppRoute: Routable {
    case home
    case detail(id: String)
    case settings
    case login
    case profile
    case shop
    case category(String)
    case product(String)
    case messageDetail(id: String)
    case loading  // placeholder for async navigation (see Async navigation)
}

enum AppMenu: MenuIdentifiable {
    case home, profile
}
```

`Routable` requires `Hashable`, `Sendable`, and `Codable`. `MenuIdentifiable` includes `CaseIterable` — the engine creates one stack per case.

### 2. Create a NavigationEngine and wire it up

```swift
struct ContentView: View {
    @State var engine = NavigationEngine<AppRoute, AppMenu>(initialMenu: .home)

    var body: some View {
        NavigationStackView(engine: engine) {
            HomeView(engine: engine)
        } destination: { route in
            switch route {
            case .home:                 HomeView(engine: engine)
            case .detail(let id):       DetailView(engine: engine, id: id)
            case .settings:            SettingsView(engine: engine)
            case .login:               LoginView(engine: engine)
            case .profile:             Text("Profile").navigationTitle("Profile")
            case .shop:                Text("Shop")
            case .category(let name):  Text("Category: \(name)")
            case .product(let id):     Text("Product: \(id)")
            case .messageDetail(let id): Text("Message \(id)")
            case .loading:             ProgressView()
            }
        }
    }
}
```

### 3. Navigate from any view

```swift
struct HomeView: View {
    let engine: NavigationEngine<AppRoute, AppMenu>

    var body: some View {
        VStack(spacing: 16) {
            Button("View Detail") {
                engine.push(.detail(id: "42"))
            }
            Button("Open Settings (guarded)") {
                engine.navigate(to: .settings)
            }
            Button("Present Login Sheet") {
                engine.present(.login, as: .sheet)
            }
        }
    }
}
```

Use `push` when the navigation decision is already made. Use `navigate(to:)` when middleware should evaluate first (auth, feature flags, analytics).

## What You Can Do

### Programmatic navigation

Full stack control from one object — no bindings to pass around:

```swift
engine.push(.detail(id: "42"))          // direct push (no middleware)
engine.pop()                            // pop top
engine.popToRoot()                      // clear stack
engine.switchMenu(to: .profile)         // switch tab
engine.replace(stack: [.home, .detail(id: "1")], for: .home)
engine.resetAll()                       // clear everything
```

### Guarded navigation with middleware

Middleware intercepts `navigate(to:)` and decides: allow, reject, or redirect.

```swift
// `myAuth` is any value conforming to `AuthStateProviding`.
let authGuard = AuthGuardMiddleware<AppRoute, AppMenu>(
    authProvider: myAuth,
    loginRoute: .login,
    isProtected: { route in route == .settings || route == .profile }
)
engine.addMiddleware(authGuard)

engine.navigate(to: .settings)  // redirects to .login if unauthenticated
```

Rejected routes are stored in `pendingRoute` so you can replay them after login.

### Modal presentation with detents

Present any route as a sheet or full-screen cover, with optional detent configuration:

```swift
engine.present(.settings, as: .sheet)

engine.present(.settings, configuration: ModalConfiguration(
    detents: [.medium, .large],
    selectedDetent: .medium,
    showDragIndicator: true
))
```

### Stack-aware navigation

Avoid duplicate screens. If the route already exists in the stack, the engine pops back to it:

```swift
engine.navigate(to: .profile, mode: .popToExisting)

// Or set it as the engine-wide default
engine.defaultNavigationMode = .popToExisting
```

### Cross-tab and path navigation

Navigate to a different tab's route or build a multi-step path in one call:

```swift
engine.navigate(to: .settings, in: .profile)
engine.navigate(path: [.shop, .category("shoes"), .product("nike-1")])
```

### Deep linking

Parse URLs, run them through middleware, and apply the result — with deferred handling if the app isn't ready:

```swift
engine.configurePipeline(DeepLinkPipeline(parser: AppDeepLinkParser()))

ContentView()
    .onOpenURL { url in engine.handle(url: url) }
```

### Context-preserving detours

Present a temporary destination (deep link, notification) while saving the user's entire context. Dismiss to restore:

```swift
engine.presentDetour(.messageDetail(id: "42"))
// user reads the message...
engine.dismissDetour()  // back to exact prior screen
```

### State persistence

Save and restore navigation state across app launches:

```swift
let data = try engine.saveState()
engine.restore(from: data)
```

### Async navigation

Show a loading screen while resolving data, then replace the stack with the result:

```swift
await engine.navigate(loading: .loading) {
    let product = try await api.fetchProduct(id: "42")
    return [.home, .detail(id: product.id)]
}
```

## Documentation

Full guides, cookbook, and API-oriented pages:

- **[Live docs (latest)](https://namalabs.github.io/SwAN/#/v0.3.0/)** — GitHub Pages from this repo’s `docs/` folder (see `.github/workflows/deploy-pages.yml`)
- **[v0.3.0 docs](/docs/v0.3.0/)** — overview, getting started, navigation, presentation, advanced, cookbook, API reference
- **Swift Package Index** — SPI primarily documents **source** packages; for this **binary** package, prefer **`docs/`** and Xcode as above.

Run Docsify locally (from the root of **this** repository, where `docs/` lives):

```bash
npx docsify-cli serve docs
```

| Version | Link |
|:---|:---|
| v0.3.0 (latest) | [docs/v0.3.0](/docs/v0.3.0/) |
| v0.2.0 | [docs/v0.2.0](/docs/v0.2.0/) |
| v0.1.0 | [docs/v0.1.0](/docs/v0.1.0/) |

Release history: [CHANGELOG.md](CHANGELOG.md).

## License

Use of the SwAN **binary** is governed by [LICENSE](LICENSE). This repository does not grant rights to view or modify library source code.
