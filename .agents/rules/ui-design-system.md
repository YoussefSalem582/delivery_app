---
description: "Design tokens — AppColors, AppSpacing for Nokta UI"
globs: "lib/**/presentation/**,lib/shared/**,lib/core/widgets/**"
alwaysApply: false
---

# Design System

## Colors (`AppColors`)

Use `AppColors.primary`, `AppColors.error`, `AppColors.surface`, etc. — never raw hex or `Colors.*`.

## Spacing (`AppSpacing`)

Use `AppSpacing.sm`, `AppSpacing.md`, `AppSpacing.lg`, `AppSpacing.radiusMd`, `AppSpacing.buttonHeight`.

## Typography

Theme-driven via `app_theme.dart` — Inter (EN) + Cairo (AR) via `google_fonts`.

## Shared widgets

Check `lib/shared/widgets/` and `lib/core/widgets/` before creating new UI (`AppButton`, `AppTextField`, `DeliveryMap`, `NoktaPrimaryButton`, `AppBrandIcon`).

## Branding assets

| Asset | Use |
|-------|-----|
| `assets/logo.svg` | In-app wordmark — `AppBrandIcon` |
| `assets/logo.png` | Native splash (horizontal) |
| `assets/app_icon.png` | Launcher icon source |

Regenerate native icons/splash via `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create` (config in `pubspec.yaml`).

## Strings

Never hardcode user-facing text — use `'key'.tr()` with keys in `assets/translations/en.json` + `ar.json`.
