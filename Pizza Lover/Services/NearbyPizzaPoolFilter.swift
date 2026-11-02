//
//  NearbyPizzaPoolFilter.swift
//  Pizza Lover
//

import Foundation
import MapKit

enum RandomPizzaMode: String, CaseIterable, Identifiable {
    case favorites = "Favorites"
    case untried = "Haven't Tried"

    var id: String { rawValue }
}

/// Pure filter layered on top of a live nearby-search result list: narrows the
/// mile-radius search results down to ones that match an already-saved
/// favorited/untried `Restaurant`, without mutating anything or touching SwiftData.
enum NearbyPizzaPoolFilter {
    static func pool(from items: [MKMapItem], mode: RandomPizzaMode, savedRestaurants: [Restaurant]) -> [MKMapItem] {
        items.filter { item in
            let existing = matchingRestaurant(for: item, in: savedRestaurants)
            if existing?.isExcluded == true { return false }
            switch mode {
            case .favorites:
                return existing?.isFavorite == true
            case .untried:
                // Never-saved places haven't been tried either, so they count as untried.
                return existing == nil || existing?.isTried == false
            }
        }
    }

    static func matchingRestaurant(for item: MKMapItem, in savedRestaurants: [Restaurant]) -> Restaurant? {
        let coordinate = item.placemark.coordinate
        let name = item.name ?? "Unknown Pizza Place"
        return savedRestaurants.first {
            $0.name == name && $0.latitude == coordinate.latitude && $0.longitude == coordinate.longitude
        }
    }
}
