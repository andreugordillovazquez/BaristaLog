//
//  AddBrewerView.swift
//  Brew
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddBrewerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var brewerToEdit: Brewer?

    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var brewType: String = ""
    @State private var portafilterSize: String = ""
    @State private var basketSize: String = ""
    @State private var notes: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?

    @FocusState private var isNameFocused: Bool

    private var isEditing: Bool { brewerToEdit != nil }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private let brewTypes = ["Espresso", "Pour Over", "Immersion", "Moka Pot", "AeroPress", "French Press", "Other"]
    private let portafilterSizes = ["49mm", "51mm", "53mm", "54mm", "58mm"]
    private let basketSizes = ["7g", "14g", "16g", "17g", "18g", "20g", "21g", "22g"]

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

                Section("Brew Type") {
                    Picker("Type", selection: $brewType) {
                        Text("None").tag("")
                        ForEach(brewTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Portafilter") {
                    Picker("Size", selection: $portafilterSize) {
                        Text("None").tag("")
                        ForEach(portafilterSizes, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    .pickerStyle(.menu)
                    Picker("Basket", selection: $basketSize) {
                        Text("None").tag("")
                        ForEach(basketSizes, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Notes") {
                    TextField("Pressure, tips...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Brewer" : "New Brewer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBrewer()
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
                if let brewer = brewerToEdit {
                    name = brewer.name
                    brand = brewer.brand ?? ""
                    brewType = brewer.brewType ?? ""
                    portafilterSize = brewer.portafilterSize ?? ""
                    basketSize = brewer.basketSize ?? ""
                    notes = brewer.notes ?? ""
                    photoData = brewer.imageData
                }
                isNameFocused = true
            }
        }
    }

    private func saveBrewer() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        if let brewer = brewerToEdit {
            // Update existing
            brewer.name = trimmedName
            brewer.brand = brand.isEmpty ? nil : brand
            brewer.brewType = brewType.isEmpty ? nil : brewType
            brewer.portafilterSize = portafilterSize.isEmpty ? nil : portafilterSize
            brewer.basketSize = basketSize.isEmpty ? nil : basketSize
            brewer.notes = notes.isEmpty ? nil : notes
            brewer.imageData = photoData
        } else {
            // Create new
            let brewer = Brewer(
                name: trimmedName,
                brand: brand.isEmpty ? nil : brand,
                brewType: brewType.isEmpty ? nil : brewType,
                portafilterSize: portafilterSize.isEmpty ? nil : portafilterSize,
                basketSize: basketSize.isEmpty ? nil : basketSize,
                notes: notes.isEmpty ? nil : notes,
                imageData: photoData
            )
            modelContext.insert(brewer)
        }

        dismiss()
    }
}

#Preview("Add") {
    AddBrewerView()
        .modelContainer(PreviewContainer.container)
}

#Preview("Edit") {
    AddBrewerView(brewerToEdit: PreviewContainer.sampleBrewer)
        .modelContainer(PreviewContainer.container)
}
