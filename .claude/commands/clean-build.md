Run a clean rebuild:

```powershell
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

Report any analyzer issues.
