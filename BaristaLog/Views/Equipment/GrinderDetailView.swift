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
        List {
            // MARK: - Hero Section
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    // Image or placeholder
                    if let imageData = grinder.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.brandBrown.opacity(0.12))
                            .frame(height: 160)
                            .overlay {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color.brandBrown)
                            }
                    }

                    // Name and subtitle
                    VStack(alignment: .leading, spacing: 8) {
                        Text(grinder.name)
                            .font(.title)
                            .fontWeight(.bold)

                        if let brand = grinder.brand {
                            Text(brand)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }

                        if let adjustmentNotes = grinder.adjustmentNotes {
                            Text(adjustmentNotes)
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .listRowInsets(EdgeInsets())
                .padding(.horizontal, 20)
                .padding(.top, 0)
                .padding(.bottom, 0)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            // MARK: - Details
            if hasDetails {
                Section {
                    if let burrType = grinder.burrType {
                        LabeledContent("Burr Type", value: burrType)
                    }
                    if let burrSize = grinder.burrSize {
                        LabeledContent("Burr Size", value: burrSize)
                    }
                    if let notes = grinder.notes, !notes.isEmpty {
                        Text(notes)
                            .foregroundStyle(.secondary)
                    }
                }
            } else if grinder.extractions?.isEmpty ?? true {
                Section {
                    VStack(spacing: 16) {
                        Text("Add burr type, burr size,\nnotes and more.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button {
                            showingEditSheet = true
                        } label: {
                            Text("Add Details")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(Color.brandBrown)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .listRowBackground(Color.clear)
            }

            // MARK: - Extractions
            if let extractions = grinder.extractions, !extractions.isEmpty {
                ExtractionPreviewSection(extractions: extractions, title: grinder.name)
            }
        }
        .contentMargins(.top, 8, for: .scrollContent)
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

    private var hasDetails: Bool {
        grinder.burrType != nil ||
        grinder.burrSize != nil ||
        (grinder.notes != nil && !grinder.notes!.isEmpty)
    }

}

#Preview {
    NavigationStack {
        GrinderDetailView(grinder: PreviewContainer.sampleGrinder)
    }
    .modelContainer(PreviewContainer.container)
}
