//
//  AchievementDefinition.swift
//  Pizza Lover
//

import Foundation

struct AchievementDefinition: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let iconName: String

    // 50 total. The original 4 are untouched; the other 46 (added 2026-11-06)
    // were scoped specifically to data the app already collects - scores,
    // dates, notes, photos, restaurant favorite/frozen/excluded flags - no
    // achievement here depends on anything not already tracked.
    static let all: [AchievementDefinition] = [
        // Original 4
        AchievementDefinition(id: "first-slice", title: "First Slice", description: "Log your first pizza.", iconName: "star.fill"),
        AchievementDefinition(id: "five-spots", title: "Five Spots", description: "Log a pizza at 5 different restaurants.", iconName: "map.fill"),
        AchievementDefinition(id: "perfect-crust", title: "Perfect Crust", description: "Give a pizza a 10/10 crust score.", iconName: "flame.fill"),
        AchievementDefinition(id: "dedicated", title: "Dedicated", description: "Log 10 total pizzas.", iconName: "trophy.fill"),

        // Volume milestones
        AchievementDefinition(id: "quarter-century", title: "Quarter Century", description: "Log 25 total pizzas.", iconName: "sparkles"),
        AchievementDefinition(id: "half-century", title: "Half Century", description: "Log 50 total pizzas.", iconName: "crown.fill"),
        AchievementDefinition(id: "centurion", title: "Centurion", description: "Log 100 total pizzas.", iconName: "shield.fill"),
        AchievementDefinition(id: "two-hundred-club", title: "200 Club", description: "Log 200 total pizzas.", iconName: "flag.checkered"),

        // Restaurant variety
        AchievementDefinition(id: "ten-spots", title: "Ten Spots", description: "Log a pizza at 10 different restaurants.", iconName: "map.fill"),
        AchievementDefinition(id: "twenty-spots", title: "Twenty Spots", description: "Log a pizza at 20 different restaurants.", iconName: "globe.americas.fill"),
        AchievementDefinition(id: "pizza-tourist", title: "Pizza Tourist", description: "Log a pizza at 50 different restaurants.", iconName: "airplane"),

        // Score perfection
        AchievementDefinition(id: "perfect-sauce", title: "Saucy", description: "Give a pizza a 10/10 sauce score.", iconName: "drop.fill"),
        AchievementDefinition(id: "perfect-toppings", title: "Loaded", description: "Give a pizza a 10/10 toppings score.", iconName: "leaf.fill"),
        AchievementDefinition(id: "perfect-overall", title: "Two Thumbs Up", description: "Give a pizza a 10/10 overall taste score.", iconName: "hand.thumbsup.fill"),
        AchievementDefinition(id: "perfect-pizza", title: "Perfect Pizza", description: "Score a single pizza 10/10 in every category.", iconName: "star.circle.fill"),
        AchievementDefinition(id: "five-perfects", title: "High Standards", description: "Give 5 different pizzas a 10/10 overall score.", iconName: "star.fill"),
        AchievementDefinition(id: "ten-perfects", title: "Impossible to Please (Except By Pizza)", description: "Give 10 different pizzas a 10/10 overall score.", iconName: "rosette"),

        // Low scores / humor
        AchievementDefinition(id: "rock-bottom", title: "Rock Bottom", description: "Give any score a 1/10.", iconName: "hand.thumbsdown.fill"),
        AchievementDefinition(id: "tough-crowd", title: "Tough Crowd", description: "Score a single pizza 1/10 in every category.", iconName: "xmark.seal.fill"),
        AchievementDefinition(id: "brutally-honest", title: "Brutally Honest", description: "Give 5 pizzas an overall score of 3 or lower.", iconName: "text.bubble.fill"),
        AchievementDefinition(id: "send-it-back", title: "Send It Back", description: "Give a pizza a 1/10 crust score.", iconName: "exclamationmark.triangle.fill"),

        // Score patterns
        AchievementDefinition(id: "right-down-the-middle", title: "Right Down the Middle", description: "Score a pizza exactly 5/10 in every category.", iconName: "equal.circle.fill"),
        AchievementDefinition(id: "in-agreement", title: "In Agreement", description: "Give a pizza the exact same score in all 4 categories.", iconName: "checkmark.circle.fill"),
        AchievementDefinition(id: "gut-over-grade", title: "Gut Over Grade", description: "Let your overall score differ wildly from your crust/sauce/toppings average.", iconName: "bolt.heart.fill"),

        // Frozen pizza
        AchievementDefinition(id: "freezer-burn", title: "Freezer Burn", description: "Log your first frozen pizza.", iconName: "snowflake"),
        AchievementDefinition(id: "home-chef", title: "Home Chef", description: "Log 5 frozen pizzas.", iconName: "house.fill"),
        AchievementDefinition(id: "frozen-fanatic", title: "Frozen Fanatic", description: "Log 10 frozen pizzas.", iconName: "snowflake.circle.fill"),
        AchievementDefinition(id: "brand-loyal", title: "Brand Loyal (to Several Brands)", description: "Log pizzas from 3 different frozen brands.", iconName: "tag.fill"),
        AchievementDefinition(id: "best-of-both", title: "Best of Both Worlds", description: "Log both a frozen pizza and a restaurant pizza.", iconName: "arrow.triangle.2.circlepath"),

        // Favorites
        AchievementDefinition(id: "first-favorite", title: "First Favorite", description: "Mark a restaurant as a favorite.", iconName: "heart.fill"),
        AchievementDefinition(id: "five-favorites", title: "Favorites List", description: "Mark 5 restaurants as favorites.", iconName: "heart.circle.fill"),
        AchievementDefinition(id: "ten-favorites", title: "VIP List", description: "Mark 10 restaurants as favorites.", iconName: "person.2.fill"),

        // Photos
        AchievementDefinition(id: "say-cheese", title: "Say Cheese", description: "Log a pizza with a photo.", iconName: "camera.fill"),
        AchievementDefinition(id: "photo-journal", title: "Photo Journal", description: "Log 10 pizzas with photos.", iconName: "photo.fill"),
        AchievementDefinition(id: "shutterbug", title: "Shutterbug", description: "Log 25 pizzas with photos.", iconName: "photo.stack.fill"),

        // Notes
        AchievementDefinition(id: "food-critic", title: "Food Critic", description: "Add notes to a pizza entry.", iconName: "pencil"),
        AchievementDefinition(id: "novelist", title: "Novelist", description: "Write a note that's 100 characters or longer.", iconName: "book.fill"),
        AchievementDefinition(id: "man-of-many-words", title: "Man of Many Words", description: "Add notes to 10 pizza entries.", iconName: "books.vertical.fill"),

        // Streaks
        AchievementDefinition(id: "back-to-back", title: "Back to Back", description: "Log pizzas on 2 days in a row.", iconName: "calendar"),
        AchievementDefinition(id: "three-peat", title: "Three-Peat", description: "Log pizzas on 3 days in a row.", iconName: "calendar.badge.clock"),
        AchievementDefinition(id: "pizza-week", title: "Pizza Week", description: "Log pizzas on 7 days in a row.", iconName: "calendar.circle.fill"),
        AchievementDefinition(id: "triple-threat", title: "Triple Threat", description: "Log 3 pizzas in a single day.", iconName: "bolt.fill"),

        // Day-of-week / calendar
        AchievementDefinition(id: "weekend-warrior", title: "Weekend Warrior", description: "Log a pizza on both a Saturday and a Sunday.", iconName: "sun.max.fill"),
        AchievementDefinition(id: "monday-blues", title: "Monday Blues", description: "Log a pizza on a Monday.", iconName: "cloud.rain.fill"),
        AchievementDefinition(id: "all-week-long", title: "All Week Long", description: "Log a pizza on every day of the week.", iconName: "infinity.circle.fill"),
        AchievementDefinition(id: "new-year-slice", title: "New Year Slice", description: "Log a pizza on January 1st.", iconName: "party.popper.fill"),
        AchievementDefinition(id: "year-rounder", title: "Year-Rounder", description: "Log a pizza in every month of the year.", iconName: "calendar"),

        // Time of day
        AchievementDefinition(id: "early-bird", title: "Early Bird", description: "Log a pizza before 11am.", iconName: "sunrise.fill"),
        AchievementDefinition(id: "night-owl", title: "Night Owl", description: "Log a pizza after 10pm.", iconName: "moon.stars.fill"),
        AchievementDefinition(id: "midnight-snack", title: "Midnight Snack", description: "Log a pizza between midnight and 4am.", iconName: "moon.fill"),
    ]
}
