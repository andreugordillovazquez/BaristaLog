//
//  BaristaCoach.swift
//  BaristaLog
//

import Foundation
import FoundationModels
import SwiftUI
import SwiftData

// MARK: - Barista Coach

@MainActor
@Observable
final class BaristaCoach {
    var summary: String?
    var isAnalyzing = false
    var error: String?

    private var session: LanguageModelSession?
    private var analyzedExtractionDate: Date?

    var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    func analyze(extraction: Extraction, previousExtractions: [Extraction] = []) async {
        // Skip if already analyzed this extraction
        if analyzedExtractionDate == extraction.date && summary != nil {
            return
        }

        guard isAvailable else { return }

        isAnalyzing = true
        error = nil
        summary = nil
        analyzedExtractionDate = extraction.date

        let instructions = """
        You are a barista coach inside a coffee tracking app. The user just pulled an espresso shot \
        and wants brief feedback.

        RULES:
        - Reply in exactly 2 plain-text sentences. No markdown, no bullets, no emoji, no headings.
        - Sentence 1: Assess the shot. Compare ratio to the 1:2 target and time to the 25-35 s window. \
        Say whether it looks good, under-extracted, or over-extracted.
        - Sentence 2: Give one specific actionable adjustment (e.g. grind finer/coarser, change dose, \
        adjust time) or say "Looks dialed in, keep it up" if the numbers are on target.
        - If dose, yield, or time are missing, base your feedback only on the data provided and note \
        what recording those values would help with.
        - If bean process or roast level are provided, factor them into your assessment (e.g. lighter roasts \
        typically need finer grinds and higher temperatures).
        - Do NOT discuss bean origins, flavor theory, or brewing history. Focus only on the shot data.
        - Keep the tone friendly and concise.
        """

        session = LanguageModelSession(instructions: instructions)

        let prompt = buildPrompt(for: extraction, previous: previousExtractions)

        do {
            let response = try await session?.respond(to: prompt)
            summary = response?.content
        } catch {
            self.error = "Could not analyze"
        }

        isAnalyzing = false
    }

    private func buildPrompt(for extraction: Extraction, previous: [Extraction]) -> String {
        var lines: [String] = []

        lines.append("Grind setting: \(extraction.grindSetting)")

        if let dose = extraction.doseIn {
            lines.append("Dose in: \(String(format: "%.1f", dose)) g")
        }

        if let yield = extraction.yieldOut {
            lines.append("Yield out: \(String(format: "%.1f", yield)) g")
        }

        if let dose = extraction.doseIn, let yield = extraction.yieldOut, dose > 0 {
            lines.append("Ratio: 1:\(String(format: "%.1f", yield / dose))")
        }

        if let time = extraction.timeSeconds {
            lines.append("Time: \(Int(time)) s")
        }

        if let temp = extraction.waterTemperature {
            lines.append("Water temperature: \(String(format: "%.0f", temp)) °C")
        }

        if let prepMethod = extraction.prepMethod {
            lines.append("Prep method: \(prepMethod)")
        }

        if let process = extraction.bean?.process {
            lines.append("Bean process: \(process)")
        }

        if let roastLevel = extraction.bean?.roastLevel {
            lines.append("Roast level: \(roastLevel)")
        }

        if let varietal = extraction.bean?.varietal {
            lines.append("Varietal: \(varietal)")
        }

        if let rating = extraction.rating {
            lines.append("User rating: \(rating)/5")
        }

        // Previous extractions for trend context (same bean only)
        let relevantPrevious = previous
            .filter { $0.bean?.name == extraction.bean?.name }
            .prefix(3)

        if !relevantPrevious.isEmpty {
            lines.append("")
            lines.append("Recent shots with same bean for context:")
            for prev in relevantPrevious {
                var parts = ["Grind \(prev.grindSetting)"]
                if let dose = prev.doseIn, let yield = prev.yieldOut, dose > 0 {
                    parts.append("ratio 1:\(String(format: "%.1f", yield / dose))")
                }
                if let time = prev.timeSeconds {
                    parts.append("\(Int(time)) s")
                }
                if let rating = prev.rating {
                    parts.append("\(rating)/5")
                }
                lines.append("- " + parts.joined(separator: ", "))
            }
        }

        return lines.joined(separator: "\n")
    }
}
