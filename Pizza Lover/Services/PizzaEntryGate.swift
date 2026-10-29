//
//  PizzaEntryGate.swift
//  Pizza Lover
//

import Foundation

/// Pure free-tier gate for saving new `PizzaEntry` rows.
///
/// Kept separate from `StoreManager` and the view layer so the actual cap
/// logic is trivially testable without StoreKit, SwiftData, or SwiftUI.
enum PizzaEntryGate {
    /// Free tier is capped at 3 total saved `PizzaEntry` rows.
    static let freeTierCap = 3

    /// Whether a new `PizzaEntry` can be saved given the current total count.
    /// Unlocked users always pass; free-tier users pass while under the cap.
    static func canSaveNewEntry(currentCount: Int, isUnlocked: Bool) -> Bool {
        isUnlocked || currentCount < freeTierCap
    }
}
