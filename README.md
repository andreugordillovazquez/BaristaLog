# BaristaLog

A beautifully simple iOS app for tracking your espresso extractions and dialing in the perfect shot.

Built with SwiftUI and SwiftData for iOS 26+.

## What it does

BaristaLog helps you log every shot you pull — what beans you used, your grind setting, dose, yield, time, and how it tasted. Over time, you build a history that helps you dial in faster and waste less coffee.

### Extraction Tracking
Record your shots with all the details that matter: equipment, grind setting, dose, yield, time, and a star rating. Use **"From Recent"** to quickly repeat your last setup.

### Bean Library
Keep track of your beans with roaster, origin, process, roast level, flavor tags, and photos. When you finish a bag, mark it as done and start a new one — your history stays with the old bag.

### Equipment Management
Organize your grinders and brewers with specs like burr type, portafilter size, and adjustment notes.

### AI Coaching
Get personalized brewing tips powered by Apple Intelligence. The on-device AI compares your current shot to your history and suggests what to adjust next — all processed privately on your device.

## Screenshots

*Coming soon*

## Requirements

- iOS 26+
- Xcode 26+
- Apple Intelligence capable device (for AI coaching)

## Building

```bash
xcodebuild -scheme BaristaLog \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
```

## Tech Stack

- **SwiftUI** — Fully declarative UI with Liquid Glass
- **SwiftData** — Local persistence with zero setup
- **Foundation Models** — On-device AI coaching via Apple Intelligence
- **PhotosUI** — Bean and equipment photos

## License

*TBD*
