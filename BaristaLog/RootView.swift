//
//  RootView.swift
//  Brew
//

import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("debugShowOnboarding") private var debugShowOnboarding = false

    private var showOnboarding: Bool {
        !hasOnboarded || debugShowOnboarding
    }

    var body: some View {
        MainTabView()
            .overlay {
                if showOnboarding {
                    OnboardingFlowView()
                        .transition(.move(edge: .bottom))
                }
            }
            .animation(.easeInOut(duration: 0.4), value: showOnboarding)
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewContainer.container)
}
