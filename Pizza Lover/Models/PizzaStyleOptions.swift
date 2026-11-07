//
//  PizzaStyleOptions.swift
//  Pizza Lover
//

import Foundation

/// Common pizza styles offered as quick-pick options in the entry form.
/// Not exhaustive on purpose - the form also lets someone type in any style
/// not listed here, and that custom value gets offered back as a pick
/// option on future entries too (see `PizzaEntryFormView.knownStyles`).
enum PizzaStyleOptions {
    static let presets: [String] = [
        "Neapolitan",
        "New York",
        "Chicago Deep Dish",
        "Detroit",
        "Sicilian",
        "Thin Crust",
        "Pan",
        "Stuffed Crust",
        "Flatbread",
        "Grandma",
        "Greek",
        "California",
        "St. Louis",
        "Quad Cities",
    ]
}
