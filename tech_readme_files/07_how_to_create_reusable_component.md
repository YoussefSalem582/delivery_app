# 07 — How to Create a Reusable Component

## Before creating

Search `lib/shared/widgets/` and `lib/core/widgets/`.

## Placement

| Scope | Location |
|-------|----------|
| App-wide UI | `lib/shared/widgets/<category>/` |
| Map / delivery specific | `lib/core/widgets/` |
| Feature-only | `features/<domain>/<sub_feature>/presentation/widgets/` |

## Conventions

- Use `AppColors`, `AppSpacing`
- Accept `Key?` and callbacks; avoid hardcoded strings
- Export from a barrel file if the category grows (see `shared/widgets/buttons/`)

## Examples

- `AppButton` — primary actions
- `AppTextField` — form inputs
- `DeliveryMap` — map wrapper
- `TripCard` — feature widget in trips/shared
