//
//  PizzaPhotoThumbnail.swift
//  Pizza Lover
//

import SwiftUI

/// Small rounded thumbnail used wherever a logged `PizzaEntry`'s photo is shown in a list row
/// (My Rankings, Restaurant Detail history). Renders nothing if `photoData` is nil or
/// undecodable, so callers can embed it unconditionally.
struct PizzaPhotoThumbnail: View {
    let photoData: Data?
    var size: CGFloat = 44

    var body: some View {
        if let photoData, let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
