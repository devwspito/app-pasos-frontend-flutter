/// Widget tests for [AppTextField].
///
/// Tests cover:
/// - Rendering with hint text
/// - Rendering with label text
/// - Calling onChanged callback when text changes
/// - Showing error text when provided
/// - Validating input using validator function
/// - Rendering prefixIcon when provided
/// - obscureText hiding password input
library;

import 'package:app_pasos_frontend/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('AppTextField', () {
    testWidgets('renders with hint text', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: AppTextField(
              hintText: 'Enter your name',
            ),
          ),
        ),
      );

      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('renders with label text', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: AppTextField(
              labelText: 'Email Address',
            ),
          ),
        ),
      );

      expect(find.text('Email Address'), findsOneWidget);
    });

    testWidgets('calls onChanged callback when text changes', (tester) async {
      String? changedValue;

      await pumpApp(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Hello World');
      await tester.pump();

      expect(changedValue, equals('Hello World'));
    });

    testWidgets('shows error text when provided', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: AppTextField(
              labelText: 'Password',
              errorText: 'Password is required',
            ),
          ),
        ),
      );

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('validates input using validator function', (tester) async {
      final formKey = GlobalKey<FormState>();

      await pumpApp(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: AppTextField(
                labelText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Validate with empty input
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField), 'invalidemail');
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Invalid email format'), findsOneWidget);

      // Enter valid email
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      formKey.currentState!.validate();
      await tester.pump();

      // Error messages should disappear
      expect(find.text('Email is required'), findsNothing);
      expect(find.text('Invalid email format'), findsNothing);
    });

    testWidgets('prefixIcon renders when provided', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: AppTextField(
              labelText: 'Email',
              prefixIcon: Icons.email,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('obscureText hides password input', (tester) async {
      final controller = TextEditingController();

      await pumpApp(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: controller,
              labelText: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'secret123');
      await tester.pump();

      // Verify the text was entered
      expect(controller.text, equals('secret123'));

      // Verify the TextField (inside TextFormField) has obscureText enabled
      final textField = tester.widget<TextField>(
        find.byType(TextField),
      );
      expect(textField.obscureText, isTrue);
    });

    testWidgets('renders suffixIcon when provided', (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('handles suffixIcon tap for password toggle', (tester) async {
      var visibilityToggled = false;

      await pumpApp(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              labelText: 'Password',
              obscureText: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.visibility_off),
                onPressed: () {
                  visibilityToggled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(visibilityToggled, isTrue);
    });

    testWidgets('disables input when enabled is false', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: AppTextField(
              labelText: 'Disabled Field',
              enabled: false,
            ),
          ),
        ),
      );

      final textFormField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(textFormField.enabled, isFalse);
    });

    testWidgets('uses provided controller', (tester) async {
      final controller = TextEditingController(text: 'Initial Value');

      await pumpApp(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: controller,
              labelText: 'Test Field',
            ),
          ),
        ),
      );

      // Verify initial value is displayed
      expect(find.text('Initial Value'), findsOneWidget);

      // Update controller and verify
      controller.text = 'Updated Value';
      await tester.pump();

      expect(find.text('Updated Value'), findsOneWidget);
    });

    testWidgets('supports multiline input with maxLines', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: AppTextField(
              labelText: 'Description',
              maxLines: 5,
            ),
          ),
        ),
      );

      // Verify the TextField (inside TextFormField) has correct maxLines
      final textField = tester.widget<TextField>(
        find.byType(TextField),
      );
      expect(textField.maxLines, equals(5));
    });

    testWidgets('renders with both hint and label text', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: AppTextField(
              labelText: 'Username',
              hintText: 'Enter your username',
            ),
          ),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
      // Hint may only show when focused, so we just ensure no errors
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('applies keyboard type', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: AppTextField(
              labelText: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );

      // Verify the TextField (inside TextFormField) has correct keyboardType
      final textField = tester.widget<TextField>(
        find.byType(TextField),
      );
      expect(textField.keyboardType, equals(TextInputType.emailAddress));
    });
  });
}
