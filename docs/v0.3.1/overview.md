# Overview

**SwAN** is a Swift Package: one **`NavigationEngine`** owns navigation state for SwiftUI — per-tab stacks, modals with detent configuration, middleware (e.g. auth), deep links, detour navigation, and JSON snapshots.

You define **`Routable`** (screens) and **`MenuIdentifiable`** (tabs; one stack per case). The engine is **`@MainActor`** and **`@Observable`**.

---

## Mental model

```
Views → engine.push / navigate / handle(url:)
   ↑
   └── NavigationStackView binds stack ↔ SwiftUI
```

**Direct** APIs (`push`, `present`, `pop`, ...) update state immediately — **no middleware**.

**Guarded** APIs run middleware first:

```swift
engine.push(.detail(id: "1"))                     // middleware skipped
engine.navigate(to: .settings)                     // middleware runs, then maybe push
engine.navigate(to: .settings, mode: .popToExisting) // guarded + stack-aware
engine.navigate(presenting: .share, as: .sheet)    // guarded modal
engine.navigate(to: .settings, in: .profile)       // guarded cross-tab
engine.navigate(path: [.list, .detail(id: "1")])   // guarded multi-step
```

---

## Where things live (package)

| Folder | What |
|:---|:---|
| `Core/` | `Routable`, `MenuIdentifiable`, `FlowIdentifiable`, `NavigationMode`, `NavigationError`, `NavigationErrorHandler` |
| `Engine/` | `NavigationEngine` + extensions (Middleware, Path, CrossTab, Detour, Async, Binding, DeepLink, Persistence) |
| `Middleware/` | `NavigationMiddleware`, `AuthGuardMiddleware`, `MiddlewareChain` |
| `DeepLink/` | `DeepLinkParser`, `DeepLinkPipeline`, `NotificationRouter` |
| `Presentation/` | `PresentationStyle`, `ModalPresenter`, `ModalConfiguration`, `ModalDetent` |
| `Views/` | `NavigationStackView`, `FlowSwitchView`, `RouteDestinationModifier` |
| `Coordinator/` | Optional `Coordinator`, `AppCoordinating`, `FlowCoordinating` |

The engine does **not** own auth tokens or "current app flow" — you inject auth into middleware and own flow in a coordinator if you use one.

---

## Read next

1. [Getting started](/v0.3.1/getting-started.md) — install + minimal UI
2. [Navigation](/v0.3.1/navigation.md) — stacks, tabs, middleware, stack-aware navigation, auto-dismiss
3. [Presentation & deep links](/v0.3.1/presentation-and-links.md) — modals, detents, detours, deep links
4. [Advanced](/v0.3.1/advanced.md) — async, path/cross-tab navigation, coordinators, global errors
5. [API reference](/v0.3.1/api.md) — lookup while coding
6. [Changelog](/v0.3.1/changelog.md) — recent releases log
