//
//  ContentView.swift
//  Pizza Lover
//
//  Created by Brent Michalski on 10/28/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            NearbyPizzaListView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Restaurant.self, PizzaEntry.self, Achievement.self], inMemory: true)
}
