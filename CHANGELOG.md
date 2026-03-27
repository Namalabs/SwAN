# Changelog

All notable changes to SwAN will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.1] — 2026-03-27

### Fixed (distribution)

- **Binary Swift package:** new immutable tag `0.3.1` with updated `SwAN.xcframework.zip` and checksum so SwiftPM/Xcode resolve cleanly after retagging `0.3.0`. No library API changes.

## [0.3.0] — 2026-03-24

### Added

#### Engine — Stack-Aware Navigation
- `NavigationMode` enum (`.push`, `.popToExisting`) — controls whether `navigate(to:)` pushes unconditionally or pops to an existing occurrence of the route
- `navigate(to:mode:)` — guarded navigation with an explicit navigation mode
- `defaultNavigationMode` property — engine-wide default for `navigate(to:)` calls (defaults to `.push` for backward compatibility)

#### Engine — Auto-Dismiss Modal
- `dismissModalOnNavigation` property — when `true`, `push`, `switchMenu`, `replace`, and `navigate` variants automatically dismiss the presented modal before proceeding (defaults to `false`)

#### Engine — Path Navigation
- `navigate(path:)` — appends an ordered sequence of routes to the active stack through middleware (evaluates the last route)
- `navigate(replacing:)` — replaces the active stack with a given path through middleware

#### Engine — Cross-Tab Navigation
- `navigate(to:in:)` — switches to a menu and pushes a route in one middleware-aware call
- `navigate(to:in:mode:)` — cross-tab navigation with explicit navigation mode
- `navigate(path:in:)` — switches to a menu and replaces its stack with a path through middleware

#### Engine — Detour Navigation
- `presentDetour(_:)` — saves a snapshot of the engine state and presents a route as a full-screen cover
- `presentDetour(path:)` — multi-step detour with snapshot preservation
- `dismissDetour()` — restores the prior state exactly from the snapshot
- `isDetourActive` property — whether a detour is currently presented
- `DetourSnapshot` type — holds the saved engine state during a detour

#### Presentation
- `ModalConfiguration` struct — rich modal configuration with detents, drag indicator, and dismiss control
- `ModalDetent` enum (`.medium`, `.large`) — sheet detent options
- `present(_:configuration:)` — present a route with a `ModalConfiguration`
- `ModalPresenter` now applies `.presentationDetents`, `.presentationDragIndicator`, and `.interactiveDismissDisabled` when `modalConfiguration` is set
- `modalConfiguration` property on the engine — the active modal configuration

#### Error Handling
- `NavigationErrorHandler` singleton — centralized error handler shared across engines
- `reportsToGlobalHandler` property — opt-in per-engine forwarding to the global handler
- `NavigationError.pathNavigationRejected` — middleware rejected a path navigation
- `NavigationError.detourAlreadyActive` — attempted to present a detour while one is active
- `NavigationError.noActiveDetour` — attempted to dismiss a detour when none is active

#### Debug
- `NavigationLogger` gains: `logAutoDismiss`, `logPath`, `logCrossTab` (route and path variants), `logDetourPresent`, `logDetourDismiss`

#### Persistence
- `NavigationState.modalConfiguration` — optional field for modal configuration persistence (backward-compatible: pre-0.3.0 data decodes with `nil` via `decodeIfPresent`)

### Fixed
- `popTo(_:)` now uses `setLastError` instead of direct assignment, ensuring `onError`, logger, and global handler are triggered consistently

### Tests
- 315 tests across 46 suites (up from 263 tests in 38 suites)
- New test suites: `PopToExistingNavigationTests`, `AutoDismissModalTests`, `ModalConfigurationTests`, `PathNavigationTests`, `CrossTabNavigationTests`, `DetourTests`, `GlobalErrorHandlerTests`, `ModalConfigPersistenceTests`

### Documentation
- README updated with new sections: Modal Configuration (Detents), Stack-Aware Navigation, Auto-Dismiss Modal, Path Navigation, Cross-Tab Navigation, Detour Navigation, Global Error Handler
- API Reference tables updated with all new methods and properties
- Programmatic Navigation quick reference expanded

---

## [0.2.0] — 2026-03-19

### Added

#### Engine
- `navigate(presenting:as:)` — guarded modal presentation through middleware chain
- `onError` callback — centralized error observation (`((NavigationError) -> Void)?`)
- Internal UUID-based race-condition guard for `navigate(loading:resolve:)` (last-writer-wins)
- Logger integration across all engine operations: push, pop, popToRoot, switchMenu, present, dismiss, errors

#### Core
- `NavigationError.deepLinkFailed(String)` — carries diagnostic reason for deep link failures
- `NavigationError.modalPresentationRejected` — middleware rejected a guarded modal
- `NavigationState.version` — integer version field for migration-safe persistence
- `NavigationState.currentVersion` — static property for the current schema version

#### Middleware
- `NavigationContext.presentedRoute` — middleware can inspect the currently presented modal

#### Deep Links
- `DeepLinkResult.presentedRoute` — deep links can trigger modal presentation
- `DeepLinkResult.presentationStyle` — modal style for deep link modals
- `DeepLinkPipeline` now applies `presentedRoute` + `presentationStyle` from result

### Changed

#### Route System
- Updated `Routable` documentation: strongly discourages `String` raw types, recommends associated values
- Updated `MenuIdentifiable` documentation: clearer guidance on enum-based tab/menu identification
- Test helpers (`MockRoute`, `MockMenu`, `MockFlow`) rewritten to use plain enums without `String` raw types
- `MockRoute` uses associated values (`productDetail(id:)`, `loading(id:)`, `shareSheet(productId:)`) — better real-world patterns

#### Persistence
- `NavigationState` decoder is now migration-safe: uses `decodeIfPresent` for the version field, defaults to version 1 for legacy payloads
- State snapshots now include a `version` key for forward-compatible schema evolution

#### Async Navigation
- `navigate(loading:resolve:)` now tracks each operation with a UUID — concurrent async navigations are resolved safely (last-writer-wins, earlier results silently discarded)

#### Error Handling
- `setLastError` now invokes `onError` callback in addition to setting `lastError`
- `NavigationError` gains `CustomStringConvertible` and `CustomDebugStringConvertible` for better diagnostics

#### Middleware
- `NavigationContext` initialiser updated to accept optional `presentedRoute` parameter

### Documentation
- README comprehensively rewritten with full API coverage, associated-value route examples, coordinator patterns, SwiftUI integration guides, architecture diagram, and complete API reference table
- Installation version updated to `0.2.0`

### Tests
- 263 tests across 38 suites (up from 228 tests in 32 suites)
- New test suites: `GuardedModalTests`, `AsyncRaceConditionTests`, `NavigationStateVersionTests`, `DeepLinkModalTests`, `OnErrorCallbackTests`, `NavigationErrorExtendedTests`
- All test mocks migrated to associated-value enums

---

## [0.1.0] — 2026-03-19

### Added

#### Core
- `Routable` protocol — type-safe route definitions (`Hashable`, `Sendable`, `Codable`)
- `MenuIdentifiable` protocol — tab/menu identification (`CaseIterable`, `Codable`)
- `FlowIdentifiable` protocol — app flow identification (auth, onboarding, etc.)
- `AuthStateProviding` protocol — injectable auth state
- `NavigationError` enum — non-throwing error emission with full conformance set
- `PresentationStyle` enum — `.sheet` and `.fullScreenCover`

#### Engine
- `NavigationEngine<R, M>` — `@Observable`, `@MainActor` isolated, multi-stack engine
- Push, pop, popToRoot, popTo, reset, resetAll, switchMenu, replace operations
- Modal presentation (sheet + fullScreenCover on iOS)
- `activeStackBinding` — `Binding<[R]>` for `NavigationStack` integration
- `navigate(to:)` — guarded navigation through middleware chain
- `navigate(loading:resolve:)` — progressive async navigation with cancellation
- `handle(url:)` / `configurePipeline` / `processDeferredURL` — deep link integration
- `saveState()` / `restore(from:)` — JSON-based state persistence

#### Middleware
- `NavigationMiddleware` protocol — composable route interception
- `MiddlewareChain` — ordered evaluation with short-circuit on reject/redirect
- `AuthGuardMiddleware` — built-in auth guard with configurable protection + login redirect
- `MiddlewareResult` — `.allow`, `.reject(error)`, `.redirect(route)`
- `NavigationContext` — navigation state snapshot for middleware evaluation

#### Deep Links
- `DeepLinkParser` protocol — consumer-implemented URL → navigation state
- `RouteSerializer` protocol — navigation state → URL
- `DeepLinkPipeline` — orchestrator: parse → middleware → apply
- `NotificationRouter` — push notification payload → deep link
- `URLParsingHelpers` — path segments, host, query params, decompose
- `DecomposedURL` — value type for decomposed URL parts
- Deferred URL support (G5) — store URL when not in main flow, apply after transition

#### Coordinator
- `Coordinator` protocol — engine ownership + destination resolution
- `AppCoordinating` protocol — app-level flow management
- `FlowCoordinating` protocol — sub-flow lifecycle

#### Views
- `NavigationStackView` — pre-wired `NavigationStack` with engine binding
- `FlowSwitchView` — flow-based view switching
- `RouteDestinationModifier` — `.routeDestination(for:destination:)` convenience

#### Presentation
- `ModalPresenter` — ViewModifier binding to engine modal state
- Platform-conditional `fullScreenCover` (iOS/tvOS/watchOS/visionOS only)

#### Persistence
- `NavigationState<R, M>` — `Codable`, `Sendable`, `Equatable` state snapshot

#### Debug
- `NavigationLogger` — opt-in console logging of navigation state transitions

### Platform Support
- iOS 17.0+
- macOS 14.0+
- Swift 6.2, strict concurrency mode
- Zero external dependencies
