//
//  Brewer.swift
//  BaristaLog
//

import Foundation
import SwiftData

/// Represents an espresso machine or brewing device used for extractions
/// This model stores information about the brewing equipment including brand,
/// type, portafilter specifications, and optional image data
@Model
final class Brewer {
    // MARK: - Required Properties
    
    /// The name or model of the espresso machine (e.g., "Gaggia Classic Pro")
    var name: String

    // MARK: - Optional Properties
    
    /// The manufacturer or brand of the machine (e.g., "La Marzocco", "Gaggia")
    var brand: String?
    
    /// The type or category of brewer (e.g., "Semi-automatic", "Manual lever")
    var brewType: String?
    
    /// The size of the portafilter (e.g., "58mm", "54mm")
    var portafilterSize: String?
    
    /// The size or capacity of the filter basket (e.g., "18g", "20-22g")
    var basketSize: String?
    
    /// User notes about the brewer (maintenance logs, modifications, tips, etc.)
    var notes: String?
    
    /// Image of the espresso machine or brewing device
    /// Stored externally to avoid database bloat with large binary data
    @Attribute(.externalStorage) var imageData: Data?

    // MARK: - Relationships
    
    /// All espresso extractions (shots) made with this brewer
    /// Uses nullify delete rule: when a brewer is deleted, associated extractions
    /// have their brewer reference set to nil rather than being deleted
    @Relationship(deleteRule: .nullify, inverse: \Extraction.brewer)
    var extractions: [Extraction]?

    // MARK: - Initialization
    
    /// Creates a new Brewer instance
    /// - Parameters:
    ///   - name: Required name/model of the espresso machine
    ///   - brand: Optional manufacturer name
    ///   - brewType: Optional brewing method or machine type
    ///   - portafilterSize: Optional portafilter diameter
    ///   - basketSize: Optional basket capacity
    ///   - notes: Optional user notes
    ///   - imageData: Optional image data of the machine
    init(
        name: String,
        brand: String? = nil,
        brewType: String? = nil,
        portafilterSize: String? = nil,
        basketSize: String? = nil,
        notes: String? = nil,
        imageData: Data? = nil
    ) {
        self.name = name
        self.brand = brand
        self.brewType = brewType
        self.portafilterSize = portafilterSize
        self.basketSize = basketSize
        self.notes = notes
        self.imageData = imageData
    }
}
