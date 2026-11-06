# App Privacy (Data Collection questionnaire)

This is App Store Connect's separate "App Privacy" nutrition-label questionnaire, distinct from the Privacy Policy URL field - also a form to fill in, not a single paste field. Based on what Pizza Lover's code actually does (confirmed against the app, not guessed):

**Data types collected:**
- **Location** - used live for the Nearby and Random Pizza MapKit searches. Not stored on any server Brent controls (no backend exists at all). Purpose: **App Functionality**. Linked to the user's identity via their iCloud account: **Yes**. Used for tracking (per Apple's definition - linking to data from other companies' apps/sites, or sharing with a data broker): **No**.
- **User Content** (photos a user attaches to a pizza entry, plus notes/scores they type) - stored only in the user's own private CloudKit database, never sent anywhere else. Purpose: **App Functionality**. Linked to identity: **Yes** (it's their iCloud data). Used for tracking: **No**.

**Data NOT collected:** no analytics SDK, no ad network, no contact info, no browsing history, no identifiers beyond what CloudKit itself requires to sync to the right account, no purchase history (app is free, no IAP).

**"Data Used to Track You" section: answer None.** Pizza Lover has no third-party SDKs and does no cross-app/cross-site tracking of any kind.

Everything above should already match what's in the live Privacy Policy page (`privacy.html`) - if either ever changes, update both together so they can't drift out of sync.
