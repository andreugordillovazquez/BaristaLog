//
//  AddExtractionView.swift
//  Brew
//

import SwiftUI
import SwiftData

struct AddExtractionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Bean.name) private var beans: [Bean]
    @Query(sort: \Grinder.name) private var grinders: [Grinder]
    @Query(sort: \Brewer.name) private var brewers: [Brewer]

    @AppStorage("defaultGrinderName") private var defaultGrinderName: String = ""
    @AppStorage("defaultBrewerName") private var defaultBrewerName: String = ""

    // Existing extraction for edit mode
    var extractionToEdit: Extraction?
    // Template extraction for "From Recent"
    var basedOn: Extraction?

    @State private var selectedBean: Bean?
    @State private var selectedGrinder: Grinder?
    @State private var selectedBrewer: Brewer?
    @State private var grindSetting: String = ""
    @State private var doseIn: Double?
    @State private var yieldOut: Double?
    @State private var timeSeconds: Double?
    @State private var rating: Int?
    @State private var notes: String = ""

    @FocusState private var isGrindSettingFocused: Bool

    private var isEditing: Bool { extractionToEdit != nil }

    private var canSave: Bool {
        selectedBean != nil &&
        selectedGrinder != nil &&
        selectedBrewer != nil &&
        !grindSetting.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Required: Equipment
                Section("Equipment") {
                    Picker("Bean", selection: $selectedBean) {
                        Text("Select a bean").tag(nil as Bean?)
                        ForEach(beans) { bean in
                            Text(bean.name).tag(bean as Bean?)
                        }
                    }

                    Picker("Grinder", selection: $selectedGrinder) {
                        Text("Select a grinder").tag(nil as Grinder?)
                        ForEach(grinders) { grinder in
                            Text(grinder.name).tag(grinder as Grinder?)
                        }
                    }

                    Picker("Brewer", selection: $selectedBrewer) {
                        Text("Select a brewer").tag(nil as Brewer?)
                        ForEach(brewers) { brewer in
                            Text(brewer.name).tag(brewer as Brewer?)
                        }
                    }
                }

                // MARK: - Required: Grind
                Section("Grind") {
                    TextField("Grind Setting", text: $grindSetting)
                        .focused($isGrindSettingFocused)
                }

                // MARK: - Measurements
                Section("Measurements") {
                    HStack {
                        Text("Dose In")
                        Spacer()
                        TextField("g", value: $doseIn, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }

                    HStack {
                        Text("Yield Out")
                        Spacer()
                        TextField("g", value: $yieldOut, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }

                    HStack {
                        Text("Time")
                        Spacer()
                        TextField("sec", value: $timeSeconds, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                // MARK: - Rating
                Section("Rating") {
                    RatingPicker(rating: $rating)
                }

                // MARK: - Notes
                Section("Notes") {
                    TextField("Tasting notes, adjustments...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Extraction" : "New Extraction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExtraction()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let extraction = extractionToEdit {
                    // Edit mode - load all data
                    selectedBean = extraction.bean
                    selectedGrinder = extraction.grinder
                    selectedBrewer = extraction.brewer
                    grindSetting = extraction.grindSetting
                    doseIn = extraction.doseIn
                    yieldOut = extraction.yieldOut
                    timeSeconds = extraction.timeSeconds
                    rating = extraction.rating
                    notes = extraction.notes ?? ""
                } else if let template = basedOn {
                    // From Recent - copy equipment and settings, not notes/rating
                    selectedBean = template.bean
                    selectedGrinder = template.grinder
                    selectedBrewer = template.brewer
                    grindSetting = template.grindSetting
                    doseIn = template.doseIn
                    // Don't copy yield, time, rating, or notes - those are specific to each shot
                } else {
                    if selectedGrinder == nil, !defaultGrinderName.isEmpty {
                        selectedGrinder = grinders.first { $0.name == defaultGrinderName }
                    }
                    if selectedBrewer == nil, !defaultBrewerName.isEmpty {
                        selectedBrewer = brewers.first { $0.name == defaultBrewerName }
                    }
                }
                isGrindSettingFocused = true
            }
        }
    }

    private func saveExtraction() {
        guard let bean = selectedBean,
              let grinder = selectedGrinder,
              let brewer = selectedBrewer else { return }

        if let extraction = extractionToEdit {
            // Update existing
            extraction.bean = bean
            extraction.grinder = grinder
            extraction.brewer = brewer
            extraction.grindSetting = grindSetting.trimmingCharacters(in: .whitespaces)
            extraction.doseIn = doseIn
            extraction.yieldOut = yieldOut
            extraction.timeSeconds = timeSeconds
            extraction.rating = rating
            extraction.notes = notes.isEmpty ? nil : notes
        } else {
            // Create new
            let extraction = Extraction(
                grindSetting: grindSetting.trimmingCharacters(in: .whitespaces),
                doseIn: doseIn,
                yieldOut: yieldOut,
                timeSeconds: timeSeconds,
                rating: rating,
                notes: notes.isEmpty ? nil : notes,
                bean: bean,
                grinder: grinder,
                brewer: brewer
            )
            modelContext.insert(extraction)
        }

        dismiss()
    }
}

// MARK: - Rating Picker

struct RatingPicker: View {
    @Binding var rating: Int?

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    if rating == star {
                        rating = nil // Tap again to clear
                    } else {
                        rating = star
                    }
                } label: {
                    Image(systemName: (rating ?? 0) >= star ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundStyle((rating ?? 0) >= star ? .yellow : .secondary)
                }
                .buttonStyle(.plain)
            }
            Spacer()
            if rating != nil {
                Button("Clear") {
                    rating = nil
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview("Add") {
    AddExtractionView()
        .modelContainer(PreviewContainer.container)
}

#Preview("Edit") {
    AddExtractionView(extractionToEdit: PreviewContainer.sampleExtraction)
        .modelContainer(PreviewContainer.container)
}
