//
//  SettingsView.swift
//  Pizza Lover
//

import SwiftUI

private struct DeveloperApp: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let appStoreURL: URL
}

private let otherApps: [DeveloperApp] = [
    DeveloperApp(
        name: "Photo Jigsaw: Personal Puzzles",
        subtitle: "Turn your own photos into jigsaw puzzles",
        appStoreURL: URL(string: "https://apps.apple.com/us/app/photo-jigsaw-personal-puzzles/id6771174544")!
    ),
    DeveloperApp(
        name: "Mindless Jigsaw: Calm Puzzles",
        subtitle: "Calm, ad-free jigsaw puzzles",
        appStoreURL: URL(string: "https://apps.apple.com/us/app/mindless-jigsaw-calm-puzzles/id6763145102")!
    ),
    DeveloperApp(
        name: "Trio: Pattern Match Puzzle",
        subtitle: "A fast pattern-matching puzzle game",
        appStoreURL: URL(string: "https://apps.apple.com/us/app/trio-pattern-match-puzzle/id6806417325")!
    ),
]

/// Minimal settings screen. The app has no account system and almost nothing
/// to configure beyond a cross-promo list of the developer's other apps.
struct SettingsView: View {
    var body: some View {
        Form {
            Section {
                ForEach(otherApps) { app in
                    Link(destination: app.appStoreURL) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(app.name)
                                .foregroundStyle(.primary)
                            Text(app.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("More Apps")
            } footer: {
                Text("If you like Pizza Lover, a rating or a look at my other apps helps a lot. Thanks for the support!")
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
