//
//  DataExportService.swift
//  Brew
//

import Foundation
import SwiftData

struct DataExportService {

    // MARK: - CSV Export (Extractions)

    static func exportExtractionsCSV(context: ModelContext) throws -> URL {
        let descriptor = FetchDescriptor<Extraction>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let extractions = try context.fetch(descriptor)

        var csv = "Date,Bean,Roaster,Grinder,Brewer,Grind Setting,Dose (g),Yield (g),Time (s),Water Temp (°C),Prep Method,Rating,Notes\n"

        let dateFormatter = ISO8601DateFormatter()

        for e in extractions {
            let fields: [String] = [
                dateFormatter.string(from: e.date),
                csvEscape(e.bean?.name),
                csvEscape(e.bean?.roaster),
                csvEscape(e.grinder?.name),
                csvEscape(e.brewer?.name),
                csvEscape(e.grindSetting),
                e.doseIn.map { String($0) } ?? "",
                e.yieldOut.map { String($0) } ?? "",
                e.timeSeconds.map { String($0) } ?? "",
                e.waterTemperature.map { String($0) } ?? "",
                csvEscape(e.prepMethod),
                e.rating.map { String($0) } ?? "",
                csvEscape(e.notes)
            ]
            csv += fields.joined(separator: ",") + "\n"
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("BaristaLog-Extractions.csv")
        try csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: - JSON Export (Full Data)

    static func exportAllJSON(context: ModelContext) throws -> URL {
        let extractions = try context.fetch(FetchDescriptor<Extraction>(sortBy: [SortDescriptor(\.date, order: .reverse)]))
        let beans = try context.fetch(FetchDescriptor<Bean>(sortBy: [SortDescriptor(\.name)]))
        let grinders = try context.fetch(FetchDescriptor<Grinder>(sortBy: [SortDescriptor(\.name)]))
        let brewers = try context.fetch(FetchDescriptor<Brewer>(sortBy: [SortDescriptor(\.name)]))

        let dateFormatter = ISO8601DateFormatter()

        let export = ExportPayload(
            exportDate: dateFormatter.string(from: .now),
            beans: beans.map { bean in
                ExportBean(
                    name: bean.name,
                    roaster: bean.roaster,
                    origin: bean.origin,
                    roastDate: bean.roastDate.map { dateFormatter.string(from: $0) },
                    openedDate: bean.openedDate.map { dateFormatter.string(from: $0) },
                    notes: bean.notes,
                    process: bean.process,
                    roastLevel: bean.roastLevel,
                    varietal: bean.varietal,
                    altitude: bean.altitude,
                    flavorTags: bean.flavorTags
                )
            },
            grinders: grinders.map { grinder in
                ExportGrinder(
                    name: grinder.name,
                    brand: grinder.brand,
                    burrType: grinder.burrType,
                    burrSize: grinder.burrSize,
                    adjustmentNotes: grinder.adjustmentNotes,
                    notes: grinder.notes
                )
            },
            brewers: brewers.map { brewer in
                ExportBrewer(
                    name: brewer.name,
                    brand: brewer.brand,
                    brewType: brewer.brewType,
                    portafilterSize: brewer.portafilterSize,
                    basketSize: brewer.basketSize,
                    notes: brewer.notes
                )
            },
            extractions: extractions.map { e in
                ExportExtraction(
                    date: dateFormatter.string(from: e.date),
                    bean: e.bean?.name,
                    grinder: e.grinder?.name,
                    brewer: e.brewer?.name,
                    grindSetting: e.grindSetting,
                    doseIn: e.doseIn,
                    yieldOut: e.yieldOut,
                    timeSeconds: e.timeSeconds,
                    waterTemperature: e.waterTemperature,
                    prepMethod: e.prepMethod,
                    rating: e.rating,
                    notes: e.notes
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(export)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("BaristaLog-Export.json")
        try data.write(to: url, options: .atomic)
        return url
    }

    // MARK: - Helpers

    private static func csvEscape(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "" }
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return value
    }
}

// MARK: - Export Codable Types

private struct ExportPayload: Encodable {
    let exportDate: String
    let beans: [ExportBean]
    let grinders: [ExportGrinder]
    let brewers: [ExportBrewer]
    let extractions: [ExportExtraction]
}

private struct ExportBean: Encodable {
    let name: String
    let roaster: String?
    let origin: String?
    let roastDate: String?
    let openedDate: String?
    let notes: String?
    let process: String?
    let roastLevel: String?
    let varietal: String?
    let altitude: String?
    let flavorTags: [String]?
}

private struct ExportGrinder: Encodable {
    let name: String
    let brand: String?
    let burrType: String?
    let burrSize: String?
    let adjustmentNotes: String?
    let notes: String?
}

private struct ExportBrewer: Encodable {
    let name: String
    let brand: String?
    let brewType: String?
    let portafilterSize: String?
    let basketSize: String?
    let notes: String?
}

private struct ExportExtraction: Encodable {
    let date: String
    let bean: String?
    let grinder: String?
    let brewer: String?
    let grindSetting: String
    let doseIn: Double?
    let yieldOut: Double?
    let timeSeconds: Double?
    let waterTemperature: Double?
    let prepMethod: String?
    let rating: Int?
    let notes: String?
}
