//
//  StoreManager.swift
//  Pizza Lover
//

import StoreKit

/// Manages the one-time unlock IAP using StoreKit 2.
///
/// Inject into the view hierarchy via `.environment(storeManager)` and
/// read from any view with `@Environment(StoreManager.self)`.
///
/// Product ID: `com.perlguy.pizzalover.unlimited`
@MainActor
@Observable
final class StoreManager {

    static let productID = "com.perlguy.pizzalover.unlimited"

    /// The StoreKit product, loaded on init. Nil if the store is temporarily unavailable.
    private(set) var product: Product?

    /// StoreKit-verified unlock state. Use `isUnlocked` for all gating checks.
    private(set) var purchaseUnlocked = false

#if DEBUG
    /// Developer override — bypasses IAP without a real purchase.
    /// Only exists in debug builds; stripped from release.
    /// Toggle in Settings → Developer.
    var debugUnlockOverride = false
#endif

    /// Whether the user has unlimited pizza entries.
    /// In debug builds, returns `true` if either a real purchase exists
    /// or `debugUnlockOverride` is on.
    var isUnlocked: Bool {
#if DEBUG
        if debugUnlockOverride { return true }
#endif
        return purchaseUnlocked
    }

    /// True once the initial StoreKit entitlement check has completed.
    /// Use this to avoid acting on `isUnlocked` before the first async check finishes.
    private(set) var isReady = false

    /// True while a purchase network request is in flight.
    private(set) var isPurchasing = false

    /// True while a restore-purchases request is in flight.
    private(set) var isRestoring = false

    /// Human-readable error from the last failed purchase or restore attempt.
    private(set) var purchaseError: String?

    /// Formatted price string from the loaded product, e.g. "$0.99".
    var displayPrice: String? { product?.displayPrice }

    // Persistent task that listens for server-side transaction updates
    // (e.g. Family Sharing grants, Ask to Buy approvals, refunds).
    // weak self prevents a retain cycle; StoreManager lives for the app's full
    // lifetime (held by @State in Pizza_LoverApp) so explicit cancellation
    // in deinit is not required.
    private var listenerTask: Task<Void, Never>?

    init() {
        // Start transaction listener before any other async work so no
        // updates are missed during the product load / entitlement check.
        listenerTask = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(result)
            }
        }
        Task { await loadProduct() }
        Task { await checkCurrentEntitlements() }
    }

    // MARK: - Public Actions

    /// Initiates a purchase flow for the unlock product.
    func purchase() async {
        guard let product else { return }
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                await handle(verification)
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    /// Re-checks current entitlements with the App Store.
    ///
    /// Call whenever the scene becomes active so that promo code redemptions,
    /// Family Sharing grants, and refunds that occurred while the app was
    /// backgrounded or closed are reflected immediately.
    func refreshEntitlements() async {
        await checkCurrentEntitlements()
    }

    /// Clears any lingering purchase error message.
    /// Call from a paywall's `onAppear` so stale errors from a previous
    /// presentation don't show on re-open.
    func clearError() {
        purchaseError = nil
    }

    /// Syncs the App Store receipt and re-checks entitlements.
    /// Used for the "Restore Purchases" flow.
    func restorePurchases() async {
        purchaseError = nil
        isRestoring = true
        defer { isRestoring = false }
        do {
            try await AppStore.sync()
            await checkCurrentEntitlements()
            if !purchaseUnlocked {
                purchaseError = "No previous purchases found for this Apple ID."
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    // MARK: - Private

    private func loadProduct() async {
        product = try? await Product.products(for: [Self.productID]).first
    }

    /// Walks the current entitlements sequence and sets purchaseUnlocked if a
    /// valid, unrevoked transaction is found.
    ///
    /// Falls back to Transaction.all when currentEntitlements finds nothing.
    /// Offer code (promo code) redemptions are not always returned by
    /// currentEntitlements — scanning full history catches those cases.
    private func checkCurrentEntitlements() async {
        var unlocked = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                unlocked = true
            }
        }

        if !unlocked {
            for await result in Transaction.all {
                if case .verified(let transaction) = result,
                   transaction.productID == Self.productID,
                   transaction.revocationDate == nil {
                    unlocked = true
                    break
                }
            }
        }

        purchaseUnlocked = unlocked

        if !isReady { isReady = true }
    }

    /// Processes a single verified (or unverified) transaction result.
    private func handle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        if transaction.productID == Self.productID {
            // A nil revocationDate means the purchase is still active.
            purchaseUnlocked = transaction.revocationDate == nil
        }
        await transaction.finish()
    }
}
