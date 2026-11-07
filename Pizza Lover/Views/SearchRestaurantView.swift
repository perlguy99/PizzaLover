//
//  SearchRestaurantView.swift
//  Pizza Lover
//

import SwiftUI
import SwiftData
import MapKit

/// Free-text restaurant search, independent of the user's current location -
/// reached from a toolbar button on Nearby Pizza. Lets someone find a place
/// in another town (e.g. "Pequod's Pizza Chicago") to log a pizza eaten
/// there in the past, not just places nearby right now.
struct SearchRestaurantView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var savedRestaurants: [Restaurant]
    @State private var placesService = PlacesService()
    @State private var queryText = ""
    @State private var selectedRestaurant: Restaurant?

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Search for a Restaurant")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $queryText, prompt: "Restaurant name and city")
                .onSubmit(of: .search) { search() }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
                .navigationDestination(item: $selectedRestaurant) { restaurant in
                    RestaurantDetailView(restaurant: restaurant)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if placesService.isSearching {
            ProgressView("Searching…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let searchError = placesService.searchError {
            ContentUnavailableView {
                Label("Search Failed", systemImage: "exclamationmark.triangle")
            } description: {
                Text(searchError)
            } actions: {
                Button("Try Again", action: search)
            }
        } else if placesService.results.isEmpty {
            ContentUnavailableView {
                Label("Search for a Restaurant", systemImage: "magnifyingglass")
            } description: {
                Text("Type a name and place, like \"Lou Malnati's Chicago\", to find it even if you're not there right now.")
            }
        } else {
            List(placesService.results, id: \.self) { item in
                Button {
                    selectPlace(item)
                } label: {
                    NearbyPizzaRow(
                        mapItem: item,
                        distanceText: nil,
                        isFavorite: isFavorite(item),
                        isTried: isTried(item),
                        isExcluded: isExcluded(item)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func search() {
        let trimmed = queryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        Task { await placesService.searchByName(query: trimmed) }
    }

    private func selectPlace(_ item: MKMapItem) {
        let restaurant = Restaurant.upsert(from: item, in: modelContext)
        try? modelContext.save()
        selectedRestaurant = restaurant
    }

    private func isFavorite(_ item: MKMapItem) -> Bool {
        NearbyPizzaPoolFilter.matchingRestaurant(for: item, in: savedRestaurants)?.isFavorite == true
    }

    private func isTried(_ item: MKMapItem) -> Bool {
        NearbyPizzaPoolFilter.matchingRestaurant(for: item, in: savedRestaurants)?.isTried == true
    }

    private func isExcluded(_ item: MKMapItem) -> Bool {
        NearbyPizzaPoolFilter.matchingRestaurant(for: item, in: savedRestaurants)?.isExcluded == true
    }
}

#Preview {
    SearchRestaurantView()
        .modelContainer(for: [Restaurant.self, PizzaEntry.self, Achievement.self], inMemory: true)
}
