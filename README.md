# Isango

Campus event discovery app for the University of Rwanda community. Students can browse, save, and submit events happening around them.

## Status

| Area | State |
|---|---|
| App shell + theme tokens | Done |
| Named routes + bottom navigation | Done |
| Sign In screen (UI) | Done |
| Sign Up screen (UI) | Done |
| Home / Saved / Submit / Settings | Placeholder |
| Auth backend (Firebase) | Not started |
| Event data + persistence | Not started |

## Project Structure

```
lib/
  main.dart
  app.dart                        # MaterialApp, routes, initialRoute
  core/
    constants/
      app_routes.dart             # All named route constants
    theme/
      app_colors.dart             # Brand colour palette
      app_radii.dart              # Border-radius scale
      app_spacing.dart            # Spacing scale
      app_text_styles.dart        # Text style definitions
      app_theme.dart              # ThemeData (Material 3)
  screens/
    auth/
      sign_in_screen.dart         # /login — email/password, loading state, error banner
      sign_up_screen.dart         # /signup — name/email/password/confirm
    home/
    saved/
    settings/
    submit/
    shared/
      placeholder_screen.dart     # Reusable in-progress screen
  widgets/
    isango_bottom_navigation.dart

test/
  screens/
    auth/
      sign_in_screen_test.dart    # 7 widget tests
```

## Getting Started

**Requirements:** Flutter SDK ≥ 3.11

```bash
# 1. Install dependencies
flutter pub get

# 2. Run on a connected device or emulator
flutter run

# 3. Run all tests
flutter test
```

## Auth Screens

The Sign In and Sign Up screens are fully built as UI — form validation, loading state, and error handling are wired up. They are not connected to a backend yet.

**Sign In** exposes an `onSignIn` callback that accepts the real auth call when it is ready:

```dart
SignInScreen(
  onSignIn: (email, password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  },
)
```

Pass nothing (or `null`) and the screen navigates straight to Home — useful during development and in tests.

## Theme Tokens

All screens use shared tokens. Import from `package:isango_app/core/theme/`.

| Token file | Example values |
|---|---|
| `app_colors.dart` | `logisticsNavy`, `commandBlue`, `mistBackground`, `safetyOrange` |
| `app_spacing.dart` | `xs` (8), `md` (16), `lg` (24), `page` (20) |
| `app_radii.dart` | `button` (24), `card` (16), `input` (12) |
| `app_text_styles.dart` | `display`, `headline`, `title`, `body`, `bodyMuted`, `label` |

## Routes

| Constant | Path | Screen |
|---|---|---|
| `AppRoutes.login` | `/login` | `SignInScreen` — **initial route** |
| `AppRoutes.signUp` | `/signup` | `SignUpScreen` |
| `AppRoutes.home` | `/` | `HomeScreen` |
| `AppRoutes.saved` | `/saved` | `SavedScreen` |
| `AppRoutes.submitEvent` | `/submit-event` | `SubmitScreen` |
| `AppRoutes.settings` | `/settings` | `SettingsScreen` |
| `AppRoutes.verifyEmail` | `/verify-email` | Not yet implemented |
| `AppRoutes.eventDetail` | `/event-detail` | Not yet implemented |
| `AppRoutes.profile` | `/profile` | Not yet implemented |

## Contributing

Issues and PRs follow the templates in `.github/`. Auth UI work uses the **Auth Screen** issue template. Every PR requires a linked issue, visual evidence for UI changes, and passing test evidence.
