import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_theme.dart';
import 'package:isango_app/screens/auth/sign_in_screen.dart';

Widget _buildApp({
  Future<void> Function(String, String)? onSignIn,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    initialRoute: AppRoutes.login,
    routes: {
      AppRoutes.login: (_) => SignInScreen(onSignIn: onSignIn),
      AppRoutes.home: (_) => const Scaffold(body: Text('Home')),
      AppRoutes.signUp: (_) => const Scaffold(body: Text('Sign Up')),
    },
  );
}

void main() {
  group('SignInScreen — validation', () {
    testWidgets('shows error when email is empty on submit', (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error for malformed email', (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(find.byType(TextFormField).first, 'notanemail');
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows error when password is empty on submit', (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(
          find.byType(TextFormField).first, 'user@example.com');
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(find.text('Please enter your password'), findsOneWidget);
    });
  });

  group('SignInScreen — navigation', () {
    testWidgets('tapping Sign up navigates to /signup', (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
    });
  });

  group('SignInScreen — loading state', () {
    testWidgets('shows spinner and disables button while onSignIn is pending',
        (tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(_buildApp(onSignIn: (_, __) => completer.future));

      await tester.enterText(
          find.byType(TextFormField).first, 'user@example.com');
      await tester.enterText(
          find.byType(TextFormField).last, 'password123');

      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('shows error banner when onSignIn throws', (tester) async {
      await tester.pumpWidget(_buildApp(
        onSignIn: (_, __) async => throw Exception('bad credentials'),
      ));

      await tester.enterText(
          find.byType(TextFormField).first, 'user@example.com');
      await tester.enterText(
          find.byType(TextFormField).last, 'password123');

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(
        find.text('Sign-in failed. Please check your credentials.'),
        findsOneWidget,
      );
    });

    testWidgets('clears error banner on next submit attempt', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(_buildApp(
        onSignIn: (_, __) async {
          callCount++;
          if (callCount == 1) throw Exception('fail');
        },
      ));

      await tester.enterText(
          find.byType(TextFormField).first, 'user@example.com');
      await tester.enterText(
          find.byType(TextFormField).last, 'password123');

      // First submit — triggers error
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(
        find.text('Sign-in failed. Please check your credentials.'),
        findsOneWidget,
      );

      // Second submit — error should be cleared immediately
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      expect(
        find.text('Sign-in failed. Please check your credentials.'),
        findsNothing,
      );

      await tester.pumpAndSettle();
    });
  });
}
