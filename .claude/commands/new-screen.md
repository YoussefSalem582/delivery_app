Add a new page + BLoC to an existing feature sub-folder under `lib/features/<domain>/<sub_feature>/presentation/`.

1. Read `AGENTS.md` § Feature Architecture and the target feature's existing bloc/pages for conventions.
2. Create or extend bloc event/state files.
3. Add page under `presentation/pages/`.
4. Register route in `route_names.dart` + `app_router.dart`.
5. Add translation keys to `en.json` + `ar.json`.
6. Register BLoC in `injection_container.dart` if new.
7. Update CHANGELOG + status docs.
