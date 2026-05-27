---
name: add-language
description: Add or update localization strings in easy_localization JSON files. Use when adding user-facing text or translations.
---

# Add / Update Localization

Nokta uses `easy_localization` with JSON files (not ARB).

## When to Use

- New user-facing text in any feature
- User says "add language", "translate", "localize"

## Adding New Strings

### Step 1 — English

Edit `assets/translations/en.json`:

```json
"feature_title": "Feature Title"
```

### Step 2 — Arabic

Edit `assets/translations/ar.json`:

```json
"feature_title": "عنوان الميزة"
```

### Step 3 — Use in Code

```dart
Text('feature_title'.tr())
// or
Text(context.tr('feature_title'))
```

## Rules

- NEVER hardcode user-facing strings
- ALWAYS add keys to BOTH `en.json` and `ar.json`
- Key naming: `snake_case`, prefixed by feature when ambiguous
- App name key: `app_name` → "Nokta"

Reference `tech_readme_files/05_how_to_add_new_language.md` for adding a third locale.
