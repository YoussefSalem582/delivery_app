# Changelog

All notable changes to Nokta will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> Doc-map entry point: [`tech_readme_files/INDEX.md`](tech_readme_files/INDEX.md). Live status: [`tech_readme_files/CURRENT_STATUS.md`](tech_readme_files/CURRENT_STATUS.md).

## [Unreleased]

### Added

- **Trips list — current trip + history sections** — `TripListPage` splits active trips into a pinned `CurrentTripCard` (with Track CTA) and a `Trip History` list below; `partitionTrips` helper on `TripEntity`.
- **Driver profile screen** — `DriverProfilePage` at `/trips/:tripId/driver` merges trip + mock driver data; ratings & reviews section with star breakdown and review cards from mock API.
- Chat layer: `ChatMessageEntity`, `ChatLocalDataSource`, `ChatRepository`, `GetChatMessagesUseCase`, `SendChatMessageUseCase`, `DriverChatBloc`, `DriverCallBloc`.
- **Functional UI controls** — Shell tab AppBars use Nokta logo instead of stub hamburger menus; `ProfileAvatarButton` navigates to profile tab; wallet top-up, profile edit, order details, ride payment/promo pickers wired with demo actions.
- Shared widgets: `ShellAppBarLogo`, `ProfileAvatarButton`; `launchSms` in `phone_launcher.dart`; `AuthRepository.updateProfile`; Profile BLoC events `ProfileWalletTopUpRequested`, `ProfileUpdateRequested`.
- Localization keys for wallet top-up, driver messaging, payment/promo, profile edit, and order details (EN + AR).
- **AI agent documentation surface** — Canonical [`AGENTS.md`](AGENTS.md) plus tool shims ([`CLAUDE.md`](CLAUDE.md), [`CURSOR.md`](CURSOR.md), [`.codex/AGENTS.md`](.codex/AGENTS.md), [`.github/copilot-instructions.md`](.github/copilot-instructions.md)), [`.agents/skills/`](.agents/skills/) (3 project-tuned + 19 official Flutter/Dart skills), [`.cursor/rules/`](.cursor/rules/), [`.claude/commands/`](.claude/commands/), [`tech_readme_files/`](tech_readme_files/) doc map, and doc-hygiene scripts + CI ([`.github/workflows/docs.yml`](.github/workflows/docs.yml)).

## [1.0.0] - 2026-05-27

Pubspec: `1.0.0+1`. Initial Nokta ride-hailing / delivery MVP template.

### Added

- Clean Architecture + BLoC with sub-feature folders (`auth/`, `home/`, `trips/`, `notifications/`, `profile/`, `settings/`)
- Offline-first Hive cache, pending sync queue, reconnect sync via `SyncService`
- Live map tracking with `flutter_map`, OSRM routing, tile disk cache
- FCM push notifications with simulated fallback
- Bilingual EN/AR via `easy_localization`, dark/light themes
- GoRouter tab shell, auth flow, trip list/detail/tracking screens
- Talker observability (Dio, BLoC, in-app debug console)

## Version History

| Version | Date | Notes |
|---------|------|-------|
| 1.0.0 | 2026-05-27 | Initial MVP template |
