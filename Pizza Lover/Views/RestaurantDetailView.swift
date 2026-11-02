//
//  RestaurantDetailView.swift
//  Pizza Lover
//

import SwiftUI
import SwiftData

struct RestaurantDetailView: View {
    @Bindable var restaurant: Restaurant
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingPizzaEntryForm = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.title2.bold())
                    if !restaurant.address.isEmpty {
                        Text(restaurant.address)
                            .foregroundStyle(.secondary)
                    }
                    if !restaurant.phone.isEmpty {
                        Text(restaurant.phone)
                            .foregroundStyle(.secondary)
                    }
                }
                Toggle("Favorite", isOn: $restaurant.isFavorite)
            }

            Section("Pizzas Logged Here") {
                if sortedEntries.isEmpty {
                    Text("No pizzas logged yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedEntries) { entry in
                        PizzaEntryRow(entry: entry)
                    }
                }
            }

            Section {
                Button {
                    isShowingPizzaEntryForm = true
                } label: {
                    Text("I Ate Pizza Here")
                }
            }
        }
        .navigationTitle(restaurant.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingPizzaEntryForm) {
            PizzaEntryFormView(restaurant: restaurant)
        }
    }

    private var sortedEntries: [PizzaEntry] {
        (restaurant.pizzaEntries ?? []).sorted { $0.date > $1.date }
    }
}

private struct PizzaEntryRow: View {
    let entry: PizzaEntry

    var body: some View {
        HStack(spacing: 12) {
            PizzaPhotoThumbnail(photoData: entry.photoData, size: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                Text("Crust \(entry.crustScore) · Sauce \(entry.sauceScore) · Toppings \(entry.toppingsScore) · Overall \(entry.overallTasteScore)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailView(restaurant: Restaurant())
    }
    .modelContainer(for: [Restaurant.self, PizzaEntry.self, Achievement.self], inMemory: true)
}
