# BalanceIQ

**BalanceIQ** is an AI-powered personal finance chatbot application built with Flutter. It features four specialized financial bots that help users manage their finances through an intuitive chat interface.

## Features

### Four Specialized Bots
1. **Balance Tracker** - Monitor expenses and track spending patterns
2. **Investment Guru** - Get insights and tips on investment options
3. **Budget Planner** - Create and maintain budgets effectively
4. **Fin Tips** - Learn financial literacy and smart money habits

### Key Capabilities
- Text, image, and audio message support
- Persistent chat history with local SQLite database
- Google and Apple sign-in authentication
- Dark mode support
- Integration with n8n workflow for AI responses
- Clean architecture with Cubit state management

## Architecture

The project follows **Clean Architecture** principles with three main layers:

```
lib/
├── core/                    # Core utilities, constants, and theme
│   ├── constants/
│   ├── database/
│   ├── di/                  # Dependency injection
│   ├── error/
│   └── theme/
└── features/               # Feature modules
    ├── auth/               # Authentication
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── chat/               # Chat functionality
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── home/               # Home screen
        └── presentation/
```

### Technology Stack
- **Flutter** - Cross-platform mobile framework
- **Cubit** (flutter_bloc) - State management
- **SQLite** - Local database for chat history
- **GetIt** - Dependency injection
- **Dio** - HTTP client for API calls
- **n8n** - Workflow automation for AI responses

## Setup Instructions

### Prerequisites
- **Flutter SDK**: 3.27.0 (using FVM - Flutter Version Management)
- **Dart SDK**: 3.6.0 (comes with Flutter)
- **FVM**: For managing Flutter versions ([Install FVM](https://fvm.app/documentation/getting-started/installation))
- **Xcode**: For iOS development (macOS only)
- **Android Studio**: For Android development
- **JDK**: Version 11 or higher
- **n8n workflow instance**: For AI bot responses

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd balanceIQ
   ```

2. **Install Flutter 3.27.0 using FVM**
   ```bash
   # Install FVM if you haven't already
   # macOS/Linux:
   brew tap leoafarias/fvm
   brew install fvm

   # Windows: Follow instructions at https://fvm.app/documentation/getting-started/installation

   # Install Flutter 3.27.0
   fvm install 3.27.0

   # Use Flutter 3.27.0 for this project
   fvm use 3.27.0
   ```

3. **Install dependencies**
   ```bash
   fvm flutter pub get
   ```

4. **Configure Google Sign-In (IMPORTANT)**

   Google Sign-In requires your device's SHA-1 certificate fingerprint to be registered in Firebase.

   **Step 1: Get your SHA-1 fingerprint**

   Run this command to get your debug keystore's SHA-1:

   **macOS/Linux:**
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep -A 2 "SHA1:"
   ```

   **Windows:**
   ```bash
   keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

   You'll see output like:
   ```
   SHA1: 9B:6D:5E:9D:07:F1:EC:35:4B:35:F9:9C:09:B2:5A:1A:09:63:95:62
   SHA256: EE:A1:93:2C:D1:BE:35:7F:C2:CF:99:BA:E5:D0:0A:6E:62:7D:7E:C5:EA:AD:2E:85:86:55:52:8D:2B:48:EB:A2
   ```

   **Step 2: Add your SHA-1 to Firebase**

   1. Go to [Firebase Console](https://console.firebase.google.com/project/balanceiq-60956/settings/general)
   2. Scroll to "Your apps" section
   3. Click on the Android app: `com.balanceiq.balance_iq`
   4. Click "Add fingerprint" button
   5. Paste your **SHA-1** fingerprint
   6. (Optional) Add your **SHA-256** fingerprint as well
   7. Click "Save"

   **Step 3: No need to update google-services.json**

   The existing `google-services.json` file in the repository will work fine! Firebase recognizes all registered SHA-1 fingerprints on the backend, so you don't need to download or update the file.

   **For iOS:**
   - The OAuth configuration is already set up in [ios/Runner/Info.plist](ios/Runner/Info.plist)
   - No additional setup required

5. **Configure Apple Sign-In (iOS only)**

   - Enable Sign in with Apple in Xcode capabilities
   - The configuration is already set up in the project

6. **Configure n8n Webhook URL**

   The app uses an n8n webhook for AI responses. You can configure the webhook URL in two ways:

   **Option 1: Environment Variable (Recommended)**
   ```bash
   fvm flutter run --dart-define=N8N_WEBHOOK_URL=https://your-n8n-instance.com/webhook/balance-iq
   ```

   **Option 2: Update Constants File**

   Edit [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart) and update the default value:
   ```dart
   static const String n8nWebhookUrl = 'https://your-n8n-instance.com/webhook/balance-iq';
   ```

### Running the App

**IMPORTANT**: Always use `fvm flutter` instead of just `flutter` to ensure you're using the correct Flutter version (3.27.0).

**Note:** The app requires a flavor (`staging` or `prod`) to run.

```bash
# Run Staging Flavor
fvm flutter run --flavor staging -t lib/main_staging.dart --dart-define=ENV=staging

# Run Production Flavor
fvm flutter run --flavor prod -t lib/main_prod.dart --dart-define=ENV=prod
```
# Check connected devices
fvm flutter devices

# Run in debug mode
fvm flutter run

# Run on a specific device
fvm flutter run -d <device-id>

# Run with custom n8n webhook URL
fvm flutter run --dart-define=N8N_WEBHOOK_URL=https://your-webhook-url.com

# Build for release (Android)
fvm flutter build apk --release

# Build for release (iOS)
fvm flutter build ios --release

# Clean build files (if you encounter issues)
fvm flutter clean && fvm flutter pub get
```

## Permissions

### Android
The following permissions are required and configured in [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml):
- `INTERNET` - Network access for API calls
- `CAMERA` - Take photos for chat messages
- `RECORD_AUDIO` - Record audio messages
- `READ_EXTERNAL_STORAGE` - Access photos from gallery
- `WRITE_EXTERNAL_STORAGE` - Save photos (Android 12 and below)

### iOS
The following permission descriptions are configured in [ios/Runner/Info.plist](ios/Runner/Info.plist):
- `NSCameraUsageDescription` - Camera access
- `NSPhotoLibraryUsageDescription` - Photo library access
- `NSMicrophoneUsageDescription` - Microphone access
- `NSPhotoLibraryAddUsageDescription` - Save photos to library

## n8n Workflow Configuration

Your n8n workflow should accept the following JSON payload:

```json
{
  "bot_id": "balance_tracker|investment_guru|budget_planner|fin_tips",
  "message": "User's text message",
  "timestamp": "ISO 8601 timestamp",
  "image": "Base64 encoded image (optional)",
  "audio": "Base64 encoded audio (optional)"
}
```

And return a response in this format:

```json
{
  "id": "unique_message_id",
  "message": "Bot's response text",
  "image_url": "https://url-to-image.com (optional)",
  "audio_url": "https://url-to-audio.com (optional)"
}
```

## File Size Limits

- **Images:** Maximum 10 MB
- **Audio:** Maximum 25 MB

These limits can be configured in [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart).

## Database Schema

The app uses SQLite with the following tables:

### Users Table
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  photo_url TEXT,
  auth_provider TEXT NOT NULL,
  created_at TEXT NOT NULL
);
```

### Messages Table
```sql
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  bot_id TEXT NOT NULL,
  sender TEXT NOT NULL,
  content TEXT NOT NULL,
  image_url TEXT,
  audio_url TEXT,
  timestamp TEXT NOT NULL,
  is_sending INTEGER NOT NULL DEFAULT 0,
  has_error INTEGER NOT NULL DEFAULT 0
);
```

## Project Structure

```
balanceIQ/
├── android/                 # Android native code
├── ios/                     # iOS native code
├── lib/                     # Flutter application code
│   ├── core/               # Core utilities and shared code
│   ├── features/           # Feature modules
│   └── main.dart           # Application entry point
├── test/                    # Unit and widget tests
├── pubspec.yaml            # Dependencies and assets
└── README.md               # This file
```

## Development

### Pre-commit Hooks

To ensure code quality, we use git hooks to check formatting, analysis, and tests before every commit.

**Setup:**
```bash
# 1. Make the hook executable
chmod +x .githooks/pre-commit

# 2. Configure git to use local hooks
git config core.hooksPath .githooks
```

**Checks run:**
1. `dart format --set-exit-if-changed .`
2. `flutter analyze --no-fatal-infos` (Switching to `--fatal-infos` recommended once backlog is cleared)
3. `flutter test`

### Adding a New Bot

1. Add the bot constants in [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart)
2. Add the bot color and icon in [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart)
3. Add the bot button in [lib/features/home/presentation/pages/home_page.dart](lib/features/home/presentation/pages/home_page.dart)
4. Update n8n workflow to handle the new bot_id

### State Management

The app uses **Cubit** for state management:
- `AuthCubit` - Handles authentication state
- `ChatCubit` - Manages chat messages and API communication

## Troubleshooting

### Build Issues
- Run `fvm flutter clean` and then `fvm flutter pub get`
- Ensure you're using Flutter 3.27.0: `fvm flutter --version`
- Delete the `build` folder and rebuild
- Check that NDK version 27.0.12077973 is installed in Android Studio

### Google Sign-In Issues

**Error: `PlatformException(sign_in_failed, ApiException: 10)`**

This means your SHA-1 fingerprint is not registered in Firebase. Follow these steps:

1. Get your SHA-1 fingerprint:
   ```bash
   # macOS/Linux
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep -A 2 "SHA1:"

   # Windows
   keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

2. Add it to [Firebase Console](https://console.firebase.google.com/project/balanceiq-60956/settings/general)
   - Click on Android app `com.balanceiq.balance_iq`
   - Click "Add fingerprint"
   - Paste your SHA-1
   - Click Save

3. **No need to update google-services.json** - Firebase handles multiple SHA-1s on the backend

4. Rebuild and run the app:
   ```bash
   fvm flutter clean
   fvm flutter pub get
   fvm flutter run
   ```

**Other Sign-In Issues:**
- Verify Google Sign-In is enabled in Firebase Console > Authentication > Sign-in method
- Check that `google-services.json` exists in `android/app/`
- Ensure you have internet connectivity

### Database Issues
- The database is automatically created on first launch
- To reset: Uninstall and reinstall the app
- Database location: App's internal storage directory

### Flutter Version Issues
- Always use `fvm flutter` commands, not just `flutter`
- Verify version: `fvm flutter --version` should show `3.27.0`
- If wrong version, run: `fvm use 3.27.0`

## Important Notes

### SHA-1 Fingerprints for Team Development

Each developer needs to add their own SHA-1 fingerprint to Firebase for Google Sign-In to work during development. However:

- **For Development**: Each teammate adds their debug keystore SHA-1 to Firebase
- **For Distribution**: When you build an APK/AAB and share it with users:
  - The APK is signed with **your keystore** (debug or release)
  - Users can login without adding their SHA-1
  - Only the keystore used to sign the APK needs to be in Firebase

- **For Production**:
  - Add your **release keystore** SHA-1 to Firebase before publishing
  - If using Google Play App Signing, add the **Play App Signing certificate** SHA-1 as well
  - Find it in: Google Play Console > App signing > App signing key certificate

### Android NDK Version

This project uses **NDK 27.0.12077973** as configured in [android/app/build.gradle.kts](android/app/build.gradle.kts#L12). This is required by the plugins used in the project. Make sure this NDK version is installed in Android Studio.

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Contact

For questions or support, please open an issue in the repository.
