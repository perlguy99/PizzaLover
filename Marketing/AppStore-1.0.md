# App Store Release Kit — v1.0

Everything here is ready to paste into App Store Connect. Character counts are validated against Apple's limits. This is the first real App Store submission for this app - no App Store Connect record exists yet (see [[Pizza Lover]] in the vault), so this kit covers the full first-listing set.

---

## 1. App Information

| Field | Value |
|---|---|
| App Name | `Pizza Lover` |
| Subtitle | `Rate, Rank & Track Every Slice` |
| Bundle ID | `net.perlguy.Pizza-Lover` |
| SKU | `pizzalover-ios` |
| Primary Language | English (U.S.) |
| Primary Category | Food & Drink |
| Secondary Category | Lifestyle |
| Price | Free |
| Copyright | `© 2026 Brent Danger Michalski` |

## 2. Metadata (full text in the field-specific files alongside this one)

### Promotional Text — 142/170 ✅
```
Rate every pizza you eat - restaurant or frozen from home. Find nearby spots, let the app pick for you, and unlock 50 achievements. 100% free.
```

### Keywords — 94/100 ✅
```
restaurant,crust,sauce,toppings,log,tracker,nearby,foodie,reviews,journal,takeout,frozen,score
```

### Description — 1,412/4,000 ✅
```
Track every pizza you eat and finally remember which spot, or which frozen brand, actually deserves another visit.

RATE EVERY PIZZA, YOUR WAY
Score crust, sauce, and toppings independently, plus your own gut-feel overall taste score that's never just an average of the other three. Add a photo and notes so you remember exactly what you ordered.

FIND PIZZA NEARBY
Search for pizza places around you using Apple Maps, see distance and contact info at a glance, and favorite the ones worth going back to.

FROZEN PIZZA COUNTS TOO
Didn't make it out? Log a frozen pizza from home just as easily, same scoring, same rankings, with its own snowflake badge so you can tell it apart.

CAN'T DECIDE? PICK FOR ME
Not sure where to go tonight? Pull a random pick from your favorites, or from places you haven't tried yet, within whatever driving radius you set.

FIFTY WAYS TO HAVE FUN
Unlock achievements for volume, variety, perfect scores, honest low scores, photo streaks, late-night slices, and more, fifty in all, every one of them based on pizza you've actually logged.

YOUR DATA, YOUR DEVICES
Everything syncs automatically across your iPhone and iPad through your own iCloud account. No account to create, no login screen, it just works.

COMPLETELY FREE
No ads. No subscription. No in-app purchases. Just a free app for people who take their pizza seriously.

Questions or feedback: Brent.Michalski@gmail.com
```

## 3. URLs

- **Privacy Policy URL:** `https://perlguy99.github.io/PizzaLover/privacy.html`
- **Support URL:** `https://perlguy99.github.io/PizzaLover/support.html`
- **Marketing URL:** leave blank (optional, no landing page exists)

## 4. Age Rating & App Privacy

See `Age Rating.md` and `App Privacy (Data Collection).md` in this folder - both are multi-step questionnaires in App Store Connect, not single paste fields, so they're documented as answer keys rather than copy blocks. Short version: Age Rating → 4+ (answer None/No throughout); App Privacy → Location + User Content, both linked to the user's iCloud identity, both App Functionality only, no tracking, no third-party SDKs.

## 5. Not done yet

- No App Store Connect app record created for this bundle ID.
- Screenshots not produced - need a fresh set from the simulator or a real device covering My Rankings (with a few entries logged), the pizza entry form, Nearby, Random, and Achievements.
- No app preview video - optional, worth considering once screenshots exist.
- The in-app IAP product Brent may have considered earlier was removed with the paywall (2026-11-02) - no IAP setup needed in App Store Connect for this app.

## 6. Release Checklist

- [x] Version confirmed as **1.0**, build **1** (`MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` in the Xcode project)
- [ ] Create the App Store Connect app record for this bundle ID
- [ ] Paste in App Name, Subtitle, Keywords, Promotional Text, Description from above
- [ ] Set Category (Food & Drink / Lifestyle), Copyright, SKU
- [ ] Paste in Privacy Policy URL and Support URL
- [ ] Complete the Age Rating questionnaire (see `Age Rating.md`)
- [ ] Complete the App Privacy questionnaire (see `App Privacy (Data Collection).md`)
- [ ] Produce and upload screenshots
- [ ] Archive and upload a build via Xcode
- [ ] Submit for review
- [ ] Tag the release: `git tag v1.0 && git push --tags`
