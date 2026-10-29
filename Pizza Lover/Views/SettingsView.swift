//
//  SettingsView.swift
//  Pizza Lover
//

import SwiftUI

/// Minimal settings screen. The app has no account system and almost nothing
/// to configure — this exists mainly to give "Restore Purchases" a permanent,
/// reachable home outside the paywall itself.
struct SettingsView: View {
    @Environment(StoreManager.self) private var store

    var body: some View {
        Form {
            Section {
                if store.isRestoring {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Restoring…")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Button("Restore Purchases") {
                        Task { await store.restorePurchases() }
                    }
                    .disabled(store.isPurchasing)
                }

                if let error = store.purchaseError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            } footer: {
                Text("Already bought Pizza Lover Unlimited on another device? Restore it here with the same Apple ID.")
            }

#if DEBUG
            Section("Developer") {
                Toggle("Debug Unlock Override", isOn: debugUnlockBinding)
            }
#endif
        }
        .navigationTitle("Settings")
        .onAppear { store.clearError() }
    }

#if DEBUG
    private var debugUnlockBinding: Binding<Bool> {
        Binding(
            get: { store.debugUnlockOverride },
            set: { store.debugUnlockOverride = $0 }
        )
    }
#endif
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(StoreManager())
}
