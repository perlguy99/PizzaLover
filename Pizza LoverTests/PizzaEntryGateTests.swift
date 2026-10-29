//
//  PizzaEntryGateTests.swift
//  Pizza LoverTests
//

import Testing
@testable import Pizza_Lover

struct PizzaEntryGateTests {

    @Test func unlockedUserAlwaysAllowedRegardlessOfCount() {
        #expect(PizzaEntryGate.canSaveNewEntry(currentCount: 0, isUnlocked: true))
        #expect(PizzaEntryGate.canSaveNewEntry(currentCount: 3, isUnlocked: true))
        #expect(PizzaEntryGate.canSaveNewEntry(currentCount: 1_000, isUnlocked: true))
    }

    @Test func freeUserAllowedBelowCap() {
        #expect(PizzaEntryGate.canSaveNewEntry(currentCount: 0, isUnlocked: false))
        #expect(PizzaEntryGate.canSaveNewEntry(currentCount: 1, isUnlocked: false))
        #expect(PizzaEntryGate.canSaveNewEntry(currentCount: 2, isUnlocked: false))
    }

    @Test func freeUserBlockedAtCap() {
        #expect(!PizzaEntryGate.canSaveNewEntry(currentCount: 3, isUnlocked: false))
    }

    @Test func freeUserBlockedAboveCap() {
        // Can happen if CloudKit sync lands extra entries from another device.
        #expect(!PizzaEntryGate.canSaveNewEntry(currentCount: 4, isUnlocked: false))
    }

    @Test func freeTierCapIsThree() {
        #expect(PizzaEntryGate.freeTierCap == 3)
    }
}
