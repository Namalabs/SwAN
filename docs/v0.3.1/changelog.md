# Changelog

Recent release notes for the versions covered here. For the **complete** project history, see [`CHANGELOG.md` on GitHub](https://github.com/Namalabs/SwAN/blob/master/CHANGELOG.md).

---

## 0.3.1

Patch release for **binary Swift package distribution**: use a new immutable tag so SwiftPM/Xcode no longer reject resolution when tag `0.3.0` was moved. **No API changes** from 0.3.0 — same library surface; update your dependency to `from: "0.3.1"`.

---

## 0.3.0

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
