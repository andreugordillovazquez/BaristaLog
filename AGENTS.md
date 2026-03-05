# Brew - Espresso Tracking App

iOS app for tracking espresso extractions, built with SwiftUI and SwiftData.

## Overview

**Target:** iOS 26+
**Architecture:** SwiftUI + SwiftData
**Design Philosophy:** Apple-native, minimal, low barrier to entry with depth for advanced users

## Project Structure

```
Brew/
├── BrewApp.swift                 # App entry point, ModelContainer setup
├── MainTabView.swift             # Root TabView (3 tabs)
├── ContentView.swift             # Extractions list + PreviewContainer
├── Models/
│   ├── Extraction.swift          # Core extraction/shot data
│   ├── Bean.swift                # Coffee bean information
│   ├── Grinder.swift             # Grinder equipment
│   └── Brewer.swift              # Brewer/machine equipment
├── Views/
│   ├── AddExtractionView.swift   # Create/edit extraction form
│   ├── ExtractionDetailView.swift # Extraction detail view
│   ├── CoachingView.swift        # AI coaching UI component
│   ├── Beans/
│   │   ├── AddBeanView.swift     # Create/edit bean form
│   │   └── BeanDetailView.swift  # Bean detail view
│   ├── Equipment/
│   │   ├── AddGrinderView.swift  # Create/edit grinder form
│   │   ├── AddBrewerView.swift   # Create/edit brewer form
│   │   ├── GrinderDetailView.swift
│   │   └── BrewerDetailView.swift
│   ├── Library/
│   │   └── LibraryView.swift     # Combined beans + equipment list
│   └── Settings/
│       └── SettingsView.swift    # App settings
└── Services/
    └── BaristaCoach.swift        # Apple Intelligence integration
```

## Data Models

### Extraction (Core Model)
```swift
@Model
final class Extraction {
    var date: Date              // Auto-set to .now
    var grindSetting: String    // Required
    var doseIn: Double?         // Optional (grams)
    var yieldOut: Double?       // Optional (grams)
    var timeSeconds: Double?    // Optional
    var rating: Int?            // Optional (1-5 stars)
    var notes: String?          // Optional

    // Relationships (required at creation)
    var bean: Bean?
    var grinder: Grinder?
    var brewer: Brewer?
}
```

### Bean
```swift
@Model
final class Bean {
    var name: String            // Required
    var roaster: String?
    var origin: String?
    var roastDate: Date?
    var openedDate: Date?
    var notes: String?

    @Relationship(deleteRule: .nullify, inverse: \Extraction.bean)
    var extractions: [Extraction]?
}
```

### Grinder
```swift
@Model
final class Grinder {
    var name: String            // Required
    var brand: String?
    var adjustmentNotes: String? // e.g., "0-50 clicks"
    var notes: String?

    @Relationship(deleteRule: .nullify, inverse: \Extraction.grinder)
    var extractions: [Extraction]?
}
```

### Brewer
```swift
@Model
final class Brewer {
    var name: String            // Required
    var brand: String?
    var brewType: String?       // Espresso, Pour Over, etc.
    var notes: String?

    @Relationship(deleteRule: .nullify, inverse: \Extraction.brewer)
    var extractions: [Extraction]?
}
```

## Navigation Structure

```
TabView
├── Extractions (ContentView)
│   ├── List grouped by date (Today, Yesterday, date)
│   ├── + Menu: "New Extraction" / "From Recent"
│   └── → ExtractionDetailView
│       ├── CoachingView (AI tips)
│       └── Edit → AddExtractionView
├── Library (LibraryView)
│   ├── Beans Section → BeanDetailView → Edit
│   ├── Grinders Section → GrinderDetailView → Edit
│   ├── Brewers Section → BrewerDetailView → Edit
│   └── + Menu: Add Bean/Grinder/Brewer
└── Settings (SettingsView)
    ├── Units (Weight)
    ├── Appearance (Theme)
    ├── Defaults (Grinder, Brewer)
    └── Data (Export, Reset - TODO)
```

## Key Patterns

### SwiftData Queries
```swift
@Query(sort: \Extraction.date, order: .reverse) private var extractions: [Extraction]
@Query(sort: \Bean.name) private var beans: [Bean]
```

### Environment & Bindings
```swift
@Environment(\.modelContext) private var modelContext
@Environment(\.dismiss) private var dismiss
@Bindable var extraction: Extraction  // For two-way binding with @Model
```

### User Preferences
```swift
@AppStorage("appTheme") private var appTheme: AppTheme = .system
@AppStorage("weightUnit") private var weightUnit: WeightUnit = .grams
@AppStorage("defaultGrinderName") private var defaultGrinderName: String = ""
```

### Form Validation
```swift
private var canSave: Bool {
    selectedBean != nil &&
    selectedGrinder != nil &&
    selectedBrewer != nil &&
    !grindSetting.trimmingCharacters(in: .whitespaces).isEmpty
}
```

## Features

### Extraction Tracking
- Record shots with equipment (bean, grinder, brewer)
- Track grind setting, dose, yield, time
- 1-5 star rating system
- Notes for tasting observations
- "From Recent" to quickly duplicate last shot's settings

### Library Management
- Organize beans with roaster, origin, dates
- Track grinders with adjustment ranges
- Manage brewers with brew type categories
- Swipe-to-delete, edit functionality

### AI Coaching (Apple Intelligence)
- On-device analysis using Foundation Models framework
- Manual trigger via "Get Coaching Tips" button
- Compares current shot to previous extractions
- Provides personalized brewing suggestions

### Settings
- Weight units (grams/ounces)
- Theme (system/light/dark)
- Default equipment selection

## UI Components

### RatingPicker
Custom star rating component (1-5 stars, tap to set/clear):
```swift
struct RatingPicker: View {
    @Binding var rating: Int?
    // Displays 5 tappable stars
    // Tap same star to clear rating
}
```

### Row Views
- `ExtractionRowView` - Shows bean name, rating stars, equipment icons
- `BeanRowView` - Name + roaster
- `GrinderRowView` - Name + brand
- `BrewerRowView` - Name + brand

## Preview Support

`PreviewContainer` in ContentView.swift provides:
- In-memory ModelContainer for previews
- Sample data: beans, grinders, brewers, extractions
- Static helpers: `sampleExtraction`, `sampleBean`, etc.

Usage:
```swift
#Preview {
    SomeView()
        .modelContainer(PreviewContainer.container)
}
```

## Build & Run

```bash
# Build for simulator
xcodebuild -scheme Brew -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Available simulators (iOS 26.2)
# iPhone 17, iPhone 17 Pro, iPhone 17 Pro Max, iPhone Air, iPhone 16e
# iPad (A16), iPad Air, iPad Pro, iPad mini
```

## TODO / Future Features

- [ ] Export data functionality
- [ ] Reset all data functionality
- [ ] Apply default grinder/brewer in AddExtractionView
- [ ] Charts/statistics for extraction history
- [ ] Bean freshness tracking (days since roast/opened)
- [ ] Grind setting suggestions based on history
