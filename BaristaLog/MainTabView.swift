//
//  MainTabView.swift
//  Brew
//

import SwiftUI
import SwiftData

enum AppTab: Hashable {
    case extractions, library, settings
}

struct MainTabView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("startGuidedExtraction") private var startGuidedExtraction = false
    @State private var selectedTab: AppTab = .extractions

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Extractions", systemImage: "cup.and.saucer", value: .extractions) {
                ContentView(selectedTab: $selectedTab)
            }

            Tab("Library", systemImage: "books.vertical", value: .library) {
                LibraryView()
            }

            Tab("Settings", systemImage: "gearshape", value: .settings) {
                SettingsView()
            }
        }
        .tint(Color.brandBrown)
        .preferredColorScheme(colorScheme)
        .sheet(isPresented: $startGuidedExtraction) {
            AddExtractionView()
        }
    }

    private var colorScheme: ColorScheme? {
        switch appTheme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(PreviewContainer.container)
}
