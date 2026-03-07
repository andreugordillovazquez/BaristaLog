//
//  BeanDetailView.swift
//  Brew
//

import SwiftUI
import SwiftData

struct BeanDetailView: View {
    @Bindable var bean: Bean
    @State private var showingEditSheet = false

    var body: some View {
        List {
            // MARK: - Hero Section
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    // Image or placeholder
                    if let imageData = bean.imageData, let uiImage = UIImage(data: imageData) {
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
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color.brandBrown)
                            }
                    }

                    // Name, subtitle, freshness, and flavor tags
                    VStack(alignment: .leading, spacing: 8) {
                        Text(bean.name)
                            .font(.title)
                            .fontWeight(.bold)

                        if bean.roaster != nil || bean.origin != nil {
                            Text([bean.roaster, bean.origin].compactMap { $0 }.joined(separator: " · "))
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }

                        if let roastDate = bean.roastDate {
                            Text("Roasted \(daysSince(roastDate)) days ago")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }

                        // Flavor tags
                        if let tags = bean.flavorTags, !tags.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.brandBrown.opacity(0.15))
                                        .foregroundStyle(Color.brandBrown)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.top, 2)
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
                    if let process = bean.process {
                        LabeledContent("Process", value: process)
                    }
                    if let roastLevel = bean.roastLevel {
                        LabeledContent("Roast Level", value: roastLevel)
                    }
                    if let varietal = bean.varietal {
                        LabeledContent("Varietal", value: varietal)
                    }
                    if let altitude = bean.altitude {
                        LabeledContent("Altitude", value: "\(altitude) masl")
                    }
                    if let roastDate = bean.roastDate {
                        LabeledContent("Roast Date", value: roastDate, format: .dateTime.day().month().year())
                    }
                    if let openedDate = bean.openedDate {
                        LabeledContent("Opened", value: openedDate, format: .dateTime.day().month().year())
                    }
                    if let notes = bean.notes, !notes.isEmpty {
                        Text(notes)
                            .foregroundStyle(.secondary)
                    }
                }
            } else if bean.extractions?.isEmpty ?? true {
                Section {
                    VStack(spacing: 16) {
                        Text("Add origin, roast level, flavor\nnotes and more.")
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
            if let extractions = bean.extractions, !extractions.isEmpty {
                Section("Extractions (\(extractions.count))") {
                    ForEach(Array(extractions.sorted(by: { $0.date > $1.date }).prefix(5))) { extraction in
                        NavigationLink {
                            ExtractionDetailView(extraction: extraction)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(extractionSummary(extraction))
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
                    if extractions.count > 5 {
                        Text("and \(extractions.count - 5) more...")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .contentMargins(.top, 8, for: .scrollContent)
        .navigationTitle("Bean")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddBeanView(beanToEdit: bean)
        }
    }

    private var hasDetails: Bool {
        bean.process != nil ||
        bean.roastLevel != nil ||
        bean.varietal != nil ||
        bean.altitude != nil ||
        bean.roastDate != nil ||
        bean.openedDate != nil ||
        (bean.notes != nil && !bean.notes!.isEmpty)
    }

    private func extractionSummary(_ extraction: Extraction) -> String {
        var parts: [String] = []
        if let dose = extraction.doseIn {
            parts.append(String(format: "%.1fg", dose))
        }
        if let yield = extraction.yieldOut {
            parts.append(String(format: "%.1fg", yield))
        }
        let recipe = parts.joined(separator: " → ")

        if let time = extraction.timeSeconds {
            let timeStr = formatTime(time)
            return recipe.isEmpty ? timeStr : "\(recipe) · \(timeStr)"
        }
        return recipe.isEmpty ? extraction.grindSetting : recipe
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if mins > 0 {
            return "\(mins)m \(secs)s"
        }
        return "\(secs)s"
    }

    private func daysSince(_ date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: .now).day ?? 0
    }
}

#Preview {
    NavigationStack {
        BeanDetailView(bean: PreviewContainer.sampleBean)
    }
    .modelContainer(PreviewContainer.container)
}
