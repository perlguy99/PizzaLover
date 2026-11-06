//
//  SettingsView.swift
//  Pizza Lover
//

import SwiftUI
import SwiftData

private struct DeveloperApp: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let appStoreURL: URL
    /// Asset catalog name - real App Store icon artwork, pulled from the
    /// iTunes Lookup API and bundled directly rather than fetched at
    /// runtime, same as how these apps' names/links were sourced.
    let iconAssetName: String
}

private let otherApps: [DeveloperApp] = [
    DeveloperApp(
        name: "Photo Jigsaw: Personal Puzzles",
        subtitle: "Turn your own photos into jigsaw puzzles",
        appStoreURL: URL(string: "https://apps.apple.com/us/app/photo-jigsaw-personal-puzzles/id6771174544")!,
        iconAssetName: "PhotoJigsawIcon"
    ),
    DeveloperApp(
        name: "Mindless Jigsaw: Calm Puzzles",
        subtitle: "Calm, ad-free jigsaw puzzles",
        appStoreURL: URL(string: "https://apps.apple.com/us/app/mindless-jigsaw-calm-puzzles/id6763145102")!,
        iconAssetName: "MindlessJigsawIcon"
    ),
    DeveloperApp(
        name: "Trio: Pattern Match Puzzle",
        subtitle: "A fast pattern-matching puzzle game",
        appStoreURL: URL(string: "https://apps.apple.com/us/app/trio-pattern-match-puzzle/id6806417325")!,
        iconAssetName: "TrioIcon"
    ),
]

/// Minimal settings screen. The app has no account system and almost nothing
/// to configure beyond a cross-promo list of the developer's other apps.
struct SettingsView: View {
    var body: some View {
        Form {
            Section {
                NavigationLink {
                    AchievementsView()
                } label: {
                    Label("Achievements", systemImage: "trophy.fill")
                }
            }

            Section {
                ForEach(otherApps) { app in
                    Link(destination: app.appStoreURL) {
                        HStack(spacing: 12) {
                            Image(app.iconAssetName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.name)
                                    .foregroundStyle(.primary)
                                Text(app.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } header: {
                Text("More Apps")
            } footer: {
                Text("If you like Pizza Lover, a rating or a look at my other apps helps a lot. Thanks for the support!")
            }

            Section {
                Link(destination: URL(string: "https://perlguy99.github.io/PizzaLover/privacy.html")!) {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                }
                Link(destination: URL(string: "https://perlguy99.github.io/PizzaLover/support.html")!) {
                    Label("Support", systemImage: "questionmark.circle.fill")
                }
            }

            Section {
                Text("Copyright © 2026, Brent Danger Michalski")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [Restaurant.self, PizzaEntry.self, Achievement.self], inMemory: true)
}
