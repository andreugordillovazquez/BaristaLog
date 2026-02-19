//
//  Grinder.swift
//  BaristaLog
//

import Foundation
import SwiftData

/// Represents a coffee grinder used for espresso preparation
/// This model stores information about the grinder including brand, burr specifications,
/// adjustment information, and optional image data
@Model
final class Grinder {
    // MARK: - Required Properties
    
    /// The name or model of the grinder (e.g., "Niche Zero", "Baratza Sette 270")
    var name: String

    // MARK: - Optional Properties
    
    /// The manufacturer or brand of the grinder (e.g., "Niche", "Baratza", "Eureka")
    var brand: String?
    
    /// The type of burrs used (e.g., "Flat", "Conical", "Ghost burrs")
    var burrType: String?
    
    /// The diameter of the burrs (e.g., "63mm", "83mm")
    var burrSize: String?
    
    /// Notes about how to read or adjust the grind settings
    /// Useful for stepless grinders or documenting calibration points
    var adjustmentNotes: String?
    
    /// General user notes about the grinder (maintenance, modifications, quirks, etc.)
    var notes: String?
    
    /// Image of the grinder
    /// Stored externally to avoid database bloat with large binary data
    @Attribute(.externalStorage) var imageData: Data?

    // MARK: - Relationships
    
    /// All espresso extractions (shots) made with this grinder
    /// Uses nullify delete rule: when a grinder is deleted, associated extractions
    /// have their grinder reference set to nil rather than being deleted
    @Relationship(deleteRule: .nullify, inverse: \Extraction.grinder)
    var extractions: [Extraction]?

    // MARK: - Initialization
    
    /// Creates a new Grinder instance
    /// - Parameters:
    ///   - name: Required name/model of the grinder
    ///   - brand: Optional manufacturer name
    ///   - burrType: Optional burr style (flat/conical)
    ///   - burrSize: Optional burr diameter
    ///   - adjustmentNotes: Optional notes about adjustment mechanism or calibration
    ///   - notes: Optional user notes
    ///   - imageData: Optional image data of the grinder
    init(
        name: String,
        brand: String? = nil,
        burrType: String? = nil,
        burrSize: String? = nil,
        adjustmentNotes: String? = nil,
        notes: String? = nil,
        imageData: Data? = nil
    ) {
        self.name = name
        self.brand = brand
        self.burrType = burrType
        self.burrSize = burrSize
        self.adjustmentNotes = adjustmentNotes
        self.notes = notes
        self.imageData = imageData
    }
}
