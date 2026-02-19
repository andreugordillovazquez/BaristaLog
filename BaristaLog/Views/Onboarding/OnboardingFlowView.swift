//
//  OnboardingFlowView.swift
//  Brew
//

import SwiftUI
import SwiftData

struct OnboardingFlowView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("debugShowOnboarding") private var debugShowOnboarding = false
    @AppStorage("startGuidedExtraction") private var startGuidedExtraction = false
    @AppStorage("weightUnit") private var weightUnit: WeightUnit = .grams
    @AppStorage("weightPrecision") private var weightPrecision: WeightPrecision = .oneDecimal
    @AppStorage("defaultGrinderName") private var defaultGrinderName: String = ""
    @AppStorage("defaultBrewerName") private var defaultBrewerName: String = ""
    @AppStorage("aiCoachingEnabled") private var aiCoachingEnabled = true

    @Query(sort: \Grinder.name) private var grinders: [Grinder]
    @Query(sort: \Brewer.name) private var brewers: [Brewer]
    @Query(sort: \Bean.name) private var beans: [Bean]

    @State private var stepIndex = 0
    @State private var showingAddBean = false
    @State private var showingAddGrinder = false
    @State private var showingAddBrewer = false

    private let totalSteps = 6

    private var continueButtonLabel: String {
        switch stepIndex {
        case 2: grinders.isEmpty && brewers.isEmpty ? "Skip" : "Continue"
        case 3: beans.isEmpty ? "Skip" : "Continue"
        case totalSteps - 1: "Finish"
        default: "Continue"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                // Back button (only show after first step)
                Button {
                    withAnimation(.easeInOut) {
                        stepIndex = max(0, stepIndex - 1)
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.glass)
                .opacity(stepIndex > 0 ? 1 : 0)
                .animation(.easeInOut, value: stepIndex)
                .disabled(stepIndex == 0)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)

            TabView(selection: $stepIndex) {
                welcomeStep
                    .tag(0)
                    .id(0)
                unitsStep
                    .tag(1)
                    .id(1)
                equipmentStep
                    .tag(2)
                    .id(2)
                beansStep
                    .tag(3)
                    .id(3)
                aiStep
                    .tag(4)
                    .id(4)
                finishStep
                    .tag(5)
                    .id(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: stepIndex)

            PageIndicator(count: totalSteps, index: stepIndex)

            Button {
                if stepIndex < totalSteps - 1 {
                    withAnimation(.easeInOut) {
                        stepIndex += 1
                    }
                } else {
                    completeOnboarding(startGuided: false)
                }
            } label: {
                Text(continueButtonLabel)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .animation(.easeInOut, value: continueButtonLabel)
            }
            .buttonStyle(.glassProminent)
            .tint(Color.brandBrown)
            .padding(.horizontal, 28)
            .padding(.bottom, 20)
        }
        .tint(Color.brandBrown)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingAddBean) {
            AddBeanView()
        }
        .sheet(isPresented: $showingAddGrinder) {
            AddGrinderView()
        }
        .sheet(isPresented: $showingAddBrewer) {
            AddBrewerView()
        }
    }

    private var welcomeStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            // App Icon
            Image("Brew")
                .resizable()
                .scaledToFit()
                .frame(width: 75, height: 75)
                .clipShape(RoundedRectangle(cornerRadius: 22.5, style: .continuous))

            // Title
            VStack(alignment: .leading, spacing: 12) {
                Text("Welcome to BaristaLog")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Your personal espresso journal. Track every shot, refine your technique, and brew better coffee.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Feature List
            VStack(alignment: .leading, spacing: 22) {
                OnboardingFeatureRow(
                    title: "Track Your Extractions",
                    subtitle: "Log espresso and pour over sessions with detailed parameters and tasting notes.",
                    systemImage: "list.clipboard.fill"
                )
                OnboardingFeatureRow(
                    title: "Organize Your Gear",
                    subtitle: "Keep beans, grinders, and brewers in one place for quick access.",
                    systemImage: "folder.fill"
                )
                OnboardingFeatureRow(
                    title: "Get Coaching Insights",
                    subtitle: "Receive personalized tips powered by Apple Intelligence.",
                    systemImage: "apple.intelligence"
                )
            }
            .padding(.top, 16)
            
            Spacer()
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var unitsStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("Choose your units")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Define your preferred units and precision for your extractions. You can adjust this later in Settings.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("My Extraction")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(.secondaryLabel))
                    .padding(.horizontal, 16)

                VStack(spacing: 0) {
                    unitsPreviewRow(label: "Dose In", gramsValue: 18.0)
                    Divider()
                        .padding(.leading, 16)
                    unitsPreviewRow(label: "Yield Out", gramsValue: 36.0)
                }
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(.systemGray4).opacity(0.45), lineWidth: 0.5)
            )

            VStack(spacing: 16) {
                Text("Weight Unit")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Picker("Weight", selection: $weightUnit) {
                    ForEach(WeightUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("Display Precision")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Picker("Precision", selection: $weightPrecision) {
                    ForEach(WeightPrecision.allCases, id: \.self) { precision in
                        Text(precision.label).tag(precision)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )

            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 8)
    }

    private func unitsPreviewRow(label: String, gramsValue: Double) -> some View {
        HStack {
            Text(label)
                .font(.callout)
                .foregroundStyle(Color(.secondaryLabel))
            Spacer()
            Text(unitsPreviewValue(gramsValue: gramsValue))
                .font(.callout.weight(.semibold))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.snappy, value: weightUnit)
                .animation(.snappy, value: weightPrecision)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }

    private func unitsPreviewValue(gramsValue: Double) -> String {
        let ouncesValue = gramsValue / 28.349523125
        let decimals = weightPrecision.decimals
        let gramsText = formatNumber(gramsValue, decimals: decimals)
        let ouncesText = formatNumber(ouncesValue, decimals: decimals)

        switch weightUnit {
        case .grams:
            return "\(gramsText) g"
        case .ounces:
            return "\(ouncesText) oz"
        }
    }

    private func formatNumber(_ value: Double, decimals: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private var equipmentStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("Add your equipment")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Start with your main grinder and brewer. You can set defaults for new extractions.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Equipment preview card
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Equipment")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(.secondaryLabel))
                    .padding(.horizontal, 16)

                VStack(spacing: 0) {
                    equipmentCardRow(
                        icon: "gearshape.fill",
                        label: "Grinders",
                        value: grinders.isEmpty ? "None added" : grinders.map(\.name).joined(separator: ", "),
                        isEmpty: grinders.isEmpty
                    )
                    Divider().padding(.leading, 16)
                    equipmentCardRow(
                        icon: "cup.and.saucer.fill",
                        label: "Brewers",
                        value: brewers.isEmpty ? "None added" : brewers.map(\.name).joined(separator: ", "),
                        isEmpty: brewers.isEmpty
                    )
                }
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(.systemGray4).opacity(0.45), lineWidth: 0.5)
            )

            // Add buttons
            HStack(spacing: 12) {
                onboardingAddButton(title: "Add Grinder", icon: "gearshape") {
                    showingAddGrinder = true
                }
                onboardingAddButton(title: "Add Brewer", icon: "cup.and.saucer") {
                    showingAddBrewer = true
                }
            }

            // Defaults card (only shown when equipment exists)
            if !grinders.isEmpty || !brewers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Defaults for New Extractions")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                        .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        if !grinders.isEmpty {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Color.brandBrown)
                                    .frame(width: 24)
                                Text("Grinder")
                                    .font(.callout)
                                    .foregroundStyle(Color(.secondaryLabel))
                                Spacer()
                                Picker("Grinder", selection: $defaultGrinderName) {
                                    Text("None").tag("")
                                    ForEach(grinders) { grinder in
                                        Text(grinder.name).tag(grinder.name)
                                    }
                                }
                                .labelsHidden()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                        }

                        if !grinders.isEmpty && !brewers.isEmpty {
                            Divider().padding(.leading, 16)
                        }

                        if !brewers.isEmpty {
                            HStack {
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Color.brandBrown)
                                    .frame(width: 24)
                                Text("Brewer")
                                    .font(.callout)
                                    .foregroundStyle(Color(.secondaryLabel))
                                Spacer()
                                Picker("Brewer", selection: $defaultBrewerName) {
                                    Text("None").tag("")
                                    ForEach(brewers) { brewer in
                                        Text(brewer.name).tag(brewer.name)
                                    }
                                }
                                .labelsHidden()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color(.systemGray4).opacity(0.45), lineWidth: 0.5)
                )
            }

            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 8)
    }

    private func equipmentCardRow(icon: String, label: String, value: String, isEmpty: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isEmpty ? Color(.tertiaryLabel) : Color.brandBrown)
                .frame(width: 24)
            Text(label)
                .font(.callout)
                .foregroundStyle(Color(.secondaryLabel))
            Spacer()
            Text(value)
                .font(.callout.weight(.semibold))
                .foregroundStyle(isEmpty ? Color(.tertiaryLabel) : .primary)
                .lineLimit(1)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }

    private func onboardingAddButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Color.brandBrown)
                Text(title)
                    .font(.callout.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.bordered)
        .tint(Color.brandBrown)
    }

    private var beansStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("Add your beans")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Add the coffee beans you're currently brewing with. You can always add more later.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Beans list card
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Beans")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(.secondaryLabel))
                    .padding(.horizontal, 16)

                VStack(spacing: 0) {
                    if beans.isEmpty {
                        HStack {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color(.tertiaryLabel))
                                .frame(width: 24)
                            Text("No beans added yet")
                                .font(.callout)
                                .foregroundStyle(Color(.tertiaryLabel))
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    } else {
                        ForEach(Array(beans.prefix(4).enumerated()), id: \.element.id) { index, bean in
                            if index > 0 {
                                Divider().padding(.leading, 16)
                            }
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Color.brandBrown)
                                    .frame(width: 24)
                                Text(bean.name)
                                    .font(.callout)
                                Spacer()
                                if let roaster = bean.roaster {
                                    Text(roaster)
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                        }
                        if beans.count > 4 {
                            Divider().padding(.leading, 16)
                            HStack {
                                Text("+\(beans.count - 4) more")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(.systemGray4).opacity(0.45), lineWidth: 0.5)
            )

            // Add button
            onboardingAddButton(title: "Add Bean", icon: "leaf") {
                showingAddBean = true
            }

            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 8)
    }

    private var aiStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("Apple Intelligence")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Get personalized coaching tips powered by on-device AI.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Feature descriptions
            VStack(alignment: .leading, spacing: 22) {
                OnboardingFeatureRow(
                    title: "Shot Analysis",
                    subtitle: "Compares your extractions to find patterns and suggest improvements.",
                    systemImage: "chart.bar.fill"
                )
                OnboardingFeatureRow(
                    title: "Grind Adjustments",
                    subtitle: "Recommends grind setting changes based on your extraction history.",
                    systemImage: "dial.medium.fill"
                )
                OnboardingFeatureRow(
                    title: "Private & On-Device",
                    subtitle: "All processing happens on your device. Your data never leaves your iPhone.",
                    systemImage: "lock.shield.fill"
                )
            }
            .padding(.top, 8)

            // Toggle card
            VStack(spacing: 3) {
                Toggle("Enable Coaching Insights", isOn: $aiCoachingEnabled)
                    .font(.callout.weight(.semibold))

                Text("You can change this later in Settings.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )

            Spacer()
        }
        .padding(.horizontal, 28)
    }

    private var finishStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56, weight: .medium))
                .foregroundStyle(Color.brandBrown)

            VStack(alignment: .leading, spacing: 12) {
                Text("You're all set")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Here's a summary of your setup.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Summary
            VStack(alignment: .leading, spacing: 22) {
                OnboardingFeatureRow(
                    title: "Units",
                    subtitle: unitsSummary,
                    systemImage: "scalemass.fill"
                )
                OnboardingFeatureRow(
                    title: "Equipment",
                    subtitle: equipmentSummary,
                    systemImage: "gearshape.2.fill"
                )
                OnboardingFeatureRow(
                    title: "Beans",
                    subtitle: beansSummary,
                    systemImage: "leaf.fill"
                )
                OnboardingFeatureRow(
                    title: "Coaching",
                    subtitle: aiCoachingEnabled ? "Apple Intelligence enabled" : "Disabled",
                    systemImage: "apple.intelligence"
                )
            }
            .padding(.top, 16)

            Spacer()
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var unitsSummary: String {
        "\(weightUnit == .grams ? "Grams" : "Ounces"), \(weightPrecision.label.lowercased())"
    }

    private var equipmentSummary: String {
        let g = grinders.count
        let b = brewers.count
        if g == 0 && b == 0 { return "No equipment added yet" }
        var parts: [String] = []
        if g > 0 { parts.append("\(g) grinder\(g == 1 ? "" : "s")") }
        if b > 0 { parts.append("\(b) brewer\(b == 1 ? "" : "s")") }
        return parts.joined(separator: ", ")
    }

    private var beansSummary: String {
        let count = beans.count
        if count == 0 { return "No beans added yet" }
        return "\(count) bean\(count == 1 ? "" : "s") added"
    }

    private func completeOnboarding(startGuided: Bool) {
        startGuidedExtraction = startGuided
        debugShowOnboarding = false
        hasOnboarded = true
    }
}

private struct OnboardingFeatureRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Color.brandBrown)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PageIndicator: View {
    let count: Int
    let index: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { dot in
                Capsule()
                    .fill(dot == index ? Color.primary : Color.secondary.opacity(0.35))
                    .frame(width: dot == index ? 18 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.2), value: index)
            }
        }
        .padding(.top, 2)
    }
}

#Preview {
    OnboardingFlowView()
        .modelContainer(PreviewContainer.container)
}
