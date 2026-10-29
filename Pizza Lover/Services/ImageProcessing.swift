//
//  ImageProcessing.swift
//  Pizza Lover
//

import UIKit

/// Pure helper for turning a picked `UIImage` into CloudKit/SwiftData-friendly JPEG `Data` —
/// downscaled so the longest side is capped, then compressed, so a full-resolution camera
/// shot never bloats the synced record.
enum ImageProcessing {
    static func jpegData(from image: UIImage, maxDimension: CGFloat = 1200, compressionQuality: CGFloat = 0.7) -> Data? {
        let resized = resized(image, maxDimension: maxDimension)
        return resized.jpegData(compressionQuality: compressionQuality)
    }

    private static func resized(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let longestSide = max(image.size.width, image.size.height)
        guard longestSide > maxDimension else { return image }

        let scale = maxDimension / longestSide
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
