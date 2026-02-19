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

    private var previousExtractions: [Extraction] {
        allExtractions.filter { $0.id != extraction.id }
    }

    var body: some View {
        Form {
            // MARK: - AI Summary
            CoachingView(
                extraction: extraction,
                previousExtractions: previousExtractions
            )

            // MARK: - Equipment Section
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

            // MARK: - Grind Section
            Section("Grind") {
                LabeledContent("Grind Setting", value: extraction.grindSetting)
                if let adjustmentNotes = extraction.grinder?.adjustmentNotes {
                    LabeledContent("Grinder Range", value: adjustmentNotes)
                }
            }

            // MARK: - Measurements Section
            if extraction.doseIn != nil || extraction.yieldOut != nil || extraction.timeSeconds != nil {
                Section("Measurements") {
                    if let dose = extraction.doseIn {
                        LabeledContent("Dose In", value: "\(formatted(dose)) g")
                    }
                    if let yield = extraction.yieldOut {
                        LabeledContent("Yield Out", value: "\(formatted(yield)) g")
                    }
                    if let time = extraction.timeSeconds {
                        LabeledContent("Time", value: formatTime(time))
                    }
                    if let dose = extraction.doseIn, let yield = extraction.yieldOut, dose > 0 {
                        LabeledContent("Ratio", value: "1:\(formatted(yield / dose))")
                    }
                }
            }

            // MARK: - Rating Section
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

            // MARK: - Notes Section
            if let notes = extraction.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
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

    private func formatted(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
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
