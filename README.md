# Barcode & QR Code Scanner

A production-ready Barcode & QR Code Scanner app built with Flutter (Flutter 3.x+), deployable to Android and iOS.

## Features

### Core Features
- **Modern UI** - Material 3 design with dark/light theme support
- **Full-screen Scanner** - Camera preview with animated overlay (rectangle + scan line animation)
- **Multi-format Support** - Real-time detection of multiple barcode formats:
  - 2D: QR Code, Data Matrix, PDF417, Aztec
  - 1D: EAN-13, EAN-8, UPC-A, UPC-E, Code 128, Code 39, Code 93, ITF, Codabar
- **Smart Content Detection** - Automatic parsing of:
  - URLs
  - Text
  - WiFi credentials
  - Contacts (vCard/MECARD)
  - Calendar events
  - Email addresses
  - Phone numbers
  - SMS
  - Geo locations
- **Action Buttons** - Copy, Share, Open (for URLs), and more based on content type
- **Scan History** - Save last 100 scans with local storage (Hive)
- **Camera Controls** - Flashlight toggle and front/back camera switch
- **Haptic Feedback** - Configurable vibration and sound on successful scan
- **Multi-language** - English (en), Russian (ru), Spanish (es)

### Production-Ready
- Uses `mobile_scanner` for optimal performance
- Proper camera permission handling
- Clean architecture (screens, widgets, services, models)
- Responsive design for all phone sizes
- Error handling for camera issues and permission denials
- No debug banner in release builds

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── app_settings.dart     # Settings model
│   ├── barcode_format.dart   # Barcode format enum
│   ├── content_type.dart     # Content type enum and parser
│   ├── scan_result.dart      # Scan result model with Hive
│   └── models.dart           # Barrel export
├── services/                 # Business logic
│   ├── action_service.dart   # Actions (copy, share, open)
│   ├── feedback_service.dart # Vibration and sound
│   ├── history_service.dart  # Scan history storage
│   ├── settings_service.dart # App settings storage
│   └── services.dart         # Barrel export
├── screens/                  # UI screens
│   ├── home_screen.dart      # Main screen with navigation
│   ├── scanner_screen.dart   # Camera scanner
│   ├── result_screen.dart    # Scan result display
│   ├── history_screen.dart   # Scan history list
│   ├── settings_screen.dart  # App settings
│   └── screens.dart          # Barrel export
├── widgets/                  # Reusable widgets
│   ├── scanner_overlay.dart  # Scanner overlay with animation
│   └── widgets.dart          # Barrel export
└── l10n/                     # Localization
    ├── app_en.arb            # English translations
    ├── app_ru.arb            # Russian translations
    └── app_es.arb            # Spanish translations
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode for platform-specific builds

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/remotenode/bar-code-scanner.git
   cd bar-code-scanner
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate Hive adapters (if needed):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Generate localizations:
   ```bash
   flutter gen-l10n
   ```

### Running the App

```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## Release Build Instructions

### Android

1. **Configure signing** (for release builds):

   Create `android/key.properties`:
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=<your-key-alias>
   storeFile=<path-to-your-keystore>
   ```

2. **Update `android/app/build.gradle`** to use the signing config (already configured for debug signing).

3. **Build APK**:
   ```bash
   flutter build apk --release
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`

4. **Build App Bundle** (recommended for Play Store):
   ```bash
   flutter build appbundle --release
   ```
   Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS

1. **Open in Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure signing**:
   - Select the Runner target
   - Go to Signing & Capabilities
   - Select your Team and Bundle Identifier

3. **Build for release**:
   ```bash
   flutter build ios --release
   ```

4. **Archive and distribute** through Xcode's Product > Archive menu.

### Generate App Icons

1. Add your icon to `assets/icons/app_icon.png` (1024x1024)
2. For Android adaptive icons, add `assets/icons/app_icon_foreground.png`
3. Run:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### Generate Splash Screen

1. Add your splash icon to `assets/icons/splash_icon.png`
2. Run:
   ```bash
   flutter pub run flutter_native_splash:create
   ```

## Adding Sound Assets

For scan success sound, add a `beep.mp3` file to `assets/sounds/`.

You can find free beep sounds at:
- [Freesound](https://freesound.org/)
- [Pixabay](https://pixabay.com/sound-effects/)

## Configuration

### Supported Languages

The app supports the following languages:
- English (en) - Default
- Russian (ru)
- Spanish (es)

To add more languages, create a new `.arb` file in `lib/l10n/` following the existing format.

### Theme Customization

The app uses Material 3 with a blue seed color. To customize:

1. Edit `lib/main.dart`
2. Modify the `ColorScheme.fromSeed()` call with your preferred seed color

## Dependencies

| Package | Description |
|---------|-------------|
| `mobile_scanner` | Camera barcode scanning |
| `hive_flutter` | Local storage |
| `provider` | State management |
| `share_plus` | Share functionality |
| `url_launcher` | Open URLs |
| `vibration` | Haptic feedback |
| `audioplayers` | Sound playback |
| `permission_handler` | Permission requests |
| `intl` | Internationalization |

## Permissions

### Android
- `CAMERA` - Required for scanning
- `VIBRATE` - For haptic feedback
- `INTERNET` - For opening URLs

### iOS
- Camera usage description in Info.plist

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [mobile_scanner](https://pub.dev/packages/mobile_scanner) for the excellent barcode scanning library
- [Material Design 3](https://m3.material.io/) for design guidelines
