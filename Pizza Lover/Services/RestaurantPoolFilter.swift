//
//  RestaurantPoolFilter.swift
//  Pizza Lover
//

import Foundation

enum RandomPizzaMode: Hashable {
    case favorites
    case untried
}

enum RestaurantPoolFilter {
    static func pool(from restaurants: [Restaurant], mode: RandomPizzaMode) -> [Restaurant] {
        switch mode {
        case .favorites: return restaurants.filter { $0.isFavorite }
        case .untried: return restaurants.filter { !$0.isTried }
        }
    }
}
