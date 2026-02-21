# Niraah Mobile App

Modular Flutter foundation with:
- Design system tokens and global theme
- Shared constants/helpers/extensions
- Dio-based API repository and network interceptors
- BLoC-based feature state management
- Feature-first folder structure

## Project Commands

- `flutter pub get`
- `flutter analyze`
- `flutter test`

## Architecture (top-level)

- `lib/app`: app shell, router, bootstrap
- `lib/core`: cross-cutting infra (network, errors, state, DI)
- `lib/design_system`: tokens, themes, reusable UI primitives
- `lib/shared`: constants, helper functions, extensions
- `lib/features`: feature slices (data/domain/presentation)
