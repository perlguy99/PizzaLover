//
//  LocationAccessViews.swift
//  Pizza Lover
//

import SwiftUI
import UIKit

/// Soft pre-permission screen shown before the real system location prompt ever fires.
/// Both Nearby and Random were calling `requestPermission()` straight out of `.task`,
/// so a brand-new user's very first moment in either tab was a cold system dialog with
/// zero context. This explains why location is used first; the system prompt only
/// fires once the user taps through here.
struct LocationPrimerView: View {
    let message: String
    let onRequestAccess: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Find Pizza Near You", systemImage: "location.circle")
        } description: {
            Text(message)
        } actions: {
            Button("Allow Location Access", action: onRequestAccess)
                .buttonStyle(.borderedProminent)
        }
    }
}

/// Shown when the user already said no (or location is restricted) - the system won't
/// re-prompt at that point, so the only way forward is the Settings app.
struct LocationAccessDeniedView: View {
    let message: String

    var body: some View {
        ContentUnavailableView {
            Label("Location Access Needed", systemImage: "location.slash")
        } description: {
            Text(message)
        } actions: {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
