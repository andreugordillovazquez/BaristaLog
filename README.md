# BaristaLog

An iOS app for tracking espresso extractions, built with SwiftUI and SwiftData.

## Overview

BaristaLog helps baristas and coffee enthusiasts log shots, organize equipment and beans, and improve their extractions over time with on-device AI coaching powered by Apple Intelligence.

**Target:** iOS 26+
**Architecture:** SwiftUI + SwiftData
**Design:** Apple-native, minimal, low barrier to entry with depth for advanced users

## Features

- **Extraction Logging** — Record shots with grind setting, dose, yield, time, and a 1–5 star rating. Required fields (bean, grinder, brewer, grind setting) keep data consistent. "From Recent" duplicates your last shot's settings for quick logging.
- **Library** — Manage your beans (with roaster, origin, roast/opened dates, and photos), grinders (burr type, size, adjustment range), and brewers (brew type, portafilter/basket specs).
- **AI Coaching** — On-device analysis using the Foundation Models framework compares your current shot to your history and suggests adjustments. Runs privately on-device via Apple Intelligence.
- **Onboarding** — A 6-step flow sets up units, default equipment, beans, and coaching preferences before the first extraction.
- **Settings** — Weight units (g/oz), decimal precision, app theme (system/light/dark), default grinder and brewer, and data reset.

## Project Structure

```
BaristaLog/
├── BrewApp.swift                 # App entry point, ModelContainer setup
├── RootView.swift                # Root view with onboarding overlay
├── MainTabView.swift             # Root TabView (3 tabs)
├── ContentView.swift             # Extractions list
├── Models/
│   ├── Extraction.swift
│   ├── Bean.swift
│   ├── Grinder.swift
│   ├── Brewer.swift
│   └── WeightPreferences.swift   # WeightUnit, WeightPrecision, AppTheme enums
├── Views/
│   ├── AddExtractionView.swift
│   ├── ExtractionDetailView.swift
│   ├── CoachingView.swift
│   ├── Beans/
│   ├── Equipment/
│   ├── Library/
│   ├── Settings/
│   └── Onboarding/
└── Services/
    └── BaristaCoach.swift        # Apple Intelligence integration
```

## Data Models

### Extraction
| Field | Type | Required |
|---|---|---|
| date | Date | Yes (auto) |
| grindSetting | String | Yes |
| bean | Bean | Yes |
| grinder | Grinder | Yes |
| brewer | Brewer | Yes |
| doseIn | Double? | No |
| yieldOut | Double? | No |
| timeSeconds | Double? | No |
| rating | Int? | No (1–5) |
| notes | String? | No |

### Bean / Grinder / Brewer
Each has a required `name`, optional metadata fields, an optional photo (`imageData`), and a back-reference to related extractions. All relationships use a `.nullify` delete rule so deleting equipment doesn't cascade-delete your shot history.

## Building

```bash
xcodebuild -scheme Brew \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
```

Supported simulators (iOS 26.2): iPhone 17, iPhone 17 Pro, iPhone 17 Pro Max, iPhone Air, iPhone 16e, iPad (A16), iPad Air, iPad Pro, iPad mini.

## Preview Support

`PreviewContainer` in `ContentView.swift` provides an in-memory `ModelContainer` with sample data for SwiftUI previews:

```swift
#Preview {
    SomeView()
        .modelContainer(PreviewContainer.container)
}
```
