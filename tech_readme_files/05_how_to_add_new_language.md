# 05 — How to Add / Update Language Strings

Nokta uses **easy_localization** with JSON files (not ARB).

## Add a string

1. Add key to `assets/translations/en.json`
2. Add same key to `assets/translations/ar.json`
3. Use `'key'.tr()` in UI
4. Hot restart to pick up JSON changes

## Add a third locale

1. Create `assets/translations/<locale>.json`
2. Register locale in `main.dart` / `EasyLocalization` supportedLocales
3. Add asset path in `pubspec.yaml` if needed

Follow skill [`add-language`](../.agents/skills/add-language/SKILL.md).

## Typography

Inter for EN, Cairo for AR — configured in theme via `google_fonts`.
