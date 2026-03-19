# ModularShop - iOS Modular Architecture Showcase

A reference iOS app demonstrating clean modular architecture with proper segregation among feature modules and utility libraries. The goal is a small, readable codebase that mirrors real-world practices for large apps — covering app launch management, routing, deeplinking, config, analytics, networking, and more.

**We care about code structure, not UI polish.** Every module is intentionally minimal yet reflects how production apps organize their code.

## Architecture

- **SPM monorepo**: All modules live in `Package.swift` — feature modules, interface modules, and shared libraries.
- **Interface/Implementation split**: Each feature (Home, Details, Cart, Checkout) has a public `*Interface` module (protocols + models) and a private implementation module.
- **Coordinator pattern**: Each feature has a Coordinator that builds screens and handles navigation.
- **CompositionRoot**: Single DI container wiring all dependencies. Uses `LazyRouter` to break circular coordinator↔router dependency.
- **MVVM + Combine**: ViewModels expose state via `CurrentValueSubject`, actions via `PassthroughSubject`.

## Key Rules

- **Always ask clarifying questions before acting.** When planning or implementing anything, ask questions first — never make assumptions or decisions independently without the user's explicit permission.
- **No unnecessary comments in code.** Code should speak for itself. Only add comments when there is an explicit need to explain something unusual or non-obvious.
- **Never run the project or tests automatically.** Always ask the user to build/run from Xcode manually, then ask what to verify.
- **UIKit only** — programmatic views. No XIBs, Storyboards, or SwiftUI.
- **Keep everything minimal** — UI, domain, and data layers. Small implementations that demonstrate the pattern, not production-scale features.
- **Prefer editing existing files** over creating new ones unless the architecture demands it.

## Module Map

| Layer | Modules |
|-------|---------|
| Libraries | `NetworkLib`, `CacheLib`, `LoggingLib`, `AnalyticsLib`, `ConfigLib`, `UIComponents` |
| Interfaces | `HomeInterface`, `DetailsInterface`, `CartInterface`, `CheckoutInterface`, `SharedRouterInterface` |
| Features | `Home`, `Details`, `Cart`, `Checkout`, `SharedRouter` |
| App | `ModularShop` (AppDelegate, CompositionRoot, AppConfigurator) |
