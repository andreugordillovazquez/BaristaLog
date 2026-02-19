//
//  Bean.swift
//  BaristaLog
//

import Foundation
import SwiftData

/// Represents a coffee bean with its metadata and relationship to extractions
/// This model stores information about coffee beans including roaster details,
/// origin, dates, and optional image data
@Model
final class Bean {
    // MARK: - Required Properties
    
    /// The name or label of the coffee bean (e.g., "Ethiopian Yirgacheffe")
    var name: String

    // MARK: - Optional Properties
    
    /// The roaster or company that roasted these beans
    var roaster: String?
    
    /// The geographic origin of the beans (e.g., "Ethiopia", "Colombia")
    var origin: String?
    
    /// The date when these beans were roasted
    var roastDate: Date?
    
    /// The date when the bag was opened (useful for tracking freshness)
    var openedDate: Date?
    
    /// User notes about the beans (tasting notes, brewing recommendations, etc.)
    var notes: String?
    
    /// Image of the coffee bag or beans
    /// Stored externally to avoid database bloat with large binary data
    @Attribute(.externalStorage) var imageData: Data?

    // MARK: - Relationships
    
    /// All espresso extractions (shots) made with this bean
    /// Uses nullify delete rule: when a bean is deleted, associated extractions
    /// have their bean reference set to nil rather than being deleted
    @Relationship(deleteRule: .nullify, inverse: \Extraction.bean)
    var extractions: [Extraction]?

    // MARK: - Initialization
    
    /// Creates a new Bean instance
    /// - Parameters:
    ///   - name: Required name of the coffee bean
    ///   - roaster: Optional roaster name
    ///   - origin: Optional geographic origin
    ///   - roastDate: Optional roast date
    ///   - openedDate: Optional date when bag was opened
    ///   - notes: Optional user notes
    ///   - imageData: Optional image data of the bag/beans
    init(
        name: String,
        roaster: String? = nil,
        origin: String? = nil,
        roastDate: Date? = nil,
        openedDate: Date? = nil,
        notes: String? = nil,
        imageData: Data? = nil
    ) {
        self.name = name
        self.roaster = roaster
        self.origin = origin
        self.roastDate = roastDate
        self.openedDate = openedDate
        self.notes = notes
        self.imageData = imageData
    }
}
