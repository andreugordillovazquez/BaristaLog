//
//  AddBeanView.swift
//  Brew
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddBeanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var beanToEdit: Bean?

    @State private var name: String = ""
    @State private var roaster: String = ""
    @State private var origin: String = ""
    @State private var roastDate: Date?
    @State private var openedDate: Date?
    @State private var notes: String = ""

    @State private var process: String = ""
    @State private var roastLevel: String = ""
    @State private var varietal: String = ""
    @State private var altitude: String = ""
    @State private var selectedFlavorTags: Set<String> = []

    @State private var showRoastDatePicker = false
    @State private var showOpenedDatePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?

    @FocusState private var isNameFocused: Bool

    private static let availableFlavorTags = [
        "Chocolate", "Fruity", "Floral", "Nutty", "Citrus",
        "Berry", "Caramel", "Spicy", "Earthy", "Herbal",
        "Sweet", "Winey", "Tropical", "Smoky", "Honey"
    ]

    private var isEditing: Bool { beanToEdit != nil }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Info
                Section {
                    TextField("Name", text: $name)
                        .focused($isNameFocused)
                    TextField("Roaster", text: $roaster)
                    TextField("Origin", text: $origin)
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        if let photoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .accessibilityLabel("Bean photo")
                        } else {
                            Label("Add Photo", systemImage: "photo.on.rectangle.angled")
                                .foregroundStyle(Color.brandBrown)
                        }
                    }
                    .accessibilityHint(photoData != nil ? "Double tap to change photo" : "Double tap to add a photo")
                    if photoData != nil {
                        Button("Remove Photo", role: .destructive) {
                            selectedPhotoItem = nil
                            photoData = nil
                        }
                    }
                }

                // MARK: - Details
                Section("Details") {
                    Picker("Process", selection: $process) {
                        Text("None").tag("")
                        ForEach(["Washed", "Natural", "Honey", "Anaerobic", "Other"], id: \.self) { p in
                            Text(p).tag(p)
                        }
                    }

                    Picker("Roast Level", selection: $roastLevel) {
                        Text("None").tag("")
                        ForEach(["Light", "Medium", "Medium-Dark", "Dark"], id: \.self) { r in
                            Text(r).tag(r)
                        }
                    }

                    TextField("Varietal", text: $varietal)
                    HStack {
                        TextField("Altitude (e.g. 1800-2000)", text: $altitude)
                        if !altitude.isEmpty {
                            Text("masl")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // MARK: - Flavor Tags
                Section("Flavor Profile") {
                    FlowLayout(spacing: 8) {
                        ForEach(Self.availableFlavorTags, id: \.self) { tag in
                            Button {
                                if selectedFlavorTags.contains(tag) {
                                    selectedFlavorTags.remove(tag)
                                } else {
                                    selectedFlavorTags.insert(tag)
                                }
                            } label: {
                                Text(tag)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        selectedFlavorTags.contains(tag)
                                            ? Color.brandBrown
                                            : Color.secondary.opacity(0.15)
                                    )
                                    .foregroundStyle(selectedFlavorTags.contains(tag) ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section("Dates") {
                    Toggle("Roast Date", isOn: $showRoastDatePicker)
                    if showRoastDatePicker {
                        DatePicker(
                            "Roasted on",
                            selection: Binding(
                                get: { roastDate ?? .now },
                                set: { roastDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }

                    Toggle("Opened Date", isOn: $showOpenedDatePicker)
                    if showOpenedDatePicker {
                        DatePicker(
                            "Opened on",
                            selection: Binding(
                                get: { openedDate ?? .now },
                                set: { openedDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                }

                Section("Notes") {
                    TextField("Flavor notes, brewing tips...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Bean" : "New Bean")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBean()
                    }
                    .disabled(!canSave)
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data),
                       let compressed = uiImage.jpegData(compressionQuality: 0.7) {
                        photoData = compressed
                    }
                }
            }
            .onAppear {
                if let bean = beanToEdit {
                    name = bean.name
                    roaster = bean.roaster ?? ""
                    origin = bean.origin ?? ""
                    roastDate = bean.roastDate
                    openedDate = bean.openedDate
                    notes = bean.notes ?? ""
                    photoData = bean.imageData
                    process = bean.process ?? ""
                    roastLevel = bean.roastLevel ?? ""
                    varietal = bean.varietal ?? ""
                    altitude = bean.altitude ?? ""
                    selectedFlavorTags = Set(bean.flavorTags ?? [])
                    showRoastDatePicker = bean.roastDate != nil
                    showOpenedDatePicker = bean.openedDate != nil
                }
                isNameFocused = true
            }
        }
    }

    private func saveBean() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let flavorTagsArray = selectedFlavorTags.isEmpty ? nil : Array(selectedFlavorTags).sorted()

        if let bean = beanToEdit {
            // Update existing
            bean.name = trimmedName
            bean.roaster = roaster.isEmpty ? nil : roaster
            bean.origin = origin.isEmpty ? nil : origin
            bean.roastDate = showRoastDatePicker ? roastDate : nil
            bean.openedDate = showOpenedDatePicker ? openedDate : nil
            bean.notes = notes.isEmpty ? nil : notes
            bean.imageData = photoData
            bean.process = process.isEmpty ? nil : process
            bean.roastLevel = roastLevel.isEmpty ? nil : roastLevel
            bean.varietal = varietal.isEmpty ? nil : varietal
            bean.altitude = altitude.isEmpty ? nil : altitude
            bean.flavorTags = flavorTagsArray
        } else {
            // Create new
            let bean = Bean(
                name: trimmedName,
                roaster: roaster.isEmpty ? nil : roaster,
                origin: origin.isEmpty ? nil : origin,
                roastDate: showRoastDatePicker ? roastDate : nil,
                openedDate: showOpenedDatePicker ? openedDate : nil,
                notes: notes.isEmpty ? nil : notes,
                imageData: photoData,
                process: process.isEmpty ? nil : process,
                roastLevel: roastLevel.isEmpty ? nil : roastLevel,
                varietal: varietal.isEmpty ? nil : varietal,
                altitude: altitude.isEmpty ? nil : altitude,
                flavorTags: flavorTagsArray
            )
            modelContext.insert(bean)
        }

        dismiss()
    }
}

#Preview("Add") {
    AddBeanView()
        .modelContainer(PreviewContainer.container)
}

#Preview("Edit") {
    AddBeanView(beanToEdit: PreviewContainer.sampleBean)
        .modelContainer(PreviewContainer.container)
}
