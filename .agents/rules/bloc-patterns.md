---
description: "BLoC/Cubit state management patterns"
globs: "lib/features/**/bloc/**/*.dart,lib/features/**/cubit/**/*.dart"
alwaysApply: false
---

# BLoC & Cubit Patterns

## File Organization

- `<name>_bloc.dart`, `<name>_event.dart`, `<name>_state.dart` (separate files)

## Rules

- BLoCs call **use cases** returning `Either<Failure, T>`, not repositories
- Use `result.fold((failure) => ..., (data) => ...)` in handlers
- `BlocBuilder` for UI, `BlocListener` for side effects, `BlocConsumer` for both
- Talker logs transitions via `TalkerBlocObserver` in `main.dart`

## Standard states

`Initial`, `Loading`, `Loaded(data)`, `Error(message)` — extend `Equatable`.
