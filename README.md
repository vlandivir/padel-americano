# Padel Americano

## Local setup

```
brew install firebase-cli

firebase login

firebase init
    Features
    * Emulators: Set up local emulators for Firebase products
    * Firestore: Configure security rules and indexes files for Firestore

    Project Setup – Don't set up a default project

    Emulators Setup
    * Firestore Emulator

firebase emulators:start
```

## Local run
```
firebase emulators:start
flutter run -d chrome
```

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application that follows the
[simple app state management
tutorial](https://flutter.dev/to/state-management-sample).

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Assets

The `assets` directory houses images, fonts, and any other files you want to
include with your application.

The `assets/images` directory contains [resolution-aware
images](https://flutter.dev/to/resolution-aware-images).

## Localization

This project generates localized messages based on arb files found in
the `lib/src/localization` directory.

To support additional languages, please visit the tutorial on
[Internationalizing Flutter apps](https://flutter.dev/to/internationalization).
