//
//  Extraction.swift
//  BaristaLog
//

import Foundation
import SwiftData

/// Represents a single espresso extraction (shot) with all its parameters and metadata
/// This is the core model that ties together beans, grinder, and brewer to record
/// the details and results of an espresso shot
@Model
final class Extraction {
    // MARK: - Automatic Properties
    
    /// The timestamp when this extraction was performed
    /// Defaults to the current date/time when created
    var date: Date

    // MARK: - Required Properties
    
    /// The grinder setting used for this shot (e.g., "15", "2.5", "fine")
    /// Required because grind setting is fundamental to espresso extraction
    var grindSetting: String

    // MARK: - Optional Shot Parameters
    
    /// The amount of coffee grounds used, in grams (e.g., 18.0, 20.5)
    var doseIn: Double?
    
    /// The amount of liquid espresso extracted, in grams or ml (e.g., 36.0, 40.0)
    var yieldOut: Double?
    
    /// The total extraction time in seconds (e.g., 28.5, 32.0)
    var timeSeconds: Double?
    
    /// User's rating of the shot quality (typically 1-5 scale)
    var rating: Int?
    
    /// User notes about the shot (taste profile, adjustments needed, observations, etc.)
    var notes: String?

    // MARK: - Relationships
    
    /// The coffee bean used for this extraction
    /// Optional in code but conceptually required - set in initializer
    var bean: Bean?
    
    /// The grinder used for this extraction
    /// Optional in code but conceptually required - set in initializer
    var grinder: Grinder?
    
    /// The espresso machine used for this extraction
    /// Optional in code but conceptually required - set in initializer
    var brewer: Brewer?

    // MARK: - Initialization
    
    /// Creates a new Extraction (espresso shot) record
    /// - Parameters:
    ///   - date: Timestamp of the extraction (defaults to now)
    ///   - grindSetting: Required grinder setting used
    ///   - doseIn: Optional coffee dose in grams
    ///   - yieldOut: Optional espresso yield in grams/ml
    ///   - timeSeconds: Optional extraction time in seconds
    ///   - rating: Optional user rating of the shot
    ///   - notes: Optional tasting notes or observations
    ///   - bean: The coffee bean used (required)
    ///   - grinder: The grinder used (required)
    ///   - brewer: The espresso machine used (required)
    init(
        date: Date = .now,
        grindSetting: String,
        doseIn: Double? = nil,
        yieldOut: Double? = nil,
        timeSeconds: Double? = nil,
        rating: Int? = nil,
        notes: String? = nil,
        bean: Bean,
        grinder: Grinder,
        brewer: Brewer
    ) {
        self.date = date
        self.grindSetting = grindSetting
        self.doseIn = doseIn
        self.yieldOut = yieldOut
        self.timeSeconds = timeSeconds
        self.rating = rating
        self.notes = notes
        self.bean = bean
        self.grinder = grinder
        self.brewer = brewer
    }
}
