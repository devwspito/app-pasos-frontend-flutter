// Widget tests for App Pasos application.
//
// These tests verify that the application widgets render correctly
// and function as expected.

import 'package:flutter_test/flutter_test.dart';

import 'package:app_pasos_frontend/app.dart';

void main() {
  testWidgets('App renders Foundation Ready screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Verify that the app title is displayed.
    expect(find.text('App Pasos'), findsWidgets);

    // Verify that the foundation ready message is displayed.
    expect(find.text('Foundation Ready'), findsOneWidget);
  });
}
