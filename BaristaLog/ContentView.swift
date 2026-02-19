//
//  ContentView.swift
//  Brew
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Extraction.date, order: .reverse) private var extractions: [Extraction]

    @State private var showingAddExtraction = false
    @State private var showingAddFromRecent = false

    private var mostRecentExtraction: Extraction? {
        extractions.first
    }

    private var groupedExtractions: [(date: Date, extractions: [Extraction])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: extractions) { extraction in
            calendar.startOfDay(for: extraction.date)
        }
        return grouped.sorted { $0.key > $1.key }
            .map { (date: $0.key, extractions: $0.value) }
    }

    var body: some View {
        NavigationStack {
            List {
                if extractions.isEmpty {
                    ContentUnavailableView(
                        "No Extractions",
                        systemImage: "cup.and.saucer",
                        description: Text("Add your first shot to get started.")
                    )
                } else {
                    ForEach(groupedExtractions, id: \.date) { group in
                        Section {
                            ForEach(group.extractions) { extraction in
                                NavigationLink {
                                    ExtractionDetailView(extraction: extraction)
                                } label: {
                                    ExtractionRowView(extraction: extraction)
                                }
                            }
                            .onDelete { offsets in
                                deleteExtractions(from: group.extractions, at: offsets)
                            }
                        } header: {
                            Text(formatSectionDate(group.date))
                                .textCase(nil)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.visible)
            .headerProminence(.increased)
            .navigationTitle("BaristaLog")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAddExtraction = true
                        } label: {
                            Label("New Extraction", systemImage: "plus")
                        }

                        if mostRecentExtraction != nil {
                            Button {
                                showingAddFromRecent = true
                            } label: {
                                Label("From Recent", systemImage: "doc.on.doc")
                            }
                        }
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExtraction) {
                AddExtractionView()
            }
            .sheet(isPresented: $showingAddFromRecent) {
                if let recent = mostRecentExtraction {
                    AddExtractionView(basedOn: recent)
                }
            }
        }
    }

    private func formatSectionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(.dateTime.weekday(.wide).day().month(.wide))
        }
    }

    private func deleteExtractions(from group: [Extraction], at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(group[index])
            }
        }
    }
}

// MARK: - Extraction Row

struct ExtractionRowView: View {
    let extraction: Extraction

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(extraction.bean?.name ?? "Unknown Bean")
                    .font(.headline)
                Spacer()
                if let rating = extraction.rating {
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundStyle(star <= rating ? .yellow : .secondary)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Label(extraction.grindSetting, systemImage: "slider.horizontal.3")
                Label(extraction.grinder?.name ?? "–", systemImage: "circle.dotted")
                Label(extraction.brewer?.name ?? "–", systemImage: "cup.and.saucer")
            }
            .font(.subheadline)
            .labelStyle(CompactIconLabelStyle(iconSpacing: 4))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Compact Label Style

struct CompactIconLabelStyle: LabelStyle {
    var iconSpacing: CGFloat = 4

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: iconSpacing) {
            configuration.icon
                .font(.subheadline)
                .imageScale(.small)
            configuration.title
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(PreviewContainer.shared.container)
}

// MARK: - Preview Container

@MainActor
enum PreviewContainer {
    static let shared = PreviewContainer.create()

    static func create() -> Self.Type {
        return self
    }

    static var container: ModelContainer {
        let schema = Schema([
            Extraction.self,
            Bean.self,
            Grinder.self,
            Brewer.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            insertSampleData(into: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }

    static func insertSampleData(into context: ModelContext) {
        // Beans
        let bean1 = Bean(name: "Ethiopia Yirgacheffe", roaster: "Square Mile", origin: "Ethiopia")
        let bean2 = Bean(name: "Colombia Huila", roaster: "Onyx Coffee", origin: "Colombia")
        let bean3 = Bean(name: "Guatemala Antigua", roaster: "Counter Culture", origin: "Guatemala")

        // Grinders
        let grinder1 = Grinder(name: "Niche Zero", brand: "Niche", adjustmentNotes: "0-50 stepless")
        let grinder2 = Grinder(name: "Comandante C40", brand: "Comandante", adjustmentNotes: "0-50 clicks")

        // Brewers
        let brewer1 = Brewer(name: "Linea Mini", brand: "La Marzocco", brewType: "Espresso")
        let brewer2 = Brewer(name: "V60 01", brand: "Hario", brewType: "Pour Over")
        let brewer3 = Brewer(name: "AeroPress", brand: "AeroPress", brewType: "Immersion")

        // Extractions
        let extraction1 = Extraction(
            date: .now,
            grindSetting: "15",
            doseIn: 18.0,
            yieldOut: 36.0,
            timeSeconds: 28.0,
            rating: 5,
            bean: bean1,
            grinder: grinder1,
            brewer: brewer1
        )

        let extraction2 = Extraction(
            date: .now.addingTimeInterval(-86400),
            grindSetting: "22",
            doseIn: 15.0,
            yieldOut: 250.0,
            timeSeconds: 180.0,
            rating: 4,
            bean: bean2,
            grinder: grinder2,
            brewer: brewer2
        )

        let extraction3 = Extraction(
            date: .now.addingTimeInterval(-172800),
            grindSetting: "18",
            doseIn: 17.5,
            yieldOut: 35.0,
            timeSeconds: 30.0,
            rating: 3,
            bean: bean3,
            grinder: grinder1,
            brewer: brewer1
        )

        let extraction4 = Extraction(
            date: .now.addingTimeInterval(-259200),
            grindSetting: "28",
            doseIn: 15.0,
            yieldOut: 220.0,
            timeSeconds: 120.0,
            notes: "Inverted method, 2 min steep",
            bean: bean1,
            grinder: grinder2,
            brewer: brewer3
        )

        context.insert(extraction1)
        context.insert(extraction2)
        context.insert(extraction3)
        context.insert(extraction4)
    }

    static var sampleExtraction: Extraction {
        let bean = Bean(name: "Ethiopia Yirgacheffe", roaster: "Square Mile", origin: "Ethiopia")
        let grinder = Grinder(name: "Niche Zero", brand: "Niche", adjustmentNotes: "0-50 stepless")
        let brewer = Brewer(name: "Linea Mini", brand: "La Marzocco", brewType: "Espresso")

        return Extraction(
            grindSetting: "15",
            doseIn: 18.0,
            yieldOut: 36.0,
            timeSeconds: 28.0,
            rating: 4,
            notes: "Sweet, fruity, slight citrus acidity. Could go finer next time.",
            bean: bean,
            grinder: grinder,
            brewer: brewer
        )
    }

    static var sampleBean: Bean {
        Bean(
            name: "Ethiopia Yirgacheffe",
            roaster: "Square Mile",
            origin: "Ethiopia",
            roastDate: Calendar.current.date(byAdding: .day, value: -14, to: .now),
            openedDate: Calendar.current.date(byAdding: .day, value: -7, to: .now),
            notes: "Floral, bergamot, bright citrus acidity. Best 14-28 days off roast."
        )
    }

    static var sampleGrinder: Grinder {
        Grinder(
            name: "Niche Zero",
            brand: "Niche",
            adjustmentNotes: "0-50 stepless, espresso around 10-15",
            notes: "63mm conical burrs. Clean weekly."
        )
    }

    static var sampleBrewer: Brewer {
        Brewer(
            name: "Linea Mini",
            brand: "La Marzocco",
            brewType: "Espresso",
            notes: "18g VST basket. 9 bar pressure."
        )
    }
}
