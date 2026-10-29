# Pizza Lover

## Project Overview
Ranks individual pizzas (not restaurants). Each pizza Brent eats is logged against a
restaurant, scored on 4 independent 1-10 values: crust, sauce, toppings, and overall taste.
Overall taste is a separate manual gut-feel score — it is NEVER computed/averaged from the
other three. Nearby pizza-place search uses Apple's free, built-in MapKit (Yelp's Fusion API
killed its free tier, now $229+/month minimum, so Yelp is not used). Future milestones add a
random pizza picker, an achievements system, full iCloud/CloudKit sync, and a $0.99 one-time
unlock after a free 3-entry cap.

## Core Principles
1. **No ads. Ever.** No ad SDKs in the bundle.
2. **Pay once, own it.** One non-consumable IAP ($0.99), no subscriptions.
3. **Overall taste score is independent.** Never derive it from crust/sauce/toppings — it is
   always a separate manual entry.
4. **No login screen.** CloudKit will ride the user's Apple ID automatically once wired up;
   no account system is ever built.

## Tech Stack
- SwiftUI + SwiftData + MapKit + CoreLocation
- StoreKit 2 (planned, not yet wired up)
- Deployment target iOS 17.6 (built/indexed with the iOS 27 SDK in Xcode — don't assume
  iOS 18+-only APIs are available; the `Tab(_:systemImage:content:)` TabView initializer
  isn't, use classic `TabView` + `.tabItem` instead, confirmed 2026-10-28), iPhone only
  (TARGETED_DEVICE_FAMILY = 1)
- `@Observable` / MV pattern (no heavy architecture)
- Swift Testing (NOT XCTest) for any future tests

## Architecture
```
Pizza Lover/
├── Models/        Restaurant, PizzaEntry, Achievement, AchievementDefinition
├── Services/      PlacesService (MapKit nearby search), LocationService (CoreLocation wrapper)
├── Views/         NearbyPizzaListView, RestaurantDetailView, PizzaEntryFormView, MyRankingsView
├── Pizza_LoverApp.swift   App entry point, CloudKit-backed SwiftData ModelContainer
├── ContentView.swift      TabView with "Nearby" (NearbyPizzaListView) and "My Rankings"
│                          (MyRankingsView) tabs, each in its own NavigationStack
└── Assets.xcassets
```

## Key Conventions
- One type per file
- All `@Model` relationships are optional (`Restaurant.pizzaEntries`, `PizzaEntry.restaurant`)
- No `@Attribute(.unique)` anywhere — CloudKit forbids unique constraints, so the schema is
  built CloudKit-safe from day one even before CloudKit is wired up
- Every `@Model` property has a default value (also a CloudKit requirement)
- `Achievement` (synced SwiftData record, just id + date earned) is split from
  `AchievementDefinition` (plain struct, display copy only) to keep title/description/icon
  text out of any future CloudKit schema
- No Yelp, no API keys, no `Configuration/Secrets.swift` — MapKit needs none of that

## Development Milestones
- **M1 "Local Data Slice"** — DONE: SwiftData models (Restaurant, PizzaEntry, Achievement,
  AchievementDefinition), PlacesService (MapKit), LocationService (CoreLocation), local-only
  ModelContainer, build-verification ContentView placeholder
- **M2 "CloudKit Wiring"** — DONE: iCloud+CloudKit capability added in Xcode (container
  `iCloud.net.perlguy.Pizza-Lover`), `ModelConfiguration(cloudKitDatabase: .automatic)` wired
  in, verified syncing live across Brent's iPhone and iPad on the same Apple ID (2026-10-28)
- **M3 "Nearby Places UI"** — DONE: `NearbyPizzaListView` (MapKit search, distance-sorted list,
  pull-to-refresh), `RestaurantDetailView` (favorite toggle, pizza-entry history, "I Ate Pizza
  Here" button — this button's behavior was replaced in M4, see below) (2026-10-28)
- **M4 "Pizza Logging & Rankings"** — DONE: `PizzaEntryFormView` (real scoring form, sheet
  presentation, 4 independent 1-10 sliders with Overall Taste visually separated under "Your
  Gut Feeling", optional notes `TextEditor`) replaces the old bare-insert placeholder behind
  "I Ate Pizza Here"; `MyRankingsView` (sorted `@Query` of all `PizzaEntry`, re-sortable by
  any of the 4 scores or date, empty state via `ContentUnavailableView`); `ContentView` is now
  a `TabView` ("Nearby" / "My Rankings") instead of a single `NavigationStack` (2026-10-28)
- **M5 "Random Pizza Picker"** — PLANNED
- **M6 "Achievements"** — PLANNED
- **M7 "Monetization"** — PLANNED
- **M8 "Ship Readiness"** — PLANNED

## Do NOT
- Add third-party frameworks without asking
- Add ads or subscriptions
- Derive `overallTasteScore` from crust/sauce/toppings
- Add a login/account screen
- Modify `.pbxproj` by hand — use `Scripts/bump-version.sh`
- Show changes before editing source files — ask first
