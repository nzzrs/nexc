<div align="center">

<img src="assets/logo.svg" alt="Nexc Logo" style="width: 256px">

# Nexc
### Private & Minimalist Workout Tracker

Nexc is a high-performance, privacy-first workout tracker built for efficiency. 
No cloud, no accounts, no tracking—just your data, on your device.

</div>

<<<<<<< HEAD
---
=======
> [!CAUTION]
> Free and Open-Source Android is under threat. Google will turn Android into a locked-down platform, restricting your essential freedom to install apps of your choice. Make your voice heard – [keepandroidopen.org](https://keepandroidopen.org).

<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/1.png" width="160" alt="Screenshot 1"><img src="fastlane/metadata/android/en-US/images/phoneScreenshots/2.png" width="160" alt="Screenshot 2"><img src="fastlane/metadata/android/en-US/images/phoneScreenshots/3.png" width="160" alt="Screenshot 3"><img src="fastlane/metadata/android/en-US/images/phoneScreenshots/4.png" width="160" alt="Screenshot 4"><img src="fastlane/metadata/android/en-US/images/phoneScreenshots/5.png" width="160" alt="Screenshot 5">

## Table of Contents

- 💡 [Motivation](README.md#-motivation)
- 🚀 [Features](README.md#-features)
- 📥 [Install](README.md#-install)
- 🤝 [Let's Build LibreFit Together](README.md#-lets-build-librefit-together)
    - 💖 [Donate](README.md#-donate)
    - 🏗️ [Contribute to the source code](README.md#-contribute-to-source-code)
    - 🌐 [Translate](CONTRIBUTING.md#translations)
  - 🏋 [Improve exercises' dataset](README.md#-improve-the-exercise-dataset)
- ❓ [I Have A Question](README.md#-i-have-a-question)
- ⚡ [Building LibreFit from source](README.md#-building-librefit-from-source)
- 📜 [License](README.md#-license)
    - ™️ [Branding](README.md#-branding)
    - 📷 [Images](README.md#-images)
- 👥 [Credits](README.md#-credits)

## 💡 Motivation

Hey, it's [IamDg](https://github.com/IamDg) here, the **creator** of LibreFit. Here’s the **motivation** for why I started building it in the first place:

LibreFit is a passion project, built by one person who believes **software** should be **open**, **simple**, **beautiful**, and above all, **respectful of your privacy**.

I pour countless hours into designing, coding, and refining every detail to create the best possible experience. It's a commitment to you, the user, and to a **better digital world**.

LibreFit is only possible with your [support](README.md#-lets-build-librefit-together).
>>>>>>> fork/main

## 🚀 Features

- **Offline-First Architecture**: Log workouts anytime, anywhere, without an internet connection.
- **Privacy Core**: All data is stored locally using SQLite. Zero analytics or external telemetry.
- **Extensive Exercise Library**: Access over 800 exercises with categorized data and instructions.
- **Custom Routines**: Create and manage personalized training templates.
- **Visual Progress**: Integrated performance charts and volume tracking.
- **Modern Interface**: Built with Jetpack Compose and Material Design 3.

## 🛠️ Building from Source

Ensure you have Android Studio and the latest Android SDK installed.

1. **Clone the repository**:
   ```bash
   git clone https://github.com/nzzrs/Nexc.git
   ```
2. **Open in Android Studio**: Open the root directory.
3. **Build the APK**:
   ```bash
   ./gradlew assembleRelease
   ```

## ⚖️ License

<<<<<<< HEAD
Nexc is licensed under the [GNU General Public License v3.0 (GPL-3)](COPYING).
Built with efficiency and sovereignty in mind.
=======
Thank you for considering improving LibreFit!

You can actively contribute to the project and become a **supporter** in one of the following ways:

- 💖 [Donations](README.md#-donate)
- 🏗️ [Contributions to the source code](README.md#-contribute-to-source-code)
- 🌐 [Translations](README.md#-translations)
- 🏋️ [Improvements to the exercise dataset](README.md#-improve-the-exercise-dataset)

Every **supporter** will be _credited_ in the about page of the app and in
[credits section](README.md#-credits), and it will be able to request [here](https://librefit.org/donate) the **supporter version** of
LibreFit
which includes:

- 📝 **Custom exercises**: The option to create and use custom exercises as they were in the dataset.
- 🎨 **Material You**: The app's theme will match the colors of system wallpaper.

> These features are either cosmetic or obtainable by giving back to the project but by no means
> this lowers the user experience

### 💖 Donate

Donations are the main way to:

- **Cover costs** (e.g. domain, paid plans for emails, etc.).
- **Thank and incentivize the creator** to invest more time in the project.

To donate, you can either send use the Monero address below or visit the [donation page](https://librefit.org/donate).

```text
842RPDZ851EitDZZxCEp1sjjyDpsaV74xAJBTPU6X7TrDAbpDrjq5rRfaF3Q8PnXyQeUYs2xLoxFpZb7ZpSJxBvdDgFVpww
```

> [!IMPORTANT]
> If you wish the **supporter version**, ensure to donate
> using the **integrated processor** at [donation page](https://librefit.org/donate)

### 🏗 Contribute to source code

See [Contributing to source code](CONTRIBUTING.md#your-first-code-contribution)

### 🌐 Translations

See [Contributing to translations](CONTRIBUTING.md#translations) to discover how to contribute.

[![Translation status](https://hosted.weblate.org/widget/librefit/librefit/horizontal-auto.svg)](https://hosted.weblate.org/engage/librefit/)

> Thanks to [Weblate](https://weblate.org) for hosting the LibreFit's translations!

### 🏋 Improve the exercise dataset

See [Contributing to exercises' dataset](CONTRIBUTING.md#improving-exercises-dataset)

## ❓ I Have a Question

Before you ask a question, it is best to search for
existing [Discussions](https://github.com/LibreFitOrg/LibreFit/discussions)
and [Issues](https://github.com/LibreFitOrg/LibreFit/issues) that might help you.

If you then still feel the need to ask a question and need clarification, we recommend the
following:

- Open a [Discussion](https://github.com/LibreFitOrg/LibreFit/discussions/new).
- Provide as much context as you can about what you're running into.
- Provide project and platform versions, depending on what seems relevant.

We will then take care of the question as soon as possible.

## ⚡ Building LibreFit from source

1. **Clone** the project locally (or download source code as `.zip` file):
    ```bash
    git clone https://github.com/LibreFitOrg/LibreFit.git
    ```
2. **Open in Android Studio:**  Open Android Studio and select _"Open an existing Android Studio
   project"_, pointing to the cloned/downloaded directory.
3. **Sync Gradle:** Let Android Studio download the dependencies and sync the project.
4. **Build the app**: Connect a device or start an emulator and run `Run 'app'` in Android Studio
   or:
    ```bash
    ./gradlew assembleDebug
    ```
   
> [!NOTE]
> This project supports [reproducible builds](https://reproducible-builds.org/). See [REPRODUCIBLE.md](REPRODUCIBLE.md)

## 📜 License

LibreFit is licensed under the [GNU General Public License v3.0 (GPL-3)](COPYING), and it is subject
to these [additional terms](ADDITIONAL_TERMS.md).

In short, this means you are free to use, modify, and distribute the code, but you must:

- **Share your changes**: If you distribute a modified version, you must also license it under the
  GPLv3.
- **Give credit:** Keep the original copyright notice and attribute the original work to LibreFit.
- **Mark your changes:** Clearly indicate that your version is a modification of the original.
- **Do not use the brand:** You cannot use the name "LibreFit" or its logo to promote your modified
  version.

### ™️ Branding

The "LibreFit" name and logos are trademarks. **All Rights Reserved**.

Their use is governed by the [Trademark Policy](TRADEMARK_POLICY.md) which applies to relevant files located in
`assets` and `app/src/main/res`.

### 📷 Images

> [!CAUTION]
> Due to the nature of AI generation, these images may contain inaccuracies and/or artifacts.
> **They are provided "as is" without any warranty**.

Images in `app/src/main/assets` are AI generated therefore they are **not subject to copyright** and are **provided without restriction**.

They are continuously reviewed and regenerated in order to improve their quality.

## 👥 Credits

Thanks to everyone who helped the project!

### 💖 Donators

- FlashyGhost
- Anonymous donators

> [Donate](README.md#-donate) to be listed here.

### 🏗 Contributors

[Contribute to source code](CONTRIBUTING.md#your-first-code-contribution) to be the **first** person listed.


### 🌐 Translators

- [doen1el](https://github.com/doen1el)  🇩🇪
- Odweta 🇨🇿
- [kid1412621](https://github.com/kid1412621) 🇨🇳
- [mwesten](https://github.com/mwesten) 🇳🇱
- [VA5H-One](https://github.com/VA5H-One) 🇪🇸

> [Contribute to translations](CONTRIBUTING.md#translations) to be listed here.

---

Made with ❤️ by [IamDg](https://github.com/IamDg) and [contributors](https://github.com/LibreFitOrg/LibreFit/graphs/contributors)
>>>>>>> fork/main
