//
//  AddGrinderView.swift
//  Brew
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddGrinderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var grinderToEdit: Grinder?

    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var burrType: String = ""
    @State private var burrSize: String = ""
    @State private var adjustmentNotes: String = ""
    @State private var notes: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?

    @FocusState private var isNameFocused: Bool

    private var isEditing: Bool { grinderToEdit != nil }

    private let burrTypes = ["Flat", "Conical", "Hybrid"]
    private let burrSizes = ["38mm", "48mm", "54mm", "58mm", "64mm", "71mm", "75mm", "80mm", "83mm", "98mm"]

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
                    TextField("Brand", text: $brand)
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        if let photoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Label("Add Photo", systemImage: "photo.on.rectangle.angled")
                                .foregroundStyle(Color.brandBrown)
                        }
                    }
                    if photoData != nil {
                        Button("Remove Photo", role: .destructive) {
                            selectedPhotoItem = nil
                            photoData = nil
                        }
                    }
                }

                Section("Burr") {
                    Picker("Type", selection: $burrType) {
                        Text("None").tag("")
                        ForEach(burrTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    Picker("Size", selection: $burrSize) {
                        Text("None").tag("")
                        ForEach(burrSizes, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Adjustment") {
                    TextField("Range/type (e.g., 0-50 clicks, stepless)", text: $adjustmentNotes)
                }

                Section("Notes") {
                    TextField("Burr type, maintenance notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Grinder" : "New Grinder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGrinder()
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
                if let grinder = grinderToEdit {
                    name = grinder.name
                    brand = grinder.brand ?? ""
                    burrType = grinder.burrType ?? ""
                    burrSize = grinder.burrSize ?? ""
                    adjustmentNotes = grinder.adjustmentNotes ?? ""
                    notes = grinder.notes ?? ""
                    photoData = grinder.imageData
                }
                isNameFocused = true
            }
        }
    }

    private func saveGrinder() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        if let grinder = grinderToEdit {
            // Update existing
            grinder.name = trimmedName
            grinder.brand = brand.isEmpty ? nil : brand
            grinder.burrType = burrType.isEmpty ? nil : burrType
            grinder.burrSize = burrSize.isEmpty ? nil : burrSize
            grinder.adjustmentNotes = adjustmentNotes.isEmpty ? nil : adjustmentNotes
            grinder.notes = notes.isEmpty ? nil : notes
            grinder.imageData = photoData
        } else {
            // Create new
            let grinder = Grinder(
                name: trimmedName,
                brand: brand.isEmpty ? nil : brand,
                burrType: burrType.isEmpty ? nil : burrType,
                burrSize: burrSize.isEmpty ? nil : burrSize,
                adjustmentNotes: adjustmentNotes.isEmpty ? nil : adjustmentNotes,
                notes: notes.isEmpty ? nil : notes,
                imageData: photoData
            )
            modelContext.insert(grinder)
        }

        dismiss()
    }
}

#Preview("Add") {
    AddGrinderView()
        .modelContainer(PreviewContainer.container)
}

#Preview("Edit") {
    AddGrinderView(grinderToEdit: PreviewContainer.sampleGrinder)
        .modelContainer(PreviewContainer.container)
}
