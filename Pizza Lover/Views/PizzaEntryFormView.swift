//
//  PizzaEntryFormView.swift
//  Pizza Lover
//

import SwiftUI
import SwiftData

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
    @State private var selectedStyle: String
    @State private var newStyleText: String = ""

    @Query(sort: \PizzaEntry.date) private var allEntries: [PizzaEntry]

    /// Sentinel tag for the "Add New Style..." picker row - never saved as-is,
    /// just triggers showing the free-text field below it.
    private let addNewStyleTag = "__add_new_style__"

    /// Presets plus any style someone already typed in before, so a custom
    /// style only ever needs to be typed once.
    private var knownStyles: [String] {
        let customStyles = Set(allEntries.compactMap(\.style)).subtracting(PizzaStyleOptions.presets)
        return PizzaStyleOptions.presets + customStyles.sorted()
    }

    /// What actually gets saved: the typed name if "Add New Style…" is
    /// selected, otherwise whatever's picked (nil for "None").
    private var resolvedStyle: String? {
        if selectedStyle == addNewStyleTag {
            let trimmed = newStyleText.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        return selectedStyle.isEmpty ? nil : selectedStyle
    }

    @State private var photoData: Data?
    @State private var isShowingPhotoSourceDialog = false
    @State private var isShowingCamera = false
    @State private var isShowingLibraryPicker = false
    @State private var isShowingDeleteConfirmation = false
    /// Set by Cancel/Save/Delete right before they dismiss, so onDisappear
    /// can tell "the user chose to leave" apart from an interactive swipe-down
    /// - only the latter should fall back to an implicit save.
    @State private var didDismissExplicitly = false
    @State private var newlyEarnedAchievements: [AchievementDefinition] = []

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
        _selectedStyle = State(initialValue: "")
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
        _selectedStyle = State(initialValue: existingEntry.style ?? "")
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

                Section("Style") {
                    Picker("Style", selection: $selectedStyle) {
                        Text("None").tag("")
                        ForEach(knownStyles, id: \.self) { style in
                            Text(style).tag(style)
                        }
                        Text("Add New Style…").tag(addNewStyleTag)
                    }
                    if selectedStyle == addNewStyleTag {
                        TextField("New style name", text: $newStyleText)
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

                if existingEntry != nil {
                    Section {
                        Button("Delete Pizza Entry", role: .destructive) {
                            isShowingDeleteConfirmation = true
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        didDismissExplicitly = true
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .confirmationDialog("Add Photo", isPresented: $isShowingPhotoSourceDialog, titleVisibility: .visible) {
                if isCameraAvailable {
                    Button("Take Photo") { isShowingCamera = true }
                }
                Button("Choose from Library") { isShowingLibraryPicker = true }
            }
            .sheet(isPresented: $isShowingCamera) {
                ImagePicker(sourceType: .camera) { image in
                    photoData = ImageProcessing.jpegData(from: image)
                    isShowingCamera = false
                } onCancel: {
                    isShowingCamera = false
                }
                .ignoresSafeArea()
            }
            .sheet(isPresented: $isShowingLibraryPicker) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    photoData = ImageProcessing.jpegData(from: image)
                    isShowingLibraryPicker = false
                } onCancel: {
                    isShowingLibraryPicker = false
                }
                .ignoresSafeArea()
            }
            .confirmationDialog("Delete this pizza entry? This can't be undone.", isPresented: $isShowingDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete Pizza Entry", role: .destructive) {
                    deleteExistingEntry()
                }
            }
            // Swiping the sheet away (instead of tapping Save) used to silently
            // discard whatever had been entered, including an already-attached
            // photo - Brent lost a logged pizza this way. Cancel/Delete still
            // discard on purpose (that's their whole point, see
            // didDismissExplicitly below); any other way this view disappears
            // now persists what's there instead of throwing it away.
            .onDisappear {
                if !didDismissExplicitly {
                    persistEntry()
                }
            }
            .overlay(alignment: .top) {
                if !newlyEarnedAchievements.isEmpty {
                    AchievementUnlockedBanner(definitions: newlyEarnedAchievements)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(duration: 0.4), value: newlyEarnedAchievements)
        }
    }

    private func save() {
        let newlyEarned = persistEntry()
        didDismissExplicitly = true
        guard !newlyEarned.isEmpty else {
            dismiss()
            return
        }
        // Let the "Achievement Unlocked" banner actually be seen before the sheet
        // closes - dismissing immediately would hide it before it could render.
        newlyEarnedAchievements = newlyEarned
        Task {
            try? await Task.sleep(for: .seconds(1.6))
            dismiss()
        }
    }

    @discardableResult
    private func persistEntry() -> [AchievementDefinition] {
        let entry = existingEntry ?? PizzaEntry()
        entry.crustScore = Int(crustScore)
        entry.sauceScore = Int(sauceScore)
        entry.toppingsScore = Int(toppingsScore)
        entry.overallTasteScore = Int(overallTasteScore)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
        entry.photoData = photoData
        entry.style = resolvedStyle

        if existingEntry == nil, let restaurant {
            entry.restaurant = restaurant
            modelContext.insert(entry)
            restaurant.isTried = true
        }
        try? modelContext.save()

        let allEntries = (try? modelContext.fetch(FetchDescriptor<PizzaEntry>())) ?? []
        let allRestaurants = (try? modelContext.fetch(FetchDescriptor<Restaurant>())) ?? []
        return AchievementEngine.evaluate(entries: allEntries, restaurants: allRestaurants, context: modelContext)
    }

    private func deleteExistingEntry() {
        guard let existingEntry else { return }
        didDismissExplicitly = true
        modelContext.delete(existingEntry)
        try? modelContext.save()
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
