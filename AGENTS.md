# Pizza Lover

## Project Overview
Ranks individual pizzas (not restaurants). Each pizza Brent eats is logged against a
restaurant, scored on 4 independent 1-10 values: crust, sauce, toppings, and overall taste.
Overall taste is a separate manual gut-feel score — it is NEVER computed/averaged from the
other three. Nearby pizza-place search uses Apple's free, built-in MapKit (Yelp's Fusion API
killed its free tier, now $229+/month minimum, so Yelp is not used). A random pizza picker, an
achievements system, and full iCloud/CloudKit sync are all built. The app is fully free with
no paywall. Remaining future milestone: ship readiness (App Store Connect).

## Core Principles
1. **No ads. Ever.** No ad SDKs in the bundle.
2. **Free, no paywall.** The app is fully free and unlimited — no IAP, no subscriptions.
3. **Overall taste score is independent.** Never derive it from crust/sauce/toppings — it is
   always a separate manual entry.
4. **No login screen.** CloudKit will ride the user's Apple ID automatically once wired up;
   no account system is ever built.
5. **Accessibility is mandatory, not a pass at the end.** VoiceOver labels, Reduce Motion,
   and Dynamic Type get considered while building each view, not bolted on afterward.

## Tech Stack
- SwiftUI + SwiftData + MapKit + CoreLocation
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
├── Services/      PlacesService (MapKit nearby search), LocationService (CoreLocation wrapper),
│                  RestaurantPoolFilter (pure favorites/untried pool filter for random picker),
│                  AchievementEngine (rule-evaluation against AchievementDefinition.all,
│                  inserts Achievement rows the first time a rule becomes true)
├── Views/         NearbyPizzaListView, RestaurantDetailView, PizzaEntryFormView, MyRankingsView,
│                  RandomPizzaPickerView, AchievementsView, SettingsView (placeholder "More Apps"
│                  cross-promo section, reachable via a gear button on My Rankings)
├── Pizza_LoverApp.swift   App entry point, CloudKit-backed SwiftData ModelContainer
├── ContentView.swift      TabView with "Nearby" (NearbyPizzaListView), "My Rankings"
│                          (MyRankingsView), "Random" (RandomPizzaPickerView), and
│                          "Achievements" (AchievementsView) tabs, each in its own
│                          NavigationStack
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
- Test everything that's testable and makes sense to test — real business logic (score
  gating, `AchievementEngine` rules, `RestaurantPoolFilter`, `ImageProcessing`) gets Swift
  Testing coverage. Skip tests that genuinely don't make sense (thin SwiftUI view bodies,
  trivial wrappers) — don't test for the sake of a number.
- Code stays readable over clever. No obfuscated one-liners or cute tricks. Comment the WHY
  when a real decision got made (a workaround, a non-obvious constraint) — not what the code
  already says plainly.

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
- **M5 "Random Pizza Picker"** — DONE: `RestaurantPoolFilter` (pure, testable filter —
  favorites vs untried pool), `RandomPizzaPickerView` (mode segmented control, "Pick For Me"
  button, `.randomElement()` pick, `ContentUnavailableView` empty states for no restaurants /
  empty pool); deliberately a plain button for v1 with no spinning-wheel animation per
  Brent's explicit instruction; the result display is its own small `RandomPickResultView`
  subview (name/address, "Pick Again", and a `NavigationLink` into `RestaurantDetailView`) so
  a future fancier "spin" presentation can swap in later without touching the filter logic;
  `ContentView` gained a third "Random" tab (2026-10-29)
- **M4 addition "Pizza Photo Capture"** — DONE (2026-10-29): added on top of M4's form per
  Brent's request, after he hands-on tested M1-M6 on his real phone. `PizzaEntryFormView` gained
  a "Photo" section (thumbnail or dashed-border placeholder) backed by a `.confirmationDialog`
  offering "Take Photo" (only shown if `UIImagePickerController.isSourceTypeAvailable(.camera)`
  — false on simulator) and "Choose from Library" (`PhotosPicker`, iOS 16+); `CameraImagePicker`
  (new `UIViewControllerRepresentable` wrapping `UIImagePickerController` with
  `sourceType = .camera` — `PhotosPicker` alone can't do camera capture); `ImageProcessing`
  (new `Services/` helper) downsizes the picked `UIImage` to a 1200px-longest-side cap and
  compresses to JPEG at 0.7 quality before it's stored in `PizzaEntry.photoData`; new
  `PizzaPhotoThumbnail` reusable view shows a small rounded thumbnail in both `MyRankingsView`
  rows (60x60) and `RestaurantDetailView`'s pizza-entry history rows (44x44) when `photoData`
  is non-nil; `INFOPLIST_KEY_NSCameraUsageDescription` added to both Debug/Release configs
  (`PhotosPicker`/`PHPicker` runs out-of-process and does not require a declared
  `NSPhotoLibraryUsageDescription`, verified — not added)
- **M6 "Achievements"** — DONE: `AchievementEngine` (pure rule-evaluation against
  `AchievementDefinition.all`, manually checks for an existing `Achievement` by `id` before
  inserting a new one since CloudKit forbids unique constraints) maps the 4 starter
  definitions to real logic — "first-slice" (>=1 `PizzaEntry`), "five-spots" (>=5 distinct
  restaurant names across entries), "perfect-crust" (any entry with `crustScore == 10`),
  "dedicated" (>=10 total entries); runs automatically right after every `PizzaEntry` save in
  `PizzaEntryFormView`; `AchievementsView` (`LazyVGrid` of cards, one per definition, earned
  shown colored with its earned date vs. locked shown dimmed/desaturated via a `@Query` of
  `Achievement`); `ContentView` gained a fourth "Achievements" tab (2026-10-29)
- **M7 "Monetization"** — BUILT then REMOVED: a $0.99 one-time StoreKit unlock gating saves
  past a free 3-entry cap was built in M7 (2026-10-29) — `StoreManager`, `PizzaEntryGate`,
  `PaywallView`, `Pizza Lover.storekit`, a Restore Purchases + `#if DEBUG` unlock toggle in
  `SettingsView`, and `PizzaEntryGateTests.swift`. On 2026-11-02 Brent decided to make the app
  fully free with no paywall — the entire paywall stack was ripped out (all files above
  deleted; `Pizza_LoverApp.swift`, `PizzaEntryFormView.swift`, `RestaurantDetailView.swift`,
  `ContentView.swift`, and the shared `.xcscheme` had their StoreManager/PaywallView
  references removed). `SettingsView` was kept as a placeholder for a future "Support the
  developer / check out my other apps" cross-promo section (real links still pending from
  Brent).
- **M8 "Ship Readiness"** — PLANNED

## Do NOT
- Add third-party frameworks without asking
- Add ads or subscriptions
- Derive `overallTasteScore` from crust/sauce/toppings
- Add a login/account screen
- Modify `.pbxproj` by hand — use `Scripts/bump-version.sh`
- Show changes before editing source files — ask first
