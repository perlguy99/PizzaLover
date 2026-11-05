//
//  ImagePicker.swift
//  Pizza Lover
//
//  Renamed from CameraImagePicker.swift 2026-11-05 - now covers camera AND
//  library, see sourceType below.
//

import SwiftUI
import UIKit

/// UIKit bridge for photo capture/selection, parameterized by source. Used for both
/// camera and library instead of SwiftUI-native `PhotosPicker` for the library case too:
/// `.photosPicker` presented from inside a view that's itself already shown as a sheet
/// has a real, reproducible bug where dismissing it after picking a photo cascades and
/// closes the parent sheet as well (confirmed by Brent on-device).
///
/// SAFETY 2026-11-05: this picker itself must NEVER call `picker.dismiss(animated:)`
/// directly. The parent view presents it via `.sheet(isPresented:)`, which already owns
/// dismissal once that bound Bool flips to false - calling `picker.dismiss()` here too
/// is a second, redundant dismissal racing the first, and nested inside another sheet
/// (PizzaEntryFormView) that race was cascading and closing the *parent* sheet as well,
/// not just this picker. `onCancel` exists specifically so Cancel also flips the SwiftUI
/// binding instead of leaving it out of sync with a picker UIKit already dismissed itself.
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var onImagePicked: (UIImage) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked, onCancel: onCancel)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImagePicked: (UIImage) -> Void
        let onCancel: () -> Void

        init(onImagePicked: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onImagePicked = onImagePicked
            self.onCancel = onCancel
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            } else {
                onCancel()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
        }
    }
}
