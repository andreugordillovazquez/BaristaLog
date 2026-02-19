//
//  GrinderDetailView.swift
//  Brew
//

import SwiftUI
import SwiftData

struct GrinderDetailView: View {
    @Bindable var grinder: Grinder
    @State private var showingEditSheet = false

    var body: some View {
        Form {
            // MARK: - Photo
            if let imageData = grinder.imageData, let uiImage = UIImage(data: imageData) {
                Section {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .listRowInsets(EdgeInsets())
                }
            }

            // MARK: - Basic Info
            Section {
                LabeledContent("Name", value: grinder.name)
                if let brand = grinder.brand {
                    LabeledContent("Brand", value: brand)
                }
                if let burrType = grinder.burrType {
                    LabeledContent("Burr Type", value: burrType)
                }
                if let burrSize = grinder.burrSize {
                    LabeledContent("Burr Size", value: burrSize)
                }
            }

            // MARK: - Adjustment
            if let adjustmentNotes = grinder.adjustmentNotes {
                Section("Adjustment") {
                    Text(adjustmentNotes)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: - Notes
            if let notes = grinder.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: - Extractions
            if let extractions = grinder.extractions, !extractions.isEmpty {
                Section("Extractions (\(extractions.count))") {
                    ForEach(extractions.sorted(by: { $0.date > $1.date }).prefix(5), id: \.self) { extraction in
                        HStack {
                            Text(extraction.grindSetting)
                            Spacer()
                            Text(extraction.bean?.name ?? "–")
                                .foregroundStyle(.secondary)
                            Text(extraction.date, format: .dateTime.day().month())
                                .foregroundStyle(.secondary)
                        }
                    }
                    if extractions.count > 5 {
                        Text("and \(extractions.count - 5) more...")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Grinder")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddGrinderView(grinderToEdit: grinder)
        }
    }
}

#Preview {
    NavigationStack {
        GrinderDetailView(grinder: PreviewContainer.sampleGrinder)
    }
    .modelContainer(PreviewContainer.container)
}
