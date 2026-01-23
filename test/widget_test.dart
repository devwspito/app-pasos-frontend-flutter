// This is a basic Flutter widget test for the App widget.
//
// Tests verify that the App widget can be built and uses MaterialApp.router.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:workspace/app.dart';
import 'package:workspace/core/di/injection_container.dart';

void main() {
  setUpAll(() {
    // Register a mock GoRouter for testing
    if (!sl.isRegistered<GoRouter>()) {
      sl.registerSingleton<GoRouter>(
        GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Test Home')),
              ),
            ),
          ],
        ),
      );
    }
  });

  tearDownAll(() {
    sl.reset();
  });

  testWidgets('App widget builds with MaterialApp.router', (WidgetTester tester) async {
    // Build the App widget
    await tester.pumpWidget(const App());

    // Verify MaterialApp.router is used by checking the app renders
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verify the test route content is displayed
    await tester.pumpAndSettle();
    expect(find.text('Test Home'), findsOneWidget);
  });

  testWidgets('App has correct title configuration', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'Pasos App');
  });

  testWidgets('App uses Material 3 theme', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, true);
  });

  testWidgets('App has debug banner disabled', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.debugShowCheckedModeBanner, false);
  });
}
