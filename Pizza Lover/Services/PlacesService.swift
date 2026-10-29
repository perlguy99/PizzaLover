//
//  PlacesService.swift
//  Pizza Lover
//

import Foundation
import MapKit

@Observable
final class PlacesService {
    var results: [MKMapItem] = []
    var isSearching = false
    var searchError: String?

    func searchNearbyPizza(center: CLLocationCoordinate2D, radiusMeters: Double = 8000) async {
        isSearching = true
        searchError = nil
        defer { isSearching = false }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "pizza"
        request.region = MKCoordinateRegion(center: center, latitudinalMeters: radiusMeters, longitudinalMeters: radiusMeters)
        request.resultTypes = .pointOfInterest

        do {
            let response = try await MKLocalSearch(request: request).start()
            results = response.mapItems
        } catch {
            searchError = error.localizedDescription
        }
    }
}
