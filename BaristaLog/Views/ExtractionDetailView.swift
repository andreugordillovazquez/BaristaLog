//
//  ExtractionDetailView.swift
//  Brew
//

import SwiftUI
import SwiftData

struct ExtractionDetailView: View {
    @Bindable var extraction: Extraction
    @Query(sort: \Extraction.date, order: .reverse) private var allExtractions: [Extraction]
    @State private var showingEditSheet = false
    @AppStorage("weightUnit") private var weightUnit: WeightUnit = .grams
    @AppStorage("weightPrecision") private var weightPrecision: WeightPrecision = .oneDecimal

    private var previousExtractions: [Extraction] {
        allExtractions.filter { $0.id != extraction.id }
    }

    private var ratioValue: Double? {
        guard let dose = extraction.doseIn, let yield = extraction.yieldOut, dose > 0 else { return nil }
        return yield / dose
    }

    var body: some View {
        List {
            // MARK: - Shot Hero Card
            Section {
                shotHeroCard
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            // MARK: - AI Coaching
            CoachingView(
                extraction: extraction,
                previousExtractions: previousExtractions
            )

            // MARK: - Equipment
            Section("Equipment") {
                LabeledContent("Bean", value: extraction.bean?.name ?? "–")
                if let roaster = extraction.bean?.roaster {
                    LabeledContent("Roaster", value: roaster)
                }
                LabeledContent("Grinder", value: extraction.grinder?.name ?? "–")
                LabeledContent("Brewer", value: extraction.brewer?.name ?? "–")
                if let brewType = extraction.brewer?.brewType {
                    LabeledContent("Brew Type", value: brewType)
                }
            }

            // MARK: - Grind
            Section("Grind") {
                LabeledContent("Grind Setting", value: extraction.grindSetting)
                if let adjustmentNotes = extraction.grinder?.adjustmentNotes {
                    LabeledContent("Grinder Range", value: adjustmentNotes)
                }
            }

            // MARK: - Rating
            if let rating = extraction.rating {
                Section("Rating") {
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .foregroundStyle(star <= rating ? .yellow : .secondary)
                        }
                    }
                    .font(.title3)
                }
            }

            // MARK: - Notes
            if let notes = extraction.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.visible)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text("Extraction")
                        .font(.headline)
                    Text(extraction.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated).hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddExtractionView(extractionToEdit: extraction)
        }
    }

    // MARK: - Shot Hero Card

    @ViewBuilder
    private var shotHeroCard: some View {
        VStack(spacing: 20) {
            // Ratio hero
            if let ratio = ratioValue {
                VStack(spacing: 4) {
                    Text("1:\(String(format: "%.1f", ratio))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.brandBrown)
                    Text("ratio")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
            }

            // Measurement pills
            HStack(spacing: 0) {
                if let dose = extraction.doseIn {
                    let unitLabel = WeightFormatter.unitLabel(for: weightUnit)
                    metricCell(value: WeightFormatter.formatValue(grams: dose, unit: weightUnit, precision: weightPrecision), unit: unitLabel, label: "Dose")
                }
                if extraction.doseIn != nil && extraction.yieldOut != nil {
                    Divider().frame(height: 36)
                }
                if let yield = extraction.yieldOut {
                    let unitLabel = WeightFormatter.unitLabel(for: weightUnit)
                    metricCell(value: WeightFormatter.formatValue(grams: yield, unit: weightUnit, precision: weightPrecision), unit: unitLabel, label: "Yield")
                }
                if (extraction.doseIn != nil || extraction.yieldOut != nil) && extraction.timeSeconds != nil {
                    Divider().frame(height: 36)
                }
                if let time = extraction.timeSeconds {
                    metricCell(value: formatTime(time), unit: "", label: "Time")
                }
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func metricCell(value: String, unit: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                Text(value)
                    .font(.title2.bold().monospacedDigit())
                if !unit.isEmpty {
                    Text(unit)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if mins > 0 {
            return "\(mins)m \(secs)s"
        }
        return "\(secs)s"
    }
}

#Preview {
    NavigationStack {
        ExtractionDetailView(extraction: PreviewContainer.sampleExtraction)
    }
    .modelContainer(PreviewContainer.container)
}
