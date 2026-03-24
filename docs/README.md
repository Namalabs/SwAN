# SwAN — SwiftUI Advanced Navigation

![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange)
![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
![License: Binary use only](https://img.shields.io/badge/License-Binary%20use%20only-lightgrey)

SwAN is a type-safe navigation library for SwiftUI. It gives you one `NavigationEngine` to manage tab stacks, modals, guarded navigation, deep links, and optional state persistence.

**License (this distribution):** the SwAN **binary** is licensed for use under the terms in the repository root `LICENSE` file (binary use only; no library source is provided here).

## Quick Preview

- **One engine, one source of truth** for navigation state
- **Direct vs guarded navigation** (`push` vs `navigate(to:)`)
- **Built for production apps** with tabs, auth guards, and deep links
- **Swift 6.2+, strict concurrency friendly**, no third-party runtime deps

```swift
import SwAN

enum AppRoute: Routable { case home, detail(id: String), settings }
enum AppMenu: MenuIdentifiable { case home, profile }

let engine = NavigationEngine<AppRoute, AppMenu>(initialMenu: .home)
engine.push(.detail(id: "42"))      // direct
engine.navigate(to: .settings)       // guarded (runs middleware)
```

## Documentation

- **Latest:** [v0.3.0](/v0.3.0/)
- **Repo:** [github.com/Namalabs/SwAN](https://github.com/Namalabs/SwAN)

## Requirements

iOS 17+, macOS 14+, Swift 6.2+, Xcode 16+
