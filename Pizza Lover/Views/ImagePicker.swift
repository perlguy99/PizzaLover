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
/// closes the parent sheet as well (confirmed by Brent on-device). `UIImagePickerController`
/// fully supports `.photoLibrary` as a source and, wrapped the same way the camera path
/// already was, doesn't have that problem - it owns its own dismissal explicitly.
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImagePicked: (UIImage) -> Void

        init(onImagePicked: @escaping (UIImage) -> Void) {
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
