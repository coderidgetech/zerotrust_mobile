# Flutter App Build Instructions

## Prerequisites

### Development Environment
```bash
# Install Flutter SDK (Latest Stable)
# Download from: https://docs.flutter.dev/get-started/install

# Verify installation
flutter doctor

# Install dependencies
flutter pub get
```

### Platform-specific Requirements

#### Android
```bash
# Install Android Studio and SDK
# Accept Android licenses
flutter doctor --android-licenses

# Connect device or start emulator
flutter devices
```

#### iOS (macOS only)
```bash
# Install Xcode from App Store
# Install CocoaPods
sudo gem install cocoapods

# For iOS deployment
cd ios
pod install
cd ..
```

## Development Build

### Run on Connected Device
```bash
# Debug mode (hot reload enabled)
flutter run

# Run on specific device
flutter run -d <device_id>

# Run with specific flavor
flutter run --flavor dev
flutter run --flavor staging
flutter run --flavor production
```

### Configuration

#### Environment Setup
Create environment configuration files:

```bash
# lib/config/dev_config.dart
class DevConfig {
  static const String apiBaseUrl = 'http://localhost:5000';
  static const String appName = 'ZeroVault Dev';
  static const bool enableLogging = true;
}

# lib/config/prod_config.dart
class ProdConfig {
  static const String apiBaseUrl = 'https://your-api.com';
  static const String appName = 'ZeroVault';
  static const bool enableLogging = false;
}
```

#### API Configuration
Update `lib/core/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-zerovault-api.com';
```

## Production Build

### Android APK
```bash
# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Build with specific flavor
flutter build apk --release --flavor production
```

#### Signing Configuration
Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=../keystore.jks
```

Update `android/app/build.gradle`:
```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### iOS Build
```bash
# Build iOS app
flutter build ios --release

# For App Store distribution
flutter build ipa --release
```

#### iOS Configuration
Update `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>ZeroVault</string>
<key>CFBundleIdentifier</key>
<string>com.yourcompany.zerovault</string>
```

## App Store Deployment

### Google Play Store (Android)

#### Prepare for Upload
```bash
# Build App Bundle
flutter build appbundle --release

# Locate the bundle
# build/app/outputs/bundle/release/app-release.aab
```

#### Upload Process
1. Create Google Play Console account
2. Create new application
3. Upload app bundle
4. Fill store listing information
5. Set up content rating
6. Configure pricing and distribution
7. Review and publish

### Apple App Store (iOS)

#### Prepare for Upload
```bash
# Build for App Store
flutter build ipa --release

# Open Xcode for final configuration
open ios/Runner.xcworkspace
```

#### Upload Process
1. Configure app in Xcode
2. Archive and upload via Xcode
3. Create app in App Store Connect
4. Fill app information
5. Submit for review

## CI/CD Pipeline

### GitHub Actions Example
```yaml
# .github/workflows/build.yml
name: Build and Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter analyze

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
```

### Firebase App Distribution
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Deploy to Firebase App Distribution
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
    --app your-android-app-id \
    --groups "testers"
```

## Testing

### Unit Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/auth_test.dart
```

### Integration Tests
```bash
# Run integration tests
flutter test integration_test/

# Run on specific device
flutter test integration_test/ -d <device_id>
```

### Widget Tests
```bash
# Test specific widget
flutter test test/widget/login_screen_test.dart
```

## Performance Optimization

### Code Analysis
```bash
# Analyze code
flutter analyze

# Check for unused dependencies
flutter pub deps
```

### Size Analysis
```bash
# Analyze APK size
flutter build apk --analyze-size

# Create size report
flutter build apk --target-platform android-arm,android-arm64 --analyze-size
```

### Performance Profiling
```bash
# Run in profile mode
flutter run --profile

# Enable performance overlay
flutter run --profile --dart-define=flutter.inspector.structuredErrors=true
```

## Troubleshooting

### Common Issues

#### Android Build Issues
```bash
# Clean build
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter build apk

# Fix Gradle issues
cd android
./gradlew --refresh-dependencies
cd ..
```

#### iOS Build Issues
```bash
# Clean iOS build
flutter clean
cd ios
rm Podfile.lock
rm -rf Pods
pod install
cd ..
flutter build ios
```

#### Dependency Issues
```bash
# Update dependencies
flutter pub upgrade

# Fix dependency conflicts
flutter pub deps
flutter pub get
```

### Performance Issues
- Use `const` constructors where possible
- Implement proper `dispose()` methods
- Use `ListView.builder()` for large lists
- Optimize image loading with `cached_network_image`
- Profile app with Flutter Inspector

### Memory Leaks
- Always dispose controllers and streams
- Use `WeakReference` for callbacks
- Monitor memory usage with Flutter DevTools
- Implement proper lifecycle management

## Security Considerations

### API Security
- Use certificate pinning
- Implement proper token refresh
- Store sensitive data in secure storage
- Validate all user inputs

### Code Obfuscation
```bash
# Build with obfuscation
flutter build apk --obfuscate --split-debug-info=debug-info/

# For iOS
flutter build ios --obfuscate --split-debug-info=debug-info/
```

### Permissions
Review and minimize required permissions in:
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

This comprehensive build guide ensures your Flutter app is production-ready with proper configuration, testing, and deployment procedures.