//
//  ExtractionListItems.swift
//  BaristaLog
//

import SwiftUI

/// Reusable row for displaying an extraction summary in a list
struct ExtractionPreviewRow: View {
    let extraction: Extraction

    var body: some View {
        NavigationLink {
            ExtractionDetailView(extraction: extraction)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(ExtractionFormatter.summary(extraction))
                        .font(.subheadline)
                    Text(extraction.date, format: .dateTime.day().month(.abbreviated).year())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let rating = extraction.rating {
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .foregroundStyle(star <= rating ? Color.brandBrown : .secondary)
                        }
                    }
                    .font(.caption2)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

/// Reusable section showing a preview of extractions with a "See All" link
struct ExtractionPreviewSection: View {
    let extractions: [Extraction]
    let title: String

    private var sorted: [Extraction] {
        extractions.sorted { $0.date > $1.date }
    }

    var body: some View {
        Section("Extractions (\(extractions.count))") {
            ForEach(Array(sorted.prefix(5))) { extraction in
                ExtractionPreviewRow(extraction: extraction)
            }
            if extractions.count > 5 {
                NavigationLink {
                    AllExtractionsView(extractions: extractions, title: title)
                } label: {
                    Text("See All \(extractions.count) Extractions")
                        .foregroundStyle(Color.brandBrown)
                }
            }
        }
    }
}

/// Full list of extractions for a given equipment or bean
struct AllExtractionsView: View {
    let extractions: [Extraction]
    let title: String

    private var sorted: [Extraction] {
        extractions.sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            ForEach(sorted) { extraction in
                ExtractionPreviewRow(extraction: extraction)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
