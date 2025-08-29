# Primedev Mobile (Flutter)

A Flutter mobile app that provides a mobile experience for a LeetCode-like practice project.

## Prerequisites
- Flutter SDK (3.x recommended): https://docs.flutter.dev/get-started/install
- Android Studio or Xcode (for device/emulator)
- Dart SDK (bundled with Flutter)

Verify your setup:
```
flutter doctor
```

## Project Setup
From the project root:
```
cd primedev_mobile_new
flutter pub get
```

## Run (Development)
- Android (device/emulator):
```
flutter run -d android
```
- iOS (simulator):
```
flutter run -d ios
```
- Web (optional, if enabled):
```
flutter run -d chrome
```

## Build
- Android APK (release):
```
flutter build apk --release
```
- Android App Bundle (Play Store):
```
flutter build appbundle --release
```
- iOS (release, requires Xcode/macOS):
```
flutter build ios --release
```

## App Structure (high level)
- `lib/`
  - `main.dart` – App entry point
  - `pages/`
    - `problem_detail.dart` – Problem details page
  - `services/`
    - `local_repository.dart` – Local data access (loads problems)
    - `python_executor.dart` – Python execution service (concept integration)
    - `js_executor.dart` – JavaScript execution via embedded runtime
    - `storage_service.dart` – Local storage utilities
- `assets/`
  - `problems.json` – Seed problem data
  - `third_party/` – Third-party assets (e.g., `skulpt.min.js`)

## Environment & Assets
- Ensure `assets/` are declared in `pubspec.yaml` (already configured).
- If you add new assets, update `pubspec.yaml` and run `flutter pub get`.

## Testing
```
flutter test
```

## Contributing
- Create a branch, commit changes, and open a PR.
```
git checkout -b feature/my-change
# make edits
git add .
git commit -m "feat: describe your change"
git push -u origin feature/my-change
```

## License
This repository uses the license configured in the root GitHub repo.
