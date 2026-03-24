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

## What's new in 0.3.0

| Feature | Description |
|:---|:---|
| **Stack-aware navigation** | `.popToExisting` mode pops to a route if it already exists in the stack |
| **Auto-dismiss modal** | `dismissModalOnNavigation` cleans up modals on push/switch/navigate |
| **Modal configuration** | `ModalConfiguration` with detents, drag indicator, dismiss control |
| **Path navigation** | `navigate(path:)` and `navigate(replacing:)` for multi-step guarded navigation |
| **Cross-tab navigation** | `navigate(to:in:)` and `navigate(path:in:)` for one-call tab switching |
| **Detour navigation** | `presentDetour` / `dismissDetour` saves and restores full engine state |
| **Global error handler** | `NavigationErrorHandler.shared` for centralized error reporting |

All new APIs are **additive**. Existing 0.2.x code compiles and behaves identically without changes.

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

1. [Getting started](/v0.3.0/getting-started.md) — install + minimal UI
2. [Navigation](/v0.3.0/navigation.md) — stacks, tabs, middleware, stack-aware navigation, auto-dismiss
3. [Presentation & deep links](/v0.3.0/presentation-and-links.md) — modals, detents, detours, deep links
4. [Advanced](/v0.3.0/advanced.md) — async, path/cross-tab navigation, coordinators, global errors
5. [API reference](/v0.3.0/api.md) — lookup while coding
