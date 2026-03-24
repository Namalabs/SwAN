# Getting started

## Requirements

iOS 17+, macOS 14+, Swift 6.2+, Xcode 16+.

## Add the package

**Package.swift**

```swift
.package(url: "https://github.com/Namalabs/SwAN.git", from: "0.3.0")
```

**Xcode:** *File → Add Package Dependencies...* → paste the repo URL.

---

## Types

```swift
import SwAN

enum AppRoute: Routable {
    case home
    case detail(id: String)
    case settings
}

enum AppMenu: MenuIdentifiable {
    case home, profile
}
```

`Routable` = `Hashable`, `Sendable`, `Codable`.
`MenuIdentifiable` already includes `CaseIterable` — the engine creates an empty stack per menu case at init.

Avoid `enum Route: String, Routable` — you lose associated values and type safety.

---

## Minimal `NavigationStack`

```swift
struct ContentView: View {
    @State var engine = NavigationEngine<AppRoute, AppMenu>(initialMenu: .home)

    var body: some View {
        NavigationStackView(engine: engine) {
            VStack(spacing: 16) {
                Text("Home")
                Button("Open detail") {
                    engine.push(.detail(id: "42"))
                }
            }
        } destination: { route in
            switch route {
            case .home:
                Text("Home")
            case .detail(let id):
                Text("Detail \(id)")
            case .settings:
                Text("Settings")
            }
        }
    }
}
```

---

## `push` vs `navigate(to:)`

Use **`push`** when the decision is already valid (e.g. after your own check). Use **`navigate(to:)`** when **middleware** should run (auth, feature flags, ...).

```swift
engine.push(.detail(id: "1"))        // no middleware
engine.navigate(to: .settings)       // middleware chain (if any)
```

---

## TabView (outline)

One `NavigationEngine`, one `NavigationStackView` per tab, selection bound to `activeMenu`:

```swift
TabView(selection: Binding(
    get: { engine.activeMenu },
    set: { engine.switchMenu(to: $0) }
)) {
    NavigationStackView(engine: engine) { HomeRoot() } destination: { route in DestinationView(route: route) }
        .tag(AppMenu.home)
    NavigationStackView(engine: engine) { ProfileRoot() } destination: { route in DestinationView(route: route) }
        .tag(AppMenu.profile)
}
```

Full pattern (including modals): [Navigation — TabView](/v0.3.0/navigation.md#tabview).

---

## Modals & URLs

**Modal** (engine + SwiftUI):

```swift
engine.present(.settings, as: .sheet)

ContentView()
    .modalPresenter(engine: engine) { route in
        switch route {
        case .settings: SettingsView()
        default: EmptyView()
        }
    }
```

**Modal with detents** (new in 0.3.0):

```swift
engine.present(.settings, configuration: ModalConfiguration(
    detents: [.medium, .large],
    selectedDetent: .medium
))
```

**Deep link** (outline): implement `DeepLinkParser`, `configurePipeline`, then `onOpenURL` → `engine.handle(url:)`. Step-by-step: [Presentation & deep links](/v0.3.0/presentation-and-links.md).

---

## Next

- Skipped the big picture? [Overview](/v0.3.0/overview.md)
- Stacks & middleware in depth: [Navigation](/v0.3.0/navigation.md)
