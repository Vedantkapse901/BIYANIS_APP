# 🚀 Quick Start Guide

Get the Student Logbook running in **5 minutes**.

---

## ⚡ Ultra-Quick Setup (TL;DR)

### Windows/macOS/Linux:

```bash
# 1. Install Flutter (if not already done)
# https://flutter.dev/docs/get-started/install

# 2. Clone project
git clone <repository-url>
cd student-logbook

# 3. Install dependencies
flutter pub get
flutter pub run build_runner build

# 4. Run the app
flutter run
```

**Done!** The app opens on your emulator/device.

---

## 📱 What You'll See

### 1. **Splash Screen** (2 seconds)
- Animated logo
- Loading indicator

### 2. **Role Selection** (Choose one)
- 👨‍🎓 Student Dashboard
- 👩‍🏫 Teacher Dashboard

### 3. **Student Dashboard**
- 🎯 Overall progress circle
- 📚 3 subjects (Math, English, Science)
- ✅ Tap to expand subjects
- ✓ Tap checkboxes to mark complete
- 📊 Real-time progress updates

### 4. **Teacher Dashboard**
- 📊 Class overview
- 👥 Student progress cards
- 🔍 Search and filter

---

## 🎮 How to Test

### As a Student:

1. **Launch app** → Select "I'm a Student"
2. **View Dashboard** → See 3 subjects with progress
3. **Expand Subject** → Tap on any subject card
4. **Mark Task Complete** → Tap the checkbox
   - Watch the **smooth animation**
   - See **percentage update** in real-time
5. **Check Overall Progress** → Top circle shows total %
6. **Go Back** → Tap back to collapse

### As a Teacher:

1. **Launch app** → Select "I'm a Teacher"
2. **View Class** → See overall class progress
3. **Search Students** → Type in search box
4. **Filter by Subject** → Click subject chips
5. **View Student Card** → See individual progress

### Test Offline Mode:

1. **Enable Airplane Mode** on your device
2. **Mark topics complete** → Works without internet
3. **Disable Airplane Mode** → Data syncs automatically

---

## 🛠️ Troubleshooting Quick Fixes

### App Won't Run:

```bash
# Clear and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build
flutter run -v
```

### Emulator Won't Start:

```bash
# Android Studio path
flutter config --android-studio-path /path/to/android-studio

# Restart emulator
adb kill-server
adb start-server
```

### Port Already in Use:

```bash
# Run on different port
flutter run --use-test-fonts -d emulator-5554
```

### Build Fails:

```bash
# Most common issue is missing dependencies
flutter pub get
flutter pub upgrade

# Hive adapters not generated
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📁 File Organization

```
student-logbook/
├── lib/main.dart                    ← Start here
├── pubspec.yaml                     ← Dependencies
├── README.md                        ← Full documentation
├── SETUP_GUIDE.md                   ← Detailed setup
├── DESIGN_DECISIONS.md              ← Architecture
└── This file                        ← Quick start
```

---

## 💡 Key Features at a Glance

| Feature | Where |
|---------|-------|
| **Real-time Progress** | Dashboard (top circle) |
| **Subject Cards** | Main screen |
| **Expandable Topics** | Tap any subject card |
| **Smooth Animations** | Checkbox & transitions |
| **Offline Support** | Works without internet |
| **Teacher Analytics** | Switch to teacher mode |
| **No Setup Required** | Mock data included |

---

## 🔧 Development Tips

### Hot Reload (Save & See Changes)
```bash
# While app is running:
# Press 'r' to hot reload
# Press 'R' to hot restart
# Press 'h' for help
```

### Enable Verbose Logging
```bash
flutter run -v
```

### Build for Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## ❓ FAQ

**Q: Do I need to create a database?**
A: No! Hive (local database) is automatically set up. Mock data included.

**Q: Can I use this with a real backend?**
A: Yes! See DESIGN_DECISIONS.md for integration patterns. Hive caches data offline.

**Q: Is the UI customizable?**
A: Yes! All colors and themes are in `lib/core/theme/app_theme.dart`

**Q: How do I add more subjects?**
A: Edit `local_datasource.dart` seedMockData() method or use the repository.

**Q: Does it work on both Android and iOS?**
A: Yes! Same codebase runs on both platforms.

---

## 🎉 You're Ready!

**Next Steps:**
1. ✅ Run `flutter run`
2. ✅ Test as Student and Teacher
3. ✅ Mark some tasks complete
4. ✅ Explore the UI
5. ✅ Read DESIGN_DECISIONS.md to understand architecture

---

## 📞 Need Help?

If something doesn't work:

1. **Check SETUP_GUIDE.md** for detailed platform-specific instructions
2. **Run flutter doctor** to diagnose issues
3. **Try clean & rebuild:** `flutter clean && flutter pub get && flutter pub run build_runner build`
4. **Check Flutter docs:** https://flutter.dev/docs

---

**That's it! Happy coding!** 🚀
