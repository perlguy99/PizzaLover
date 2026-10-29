//
//  AchievementEngine.swift
//  Pizza Lover
//

import Foundation
import SwiftData

enum AchievementEngine {
    /// Evaluates every `AchievementDefinition` against the current data and inserts an
    /// `Achievement` record for any that just became earned. Safe to call repeatedly —
    /// already-earned achievements are skipped (no unique constraint exists since CloudKit
    /// forbids one, so this duplicate check is done manually).
    ///
    /// Call this after any save that might newly unlock an achievement, passing every
    /// `PizzaEntry` currently in the store (not just the one that was just saved), since
    /// several rules (e.g. "dedicated", "five-spots") depend on the full history.
    static func evaluate(entries: [PizzaEntry], context: ModelContext) {
        for definition in AchievementDefinition.all where isEarned(definition, entries: entries) {
            award(definition.id, context: context)
        }
        try? context.save()
    }

    private static func isEarned(_ definition: AchievementDefinition, entries: [PizzaEntry]) -> Bool {
        switch definition.id {
        case "first-slice":
            return !entries.isEmpty
        case "five-spots":
            let distinctRestaurantNames = Set(entries.compactMap { $0.restaurant?.name })
            return distinctRestaurantNames.count >= 5
        case "perfect-crust":
            return entries.contains { $0.crustScore == 10 }
        case "dedicated":
            return entries.count >= 10
        default:
            return false
        }
    }

    private static func award(_ id: String, context: ModelContext) {
        let predicate = #Predicate<Achievement> { $0.id == id }
        let alreadyEarned = (try? context.fetch(FetchDescriptor(predicate: predicate)))?.isEmpty == false
        guard !alreadyEarned else { return }

        let achievement = Achievement()
        achievement.id = id
        context.insert(achievement)
    }
}
