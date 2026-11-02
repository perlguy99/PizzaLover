//
//  PizzaEntryFormView.swift
//  Pizza Lover
//

import SwiftUI
import SwiftData
import PhotosUI

struct PizzaEntryFormView: View {
    /// Set when logging a brand-new pizza; nil when editing an existing one.
    let restaurant: Restaurant?
    /// Set when editing an existing pizza; nil when logging a new one.
    let existingEntry: PizzaEntry?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var crustScore: Double
    @State private var sauceScore: Double
    @State private var toppingsScore: Double
    @State private var overallTasteScore: Double
    @State private var notes: String

    @State private var photoData: Data?
    @State private var isShowingPhotoSourceDialog = false
    @State private var isShowingCamera = false
    @State private var isShowingPhotoLibraryPicker = false
    @State private var photosPickerItem: PhotosPickerItem?

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    private var navigationTitle: String {
        if existingEntry != nil {
            return "Edit Pizza"
        }
        return restaurant?.name ?? ""
    }

    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        self.existingEntry = nil
        _crustScore = State(initialValue: 5)
        _sauceScore = State(initialValue: 5)
        _toppingsScore = State(initialValue: 5)
        _overallTasteScore = State(initialValue: 5)
        _notes = State(initialValue: "")
        _photoData = State(initialValue: nil)
    }

    init(existingEntry: PizzaEntry) {
        self.restaurant = nil
        self.existingEntry = existingEntry
        _crustScore = State(initialValue: Double(existingEntry.crustScore))
        _sauceScore = State(initialValue: Double(existingEntry.sauceScore))
        _toppingsScore = State(initialValue: Double(existingEntry.toppingsScore))
        _overallTasteScore = State(initialValue: Double(existingEntry.overallTasteScore))
        _notes = State(initialValue: existingEntry.notes ?? "")
        _photoData = State(initialValue: existingEntry.photoData)
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
            .navigationTitle(navigationTitle)
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
                Button("Choose from Library") { isShowingPhotoLibraryPicker = true }
            }
            .sheet(isPresented: $isShowingCamera) {
                CameraImagePicker { image in
                    photoData = ImageProcessing.jpegData(from: image)
                    isShowingCamera = false
                }
                .ignoresSafeArea()
            }
            .photosPicker(isPresented: $isShowingPhotoLibraryPicker, selection: $photosPickerItem, matching: .images)
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
        let entry = existingEntry ?? PizzaEntry()
        entry.crustScore = Int(crustScore)
        entry.sauceScore = Int(sauceScore)
        entry.toppingsScore = Int(toppingsScore)
        entry.overallTasteScore = Int(overallTasteScore)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
        entry.photoData = photoData

        if existingEntry == nil, let restaurant {
            entry.restaurant = restaurant
            modelContext.insert(entry)
            restaurant.isTried = true
        }
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
