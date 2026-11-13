# Release Builds & Verification

Nexc ships an Android APK built from source by GitHub Actions on every `v*` tag.
The build is **best-effort reproducible**: it aims for a deterministic, inspectable
artifact, but the APK is **not guaranteed to be byte-identical** between local and
CI builds.

> [!IMPORTANT]
> Earlier LibreFit-era documentation claimed byte-identical APKs. That claim does
> not hold for the current Flutter build pipeline and has been removed.

## Why the APK is not byte-identical

Flutter release builds are not fully deterministic:

- The Flutter engine AOT snapshot and the Dart kernel compilation embed timestamps
  and build paths in some artifacts.
- Flutter tooling and the Android Gradle Plugin regenerate build intermediates,
  resource tables and zip metadata on each run.
- `zipalign`/`apksigner` padding and signing metadata differ when the environment
  differs (JDK, SDK build-tools, NDK and dependency resolution).
- Dependency versions are pinned by `pubspec.lock`, but the Android toolchain is
  resolved from the runner image.

The workflow therefore publishes a **SHA-256 checksum next to the APK** so a build
can be compared for equality when it comes from the same toolchain, and so any
given download can be integrity-checked.

## What the release workflow does

`.github/workflows/reproducible-release.yml`:

1. Checks out the tagged commit.
2. Sets up JDK 17 (Temurin) and Flutter 3.38.8 stable.
3. Runs `flutter pub get` and `flutter build apk --release`.
4. Copies the APK to `Nexc-release.apk` and writes `Nexc-release.apk.sha256`.
5. Attaches both files to the GitHub release for the tag.

Release signing is not configured yet: the APK is signed with the Android debug
key, so it is suitable for testing and inspection, not for store distribution.

## Verifying a download

Check the published checksum:

```bash
sha256sum -c Nexc-release.apk.sha256
```

## Building locally with the same toolchain

Prerequisites: Git, JDK 17, Android SDK, Flutter **3.38.8** stable
(the version pinned in [`.tool-versions`](.tool-versions)).

```bash
git clone https://github.com/nzzrs/nexc.git
cd nexc
git checkout v0.2.0-alpha.1
flutter pub get
flutter build apk --release
sha256sum build/app/outputs/flutter-apk/app-release.apk
```

Builds produced with the exact same Flutter version, JDK, Android SDK/Build-Tools
and dependency lockfile *may* match the CI artifact. Treat a match as a bonus, not
as a guarantee, and review the diff against the tagged source when investigating a
mismatch.

## Reproducibility roadmap

- Pin the Android SDK Build-Tools and NDK versions used by CI.
- Normalise timestamps in the APK (for example with `SOURCE_DATE_EPOCH`-aware
  packaging) once Flutter tooling supports it end to end.
- Configure a real release signing key so published APKs can be verified against a
  public certificate fingerprint.
