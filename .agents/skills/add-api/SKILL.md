---
name: add-api
description: Add API integration end-to-end — data source, model, repository, use case, BLoC. Use when connecting a backend endpoint or mock JSON.
---

# Add New API Integration

Connect an endpoint through Clean Architecture layers.

Reference `tech_readme_files/04_how_to_add_new_api.md`.

## Step 1 — Data Source

In `features/<domain>/shared/data/datasources/*_remote_datasource.dart`:
- Use `ApiClient.get/post/put/delete`
- Demo: ensure path matches `MockApiInterceptor` or add mock JSON under `assets/mock/`

## Step 2 — Model

`fromJson`/`toJson` in `shared/data/models/`

## Step 3 — Domain contract + repository impl

`Either<Failure, T>` with failure mapping

## Step 4 — Use case + BLoC

Single-responsibility use case; wire event handler in BLoC

## Step 5 — Offline behavior

- Reads: cache in Hive where applicable; honor 5-min TTL
- Writes: `PendingSyncLocalDataSource` when offline

## Step 6 — DI

Register in `injection_container.dart`
