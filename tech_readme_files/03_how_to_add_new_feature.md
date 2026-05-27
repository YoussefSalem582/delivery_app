# 03 — How to Add a New Feature

Follow skill [`add-feature`](../.agents/skills/add-feature/SKILL.md).

## Quick checklist

1. Create `lib/features/<domain>/shared/` (data + domain) if new domain
2. Create `lib/features/<domain>/<sub_feature>/presentation/` (bloc, pages, widgets)
3. Register DI in `injection_container.dart`
4. Add route to `route_names.dart` + `app_router.dart`
5. Add translation keys to `en.json` + `ar.json`
6. Update CHANGELOG + status docs

## Example: adding `promotions` domain

```
features/promotions/
├── shared/
│   ├── data/datasources/promotion_remote_datasource.dart
│   ├── data/repositories/promotion_repository_impl.dart
│   └── domain/usecases/get_promotions_usecase.dart
└── promo_list/
    └── presentation/
        ├── bloc/promo_list_bloc.dart
        └── pages/promo_list_page.dart
```

Copy patterns from `features/trips/` — closest existing reference.
