//
//  PaywallView.swift
//  Pizza Lover
//

import SwiftUI

/// Full-screen paywall shown when the player hits the free-tier gate.
///
/// Gate: reaching the 3-entry free-tier cap (`PizzaEntryGate.freeTierCap`) in
/// `PizzaEntryFormView`.
///
/// Displays product price (live from StoreKit), feature list, buy button,
/// and a restore link. Dismisses itself when `StoreManager.isUnlocked` becomes true.
struct PaywallView: View {

    @Environment(StoreManager.self) private var store
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)

                VStack(spacing: 8) {
                    Text("Unlock Pizza Lover")
                        .font(.title2)
                        .bold()
                        .accessibilityAddTraits(.isHeader)

                    // Prominent one-time purchase callout
                    Text("One-time purchase · Unlimited pizza entries · Never any ads!")
                        .font(.subheadline)
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.accentColor, in: .capsule)
                }

                featureList
                    .padding(.horizontal)

                Spacer()

                actionArea
                    .padding(.bottom)
            }
            .padding()
            .frame(maxWidth: 400)
        }
        .onAppear { store.clearError() }
    }
}

// MARK: - Feature List

private extension PaywallView {
    var featureList: some View {
        VStack(alignment: .leading, spacing: 12) {
            FeatureRow(icon: "infinity",          text: "Unlimited pizza entries")
            FeatureRow(icon: "xmark.circle.fill",  text: "No ads, ever")
            FeatureRow(icon: "checkmark.seal.fill", text: "One-time purchase, yours forever")
        }
    }
}

// MARK: - Action Area

private extension PaywallView {
    var actionArea: some View {
        VStack(spacing: 12) {
            if store.isPurchasing {
                ProgressView()
                    .controlSize(.large)
                    .accessibilityLabel("Processing purchase")
            } else {
                Button {
                    Task { await store.purchase() }
                } label: {
                    Text(buyLabel)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(store.product == nil)
            }

            if let error = store.purchaseError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            if store.isRestoring {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Restoring…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
            } else {
                Button("Restore Purchases") {
                    Task { await store.restorePurchases() }
                }
                .font(.subheadline)
                .disabled(store.isPurchasing)
            }

            Button("Not Now", action: onDismiss)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    var buyLabel: String {
        store.displayPrice.map { "Unlock for \($0)" } ?? "Unlock — $0.99"
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .frame(width: 24, alignment: .center)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            Text(text)
        }
    }
}

// MARK: - Preview

#Preview {
    PaywallView { }
        .environment(StoreManager())
}
