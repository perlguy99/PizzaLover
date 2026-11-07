//
//  PizzaEntryDetailView.swift
//  Pizza Lover
//

import SwiftUI

/// Full detail screen for a single logged `PizzaEntry`, reached by tapping a row in
/// `MyRankingsView`. Shows the photo (if one was taken), the restaurant, the date,
/// all 4 scores, and any notes.
struct PizzaEntryDetailView: View {
    let entry: PizzaEntry

    @State private var isShowingEditSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let photoData = entry.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityLabel("Photo of the pizza")
                } else {
                    ContentUnavailableView {
                        Label("No Photo", systemImage: "camera")
                    }
                    .frame(height: 160)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.restaurant?.name ?? "Unknown Restaurant")
                        .font(.title2)
                        .bold()
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let style = entry.style, !style.isEmpty {
                        Text(style)
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.quaternary, in: Capsule())
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Scores")
                        .font(.headline)
                    ScoreRow(label: "Crust", value: entry.crustScore)
                    ScoreRow(label: "Sauce", value: entry.sauceScore)
                    ScoreRow(label: "Toppings", value: entry.toppingsScore)
                    Divider()
                    ScoreRow(label: "Overall Taste", value: entry.overallTasteScore)
                }
                .padding(.vertical, 8)

                if let notes = entry.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.headline)
                        Text(notes)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Pizza Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { isShowingEditSheet = true }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            PizzaEntryFormView(existingEntry: entry)
        }
    }
}

private struct ScoreRow: View {
    let label: String
    let value: Int

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(value)/10")
                .bold()
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let entry = PizzaEntry()
    entry.crustScore = 8
    entry.sauceScore = 7
    entry.toppingsScore = 9
    entry.overallTasteScore = 9
    entry.notes = "Great crust, a little light on sauce."

    return NavigationStack {
        PizzaEntryDetailView(entry: entry)
    }
}
