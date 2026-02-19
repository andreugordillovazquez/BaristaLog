//
//  MainTabView.swift
//  Brew
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("startGuidedExtraction") private var startGuidedExtraction = false

    var body: some View {
        TabView {
            Tab("Extractions", systemImage: "cup.and.saucer") {
                ContentView()
            }

            Tab("Library", systemImage: "books.vertical") {
                LibraryView()
            }

            Tab("Settings", systemImage: "gearshape") {
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
