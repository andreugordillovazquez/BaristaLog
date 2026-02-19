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
        You are an expert barista coach. Analyze the espresso extraction data and provide a brief, \
        friendly 2-3 sentence summary. Include what went well and one key tip for improvement. \
        Be concise and encouraging. Ideal espresso: ratio ~1:2, time 25-35 seconds.
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
        var prompt = "Analyze this shot:\n"

        prompt += "Bean: \(extraction.bean?.name ?? "Unknown")\n"
        prompt += "Grind: \(extraction.grindSetting)\n"

        if let dose = extraction.doseIn {
            prompt += "Dose: \(String(format: "%.1f", dose))g\n"
        }

        if let yield = extraction.yieldOut {
            prompt += "Yield: \(String(format: "%.1f", yield))g\n"
        }

        if let dose = extraction.doseIn, let yield = extraction.yieldOut, dose > 0 {
            prompt += "Ratio: 1:\(String(format: "%.1f", yield / dose))\n"
        }

        if let time = extraction.timeSeconds {
            prompt += "Time: \(Int(time))s\n"
        }

        if let notes = extraction.notes, !notes.isEmpty {
            prompt += "Notes: \(notes)\n"
        }

        // Previous extractions for context
        let relevantPrevious = previous
            .filter { $0.bean?.name == extraction.bean?.name }
            .prefix(2)

        if !relevantPrevious.isEmpty {
            prompt += "\nRecent shots with same bean: "
            for prev in relevantPrevious {
                prompt += "Grind \(prev.grindSetting)"
                if let time = prev.timeSeconds {
                    prompt += " / \(Int(time))s"
                }
                prompt += "; "
            }
        }

        return prompt
    }
}
