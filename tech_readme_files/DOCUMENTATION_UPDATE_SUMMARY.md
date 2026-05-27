# Documentation Update Summary

> Rolling log of documentation changes. Newest entries first.

---

## 2026-05-27 — Wire all buttons and icons

**What changed:** Replaced non-functional stub controls across main-shell tabs and trip/profile flows with working demo actions.

**UI / navigation:**

- Removed hamburger menu stubs on Home, Trips, Notifications, Profile; added `ShellAppBarLogo` leading widget
- Home/Trips AppBar avatars navigate to profile tab via `ProfileAvatarButton`

**Profile:**

- Wallet Top Up opens amount picker (50/100/200 EGP) → `ProfileWalletTopUpRequested`
- Avatar edit badge opens name editor → `AuthRepository.updateProfile` + `ProfileUpdateRequested`
- Order tiles open read-only detail bottom sheet

**Trips / ride flow:**

- Trip detail call/SMS use `launchPhoneCall` / `launchSms` when driver phone present; error state retry wired
- Ride selection payment/promo chips open picker sheet and promo dialog

**Files touched:** `shell_app_bar_logo.dart`, `profile_avatar_button.dart`, `phone_launcher.dart`, tab pages, `profile_page.dart`, `profile_bloc.dart`, `auth_repository*.dart`, `trip_detail_page.dart`, `ride_selection_sheet.dart`, `en.json`, `ar.json`

---

## 2026-05-27 — AI agent documentation surface

**What changed:** Added Technology 92–style agent infrastructure adapted for Nokta.

**Files created:**

- `AGENTS.md` (expanded canonical), `CLAUDE.md`, `CURSOR.md`, `CHANGELOG.md`
- `.agents/` — AGENTS.md shim, 7 rules, 22 skills (3 project-tuned + 19 official)
- `.cursor/rules/` — 7 scoped `.mdc` rules; `.cursor/skills/` — 3 project skills
- `.claude/commands/` — 8 slash commands + settings.json
- `.codex/AGENTS.md`, `.github/copilot-instructions.md`, `.github/workflows/docs.yml`
- `tech_readme_files/` — INDEX, ONBOARDING, CURRENT_STATUS, how-tos, ADRs, pitfalls, troubleshooting, glossary
- `scripts/docs/` — ai_ignore_template, sync/check scripts + root shims
- `skills-lock.json`, `.markdownlint-cli2.jsonc`

**Key decisions:**

- easy_localization JSON instead of ARB (matches existing codebase)
- Sub-feature `shared/` + presentation layout documented as canonical
- Official Flutter/Dart skills copied from tech92 lockfile (same upstream hashes)

**Verification:**

- Run `.\scripts\sync_ai_ignores.ps1`
- Run `.\scripts\check_docs_freshness.ps1`
- Run `.\scripts\check_skills_drift.ps1`
