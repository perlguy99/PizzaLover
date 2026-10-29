//
//  ContentView.swift
//  Pizza Lover
//
//  Created by Brent Michalski on 10/28/26.
//
//  Build-verification placeholder only — proves the SwiftData container
//  works end to end. Real UI comes in a later milestone.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var pizzaEntries: [PizzaEntry]

    var body: some View {
        VStack(spacing: 20) {
            Text("Pizza Lover")
                .font(.largeTitle)

            Text("Pizza entries in store: \(pizzaEntries.count)")

            Button("Add Dummy Pizza Entry") {
                addDummyEntry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func addDummyEntry() {
        let restaurant = Restaurant.findOrCreate(
            name: "Test Pizzeria",
            latitude: 0,
            longitude: 0,
            in: modelContext
        )

        let entry = PizzaEntry()
        entry.restaurant = restaurant
        modelContext.insert(entry)

        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Restaurant.self, PizzaEntry.self, Achievement.self], inMemory: true)
}
