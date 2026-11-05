//
//  AddFrozenPizzaView.swift
//  Pizza Lover
//

import SwiftUI
import SwiftData

/// Captures just the brand/pizza name for a store-bought frozen pizza logged
/// from home, then hands the created-or-reused Restaurant back to the caller
/// so it can move straight into PizzaEntryFormView to log the actual tasting.
struct AddFrozenPizzaView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    let onCreated: (Restaurant) -> Void

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Brand & Pizza Name") {
                    TextField("e.g. DiGiorno Rising Crust Pepperoni", text: $name)
                }
            }
            .navigationTitle("Add Frozen Pizza")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Next") {
                        let restaurant = Restaurant.findOrCreateFrozen(name: trimmedName, in: modelContext)
                        try? modelContext.save()
                        onCreated(restaurant)
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddFrozenPizzaView { _ in }
        .modelContainer(for: [Restaurant.self, PizzaEntry.self, Achievement.self], inMemory: true)
}
