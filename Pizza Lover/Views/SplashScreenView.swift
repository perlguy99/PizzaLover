//
//  SplashScreenView.swift
//  Pizza Lover
//

import SwiftUI

/// Shown briefly over `ContentView` on launch, purely decorative - no data
/// loading gates on it, `Pizza_LoverApp` just dismisses it after a short
/// delay. SF Symbols only, deliberately not referencing the app icon asset
/// directly (Apple doesn't officially support pulling `AppIcon` into a
/// regular `Image` view).
struct SplashScreenView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.orange.opacity(0.18), Color.red.opacity(0.10)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 88))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .red)
                    .scaleEffect(isAnimating ? 1 : 0.7)
                    .opacity(isAnimating ? 1 : 0)

                Text("Pizza Lover")
                    .font(.largeTitle.bold())
                    .opacity(isAnimating ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
