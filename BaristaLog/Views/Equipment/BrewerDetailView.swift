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
        List {
            // MARK: - Hero Section
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    // Image or placeholder
                    if let imageData = brewer.imageData, let uiImage = UIImage(data: imageData) {
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
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color.brandBrown)
                            }
                    }

                    // Name and subtitle
                    VStack(alignment: .leading, spacing: 8) {
                        Text(brewer.name)
                            .font(.title)
                            .fontWeight(.bold)

                        if let brand = brewer.brand {
                            Text(brand)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }

                        if let brewType = brewer.brewType {
                            Text(brewType)
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
                    if let portafilterSize = brewer.portafilterSize {
                        LabeledContent("Portafilter", value: portafilterSize)
                    }
                    if let basketSize = brewer.basketSize {
                        LabeledContent("Basket", value: basketSize)
                    }
                    if let notes = brewer.notes, !notes.isEmpty {
                        Text(notes)
                            .foregroundStyle(.secondary)
                    }
                }
            } else if brewer.extractions?.isEmpty ?? true {
                Section {
                    VStack(spacing: 16) {
                        Text("Add portafilter size, basket\ndetails, notes and more.")
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
            if let extractions = brewer.extractions, !extractions.isEmpty {
                ExtractionPreviewSection(extractions: extractions, title: brewer.name)
            }
        }
        .contentMargins(.top, 8, for: .scrollContent)
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

    private var hasDetails: Bool {
        brewer.portafilterSize != nil ||
        brewer.basketSize != nil ||
        (brewer.notes != nil && !brewer.notes!.isEmpty)
    }

}

#Preview {
    NavigationStack {
        BrewerDetailView(brewer: PreviewContainer.sampleBrewer)
    }
    .modelContainer(PreviewContainer.container)
}
