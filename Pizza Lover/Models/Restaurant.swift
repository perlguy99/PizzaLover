//
//  Restaurant.swift
//  Pizza Lover
//

import Foundation
import SwiftData

@Model
final class Restaurant {
    var mapItemIdentifier: String = ""   // MKMapItem has no stable persistent ID across searches pre-iOS18 Identifiable changes; use name+coordinate as a practical dedupe key for now, see findOrCreate below
    var name: String = ""
    var address: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var phone: String = ""
    var isFavorite: Bool = false
    var isTried: Bool = false
    var isExcluded: Bool = false   // never appears in Random Pizza picks, regardless of mode
    var dateAdded: Date = Date()
    var isFrozen: Bool = false   // a store-bought frozen pizza logged from home, not a real place - no address/coordinates

    @Relationship(deleteRule: .cascade, inverse: \PizzaEntry.restaurant)
    var pizzaEntries: [PizzaEntry]? = []

    init() {}

    static func findOrCreate(name: String, latitude: Double, longitude: Double, in context: ModelContext) -> Restaurant {
        let predicate = #Predicate<Restaurant> { $0.name == name && $0.latitude == latitude && $0.longitude == longitude }
        if let existing = try? context.fetch(FetchDescriptor(predicate: predicate)).first {
            return existing
        }
        let fresh = Restaurant()
        fresh.name = name
        fresh.latitude = latitude
        fresh.longitude = longitude
        context.insert(fresh)
        return fresh
    }

    /// Same dedupe idea as findOrCreate, but for frozen pizzas: no coordinates to key
    /// off of, so match on name alone (so logging "DiGiorno Pepperoni" a second time
    /// adds another entry to the same brand instead of fragmenting it into a duplicate).
    static func findOrCreateFrozen(name: String, in context: ModelContext) -> Restaurant {
        let predicate = #Predicate<Restaurant> { $0.isFrozen == true && $0.name == name }
        if let existing = try? context.fetch(FetchDescriptor(predicate: predicate)).first {
            return existing
        }
        let fresh = Restaurant()
        fresh.name = name
        fresh.isFrozen = true
        fresh.isTried = true
        context.insert(fresh)
        return fresh
    }
}
