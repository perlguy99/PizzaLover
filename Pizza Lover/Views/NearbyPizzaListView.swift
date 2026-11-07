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
    @Query private var savedRestaurants: [Restaurant]
    @State private var locationService = LocationService()
    @State private var placesService = PlacesService()
    @State private var selectedRestaurant: Restaurant?
    @State private var hasStartedLocating = false
    @State private var isShowingSearch = false

    var body: some View {
        rootContent
            .navigationTitle("Nearby Pizza")
            .navigationDestination(item: $selectedRestaurant) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .accessibilityLabel("Search for a Restaurant")
                }
            }
            .sheet(isPresented: $isShowingSearch) {
                SearchRestaurantView()
            }
            .task {
                startLocatingIfAlreadyAuthorized()
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
    private var rootContent: some View {
        switch locationService.authorizationStatus {
        case .notDetermined:
            LocationPrimerView(message: "Pizza Lover uses your location to find pizza places near you. You'll get the system prompt next.") {
                locationService.requestPermission()
            }
        case .denied, .restricted:
            LocationAccessDeniedView(message: "Location access was denied, so nearby pizza places can't be found. Turn it back on in Settings to use this tab.")
        default:
            content
        }
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
                VStack(alignment: .leading, spacing: 2) {
                    Button {
                        selectPlace(item)
                    } label: {
                        NearbyPizzaRow(mapItem: item, distanceText: distanceText(to: item), isFavorite: isFavorite(item), isTried: isTried(item), isExcluded: isExcluded(item))
                    }
                    .buttonStyle(.plain)

                    // Kept as a sibling of the row's Button, not nested inside its
                    // label — a tappable Link inside a Button's label doesn't get its
                    // own tap recognized, the outer Button swallows it.
                    if let phoneNumber = item.phoneNumber, let telURL = phoneNumber.telURL {
                        Link(phoneNumber, destination: telURL)
                            .font(.caption)
                            .padding(.leading, 2)
                    }
                }
                .contextMenu {
                    Button {
                        toggleFavorite(item)
                    } label: {
                        if isFavorite(item) {
                            Label("Remove from Favorites", systemImage: "star.slash")
                        } else {
                            Label("Add to Favorites", systemImage: "star")
                        }
                    }
                    Button {
                        toggleTried(item)
                    } label: {
                        if isTried(item) {
                            Label("Mark as Not Visited", systemImage: "xmark.circle")
                        } else {
                            Label("Mark as Visited", systemImage: "checkmark.circle")
                        }
                    }
                    Button(role: isExcluded(item) ? nil : .destructive) {
                        toggleExcluded(item)
                    } label: {
                        if isExcluded(item) {
                            Label("Include in Random Picks", systemImage: "nosign")
                        } else {
                            Label("Exclude from Random Picks", systemImage: "nosign")
                        }
                    }
                }
            }
            .refreshable { await refreshAsync() }
        }
    }

    /// Only fires the (silent, already-granted) location fetch - never the system
    /// permission prompt itself, which now only fires from `LocationPrimerView`'s button.
    private func startLocatingIfAlreadyAuthorized() {
        guard !hasStartedLocating else { return }
        guard locationService.authorizationStatus == .authorizedWhenInUse || locationService.authorizationStatus == .authorizedAlways else { return }
        hasStartedLocating = true
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

    private func toggleFavorite(_ item: MKMapItem) {
        let restaurant = Restaurant.upsert(from: item, in: modelContext)
        restaurant.isFavorite.toggle()
        try? modelContext.save()
    }

    private func toggleTried(_ item: MKMapItem) {
        let restaurant = Restaurant.upsert(from: item, in: modelContext)
        restaurant.isTried.toggle()
        try? modelContext.save()
    }

    private func toggleExcluded(_ item: MKMapItem) {
        let restaurant = Restaurant.upsert(from: item, in: modelContext)
        restaurant.isExcluded.toggle()
        try? modelContext.save()
    }
}

/// Not private - also reused by `SearchRestaurantView` for its results list.
struct NearbyPizzaRow: View {
    let mapItem: MKMapItem
    let distanceText: String?
    let isFavorite: Bool
    let isTried: Bool
    let isExcluded: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
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

            if isFavorite || isTried || isExcluded {
                Spacer()
                VStack(spacing: 4) {
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .accessibilityLabel("Favorite")
                    }
                    if isTried {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .accessibilityLabel("Visited before")
                    }
                    if isExcluded {
                        Image(systemName: "nosign")
                            .foregroundStyle(.red)
                            .accessibilityLabel("Excluded from random picks")
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

extension MKMapItem {
    /// Built from the placemark's structured components (never `.title`, which is a
    /// single locale-formatted line that always ends in ", United States") so we get
    /// a real two-line mailing-address layout with no country line — we only ever
    /// show US places, so it'd just be noise.
    var formattedAddress: String {
        let placemark = self.placemark
        let streetLine = [placemark.subThoroughfare, placemark.thoroughfare]
            .compactMap { $0 }
            .joined(separator: " ")

        let cityState = [placemark.locality, placemark.administrativeArea]
            .compactMap { $0 }
            .joined(separator: ", ")
        let cityStateZip = [cityState, placemark.postalCode]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        let lines = [streetLine, cityStateZip].filter { !$0.isEmpty }
        return lines.isEmpty ? "Address unavailable" : lines.joined(separator: "\n")
    }
}

extension String {
    /// A `tel:` link for this phone number string, or nil if it has no digits to call.
    /// Strips formatting (spaces, dashes, parens) but keeps a leading "+" for
    /// international numbers, since `tel:` URLs don't need human-readable punctuation.
    var telURL: URL? {
        let digitsAndPlus = filter { $0.isNumber || $0 == "+" }
        guard !digitsAndPlus.isEmpty else { return nil }
        return URL(string: "tel:\(digitsAndPlus)")
    }
}

#Preview {
    NavigationStack {
        NearbyPizzaListView()
    }
    .modelContainer(for: [Restaurant.self, PizzaEntry.self, Achievement.self], inMemory: true)
}
