//
//  AchievementsView.swift
//  Pizza Lover
//

import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Query private var earnedAchievements: [Achievement]

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(AchievementDefinition.all) { definition in
                    AchievementCard(definition: definition, earnedDate: earnedDate(for: definition))
                }
            }
            .padding()
        }
        .navigationTitle("Achievements")
    }

    private func earnedDate(for definition: AchievementDefinition) -> Date? {
        earnedAchievements.first { $0.id == definition.id }?.dateEarned
    }
}

private struct AchievementCard: View {
    let definition: AchievementDefinition
    let earnedDate: Date?

    private var isEarned: Bool { earnedDate != nil }

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: definition.iconName)
                .font(.largeTitle)
                .foregroundStyle(isEarned ? .yellow : .secondary)

            Text(definition.title)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(definition.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text(earnedDate.map { "Earned \($0.formatted(date: .abbreviated, time: .omitted))" } ?? "Locked")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
        .opacity(isEarned ? 1 : 0.5)
        .saturation(isEarned ? 1 : 0)
    }
}

#Preview {
    NavigationStack {
        AchievementsView()
    }
    .modelContainer(for: [Restaurant.self, PizzaEntry.self, Achievement.self], inMemory: true)
}
