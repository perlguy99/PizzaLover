//
//  RestaurantMapItemUpsert.swift
//  Pizza Lover
//

import MapKit
import SwiftData

extension Restaurant {
    /// Finds or creates the `Restaurant` backing a live search result, filling in
    /// address/phone the first time it's seen. Shared by every screen that turns an
    /// `MKMapItem` into a persisted restaurant (Nearby, Random, favoriting).
    @discardableResult
    static func upsert(from item: MKMapItem, in context: ModelContext) -> Restaurant {
        let coordinate = item.placemark.coordinate
        let restaurant = findOrCreate(
            name: item.name ?? "Unknown Pizza Place",
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            in: context
        )
        if restaurant.address.isEmpty {
            restaurant.address = item.formattedAddress
        }
        if restaurant.phone.isEmpty, let phoneNumber = item.phoneNumber {
            restaurant.phone = phoneNumber
        }
        return restaurant
    }
}
