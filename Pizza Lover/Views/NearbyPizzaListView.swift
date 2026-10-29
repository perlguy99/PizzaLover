//
//  NearbyPizzaListView.swift
//  Pizza Lover
//

import SwiftUI
import SwiftData
import MapKit
import CoreLocation

struct NearbyPizzaListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var locationService = LocationService()
    @State private var placesService = PlacesService()
    @State private var selectedRestaurant: Restaurant?
    @State private var hasStartedLocating = false

    var body: some View {
        content
            .navigationTitle("Nearby Pizza")
            .navigationDestination(item: $selectedRestaurant) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
            }
            .task {
                startLocating()
            }
            .onChange(of: locationKey) { _, _ in
                guard let coordinate = locationService.currentLocation else { return }
                Task { await placesService.searchNearbyPizza(center: coordinate) }
            }
    }

    // CLLocationCoordinate2D isn't Equatable, so derive a plain String key to drive onChange.
    private var locationKey: String? {
        guard let coordinate = locationService.currentLocation else { return nil }
        return "\(coordinate.latitude),\(coordinate.longitude)"
    }

    @ViewBuilder
    private var content: some View {
        if placesService.isSearching {
            ProgressView("Finding nearby pizza…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let searchError = placesService.searchError {
            ContentUnavailableView {
                Label("Couldn't Find Pizza", systemImage: "exclamationmark.triangle")
            } description: {
                Text(searchError)
            } actions: {
                Button("Try Again") { refresh() }
            }
        } else if placesService.results.isEmpty {
            ContentUnavailableView {
                Label("No Pizza Nearby", systemImage: "map")
            } description: {
                Text("Pull to refresh once your location is available.")
            } actions: {
                Button("Search Again") { refresh() }
            }
        } else {
            List(placesService.results, id: \.self) { item in
                Button {
                    selectPlace(item)
                } label: {
                    NearbyPizzaRow(mapItem: item, distanceText: distanceText(to: item))
                }
                .buttonStyle(.plain)
            }
            .refreshable { await refreshAsync() }
        }
    }

    private func startLocating() {
        guard !hasStartedLocating else { return }
        hasStartedLocating = true
        locationService.requestPermission()
        locationService.requestLocation()
    }

    private func refresh() {
        Task { await refreshAsync() }
    }

    private func refreshAsync() async {
        locationService.requestLocation()
        if let coordinate = locationService.currentLocation {
            await placesService.searchNearbyPizza(center: coordinate)
        }
    }

    private func distanceText(to item: MKMapItem) -> String? {
        guard let coordinate = locationService.currentLocation else { return nil }
        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let placeLocation = CLLocation(
            latitude: item.placemark.coordinate.latitude,
            longitude: item.placemark.coordinate.longitude
        )
        let meters = userLocation.distance(from: placeLocation)
        let measurement = Measurement(value: meters, unit: UnitLength.meters)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.unitStyle = .medium
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter.string(from: measurement)
    }

    private func selectPlace(_ item: MKMapItem) {
        let coordinate = item.placemark.coordinate
        let restaurant = Restaurant.findOrCreate(
            name: item.name ?? "Unknown Pizza Place",
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            in: modelContext
        )
        if restaurant.address.isEmpty {
            restaurant.address = item.formattedAddress
        }
        if restaurant.phone.isEmpty, let phoneNumber = item.phoneNumber {
            restaurant.phone = phoneNumber
        }
        try? modelContext.save()
        selectedRestaurant = restaurant
    }
}

private struct NearbyPizzaRow: View {
    let mapItem: MKMapItem
    let distanceText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(mapItem.name ?? "Unknown Pizza Place")
                .font(.headline)
            Text(mapItem.formattedAddress)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let distanceText {
                Text(distanceText)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

extension MKMapItem {
    var formattedAddress: String {
        if let title = placemark.title, !title.isEmpty {
            return title
        }
        let components = [placemark.thoroughfare, placemark.locality, placemark.administrativeArea]
            .compactMap { $0 }
        return components.isEmpty ? "Address unavailable" : components.joined(separator: ", ")
    }
}

#Preview {
    NavigationStack {
        NearbyPizzaListView()
    }
    .modelContainer(for: [Restaurant.self, PizzaEntry.self, Achievement.self], inMemory: true)
}
