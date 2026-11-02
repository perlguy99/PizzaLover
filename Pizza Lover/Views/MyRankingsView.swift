//
//  MyRankingsView.swift
//  Pizza Lover
//

import SwiftUI
import SwiftData

private enum RankingSort: String, CaseIterable, Identifiable {
    case overallTaste = "Overall"
    case crust = "Crust"
    case sauce = "Sauce"
    case toppings = "Toppings"
    case date = "Date"

    var id: String { rawValue }

    var sortDescriptor: SortDescriptor<PizzaEntry> {
        switch self {
        case .overallTaste: SortDescriptor(\PizzaEntry.overallTasteScore, order: .reverse)
        case .crust: SortDescriptor(\PizzaEntry.crustScore, order: .reverse)
        case .sauce: SortDescriptor(\PizzaEntry.sauceScore, order: .reverse)
        case .toppings: SortDescriptor(\PizzaEntry.toppingsScore, order: .reverse)
        case .date: SortDescriptor(\PizzaEntry.date, order: .reverse)
        }
    }
}

struct MyRankingsView: View {
    @State private var sort: RankingSort = .overallTaste
    @Query(sort: [SortDescriptor(\PizzaEntry.overallTasteScore, order: .reverse)])
    private var entries: [PizzaEntry]

    var body: some View {
        Group {
            if sortedEntries.isEmpty {
                ContentUnavailableView {
                    Label("No Pizzas Logged Yet", systemImage: "fork.knife")
                } description: {
                    Text("Log a pizza from a restaurant's detail screen to see it ranked here.")
                }
            } else {
                List(sortedEntries) { entry in
                    NavigationLink {
                        PizzaEntryDetailView(entry: entry)
                    } label: {
                        PizzaRankingRow(entry: entry)
                    }
                }
            }
        }
        .navigationTitle("My Rankings")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Picker("Sort By", selection: $sort) {
                    ForEach(RankingSort.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            }
        }
    }

    private var sortedEntries: [PizzaEntry] {
        entries.sorted(using: sort.sortDescriptor)
    }
}

private struct PizzaRankingRow: View {
    let entry: PizzaEntry

    var body: some View {
        HStack(spacing: 12) {
            PizzaPhotoThumbnail(photoData: entry.photoData, size: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.restaurant?.name ?? "Unknown Restaurant")
                    .font(.headline)
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Crust \(entry.crustScore) · Sauce \(entry.sauceScore) · Toppings \(entry.toppingsScore) · Overall \(entry.overallTasteScore)")
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        MyRankingsView()
    }
    .modelContainer(for: [Restaurant.self, PizzaEntry.self, Achievement.self], inMemory: true)
}
