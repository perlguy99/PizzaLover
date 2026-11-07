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

    /// Free-text search for a specific named place, not constrained to the
    /// user's current location - lets someone find a restaurant in another
    /// town to log a pizza eaten there in the past. Deliberately sets no
    /// `region` (unlike `searchNearbyPizza`), so MapKit resolves the query
    /// based on whatever location context is in the text itself, e.g.
    /// "Lou Malnati's Chicago".
    func searchByName(query: String) async {
        isSearching = true
        searchError = nil
        defer { isSearching = false }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest

        do {
            let response = try await MKLocalSearch(request: request).start()
            results = response.mapItems
        } catch {
            searchError = error.localizedDescription
        }
    }
}
