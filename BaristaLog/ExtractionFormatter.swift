//
//  ExtractionFormatter.swift
//  BaristaLog
//

import Foundation

enum ExtractionFormatter {
    static func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if mins > 0 {
            return "\(mins)m \(secs)s"
        }
        return "\(secs)s"
    }

    static func summary(_ extraction: Extraction) -> String {
        var parts: [String] = []
        if let dose = extraction.doseIn {
            parts.append(String(format: "%.1fg", dose))
        }
        if let yield = extraction.yieldOut {
            parts.append(String(format: "%.1fg", yield))
        }
        let recipe = parts.joined(separator: " → ")

        if let time = extraction.timeSeconds {
            let timeStr = formatTime(time)
            return recipe.isEmpty ? timeStr : "\(recipe) · \(timeStr)"
        }
        return recipe.isEmpty ? extraction.grindSetting : recipe
    }
}
