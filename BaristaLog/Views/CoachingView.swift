//
//  CoachingView.swift
//  Brew
//

import SwiftUI
import SwiftData

struct CoachingView: View {
    let extraction: Extraction
    let previousExtractions: [Extraction]

    @AppStorage("aiCoachingEnabled") private var aiCoachingEnabled = true
    @State private var coach = BaristaCoach()

    var body: some View {
        Section {
            if !aiCoachingEnabled {
                Label("Apple Intelligence turned off", systemImage: "sparkles.slash")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if !coach.isAvailable {
                Label("Apple Intelligence not available", systemImage: "sparkles.slash")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if coach.isAnalyzing {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Analyzing...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let summary = coach.summary {
                Label {
                    Text(summary)
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Color.brandBrown)
                }
            } else {
                Button {
                    Task {
                        await coach.analyze(
                            extraction: extraction,
                            previousExtractions: previousExtractions
                        )
                    }
                } label: {
                    Label("Get Coaching Tips", systemImage: "sparkles")
                }
            }
        }
    }
}

#Preview {
    Form {
        CoachingView(
            extraction: PreviewContainer.sampleExtraction,
            previousExtractions: []
        )
    }
    .modelContainer(PreviewContainer.container)
}
