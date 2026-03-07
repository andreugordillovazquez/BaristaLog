//
//  ContentView.swift
//  Brew
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Extraction.date, order: .reverse) private var extractions: [Extraction]
    @Query(filter: #Predicate<Bean> { $0.finishedDate == nil }) private var activeBeans: [Bean]
    @Query private var grinders: [Grinder]
    @Query private var brewers: [Brewer]

    @Binding var selectedTab: AppTab
    @State private var showingAddExtraction = false
    @State private var showingAddFromRecent = false

    private var canCreateExtraction: Bool {
        !activeBeans.isEmpty && !grinders.isEmpty && !brewers.isEmpty
    }

    private var missingEquipment: [String] {
        var missing: [String] = []
        if activeBeans.isEmpty { missing.append("bean") }
        if grinders.isEmpty { missing.append("grinder") }
        if brewers.isEmpty { missing.append("brewer") }
        return missing
    }

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
            Group {
                if extractions.isEmpty {
                    if canCreateExtraction {
                        ExtractionEmptyStateView {
                            showingAddExtraction = true
                        }
                    } else {
                        SetupNeededView(missingEquipment: missingEquipment) {
                            selectedTab = .library
                        }
                    }
                } else {
                    List {
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
                                Text("\(formatSectionDate(group.date)) · \(group.extractions.count)")
                                    .textCase(nil)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.visible)
                    .headerProminence(.increased)
                }
            }
            .navigationTitle("BaristaLog")
            .toolbar {
                if canCreateExtraction {
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
        } else if let daysAgo = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: .now)).day, daysAgo < 7 {
            return date.formatted(.dateTime.weekday(.wide))
        } else {
            return date.formatted(.dateTime.day().month(.wide))
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
    @AppStorage("weightUnit") private var weightUnit: WeightUnit = .grams
    @AppStorage("weightPrecision") private var weightPrecision: WeightPrecision = .oneDecimal

    private var measurementLine: String? {
        var parts: [String] = []
        if let dose = extraction.doseIn {
            parts.append(WeightFormatter.format(grams: dose, unit: weightUnit, precision: weightPrecision))
        }
        if let yield = extraction.yieldOut {
            parts.append(WeightFormatter.format(grams: yield, unit: weightUnit, precision: weightPrecision))
        }
        let dosePart = parts.joined(separator: " → ")

        var result = dosePart
        if let time = extraction.timeSeconds {
            let timeStr = ExtractionFormatter.formatTime(time)
            if !timeStr.isEmpty {
                result = result.isEmpty ? timeStr : result + " · " + timeStr
            }
        }
        return result.isEmpty ? nil : result
    }

    private var ratioText: String? {
        guard let dose = extraction.doseIn, let yield = extraction.yieldOut, dose > 0 else { return nil }
        return "1:\(String(format: "%.1f", yield / dose))"
    }

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
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(rating) out of 5 stars")
                }
            }

            if let measurement = measurementLine {
                HStack(spacing: 6) {
                    Text(measurement)
                    if let ratio = ratioText {
                        Text("(\(ratio))")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.subheadline.monospacedDigit())
            }

            equipmentRow
                .font(.caption)
                .labelStyle(CompactIconLabelStyle(iconSpacing: 3))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var equipmentRow: some View {
        let grind = Label(extraction.grindSetting, systemImage: "slider.horizontal.3")
        let grinder = Label(extraction.grinder?.name ?? "–", systemImage: "circle.dotted")
        let brewer = Label(extraction.brewer?.name ?? "–", systemImage: "cup.and.saucer")

        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) { grind; grinder; brewer }
            VStack(alignment: .leading, spacing: 4) { grind; grinder; brewer }
        }
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

// MARK: - Extraction Empty State

struct ExtractionEmptyStateView: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.brandBrown.opacity(0.12))
                    .frame(width: 88, height: 88)
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(Color.brandBrown)
            }
            .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("No Extractions Yet")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Log your first espresso shot\nto start tracking your brews.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)

            Button(action: action) {
                Text("Log First Shot")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(minWidth: 160)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.glassProminent)
            .tint(Color.brandBrown)
            .padding(.top, 24)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Setup Needed View

struct SetupNeededView: View {
    let missingEquipment: [String]
    let onGoToLibrary: () -> Void

    private var missingText: String {
        switch missingEquipment.count {
        case 1:
            return "Add a \(missingEquipment[0]) to your Library to start logging extractions."
        case 2:
            return "Add a \(missingEquipment[0]) and \(missingEquipment[1]) to your Library to start logging."
        default:
            return "Add a bean, grinder, and brewer to your Library to start logging."
        }
    }

    var body: some View {
        ZStack {
            // Skeleton background
            List {
                ForEach(["Today", "Yesterday"], id: \.self) { section in
                    Section {
                        ForEach(0..<3, id: \.self) { _ in
                            SkeletonExtractionRow()
                        }
                    } header: {
                        Text("\(section) · 3")
                            .textCase(nil)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.visible)
            .headerProminence(.increased)
            .scrollDisabled(true)
            .blur(radius: 4)
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .black, location: 0),
                        .init(color: .black, location: 0.7),
                        .init(color: .clear, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .allowsHitTesting(false)
            .accessibilityHidden(true)

            // Overlay content
            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.brandBrown.opacity(0.12))
                        .frame(width: 88, height: 88)
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(Color.brandBrown)
                }
                .accessibilityHidden(true)

                VStack(spacing: 8) {
                    Text("Almost There")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(missingText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 260)
                }
                .padding(.top, 20)

                Button(action: onGoToLibrary) {
                    Text("Go to Library")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(minWidth: 160)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.glassProminent)
                .tint(Color.brandBrown)
                .padding(.top, 24)

                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Skeleton Extraction Row

private struct SkeletonExtractionRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 140, height: 16)
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.secondary.opacity(0.2))
                    }
                }
            }
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.secondary.opacity(0.15))
                .frame(width: 180, height: 14)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.secondary.opacity(0.1))
                .frame(width: 220, height: 12)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    ContentView(selectedTab: .constant(.extractions))
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
        let bean1 = Bean(
            name: "Ethiopia Yirgacheffe",
            roaster: "Square Mile",
            origin: "Ethiopia",
            roastDate: .now.addingTimeInterval(-12 * 86400),
            openedDate: .now.addingTimeInterval(-5 * 86400),
            notes: "Bright and complex, best at 1:2 ratio with light preinfusion.",
            process: "Washed",
            roastLevel: "Light",
            varietal: "Heirloom",
            altitude: "1800-2200",
            flavorTags: ["Floral", "Citrus", "Berry"]
        )
        let bean2 = Bean(
            name: "Colombia Huila",
            roaster: "Onyx Coffee",
            origin: "Colombia",
            roastDate: .now.addingTimeInterval(-20 * 86400),
            openedDate: .now.addingTimeInterval(-10 * 86400),
            notes: "Forgiving bean, works well across a wide grind range.",
            process: "Natural",
            roastLevel: "Medium",
            varietal: "Caturra",
            altitude: "1600-1900",
            flavorTags: ["Chocolate", "Caramel", "Nutty"]
        )
        let bean3 = Bean(
            name: "Guatemala Antigua",
            roaster: "Counter Culture",
            origin: "Guatemala",
            roastDate: .now.addingTimeInterval(-8 * 86400),
            notes: "Rich body, great for milk drinks.",
            process: "Honey",
            roastLevel: "Medium-Dark",
            varietal: "Bourbon",
            altitude: "1500-1700",
            flavorTags: ["Chocolate", "Sweet", "Spicy"]
        )

        let bean4 = Bean(
            name: "Kenya Nyeri",
            roaster: "Tim Wendelboe",
            origin: "Kenya",
            roastDate: Calendar.current.date(byAdding: .day, value: -60, to: .now),
            openedDate: Calendar.current.date(byAdding: .day, value: -45, to: .now),
            process: "Washed",
            roastLevel: "Light",
            varietal: "SL28",
            altitude: "1800-2000",
            flavorTags: ["Fruity", "Berry", "Citrus"],
            finishedDate: Calendar.current.date(byAdding: .day, value: -10, to: .now)
        )

        // Grinders
        let grinder1 = Grinder(
            name: "Niche Zero",
            brand: "Niche",
            burrType: "Conical",
            burrSize: "63mm",
            adjustmentNotes: "0-50 stepless",
            notes: "Single dose, zero retention. Great for switching between beans."
        )
        let grinder2 = Grinder(
            name: "Comandante C40",
            brand: "Comandante",
            burrType: "Conical",
            burrSize: "39mm",
            adjustmentNotes: "0-50 clicks",
            notes: "Hand grinder, best for pour over and travel."
        )

        // Brewers
        let brewer1 = Brewer(
            name: "Linea Mini",
            brand: "La Marzocco",
            brewType: "Espresso",
            portafilterSize: "58mm",
            basketSize: "18g",
            notes: "Dual boiler, PID temperature control. Warm up 25 min."
        )
        let brewer2 = Brewer(
            name: "V60 01",
            brand: "Hario",
            brewType: "Pour Over",
            notes: "Use Cafec Abaca filters for best results."
        )
        let brewer3 = Brewer(
            name: "AeroPress",
            brand: "AeroPress",
            brewType: "Immersion",
            notes: "Inverted method preferred. Metal filter for more body."
        )

        // Extractions
        let extraction1 = Extraction(
            date: .now,
            grindSetting: "15",
            doseIn: 18.0,
            yieldOut: 36.0,
            timeSeconds: 28.0,
            rating: 5,
            waterTemperature: 93.5,
            prepMethod: "WDT",
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
            waterTemperature: 96.0,
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
            waterTemperature: 92.0,
            prepMethod: "Distribution Tool",
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
            waterTemperature: 95.0,
            bean: bean1,
            grinder: grinder2,
            brewer: brewer3
        )

        // More extractions for bean1/grinder1/brewer1 to test "See All" (>5)
        let extraction5 = Extraction(
            date: .now.addingTimeInterval(-4 * 86400),
            grindSetting: "14",
            doseIn: 18.0,
            yieldOut: 38.0,
            timeSeconds: 32.0,
            rating: 4,
            notes: "Slightly over-extracted, go coarser.",
            waterTemperature: 93.0,
            prepMethod: "WDT",
            bean: bean1,
            grinder: grinder1,
            brewer: brewer1
        )

        let extraction6 = Extraction(
            date: .now.addingTimeInterval(-5 * 86400),
            grindSetting: "16",
            doseIn: 18.0,
            yieldOut: 34.0,
            timeSeconds: 26.0,
            rating: 3,
            waterTemperature: 94.0,
            bean: bean1,
            grinder: grinder1,
            brewer: brewer1
        )

        let extraction7 = Extraction(
            date: .now.addingTimeInterval(-6 * 86400),
            grindSetting: "15",
            doseIn: 18.0,
            yieldOut: 36.0,
            timeSeconds: 27.0,
            rating: 5,
            notes: "Dialed in perfectly. Sweet and balanced.",
            waterTemperature: 93.5,
            prepMethod: "WDT",
            bean: bean1,
            grinder: grinder1,
            brewer: brewer1
        )

        let extraction8 = Extraction(
            date: .now.addingTimeInterval(-7 * 86400),
            grindSetting: "13",
            doseIn: 18.0,
            yieldOut: 32.0,
            timeSeconds: 35.0,
            rating: 2,
            notes: "Choked. Way too fine.",
            waterTemperature: 93.5,
            bean: bean1,
            grinder: grinder1,
            brewer: brewer1
        )

        let extraction9 = Extraction(
            date: .now.addingTimeInterval(-8 * 86400),
            grindSetting: "15",
            doseIn: 17.0,
            yieldOut: 35.0,
            timeSeconds: 29.0,
            rating: 4,
            waterTemperature: 93.0,
            prepMethod: "Distribution Tool",
            bean: bean2,
            grinder: grinder1,
            brewer: brewer1
        )

        let extraction10 = Extraction(
            date: .now.addingTimeInterval(-9 * 86400),
            grindSetting: "24",
            doseIn: 15.0,
            yieldOut: 240.0,
            timeSeconds: 195.0,
            rating: 3,
            notes: "Longer brew time, richer body.",
            waterTemperature: 95.0,
            bean: bean3,
            grinder: grinder2,
            brewer: brewer2
        )

        context.insert(bean4)
        context.insert(extraction1)
        context.insert(extraction2)
        context.insert(extraction3)
        context.insert(extraction4)
        context.insert(extraction5)
        context.insert(extraction6)
        context.insert(extraction7)
        context.insert(extraction8)
        context.insert(extraction9)
        context.insert(extraction10)
    }

    static var sampleExtraction: Extraction {
        let bean = Bean(
            name: "Ethiopia Yirgacheffe",
            roaster: "Square Mile",
            origin: "Ethiopia",
            process: "Washed",
            roastLevel: "Light",
            varietal: "Heirloom",
            altitude: "1800-2200 masl",
            flavorTags: ["Floral", "Citrus", "Berry"]
        )
        let grinder = Grinder(name: "Niche Zero", brand: "Niche", adjustmentNotes: "0-50 stepless")
        let brewer = Brewer(name: "Linea Mini", brand: "La Marzocco", brewType: "Espresso")

        return Extraction(
            grindSetting: "15",
            doseIn: 18.0,
            yieldOut: 36.0,
            timeSeconds: 28.0,
            rating: 4,
            notes: "Sweet, fruity, slight citrus acidity. Could go finer next time.",
            waterTemperature: 93.5,
            prepMethod: "WDT",
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
            notes: "Floral, bergamot, bright citrus acidity. Best 14-28 days off roast.",
            process: "Washed",
            roastLevel: "Light",
            varietal: "Heirloom",
            altitude: "1800-2200 masl",
            flavorTags: ["Floral", "Citrus", "Berry", "Sweet"]
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
