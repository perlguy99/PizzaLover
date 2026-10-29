//
//  PizzaEntry.swift
//  Pizza Lover
//

import Foundation
import SwiftData

@Model
final class PizzaEntry {
    var date: Date = Date()
    var crustScore: Int = 5
    var sauceScore: Int = 5
    var toppingsScore: Int = 5
    var overallTasteScore: Int = 5
    var notes: String?
    var photoData: Data?

    var restaurant: Restaurant?

    init() {}
}
