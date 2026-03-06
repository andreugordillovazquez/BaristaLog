//
//  SettingsView.swift
//  Brew
//

import SwiftUI
import SwiftData
import UIKit
import FoundationModels

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("weightUnit") private var weightUnit: WeightUnit = .grams
    @AppStorage("weightPrecision") private var weightPrecision: WeightPrecision = .oneDecimal
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("aiCoachingEnabled") private var aiCoachingEnabled = true
    @AppStorage("debugShowOnboarding") private var debugShowOnboarding = false
    @AppStorage("hasOnboarded") private var hasOnboarded = true

    @Query(sort: \Grinder.name) private var grinders: [Grinder]
    @Query(sort: \Brewer.name) private var brewers: [Brewer]

    @AppStorage("defaultGrinderID") private var defaultGrinderID: String = ""
    @AppStorage("defaultBrewerID") private var defaultBrewerID: String = ""

    @State private var showingResetConfirmation = false
    @State private var showingExportOptions = false
    @State private var exportedFileURL: URL?
    @State private var exportError: String?

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Units
                Section("Units") {
                    Picker("Weight", selection: $weightUnit) {
                        ForEach(WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }

                    Picker("Precision", selection: $weightPrecision) {
                        ForEach(WeightPrecision.allCases, id: \.self) { precision in
                            Text(precision.label).tag(precision)
                        }
                    }
                }

                // MARK: - Appearance
                Section("Appearance") {
                    Picker("Theme", selection: $appTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                }

                // MARK: - Coaching
                Section {
                    Toggle("Apple Intelligence", isOn: $aiCoachingEnabled)
                        .disabled(!isAppleIntelligenceAvailable)
                } header: {
                    Text("Coaching")
                }
                footer: {
                    if isAppleIntelligenceAvailable {
                        Text("")
                    } else {
                        Text("Apple Intelligence is not available on this device.")
                    }
                }

                // MARK: - Defaults
                Section {
                    Picker("Default Grinder", selection: $defaultGrinderID) {
                        Text("None").tag("")
                        ForEach(grinders) { grinder in
                            Text(grinder.name).tag(grinder.stableID.uuidString)
                        }
                    }

                    Picker("Default Brewer", selection: $defaultBrewerID) {
                        Text("None").tag("")
                        ForEach(brewers) { brewer in
                            Text(brewer.name).tag(brewer.stableID.uuidString)
                        }
                    }
                } header: {
                    Text("Defaults")
                } footer: {
                    Text("Pre-selected when creating new extractions")
                }

                // MARK: - Data
                Section {
                    Button {
                        showingExportOptions = true
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    .confirmationDialog("Export Format", isPresented: $showingExportOptions) {
                        Button("CSV (Extractions)") {
                            exportData(format: .csv)
                        }
                        Button("JSON (All Data)") {
                            exportData(format: .json)
                        }
                    } message: {
                        Text("Choose an export format")
                    }

                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }
                    .confirmationDialog(
                        "Reset All Data",
                        isPresented: $showingResetConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Delete Everything", role: .destructive) {
                            resetAllData()
                        }
                    } message: {
                        Text("This will delete all extractions, beans, grinders, and brewers, and reset all settings. This cannot be undone.")
                    }
                } header: {
                    Text("Data")
                }

                // MARK: - Debug
                Section("Debug") {
                    Toggle("Show Onboarding", isOn: $debugShowOnboarding)

                    Button {
                        PreviewContainer.insertSampleData(into: modelContext)
                    } label: {
                        Label("Add Sample Data", systemImage: "sparkles")
                    }
                }

                // MARK: - About
                Section("About") {
                    LabeledContent("Version", value: appVersion)
                    LabeledContent("Build", value: appBuild)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.visible)
            .navigationTitle("Settings")
            .sheet(item: $exportedFileURL) { url in
                ShareSheet(activityItems: [url])
            }
            .alert("Export Failed", isPresented: .init(get: { exportError != nil }, set: { if !$0 { exportError = nil } })) {
                Button("OK") { exportError = nil }
            } message: {
                Text(exportError ?? "")
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    private var isAppleIntelligenceAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    private enum ExportFormat {
        case csv, json
    }

    private func exportData(format: ExportFormat) {
        do {
            let url: URL
            switch format {
            case .csv:
                url = try DataExportService.exportExtractionsCSV(context: modelContext)
            case .json:
                url = try DataExportService.exportAllJSON(context: modelContext)
            }
            exportedFileURL = url
        } catch {
            exportError = error.localizedDescription
        }
    }

    private func resetAllData() {
        // Delete all SwiftData models
        do {
            try modelContext.delete(model: Extraction.self)
            try modelContext.delete(model: Bean.self)
            try modelContext.delete(model: Grinder.self)
            try modelContext.delete(model: Brewer.self)
        } catch {
            print("Failed to delete data: \(error)")
        }

        // Reset preferences
        weightUnit = .grams
        weightPrecision = .oneDecimal
        appTheme = .system
        aiCoachingEnabled = true
        defaultGrinderID = ""
        defaultBrewerID = ""
    }
}


// MARK: - ShareSheet

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

#Preview {
    SettingsView()
        .modelContainer(PreviewContainer.container)
}
