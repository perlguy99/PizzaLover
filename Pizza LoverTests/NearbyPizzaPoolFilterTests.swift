//
//  NearbyPizzaPoolFilterTests.swift
//  Pizza LoverTests
//

import Testing
import MapKit
@testable import Pizza_Lover

struct NearbyPizzaPoolFilterTests {
    private func mapItem(name: String, latitude: Double, longitude: Double) -> MKMapItem {
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        let item = MKMapItem(placemark: placemark)
        item.name = name
        return item
    }

    private func restaurant(name: String, latitude: Double, longitude: Double, isFavorite: Bool = false, isTried: Bool = false) -> Restaurant {
        let restaurant = Restaurant()
        restaurant.name = name
        restaurant.latitude = latitude
        restaurant.longitude = longitude
        restaurant.isFavorite = isFavorite
        restaurant.isTried = isTried
        return restaurant
    }

    @Test func favoritesModeKeepsOnlyMatchedFavorites() {
        let favorite = mapItem(name: "Favorite Pie", latitude: 1, longitude: 1)
        let nonFavorite = mapItem(name: "Plain Pie", latitude: 2, longitude: 2)
        let neverSeen = mapItem(name: "New Pie", latitude: 3, longitude: 3)
        let saved = [
            restaurant(name: "Favorite Pie", latitude: 1, longitude: 1, isFavorite: true),
            restaurant(name: "Plain Pie", latitude: 2, longitude: 2, isFavorite: false),
        ]

        let pool = NearbyPizzaPoolFilter.pool(from: [favorite, nonFavorite, neverSeen], mode: .favorites, savedRestaurants: saved)

        #expect(pool.map(\.name) == [favorite.name])
    }

    @Test func untriedModeExcludesOnlyAlreadyTried() {
        let tried = mapItem(name: "Been There Pie", latitude: 1, longitude: 1)
        let untried = mapItem(name: "Not Yet Pie", latitude: 2, longitude: 2)
        let neverSeen = mapItem(name: "New Pie", latitude: 3, longitude: 3)
        let saved = [
            restaurant(name: "Been There Pie", latitude: 1, longitude: 1, isTried: true),
            restaurant(name: "Not Yet Pie", latitude: 2, longitude: 2, isTried: false),
        ]

        let pool = NearbyPizzaPoolFilter.pool(from: [tried, untried, neverSeen], mode: .untried, savedRestaurants: saved)

        #expect(Set(pool.map { $0.name ?? "" }) == Set([untried.name, neverSeen.name].compactMap { $0 }))
    }

    @Test func noMatchingSavedRestaurantExcludesFromFavorites() {
        let neverSeen = mapItem(name: "New Pie", latitude: 3, longitude: 3)

        let pool = NearbyPizzaPoolFilter.pool(from: [neverSeen], mode: .favorites, savedRestaurants: [])

        #expect(pool.isEmpty)
    }
}
