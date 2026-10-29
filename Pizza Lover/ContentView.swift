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
        TabView {
            NavigationStack {
                NearbyPizzaListView()
            }
            .tabItem {
                Label("Nearby", systemImage: "map")
            }

            NavigationStack {
                MyRankingsView()
            }
            .tabItem {
                Label("My Rankings", systemImage: "list.star")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Restaurant.self, PizzaEntry.self, Achievement.self], inMemory: true)
}
