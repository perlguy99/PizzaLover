//
//  Pizza_LoverApp.swift
//  Pizza Lover
//
//  Created by Brent Michalski on 10/28/26.
//

import SwiftUI
import SwiftData

@main
struct Pizza_LoverApp: App {
    let modelContainer: ModelContainer
    @State private var storeManager = StoreManager()

    init() {
        let schema = Schema([Restaurant.self, PizzaEntry.self, Achievement.self])
        let configuration = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(storeManager)
        }
        .modelContainer(modelContainer)
    }
}
