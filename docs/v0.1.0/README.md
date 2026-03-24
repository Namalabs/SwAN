# SwAN v0.1.0

> ⚠️ **This version is deprecated.** The documentation below is preserved for reference. New projects should use the latest version.

👉 [Latest docs (v0.3.0)](/latest/) — see [Overview](/v0.3.0/overview.md) there.

---

## Basic Usage

### Define Routes and Menus

```swift
import SwAN

enum AppRoute: Routable {
    case home
    case productDetail(id: String)
    case settings
}

enum AppMenu: MenuIdentifiable, CaseIterable {
    case home, profile
}
```

### Create the Engine

```swift
let engine = NavigationEngine<AppRoute, AppMenu>(initialMenu: .home)
```

### Navigate

```swift
// Push a screen
engine.push(.productDetail(id: "42"))

// Go back
engine.pop()

// Go back to root
engine.popToRoot()

// Switch tab
engine.switchMenu(to: .profile)

// Show a modal
engine.present(.settings, as: .sheet)

// Dismiss modal
engine.dismiss()
```

### SwiftUI Integration

```swift
struct ContentView: View {
    @State var engine = NavigationEngine<AppRoute, AppMenu>(initialMenu: .home)

    var body: some View {
        NavigationStackView(engine: engine) {
            HomeView()
        } destination: { route in
            switch route {
            case .home: HomeView()
            case .productDetail(let id): ProductDetailView(id: id)
            case .settings: SettingsView()
            }
        }
    }
}
```

---

> For middleware, deep links, async navigation, coordinators, and all other features, see the [latest documentation](/latest/).
