//
//  WeightPreferences.swift
//  BaristaLog
//

import Foundation

// MARK: - Weight Unit

/// Defines the available units for displaying weight measurements throughout the app
/// Used for dose in, yield out, and other weight-based metrics
enum WeightUnit: String, CaseIterable {
    /// Metric system - grams (default for most espresso recipes)
    case grams = "Grams (g)"
    
    /// Imperial system - ounces (less common for espresso)
    case ounces = "Ounces (oz)"
}

// MARK: - Weight Precision

/// Defines how many decimal places to display for weight measurements
/// Allows users to match their scale's precision or personal preference
enum WeightPrecision: String, CaseIterable {
    /// No decimal places (e.g., 18 g)
    /// Suitable for basic scales or users who prefer whole numbers
    case zeroDecimal = "18 g"
    
    /// One decimal place (e.g., 18.0 g)
    /// Standard precision for most espresso scales
    case oneDecimal = "18.0 g"
    
    /// Two decimal places (e.g., 18.00 g)
    /// High precision for users with accurate scales
    case twoDecimal = "18.00 g"

    /// Human-readable label for the precision option
    /// Used in settings UI to describe each option clearly
    var label: String {
        switch self {
        case .zeroDecimal: return "No decimals"
        case .oneDecimal: return "1 decimal"
        case .twoDecimal: return "2 decimals"
        }
    }

    /// The number of decimal places as an integer
    /// Used for string formatting with NumberFormatter or similar
    var decimals: Int {
        switch self {
        case .zeroDecimal: return 0
        case .oneDecimal: return 1
        case .twoDecimal: return 2
        }
    }
}

// MARK: - Weight Formatter

enum WeightFormatter {
    static func format(grams: Double, unit: WeightUnit, precision: WeightPrecision) -> String {
        let value: Double
        let symbol: String
        switch unit {
        case .grams:
            value = grams
            symbol = "g"
        case .ounces:
            value = grams / 28.349523125
            symbol = "oz"
        }
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = precision.decimals
        formatter.maximumFractionDigits = precision.decimals
        let number = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(number)\(symbol)"
    }

    static func unitLabel(for unit: WeightUnit) -> String {
        switch unit {
        case .grams: return "g"
        case .ounces: return "oz"
        }
    }

    static func formatValue(grams: Double, unit: WeightUnit, precision: WeightPrecision) -> String {
        let value: Double = unit == .grams ? grams : grams / 28.349523125
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = precision.decimals
        formatter.maximumFractionDigits = precision.decimals
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

// MARK: - App Theme

/// Defines the available color scheme options for the app
/// Allows users to choose between light mode, dark mode, or system default
enum AppTheme: String, CaseIterable {
    /// Follow the device's system appearance setting
    case system = "System"
    
    /// Always use light mode regardless of system setting
    case light = "Light"
    
    /// Always use dark mode regardless of system setting
    case dark = "Dark"
}
