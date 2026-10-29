//
//  AchievementDefinition.swift
//  Pizza Lover
//

import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(id: "first-slice", title: "First Slice", description: "Log your first pizza.", iconName: "star.fill"),
        AchievementDefinition(id: "five-spots", title: "Five Spots", description: "Log a pizza at 5 different restaurants.", iconName: "map.fill"),
        AchievementDefinition(id: "perfect-crust", title: "Perfect Crust", description: "Give a pizza a 10/10 crust score.", iconName: "flame.fill"),
        AchievementDefinition(id: "dedicated", title: "Dedicated", description: "Log 10 total pizzas.", iconName: "trophy.fill")
    ]
}
