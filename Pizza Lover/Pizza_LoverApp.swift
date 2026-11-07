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
            LaunchContainerView()
        }
        .modelContainer(modelContainer)
    }
}

/// Shows `SplashScreenView` over `ContentView` for a moment on launch, then
/// fades it out - purely decorative, not gating on anything loading.
private struct LaunchContainerView: View {
    @State private var isShowingSplash = true

    var body: some View {
        ZStack {
            ContentView()
            if isShowingSplash {
                // A plain opacity crossfade let My Rankings show through while
                // the splash was still partway visible, and the two fork/knife
                // icons + titles visually collided mid-transition. Sliding the
                // splash off instead means the two never overlap the same
                // screen space at once.
                SplashScreenView()
                    .transition(.move(edge: .bottom))
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation(.easeInOut(duration: 0.4)) {
                isShowingSplash = false
            }
        }
    }
}
