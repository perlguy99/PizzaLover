//
//  PizzaEntryFormView.swift
//  Pizza Lover
//

import SwiftUI
import SwiftData
import PhotosUI

struct PizzaEntryFormView: View {
    let restaurant: Restaurant

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var crustScore: Double = 5
    @State private var sauceScore: Double = 5
    @State private var toppingsScore: Double = 5
    @State private var overallTasteScore: Double = 5
    @State private var notes: String = ""

    @State private var photoData: Data?
    @State private var isShowingPhotoSourceDialog = false
    @State private var isShowingCamera = false
    @State private var photosPickerItem: PhotosPickerItem?

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    PhotoPickerButton(photoData: photoData) {
                        isShowingPhotoSourceDialog = true
                    } onRemove: {
                        photoData = nil
                    }
                }

                Section("Crust, Sauce & Toppings") {
                    ScoreSlider(label: "Crust", value: $crustScore)
                    ScoreSlider(label: "Sauce", value: $sauceScore)
                    ScoreSlider(label: "Toppings", value: $toppingsScore)
                }

                Section("Your Gut Feeling") {
                    Text("Overall taste is its own score — go with your gut, not the average of the three above.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ScoreSlider(label: "Overall Taste", value: $overallTasteScore)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(restaurant.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .confirmationDialog("Add Photo", isPresented: $isShowingPhotoSourceDialog, titleVisibility: .visible) {
                if isCameraAvailable {
                    Button("Take Photo") { isShowingCamera = true }
                }
                PhotosPicker("Choose from Library", selection: $photosPickerItem, matching: .images)
            }
            .sheet(isPresented: $isShowingCamera) {
                CameraImagePicker { image in
                    photoData = ImageProcessing.jpegData(from: image)
                    isShowingCamera = false
                }
                .ignoresSafeArea()
            }
            .onChange(of: photosPickerItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        photoData = ImageProcessing.jpegData(from: uiImage)
                    }
                    photosPickerItem = nil
                }
            }
        }
    }

    private func save() {
        let entry = PizzaEntry()
        entry.crustScore = Int(crustScore)
        entry.sauceScore = Int(sauceScore)
        entry.toppingsScore = Int(toppingsScore)
        entry.overallTasteScore = Int(overallTasteScore)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
        entry.photoData = photoData
        entry.restaurant = restaurant
        modelContext.insert(entry)
        restaurant.isTried = true
        try? modelContext.save()

        let allEntries = (try? modelContext.fetch(FetchDescriptor<PizzaEntry>())) ?? []
        AchievementEngine.evaluate(entries: allEntries, context: modelContext)

        dismiss()
    }
}

private struct PhotoPickerButton: View {
    let photoData: Data?
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        Button(action: onTap) {
            if let photoData, let uiImage = UIImage(data: photoData) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 160)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white, .black.opacity(0.6))
                            .padding(6)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .foregroundStyle(.secondary)
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        VStack(spacing: 6) {
                            Image(systemName: "camera")
                                .font(.title2)
                            Text("Add Photo")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.secondary)
                    }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct ScoreSlider: View {
    let label: String
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline.bold())
                Spacer()
                Text("\(Int(value))")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: 1...10, step: 1)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    PizzaEntryFormView(restaurant: Restaurant())
        .modelContainer(for: [Restaurant.self, PizzaEntry.self, Achievement.self], inMemory: true)
}
