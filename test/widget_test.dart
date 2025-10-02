// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healer_map_flutter/app/app.dart';

void main() {
  testWidgets('App starts at Splash and goes to Login', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const ProviderScope(child: App()));

    // Splash shows CircularProgressIndicator initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let splash decide and navigate
    await tester.pumpAndSettle();

    // Should be on Login page with email/password field titles
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email'), findsWidgets);
    expect(find.text('Password'), findsWidgets);
  });
}
