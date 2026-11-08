# App Review Information — Notes field

Apple rejected the first submission and asked for this info to be added to the **App Review Information > Notes** field before resubmitting (2026-11-08). Paste the whole block below as-is - it's written in plain text (no markdown) since that field doesn't render formatting.

```
1. Screen recording

A screen recording from a physical device running the latest iOS has been captured separately and is attached/uploaded with this submission, starting from app launch and showing the typical user flow.

The app has no account registration, login, or account deletion flow - there is no account system of any kind. Data syncs automatically through the user's already-signed-in iCloud account via CloudKit, with no sign-up or login step anywhere in the app.

The app has no user-generated content that is shared with or visible to other users. Every pizza entry, photo, and note a user creates is private to their own iCloud account. There is no social feed, no public posting, and therefore no content reporting or blocking mechanism is needed or present.

The app has no paid content or features. It is entirely free, with no in-app purchases, subscriptions, or ads.

2. App purpose and target audience

Pizza Lover is a personal food journal focused specifically on pizza. It lets someone who eats out or orders pizza regularly track and rate every pizza they have, scoring crust, sauce, and toppings independently plus a separate overall "gut feel" taste score, tagging the pizza's style (Neapolitan, New York, Chicago deep dish, Detroit, and others, or a custom style), and attaching a photo and notes.

The target audience is everyday pizza enthusiasts who want an easy way to remember which restaurant, or frozen brand, is actually worth going back to, rather than relying on memory or scattered notes. Across dozens of pizza experiences over months or years, people lose track of which specific place, style, or order was actually good. Pizza Lover gives them one simple, private place to log, rate, and look back on that history, with light gamification (50 achievements) to make the habit more fun. It is a personal record, not a public review or social platform.

3. Setup and main feature instructions

No login or account creation is required. On first launch, the app opens directly to the My Rankings tab. Data syncs automatically through the user's already-signed-in iCloud account - there is no sign-up screen, no username or password, and no sample files or credentials are needed to evaluate any part of the app.

Main features:
- My Rankings (default tab): every pizza logged so far, with search and a quick stats summary. The snowflake icon in the toolbar logs a frozen pizza eaten at home.
- Nearby (second tab): searches for pizza restaurants near the device's current location using Apple Maps. The magnifying-glass icon in the toolbar searches for a restaurant by name anywhere, not just nearby, for logging a pizza eaten on a past trip.
- Tapping a restaurant opens its detail screen, where "I Ate Pizza Here" opens the rating form: crust, sauce, toppings, and overall-taste sliders, an optional style picker, an optional photo, optional notes, and a date picker that defaults to today and can be backdated.
- Random (third tab): picks a random restaurant from the user's favorites or untried places nearby.
- Settings (fourth tab): Achievements list, Privacy Policy and Support links, and a Reset All Data option.

Location access is requested only the first time Nearby or Random is opened, with an in-app explanation shown before the system permission prompt. If access is denied, those two tabs show a clear message with a link to Settings to re-enable it; My Rankings and Settings work fully without location access.

4. External services

Pizza Lover uses two services, both from Apple directly:
- Apple MapKit (MKLocalSearch), to find and display nearby or named pizza restaurants.
- Apple CloudKit (via SwiftData), to store and sync each user's own pizza entries, photos, and achievements privately across their own devices, tied to their existing iCloud account.

There are no third-party servers, analytics SDKs, advertising networks, AI or ML services, or payment processors. The app is entirely free with no in-app purchases.

5. Regional differences

The app functions consistently across all regions. There are no region-gated features, no region-specific content, and no pricing tiers, since the app is free everywhere. The only natural variation is that restaurant search results depend on how much map data Apple has indexed for a given area, which is a property of Apple's own Maps data coverage, not something this app controls or varies by design.

6. Regulated industry or protected material

Pizza Lover does not operate in a regulated industry - it is not a healthcare, financial, gambling, or alcohol-related app - and includes no protected third-party material. The pizza style names shown in the app (Neapolitan, New York, Chicago Deep Dish, Detroit, and others) are generic, widely-used descriptive terms for pizza-making styles, not trademarks, licensed brands, or protected intellectual property belonging to any third party.
```
