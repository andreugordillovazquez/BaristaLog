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
        Form {
            // MARK: - Photo
            if let imageData = bean.imageData, let uiImage = UIImage(data: imageData) {
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
                LabeledContent("Name", value: bean.name)
                if let roaster = bean.roaster {
                    LabeledContent("Roaster", value: roaster)
                }
                if let origin = bean.origin {
                    LabeledContent("Origin", value: origin)
                }
            }

            // MARK: - Dates
            if bean.roastDate != nil || bean.openedDate != nil {
                Section("Dates") {
                    if let roastDate = bean.roastDate {
                        LabeledContent("Roasted", value: roastDate, format: .dateTime.day().month().year())
                        LabeledContent("Days since roast", value: "\(daysSince(roastDate))")
                    }
                    if let openedDate = bean.openedDate {
                        LabeledContent("Opened", value: openedDate, format: .dateTime.day().month().year())
                        LabeledContent("Days since opened", value: "\(daysSince(openedDate))")
                    }
                }
            }

            // MARK: - Notes
            if let notes = bean.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: - Extractions
            if let extractions = bean.extractions, !extractions.isEmpty {
                Section("Extractions (\(extractions.count))") {
                    ForEach(extractions.sorted(by: { $0.date > $1.date }).prefix(5), id: \.self) { extraction in
                        HStack {
                            Text(extraction.grindSetting)
                            Spacer()
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
