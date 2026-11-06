//
//  RandomPizzaPickerView.swift
//  Pizza Lover
//

import SwiftUI
import SwiftData
import MapKit
import CoreLocation

private enum RadiusOption: Int, CaseIterable, Identifiable {
    case five = 5
    case ten = 10
    case fifteen = 15
    case twenty = 20

    var id: Int { rawValue }
    var label: String { "\(rawValue) mi" }
    var meters: Double { Double(rawValue) * 1609.34 }
}

struct RandomPizzaPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedRestaurants: [Restaurant]
    @State private var locationService = LocationService()
    @State private var placesService = PlacesService()
    @State private var radius: RadiusOption = .ten
    @State private var mode: RandomPizzaMode = .favorites
    @State private var pickedRestaurant: Restaurant?
    @State private var hasStartedLocating = false

    var body: some View {
        Group {
            switch locationService.authorizationStatus {
            case .notDetermined:
                LocationPrimerView(message: "Pizza Lover uses your location to find a random nearby pizza spot. You'll get the system prompt next.") {
                    locationService.requestPermission()
                }
            case .denied, .restricted:
                LocationAccessDeniedView(message: "Location access was denied, so a random nearby pick can't be found. Turn it back on in Settings to use this tab.")
            default:
                pickerContent
            }
        }
        .navigationTitle("Random Pizza")
        .task {
            startLocatingIfAlreadyAuthorized()
        }
        .onChange(of: locationKey) { _, _ in
            search()
        }
    }

    private var pickerContent: some View {
        VStack(spacing: 24) {
            Picker("Radius", selection: $radius) {
                ForEach(RadiusOption.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .onChange(of: radius) { _, _ in
                pickedRestaurant = nil
                search()
            }

            Picker("Mode", selection: $mode) {
                ForEach(RandomPizzaMode.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .onChange(of: mode) { _, _ in
                pickedRestaurant = nil
            }

            Spacer()

            resultContent

            Spacer()
        }
    }

    @ViewBuilder
    private var resultContent: some View {
        if let pickedRestaurant {
            // Swappable result presentation: a future fancier "spin" UI can
            // replace just this subview without touching the pick logic above.
            RandomPickResultView(restaurant: pickedRestaurant) {
                pick()
            }
        } else if placesService.isSearching {
            ProgressView("Finding nearby pizza…")
        } else if let searchError = placesService.searchError {
            ContentUnavailableView {
                Label("Couldn't Find Pizza", systemImage: "exclamationmark.triangle")
            } description: {
                Text(searchError)
            } actions: {
                Button("Try Again") { search() }
            }
        } else if pool.isEmpty {
            ContentUnavailableView {
                Label(emptyTitle, systemImage: "map")
            } description: {
                Text(emptyDescription)
            } actions: {
                Button("Search Again") { search() }
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
    }

    // CLLocationCoordinate2D isn't Equatable, so derive a plain String key to drive onChange.
    private var locationKey: String? {
        guard let coordinate = locationService.currentLocation else { return nil }
        return "\(coordinate.latitude),\(coordinate.longitude)"
    }

    /// Only fires the (silent, already-granted) location fetch - never the system
    /// permission prompt itself, which now only fires from `LocationPrimerView`'s button.
    private func startLocatingIfAlreadyAuthorized() {
        guard !hasStartedLocating else { return }
        guard locationService.authorizationStatus == .authorizedWhenInUse || locationService.authorizationStatus == .authorizedAlways else { return }
        hasStartedLocating = true
        locationService.requestLocation()
    }

    private func search() {
        guard let coordinate = locationService.currentLocation else { return }
        Task { await placesService.searchNearbyPizza(center: coordinate, radiusMeters: radius.meters) }
    }

    private var pool: [MKMapItem] {
        NearbyPizzaPoolFilter.pool(from: placesService.results, mode: mode, savedRestaurants: savedRestaurants)
    }

    private var emptyTitle: String {
        switch mode {
        case .favorites: "No Favorites Within \(radius.rawValue) mi"
        case .untried: "You've Tried Them All Within \(radius.rawValue) mi"
        }
    }

    private var emptyDescription: String {
        switch mode {
        case .favorites: "None of your favorited restaurants are in range. Try a bigger radius, or favorite a nearby place from its detail screen."
        case .untried: "You've already tried every nearby place in range. Try a bigger radius to find somewhere new."
        }
    }

    private func pick() {
        guard let item = pool.randomElement() else {
            pickedRestaurant = nil
            return
        }
        pickedRestaurant = restaurant(from: item)
    }

    /// Persists the picked map item as a `Restaurant` so "Go to Restaurant" can hand
    /// off to a real detail screen.
    private func restaurant(from item: MKMapItem) -> Restaurant {
        let restaurant = Restaurant.upsert(from: item, in: modelContext)
        try? modelContext.save()
        return restaurant
    }
}

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
                if !restaurant.phone.isEmpty {
                    if let telURL = restaurant.phone.telURL {
                        Link(restaurant.phone, destination: telURL)
                    } else {
                        Text(restaurant.phone)
                            .foregroundStyle(.secondary)
                    }
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
