//
//  BrewerDetailView.swift
//  Brew
//

import SwiftUI
import SwiftData

struct BrewerDetailView: View {
    @Bindable var brewer: Brewer
    @State private var showingEditSheet = false

    var body: some View {
        Form {
            // MARK: - Photo
            if let imageData = brewer.imageData, let uiImage = UIImage(data: imageData) {
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
                LabeledContent("Name", value: brewer.name)
                if let brand = brewer.brand {
                    LabeledContent("Brand", value: brand)
                }
                if let brewType = brewer.brewType {
                    LabeledContent("Type", value: brewType)
                }
                if let portafilterSize = brewer.portafilterSize {
                    LabeledContent("Portafilter", value: portafilterSize)
                }
                if let basketSize = brewer.basketSize {
                    LabeledContent("Basket", value: basketSize)
                }
            }

            // MARK: - Notes
            if let notes = brewer.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: - Extractions
            if let extractions = brewer.extractions, !extractions.isEmpty {
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
        .navigationTitle("Brewer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddBrewerView(brewerToEdit: brewer)
        }
    }
}

#Preview {
    NavigationStack {
        BrewerDetailView(brewer: PreviewContainer.sampleBrewer)
    }
    .modelContainer(PreviewContainer.container)
}
