//
//  SplashScreenView.swift
//  Pizza Lover
//

import SwiftUI

/// Shown briefly over `ContentView` on launch, purely decorative - no data
/// loading gates on it, `Pizza_LoverApp` just dismisses it after a short
/// delay. Uses the real app icon artwork, duplicated into its own
/// `LaunchIcon` imageset (same pattern as the cross-promo icons in
/// Settings) rather than referencing the reserved `AppIcon` asset directly,
/// which Apple doesn't officially support pulling into a regular `Image`.
struct SplashScreenView: View {
    @State private var isAnimating = false

    /// Same cream tone used on the hosted Privacy/Support pages, for a
    /// consistent brand look - fully opaque, not a low-opacity tint, so
    /// nothing behind it (My Rankings) can bleed through while it's up.
    private let backgroundColor = Color(red: 0.996, green: 0.980, blue: 0.965)
    /// Matches the dark ink color used on those same pages. Fixed, not
    /// `.primary` - this is a branded launch screen with its own fixed
    /// light background, so the text can't follow the system's light/dark
    /// mode or it goes white-on-white in Dark Mode.
    private let textColor = Color(red: 0.169, green: 0.141, blue: 0.125)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image("LaunchIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 108, height: 108)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    .scaleEffect(isAnimating ? 1 : 0.7)
                    .opacity(isAnimating ? 1 : 0)

                Text("Pizza Lover")
                    .font(.largeTitle.bold())
                    .foregroundStyle(textColor)
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
