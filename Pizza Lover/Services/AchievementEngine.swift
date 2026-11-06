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
    /// several rules (e.g. "dedicated", "five-spots") depend on the full history. `restaurants`
    /// is passed separately (not derived from entries) because favorite/excluded status can be
    /// set on a restaurant before any pizza is ever logged there (e.g. favoriting straight from
    /// the Nearby list) — deriving it from entries alone would miss that.
    ///
    /// Returns the definitions that became newly earned on *this* call (empty if none did),
    /// so a caller can show an in-the-moment "achievement unlocked" banner.
    @discardableResult
    static func evaluate(entries: [PizzaEntry], restaurants: [Restaurant], context: ModelContext) -> [AchievementDefinition] {
        var newlyEarned: [AchievementDefinition] = []
        for definition in AchievementDefinition.all where isEarned(definition, entries: entries, restaurants: restaurants) {
            if award(definition.id, context: context) {
                newlyEarned.append(definition)
            }
        }
        try? context.save()
        return newlyEarned
    }

    private static func isEarned(_ definition: AchievementDefinition, entries: [PizzaEntry], restaurants: [Restaurant]) -> Bool {
        let calendar = Calendar.current

        switch definition.id {
        // Original 4
        case "first-slice":
            return !entries.isEmpty
        case "five-spots":
            return distinctRestaurantNames(entries).count >= 5
        case "perfect-crust":
            return entries.contains { $0.crustScore == 10 }
        case "dedicated":
            return entries.count >= 10

        // Volume milestones
        case "quarter-century":
            return entries.count >= 25
        case "half-century":
            return entries.count >= 50
        case "centurion":
            return entries.count >= 100
        case "two-hundred-club":
            return entries.count >= 200

        // Restaurant variety
        case "ten-spots":
            return distinctRestaurantNames(entries).count >= 10
        case "twenty-spots":
            return distinctRestaurantNames(entries).count >= 20
        case "pizza-tourist":
            return distinctRestaurantNames(entries).count >= 50

        // Score perfection
        case "perfect-sauce":
            return entries.contains { $0.sauceScore == 10 }
        case "perfect-toppings":
            return entries.contains { $0.toppingsScore == 10 }
        case "perfect-overall":
            return entries.contains { $0.overallTasteScore == 10 }
        case "perfect-pizza":
            return entries.contains {
                $0.crustScore == 10 && $0.sauceScore == 10 && $0.toppingsScore == 10 && $0.overallTasteScore == 10
            }
        case "five-perfects":
            return entries.filter { $0.overallTasteScore == 10 }.count >= 5
        case "ten-perfects":
            return entries.filter { $0.overallTasteScore == 10 }.count >= 10

        // Low scores / humor
        case "rock-bottom":
            return entries.contains { $0.crustScore == 1 || $0.sauceScore == 1 || $0.toppingsScore == 1 || $0.overallTasteScore == 1 }
        case "tough-crowd":
            return entries.contains {
                $0.crustScore == 1 && $0.sauceScore == 1 && $0.toppingsScore == 1 && $0.overallTasteScore == 1
            }
        case "brutally-honest":
            return entries.filter { $0.overallTasteScore <= 3 }.count >= 5
        case "send-it-back":
            return entries.contains { $0.crustScore == 1 }

        // Score patterns
        case "right-down-the-middle":
            return entries.contains {
                $0.crustScore == 5 && $0.sauceScore == 5 && $0.toppingsScore == 5 && $0.overallTasteScore == 5
            }
        case "in-agreement":
            return entries.contains {
                $0.crustScore == $0.sauceScore && $0.sauceScore == $0.toppingsScore && $0.toppingsScore == $0.overallTasteScore
            }
        case "gut-over-grade":
            return entries.contains {
                let average = Double($0.crustScore + $0.sauceScore + $0.toppingsScore) / 3.0
                return abs(Double($0.overallTasteScore) - average) >= 5.0
            }

        // Frozen pizza
        case "freezer-burn":
            return entries.contains { $0.restaurant?.isFrozen == true }
        case "home-chef":
            return entries.filter { $0.restaurant?.isFrozen == true }.count >= 5
        case "frozen-fanatic":
            return entries.filter { $0.restaurant?.isFrozen == true }.count >= 10
        case "brand-loyal":
            let frozenBrands = Set(entries.filter { $0.restaurant?.isFrozen == true }.compactMap { $0.restaurant?.name })
            return frozenBrands.count >= 3
        case "best-of-both":
            return entries.contains { $0.restaurant?.isFrozen == true } && entries.contains { $0.restaurant?.isFrozen == false }

        // Favorites (restaurant-level, not entry-level — see evaluate() doc comment)
        case "first-favorite":
            return restaurants.contains { $0.isFavorite }
        case "five-favorites":
            return restaurants.filter { $0.isFavorite }.count >= 5
        case "ten-favorites":
            return restaurants.filter { $0.isFavorite }.count >= 10

        // Photos
        case "say-cheese":
            return entries.contains { $0.photoData != nil }
        case "photo-journal":
            return entries.filter { $0.photoData != nil }.count >= 10
        case "shutterbug":
            return entries.filter { $0.photoData != nil }.count >= 25

        // Notes
        case "food-critic":
            return entries.contains { !($0.notes?.isEmpty ?? true) }
        case "novelist":
            return entries.contains { ($0.notes?.count ?? 0) >= 100 }
        case "man-of-many-words":
            return entries.filter { !($0.notes?.isEmpty ?? true) }.count >= 10

        // Streaks
        case "back-to-back":
            return longestConsecutiveDayStreak(entries, calendar: calendar) >= 2
        case "three-peat":
            return longestConsecutiveDayStreak(entries, calendar: calendar) >= 3
        case "pizza-week":
            return longestConsecutiveDayStreak(entries, calendar: calendar) >= 7
        case "triple-threat":
            return maxEntriesInSingleDay(entries, calendar: calendar) >= 3

        // Day-of-week / calendar
        case "weekend-warrior":
            let weekdays = Set(entries.map { calendar.component(.weekday, from: $0.date) })
            return weekdays.contains(7) && weekdays.contains(1) // Saturday=7, Sunday=1 (Gregorian)
        case "monday-blues":
            return entries.contains { calendar.component(.weekday, from: $0.date) == 2 }
        case "all-week-long":
            return Set(entries.map { calendar.component(.weekday, from: $0.date) }).count == 7
        case "new-year-slice":
            return entries.contains {
                let c = calendar.dateComponents([.month, .day], from: $0.date)
                return c.month == 1 && c.day == 1
            }
        case "year-rounder":
            return Set(entries.map { calendar.component(.month, from: $0.date) }).count == 12

        // Time of day
        case "early-bird":
            return entries.contains { calendar.component(.hour, from: $0.date) < 11 }
        case "night-owl":
            return entries.contains { calendar.component(.hour, from: $0.date) >= 22 }
        case "midnight-snack":
            return entries.contains {
                let hour = calendar.component(.hour, from: $0.date)
                return hour >= 0 && hour < 4
            }

        default:
            return false
        }
    }

    private static func distinctRestaurantNames(_ entries: [PizzaEntry]) -> Set<String> {
        Set(entries.compactMap { $0.restaurant?.name })
    }

    /// Longest run of consecutive calendar days (not necessarily just one entry per day)
    /// that have at least one logged pizza.
    private static func longestConsecutiveDayStreak(_ entries: [PizzaEntry], calendar: Calendar) -> Int {
        let days = Set(entries.map { calendar.startOfDay(for: $0.date) }).sorted()
        guard !days.isEmpty else { return 0 }

        var longest = 1
        var current = 1
        for i in 1..<days.count {
            if calendar.dateComponents([.day], from: days[i - 1], to: days[i]).day == 1 {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }

    private static func maxEntriesInSingleDay(_ entries: [PizzaEntry], calendar: Calendar) -> Int {
        let grouped = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
        return grouped.values.map(\.count).max() ?? 0
    }

    /// Inserts the `Achievement` record if it isn't already earned. Returns whether this
    /// call was the one that newly earned it (false if it was already earned before).
    @discardableResult
    private static func award(_ id: String, context: ModelContext) -> Bool {
        let predicate = #Predicate<Achievement> { $0.id == id }
        let alreadyEarned = (try? context.fetch(FetchDescriptor(predicate: predicate)))?.isEmpty == false
        guard !alreadyEarned else { return false }

        let achievement = Achievement()
        achievement.id = id
        context.insert(achievement)
        return true
    }
}
