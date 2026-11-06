//
//  AchievementUnlockedBanner.swift
//  Pizza Lover
//

import SwiftUI

/// Transient "Achievement Unlocked" banner shown over `PizzaEntryFormView` right after
/// a save newly earns one or more achievements - without this, the only way to ever
/// notice an achievement was earned was to happen to open Settings > Achievements and
/// spot something no longer grayed out.
struct AchievementUnlockedBanner: View {
    let definitions: [AchievementDefinition]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(definitions) { definition in
                HStack(spacing: 12) {
                    Image(systemName: definition.iconName)
                        .font(.title2)
                        .foregroundStyle(.yellow)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Achievement Unlocked!")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Text(definition.title)
                            .font(.subheadline.bold())
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                .shadow(radius: 6, y: 2)
            }
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    AchievementUnlockedBanner(definitions: [
        AchievementDefinition(id: "first-slice", title: "First Slice", description: "Log your first pizza.", iconName: "star.fill")
    ])
}
