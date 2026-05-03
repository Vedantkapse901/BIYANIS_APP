# Student Logbook System - Complete Setup Guide

A premium Flutter app for managing student learning progress with 2000+ students and 200+ teachers support.

---

## 🎯 Prerequisites

Before starting, ensure you have:
- Windows 10+, macOS 10.15+, or Linux (Ubuntu 18.04+)
- 8GB RAM minimum (16GB recommended)
- 5GB free disk space
- Git installed

---

## 📱 Step 1: Install Flutter SDK

### For Windows:

1. **Download Flutter SDK**
   - Go to https://flutter.dev/docs/get-started/install/windows
   - Download the latest Flutter SDK (e.g., `flutter_windows_3.19.0-stable.zip`)

2. **Extract Flutter**
   - Extract the downloaded ZIP to a permanent location (e.g., `C:\src\flutter`)
   - ⚠️ Avoid paths with spaces or special characters

3. **Add Flutter to PATH (Windows)**
   - Press `Win + X` → Search "Environment Variables"
   - Click "Edit the system environment variables"
   - Click "Environment Variables..." button
   - Under "User variables", click "New"
     - Variable name: `PATH`
     - Variable value: `C:\src\flutter\bin`
   - Click OK three times
   - Restart your computer

4. **Verify Installation**
   - Open Command Prompt (cmd) or PowerShell
   - Type: `flutter --version`
   - You should see the Flutter version number

### For macOS:

1. **Download Flutter SDK**
   - Go to https://flutter.dev/docs/get-started/install/macos
   - Download the latest stable release

2. **Extract Flutter**
   ```bash
   cd ~/development
   unzip ~/Downloads/flutter_macos_*.zip
   ```

3. **Add Flutter to PATH (macOS)**
   ```bash
   # Open terminal and edit your profile
   nano ~/.zshrc
   # or if using bash
   nano ~/.bash_profile
   
   # Add this line at the end:
   export PATH="$PATH:$HOME/development/flutter/bin"
   
   # Save and exit (Ctrl+X, then Y, then Enter)
   # Then run:
   source ~/.zshrc
   ```

4. **Verify Installation**
   ```bash
   flutter --version
   ```

### For Linux:

1. **Download Flutter SDK**
   ```bash
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_*.tar.xz
   tar xf flutter_linux_*.tar.xz
   ```

2. **Add Flutter to PATH**
   ```bash
   nano ~/.bashrc
   # Add at the end:
   export PATH="$PATH:$HOME/development/flutter/bin"
   
   # Save and run:
   source ~/.bashrc
   ```

3. **Verify**
   ```bash
   flutter --version
   ```

---

## 🛠️ Step 2: Install Development Tools

### Option A: Android Studio (Recommended for Android)

1. **Download Android Studio**
   - Go to https://developer.android.com/studio
   - Download the latest version

2. **Install Android Studio**
   - Run the installer and follow the setup wizard
   - Select "Standard" installation type
   - When prompted to install Android SDK, click "Next"

3. **Install Flutter and Dart Plugins**
   - Open Android Studio
   - Go to `Preferences` (macOS) or `File > Settings` (Windows/Linux)
   - Search for "Plugins"
   - Search for "Flutter" and click "Install"
   - It will automatically install Dart plugin
   - Restart Android Studio

4. **Accept Android Licenses**
   ```bash
   flutter doctor --android-licenses
   # Type 'y' for each license agreement
   ```

### Option B: Visual Studio Code (Lightweight Alternative)

1. **Download VS Code**
   - Go to https://code.visualstudio.com/
   - Download and install

2. **Install Flutter Extension**
   - Open VS Code
   - Go to Extensions (Ctrl+Shift+X)
   - Search for "Flutter" (by Dart Code)
   - Click "Install"
   - It will also install Dart extension

### For iOS Development (macOS only):

1. **Install Xcode**
   ```bash
   xcode-select --install
   ```

2. **Accept Xcode License**
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/xcode-select
   sudo xcodebuild -runFirstLaunch
   ```

---

## 📋 Step 3: Verify Installation

Run the following command:

```bash
flutter doctor
```

**Expected Output:**
```
Doctor summary (to get all the required dependencies):
[✓] Flutter (Channel stable, 3.19.0, on Windows 11, locale en-US)
[✓] Windows Version (Windows 11 (Build 22621))
[✓] Android SDK (Android 13 (API 33))
[✓] Android Studio (version 2023.1)
[✓] VS Code (version 1.85.0)
[✓] Connected device (1 available)

All good! ✅
```

❌ **If you see issues:**
- Re-read the setup instructions for your platform
- Make sure PATH variables are set correctly
- Restart your terminal/computer

---

## 🚀 Step 4: Clone & Setup Project

### Clone the Project

1. **Open Terminal/Command Prompt**
2. **Navigate to your desired location:**
   ```bash
   cd C:\Users\YourName\Documents
   # or for macOS/Linux:
   cd ~/Documents
   ```

3. **Clone the project:**
   ```bash
   git clone <repository-url> student-logbook
   cd student-logbook
   ```

### Install Dependencies

```bash
# Get all Flutter packages
flutter pub get

# Generate Hive adapters (required for database)
flutter pub run build_runner build
```

**Wait:** This may take 2-3 minutes on first run.

---

## 📱 Step 5: Run on Emulator

### Android Emulator:

1. **Open Android Studio**
2. Go to `Tools > Device Manager`
3. Click "Create Device"
4. Select "Pixel 6 Pro" and click "Next"
5. Select "API 33" and click "Next"
6. Click "Finish"
7. Click the Play button to start the emulator

### iOS Simulator (macOS only):

```bash
open -a Simulator
```

### Start the App:

```bash
# Run on connected device/emulator
flutter run

# Run with verbose output (for debugging)
flutter run -v

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

**First run:** Wait 2-3 minutes for APK/IPA compilation.

---

## 📦 Step 6: Run on Real Device

### Android:

1. **Enable Developer Mode**
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings > Developer Options
   - Enable "USB Debugging"

2. **Connect Device via USB**
3. **Run the app:**
   ```bash
   flutter devices  # Verify device shows up
   flutter run
   ```

### iOS:

1. **Open Xcode Project**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Select Device**
   - Top of Xcode window, select your device
   - Click "Run" button

3. **Trust Developer Certificate**
   - On your iPhone: Settings > General > Device Management > Trust

---

## 🐛 Common Errors & Solutions

### Error: "Flutter is not recognized"
**Solution:**
- PATH not set correctly
- Restart terminal/computer
- Type: `echo %PATH%` (Windows) or `echo $PATH` (macOS/Linux) to verify Flutter path is included

### Error: "Android SDK not found"
**Solution:**
```bash
flutter config --android-sdk /path/to/android/sdk
```

For Windows: `C:\Users\YourName\AppData\Local\Android\sdk`
For macOS: `~/Library/Android/sdk`

### Error: "Xcode not found" (macOS)
**Solution:**
```bash
sudo xcode-select --install
sudo xcode-select --switch /Applications/Xcode.app/xcode-select
```

### Error: "Unable to boot simulator" (iOS)
**Solution:**
```bash
xcrun simctl erase all
open -a Simulator
```

### Error: "Build failed"
**Solution:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Error: "Gradle build failed"
**Solution:**
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter run
```

---

## 🎮 Testing the App

### Step-by-step:

1. **Launch the app** (emulator or device)
2. **Role Selection Screen**
   - Choose "I'm a Student" or "I'm a Teacher"

3. **Student Dashboard**
   - See subjects (Math, English, Science)
   - Each subject shows 5 topics
   - First 2 topics are pre-completed
   - **Tap the checkbox** to mark topics complete
   - **Progress updates in real-time**

4. **Teacher Dashboard**
   - See overall class progress
   - View student progress cards
   - Search and filter students

### Test Offline Functionality:

1. **Enable Airplane Mode** on your device
2. **Mark topics complete** - they update locally
3. **Disable Airplane Mode** - data syncs automatically

---

## 🔧 Project Structure

```
student-logbook/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── core/
│   │   ├── theme/                # App colors, typography
│   │   └── utils/                # Animations, helpers
│   └── features/
│       ├── auth/                 # Role selection
│       └── logbook/
│           ├── data/             # Database, models
│           ├── domain/           # Entities, business logic
│           └── presentation/     # Screens, widgets
├── pubspec.yaml                  # Dependencies
├── android/                      # Android native code
├── ios/                          # iOS native code
└── README.md                     # This file
```

---

## 📚 Key Features Explained

### State Management (Riverpod):
- **Fast** and lightweight
- **Testable** reactive code
- All data flows through providers
- Auto-refresh when data changes

### Local Database (Hive):
- **No SQL needed** - simple key-value storage
- **Offline-first** - data always available
- **Auto-sync** when online

### Animations:
- Checkbox tick animation
- Smooth page transitions
- Expand/collapse animations
- Progress bar updates

---

## 📞 Troubleshooting Help

If you're stuck:

1. **Check Flutter Doctor:**
   ```bash
   flutter doctor -v
   ```

2. **Clean and Rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   flutter run -v
   ```

3. **Check Logs:**
   ```bash
   flutter run -v 2>&1 | tee flutter_log.txt
   ```

4. **Stack Overflow**: Search the exact error message

---

## 🎉 You're All Set!

The app is now ready to run. Here's what you've built:

✅ Premium Material 3 UI
✅ Offline-first functionality  
✅ Real-time progress tracking
✅ Smooth animations
✅ Clean architecture
✅ Scalable for 2000+ students

**Start by running:**
```bash
flutter run
```

---

## 📦 Production Build

When ready to deploy:

### Android APK:
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-app.apk
```

### iOS App:
```bash
flutter build ios --release
# Use with Xcode for App Store submission
```

---

**Happy coding! 🚀**
