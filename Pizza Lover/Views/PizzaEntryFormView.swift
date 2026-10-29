//
//  PizzaEntryFormView.swift
//  Pizza Lover
//

import SwiftUI
import SwiftData

struct PizzaEntryFormView: View {
    let restaurant: Restaurant

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var crustScore: Double = 5
    @State private var sauceScore: Double = 5
    @State private var toppingsScore: Double = 5
    @State private var overallTasteScore: Double = 5
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
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
        entry.restaurant = restaurant
        modelContext.insert(entry)
        restaurant.isTried = true
        try? modelContext.save()

        let allEntries = (try? modelContext.fetch(FetchDescriptor<PizzaEntry>())) ?? []
        AchievementEngine.evaluate(entries: allEntries, context: modelContext)

        dismiss()
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
