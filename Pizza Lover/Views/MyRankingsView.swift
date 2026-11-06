//
//  MyRankingsView.swift
//  Pizza Lover
//

import SwiftUI
import SwiftData

/// Brent's preferred icy blue for anything marking a frozen pizza (toolbar
/// button + row badge) - keep both in sync with this one value.
private let frozenPizzaBlue = Color(red: 0.75, green: 0.9, blue: 1.0)

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
    @Environment(\.modelContext) private var modelContext
    @State private var sort: RankingSort = .overallTaste
    @State private var isShowingAddFrozen = false
    @State private var frozenRestaurantToLog: Restaurant?
    @State private var searchText = ""
    @Query(sort: [SortDescriptor(\PizzaEntry.overallTasteScore, order: .reverse)])
    private var entries: [PizzaEntry]

    var body: some View {
        Group {
            if entries.isEmpty {
                ContentUnavailableView {
                    Label("No Pizzas Logged Yet", systemImage: "fork.knife")
                } description: {
                    Text("Log a pizza from a restaurant's detail screen, or add a frozen pizza from home, to see it ranked here.")
                }
            } else if sortedEntries.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                List {
                    Section {
                        RankingsStatsHeader(entries: entries)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())

                    ForEach(sortedEntries) { entry in
                        NavigationLink {
                            PizzaEntryDetailView(entry: entry)
                        } label: {
                            PizzaRankingRow(entry: entry)
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
            }
        }
        .navigationTitle("My Rankings")
        .searchable(text: $searchText, prompt: "Search by restaurant")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isShowingAddFrozen = true
                } label: {
                    Image(systemName: "snowflake")
                        .foregroundStyle(frozenPizzaBlue)
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
        .sheet(isPresented: $isShowingAddFrozen) {
            AddFrozenPizzaView { restaurant in
                isShowingAddFrozen = false
                frozenRestaurantToLog = restaurant
            }
        }
        .sheet(item: $frozenRestaurantToLog) { restaurant in
            PizzaEntryFormView(restaurant: restaurant)
        }
    }

    private var sortedEntries: [PizzaEntry] {
        let filtered: [PizzaEntry]
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            filtered = entries
        } else {
            filtered = entries.filter {
                ($0.restaurant?.name ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        return filtered.sorted(using: sort.sortDescriptor)
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sortedEntries[index])
        }
        try? modelContext.save()
    }
}

/// Quick-glance totals shown above the rankings list - the app had no moment anywhere
/// that celebrated the collected data, so this surfaces it right where it's most seen.
/// Always built from the full, unfiltered `entries` list, not whatever the search/sort
/// state happens to be showing.
private struct RankingsStatsHeader: View {
    let entries: [PizzaEntry]

    private var averageOverallScore: Double {
        guard !entries.isEmpty else { return 0 }
        let total = entries.reduce(0) { $0 + $1.overallTasteScore }
        return Double(total) / Double(entries.count)
    }

    private var favoriteRestaurantName: String? {
        let counts = Dictionary(grouping: entries) { $0.restaurant?.name ?? "Unknown" }
            .mapValues(\.count)
        return counts.max { $0.value < $1.value }?.key
    }

    var body: some View {
        HStack(spacing: 0) {
            StatColumn(value: "\(entries.count)", label: entries.count == 1 ? "Pizza" : "Pizzas")
            Divider().frame(height: 36)
            StatColumn(value: String(format: "%.1f", averageOverallScore), label: "Avg Score")
            Divider().frame(height: 36)
            StatColumn(value: favoriteRestaurantName ?? "—", label: "Top Spot", isCompact: true)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

private struct StatColumn: View {
    let value: String
    let label: String
    var isCompact: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(isCompact ? .subheadline.bold() : .title3.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
    }
}

private struct PizzaRankingRow: View {
    let entry: PizzaEntry

    var body: some View {
        HStack(spacing: 12) {
            PizzaPhotoThumbnail(photoData: entry.photoData, size: 60)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 4) {
                    if entry.restaurant?.isFrozen == true {
                        Image(systemName: "snowflake")
                            .font(.subheadline)
                            .foregroundStyle(frozenPizzaBlue)
                    }
                    Text(entry.restaurant?.name ?? "Unknown Restaurant")
                        .font(.headline)
                }
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
