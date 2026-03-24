# Overview

**SwAN** is a Swift Package: one **`NavigationEngine`** owns navigation state for SwiftUI — per-tab stacks, optional modals, middleware (e.g. auth), deep links, and JSON snapshots.

You define **`Routable`** (screens) and **`MenuIdentifiable`** (tabs; one stack per case). The engine is **`@MainActor`** and **`@Observable`**.

---

## Mental model

```
Views → engine.push / navigate / handle(url:)
   ↑
   └── NavigationStackView binds stack ↔ SwiftUI
```

**Direct** APIs (`push`, `present`, `pop`, …) update state immediately — **no middleware**.

**Guarded** APIs run middleware first:

```swift
engine.push(.detail(id: "1"))           // middleware skipped
engine.navigate(to: .settings)          // middleware runs, then maybe push
engine.navigate(presenting: .share, as: .sheet)  // guarded modal
```

---

## Where things live (package)

| Folder | What |
|:---|:---|
| `Engine/` | `NavigationEngine` |
| `Middleware/` | `NavigationMiddleware`, `AuthGuardMiddleware` |
| `DeepLink/` | `DeepLinkParser`, `DeepLinkPipeline`, `NotificationRouter` |
| `Views/` | `NavigationStackView`, `FlowSwitchView`, `modalPresenter` |
| `Coordinator/` | Optional `Coordinator`, `AppCoordinating`, `FlowCoordinating` |

The engine does **not** own auth tokens or “current app flow” — you inject auth into middleware and own flow in a coordinator if you use one.

---

## Read next

1. [Getting started](/v0.2.0/getting-started.md) — install + minimal UI  
2. [Navigation](/v0.2.0/navigation.md) — stacks, tabs, middleware  
3. [API reference](/v0.2.0/api.md) — lookup while coding  
