# Reproducible Builds

This project supports [Reproducible Builds](https://reproducible-builds.org/).
This means the APK distributed on GitHub or F-Droid matches the source code exactly, proving no hidden code was injected during the release process.

> [!TIP]
> More info at: https://f-droid.org/docs/Reproducible_Builds/

## How to verify

The proof of a reproducible build is when the SHA-256 hash of a locally built APK matches the CI's build.
This guarantees the compiler, code, and resources are exactly the same.

## Prerequisites
- Git
- JDK 21

> Version 21 because F-droid use it so CI use it to ensure reproducibility, however other versions may work (e.g. 17) 

## Guide

To reproduce the **APKs** exactly as it was built by the CI server:

1.  **Clone the repository and checkout the tag/commit to verify:**
    ```bash
    git clone https://github.com/NexcOrg/Nexc.git
    cd Nexc
    # Specify version tag (e.g. v0.1.0)
    git checkout v0.1.0
    ```

2.  **Build the release APK locally:**
    ```bash
    ./gradlew clean assembleRelease --no-daemon
    ```
    The APK will be at `app/build/outputs/apk/release/Nexc-release-unsigned.apk`.

3.  **Verify unsigned APK built by CI server:**
    Download the unsigned APK (`Librefit-unsigned.apk`) from CI server.
    To ensure the APKs are identical, their SHA-256 must match.
    For instance, the following command computes both their hashes:
    ```bash
    # Output SHA-256 of CI's APK and locally built APK
    sha256sum Nexc-unsigned.apk Nexc-release-unsigned.apk
    ```
    ✅ Verification is successful if and only if hashes are identical.