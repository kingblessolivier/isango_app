import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_theme.dart';
import 'package:isango_app/screens/auth/sign_up_screen.dart';

Widget _buildApp({
  Future<void> Function(String, String, String)? onSignUp,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    initialRoute: AppRoutes.signUp,
    routes: {
      AppRoutes.signUp: (_) => SignUpScreen(onSignUp: onSignUp),
      AppRoutes.verifyEmail: (_) => const Scaffold(body: Text('Verify Email')),
      AppRoutes.login: (_) => const Scaffold(body: Text('Sign In')),
    },
  );
}

Future<void> _fillValidForm(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'Ada Lovelace');
  await tester.enterText(fields.at(1), 'ada@example.com');
  await tester.enterText(fields.at(2), 'password123');
  await tester.enterText(fields.at(3), 'password123');
}

void main() {
  group('SignUpScreen — validation', () {
    testWidgets('shows error when name is empty on submit', (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('shows error when email is empty on submit', (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(find.byType(TextFormField).at(0), 'Ada Lovelace');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error for malformed email', (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(find.byType(TextFormField).at(0), 'Ada Lovelace');
      await tester.enterText(find.byType(TextFormField).at(1), 'notanemail');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows error when password is too short', (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(find.byType(TextFormField).at(0), 'Ada Lovelace');
      await tester.enterText(find.byType(TextFormField).at(1), 'ada@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'short');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(find.byType(TextFormField).at(0), 'Ada Lovelace');
      await tester.enterText(find.byType(TextFormField).at(1), 'ada@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'different123');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('SignUpScreen — navigation', () {
    testWidgets('tapping Log in pops back to sign in screen', (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        navigatorKey: navKey,
        routes: {
          AppRoutes.login: (_) => const Scaffold(body: Text('Sign In')),
          AppRoutes.signUp: (_) => const SignUpScreen(),
          AppRoutes.verifyEmail: (_) =>
              const Scaffold(body: Text('Verify Email')),
        },
        initialRoute: AppRoutes.login,
      ));

      navKey.currentState!.pushNamed(AppRoutes.signUp);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Log in'));
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('successful submit navigates to /verify-email', (tester) async {
      await tester.pumpWidget(_buildApp());
      await _fillValidForm(tester);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Verify Email'), findsOneWidget);
    });
  });

  group('SignUpScreen — loading state', () {
    testWidgets('shows spinner and disables button while onSignUp is pending',
        (tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(_buildApp(onSignUp: (_, _, _) => completer.future));
      await _fillValidForm(tester);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('shows error banner when onSignUp throws', (tester) async {
      await tester.pumpWidget(_buildApp(
        onSignUp: (_, _, _) async => throw Exception('email already in use'),
      ));
      await _fillValidForm(tester);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Sign-up failed. Please try again.'), findsOneWidget);
    });

    testWidgets('clears error banner on next submit attempt', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(_buildApp(
        onSignUp: (_, _, _) async {
          callCount++;
          if (callCount == 1) throw Exception('fail');
        },
      ));
      await _fillValidForm(tester);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Sign-up failed. Please try again.'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(find.text('Sign-up failed. Please try again.'), findsNothing);

      await tester.pumpAndSettle();
    });
  });
}
