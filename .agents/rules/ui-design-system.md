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

Check `lib/shared/widgets/` and `lib/core/widgets/` before creating new UI (`AppButton`, `AppTextField`, `DeliveryMap`, `NoktaPrimaryButton`).

## Strings

Never hardcode user-facing text — use `'key'.tr()` with keys in `assets/translations/en.json` + `ar.json`.
