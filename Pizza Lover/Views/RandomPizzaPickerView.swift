//
//  RandomPizzaPickerView.swift
//  Pizza Lover
//

import SwiftUI
import SwiftData

struct RandomPizzaPickerView: View {
    @Query private var restaurants: [Restaurant]
    @State private var mode: RandomPizzaMode = .favorites
    @State private var pickedRestaurant: Restaurant?

    var body: some View {
        VStack(spacing: 24) {
            Picker("Mode", selection: $mode) {
                Text("Favorites").tag(RandomPizzaMode.favorites)
                Text("Haven't Tried").tag(RandomPizzaMode.untried)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .onChange(of: mode) { _, _ in
                pickedRestaurant = nil
            }

            Spacer()

            if restaurants.isEmpty {
                ContentUnavailableView {
                    Label("No Restaurants Yet", systemImage: "fork.knife")
                } description: {
                    Text("Find a nearby pizza place and add it before using the picker.")
                }
            } else if let pickedRestaurant {
                // Swappable result presentation: a future fancier "spin" UI can
                // replace just this subview without touching the filter logic above.
                RandomPickResultView(restaurant: pickedRestaurant) {
                    pick()
                }
            } else if pool.isEmpty {
                ContentUnavailableView {
                    Label(emptyTitle, systemImage: "questionmark.circle")
                } description: {
                    Text(emptyDescription)
                }
            } else {
                Button {
                    pick()
                } label: {
                    Text("Pick For Me")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle("Random Pizza")
    }

    private var pool: [Restaurant] {
        RestaurantPoolFilter.pool(from: restaurants, mode: mode)
    }

    private func pick() {
        pickedRestaurant = pool.randomElement()
    }

    private var emptyTitle: String {
        switch mode {
        case .favorites: "No Favorites Yet"
        case .untried: "You've Tried Them All!"
        }
    }

    private var emptyDescription: String {
        switch mode {
        case .favorites: "You haven't favorited any restaurants yet. Mark a few as favorites from their detail screen."
        case .untried: "You've tried every restaurant you've added. Find a new one to shake things up."
        }
    }
}

/// Result presentation for a random pick. Kept as its own small subview so a future
/// fancier "spin" animation can swap in here without touching the filter logic or
/// the surrounding picker/empty-state plumbing in `RandomPizzaPickerView`.
private struct RandomPickResultView: View {
    let restaurant: Restaurant
    let onPickAgain: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(restaurant.name)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                if !restaurant.address.isEmpty {
                    Text(restaurant.address)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))

            HStack(spacing: 12) {
                Button("Pick Again", action: onPickAgain)
                    .buttonStyle(.bordered)

                NavigationLink("Go to Restaurant") {
                    RestaurantDetailView(restaurant: restaurant)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        RandomPizzaPickerView()
    }
    .modelContainer(for: [Restaurant.self, PizzaEntry.self, Achievement.self], inMemory: true)
}
