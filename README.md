<div align="center">

<img src="assets/logo.svg" alt="Nexc Logo" style="width: 256px">

# Nexc
### Private & Minimalist Workout Tracker

Nexc is a high-performance, privacy-first workout tracker built for efficiency.  
No cloud, no accounts, no tracking — just your data, on your device.

</div>

---

## 🚀 Features

- **Offline-First**: Log workouts anytime, anywhere — no internet required.
- **Privacy Core**: All data stored locally with SQLite. Zero telemetry.
- **Extensive Library**: 800+ exercises with categorized data and instructions.
- **Custom Routines**: Create and manage personalized training templates.
- **Superset Support**: Link exercises into supersets during active workouts.
- **Intensity Tracking**: RPE / RIR support per set.
- **Exercise Management**: Replace or reorder exercises mid-session.
- **Visual Progress**: Performance charts and volume tracking.
- **Modern UI**: Built with Jetpack Compose and Material Design 3.

## 🛠️ Building from Source

Requires Android Studio and a recent Android SDK.

1. **Clone**:
   ```bash
   git clone https://github.com/nzzrs/nexc.git
   ```
2. **Open** the root directory in Android Studio.
3. **Sync Gradle** — dependencies download automatically.
4. **Run** on a device or emulator:
   ```bash
   ./gradlew assembleDebug
   ```
   Or generate a release APK:
   ```bash
   ./gradlew assembleRelease
   ```

## ⚖️ License

Nexc is a fork of [LibreFit](https://github.com/LibreFitOrg/LibreFit), licensed under the
[GNU General Public License v3.0 (GPL-3)](COPYING).

You are free to use, modify, and distribute the code under the same license.  
You must share changes under GPLv3 and clearly mark modifications as your own.
