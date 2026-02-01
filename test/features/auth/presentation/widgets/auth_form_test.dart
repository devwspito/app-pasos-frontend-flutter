/// Widget tests for [AuthForm].
///
/// Tests cover:
/// - Login form type rendering and validation
/// - Register form type rendering and validation
/// - Loading state behavior
/// - Form submission with valid data
library;

import 'package:app_pasos_frontend/features/auth/presentation/widgets/auth_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('AuthForm', () {
    group('Login Form Type', () {
      testWidgets('renders email field with label Email', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AuthForm(
                  formType: AuthFormType.login,
                  onSubmit: (_, __, ___) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Email'), findsOneWidget);
      });

      testWidgets('renders password field with label Password', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AuthForm(
                  formType: AuthFormType.login,
                  onSubmit: (_, __, ___) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Password'), findsOneWidget);
      });

      testWidgets('does NOT render name field', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AuthForm(
                  formType: AuthFormType.login,
                  onSubmit: (_, __, ___) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Full Name'), findsNothing);
      });

      testWidgets('does NOT render confirm password field', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AuthForm(
                  formType: AuthFormType.login,
                  onSubmit: (_, __, ___) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Confirm Password'), findsNothing);
      });

      testWidgets('shows Login button text', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AuthForm(
                  formType: AuthFormType.login,
                  onSubmit: (_, __, ___) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Login'), findsOneWidget);
      });

      testWidgets(
        'validates email format and shows error message',
        (tester) async {
          await pumpApp(
            tester,
            Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AuthForm(
                    formType: AuthFormType.login,
                    onSubmit: (_, __, ___) {},
                  ),
                ),
              ),
            ),
          );

          // Enter invalid email
          final emailFields = find.byType(TextFormField);
          await tester.enterText(emailFields.first, 'invalidemail');
          await tester.pump();

          // Tap login button to trigger validation
          await tester.tap(find.text('Login'));
          await tester.pump();

          expect(
            find.text('Please enter a valid email address'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'validates password required and shows error message',
        (tester) async {
          await pumpApp(
            tester,
            Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AuthForm(
                    formType: AuthFormType.login,
                    onSubmit: (_, __, ___) {},
                  ),
                ),
              ),
            ),
          );

          // Enter valid email but empty password
          final emailFields = find.byType(TextFormField);
          await tester.enterText(emailFields.first, 'test@example.com');
          await tester.pump();

          // Tap login button to trigger validation
          await tester.tap(find.text('Login'));
          await tester.pump();

          expect(find.text('Password is required'), findsOneWidget);
        },
      );

      testWidgets(
        'calls onSubmit with email, password, null when valid',
        (tester) async {
          String? submittedEmail;
          String? submittedPassword;
          String? submittedName;
          var onSubmitCalled = false;

          await pumpApp(
            tester,
            Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AuthForm(
                    formType: AuthFormType.login,
                    onSubmit: (email, password, name) {
                      onSubmitCalled = true;
                      submittedEmail = email;
                      submittedPassword = password;
                      submittedName = name;
                    },
                  ),
                ),
              ),
            ),
          );

          // Enter valid email
          final textFormFields = find.byType(TextFormField);
          await tester.enterText(textFormFields.at(0), 'test@example.com');
          await tester.pump();

          // Enter valid password (must meet requirements: 8+ chars, upper, lower, digit)
          await tester.enterText(textFormFields.at(1), 'Password123');
          await tester.pump();

          // Tap login button
          await tester.tap(find.text('Login'));
          await tester.pump();

          expect(onSubmitCalled, isTrue);
          expect(submittedEmail, equals('test@example.com'));
          expect(submittedPassword, equals('Password123'));
          expect(submittedName, isNull);
        },
      );
    });

    group('Register Form Type', () {
      testWidgets('renders name field with label Full Name', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AuthForm(
                  formType: AuthFormType.register,
                  onSubmit: (_, __, ___) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Full Name'), findsOneWidget);
      });

      testWidgets('renders email field', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AuthForm(
                  formType: AuthFormType.register,
                  onSubmit: (_, __, ___) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Email'), findsOneWidget);
      });

      testWidgets('renders password field', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AuthForm(
                  formType: AuthFormType.register,
                  onSubmit: (_, __, ___) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Password'), findsOneWidget);
      });

      testWidgets('renders confirm password field', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AuthForm(
                  formType: AuthFormType.register,
                  onSubmit: (_, __, ___) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Confirm Password'), findsOneWidget);
      });

      testWidgets('shows Create Account button text', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AuthForm(
                  formType: AuthFormType.register,
                  onSubmit: (_, __, ___) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Create Account'), findsOneWidget);
      });

      testWidgets(
        'validates password match and shows error message',
        (tester) async {
          await pumpApp(
            tester,
            Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AuthForm(
                    formType: AuthFormType.register,
                    onSubmit: (_, __, ___) {},
                  ),
                ),
              ),
            ),
          );

          final textFormFields = find.byType(TextFormField);

          // Enter name
          await tester.enterText(textFormFields.at(0), 'John Doe');
          await tester.pump();

          // Enter valid email
          await tester.enterText(textFormFields.at(1), 'john@example.com');
          await tester.pump();

          // Enter valid password
          await tester.enterText(textFormFields.at(2), 'Password123');
          await tester.pump();

          // Enter mismatched confirm password
          await tester.enterText(textFormFields.at(3), 'DifferentPassword123');
          await tester.pump();

          // Tap Create Account button to trigger validation
          await tester.tap(find.text('Create Account'));
          await tester.pump();

          expect(find.text('Passwords do not match'), findsOneWidget);
        },
      );

      testWidgets(
        'calls onSubmit with email, password, name when valid',
        (tester) async {
          String? submittedEmail;
          String? submittedPassword;
          String? submittedName;
          var onSubmitCalled = false;

          await pumpApp(
            tester,
            Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AuthForm(
                    formType: AuthFormType.register,
                    onSubmit: (email, password, name) {
                      onSubmitCalled = true;
                      submittedEmail = email;
                      submittedPassword = password;
                      submittedName = name;
                    },
                  ),
                ),
              ),
            ),
          );

          final textFormFields = find.byType(TextFormField);

          // Enter name
          await tester.enterText(textFormFields.at(0), 'John Doe');
          await tester.pump();

          // Enter valid email
          await tester.enterText(textFormFields.at(1), 'john@example.com');
          await tester.pump();

          // Enter valid password (must meet requirements)
          await tester.enterText(textFormFields.at(2), 'Password123');
          await tester.pump();

          // Enter matching confirm password
          await tester.enterText(textFormFields.at(3), 'Password123');
          await tester.pump();

          // Tap Create Account button
          await tester.tap(find.text('Create Account'));
          await tester.pump();

          expect(onSubmitCalled, isTrue);
          expect(submittedEmail, equals('john@example.com'));
          expect(submittedPassword, equals('Password123'));
          expect(submittedName, equals('John Doe'));
        },
      );

      testWidgets('validates name is required', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AuthForm(
                  formType: AuthFormType.register,
                  onSubmit: (_, __, ___) {},
                ),
              ),
            ),
          ),
        );

        // Tap Create Account button without filling any fields
        await tester.tap(find.text('Create Account'));
        await tester.pump();

        expect(find.text('Name is required'), findsOneWidget);
      });
    });

    group('Loading State', () {
      testWidgets('form fields disabled when isLoading true', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AuthForm(
                  formType: AuthFormType.login,
                  isLoading: true,
                  onSubmit: (_, __, ___) {},
                ),
              ),
            ),
          ),
        );

        // Find all TextFormFields and verify they are disabled
        final textFormFields = tester.widgetList<TextFormField>(
          find.byType(TextFormField),
        );

        for (final field in textFormFields) {
          expect(field.enabled, isFalse);
        }
      });

      testWidgets(
        'button shows loading indicator when isLoading true',
        (tester) async {
          await pumpApp(
            tester,
            Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AuthForm(
                    formType: AuthFormType.login,
                    isLoading: true,
                    onSubmit: (_, __, ___) {},
                  ),
                ),
              ),
            ),
          );

          // The AppButton shows a CircularProgressIndicator when isLoading is true
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'button is not tappable when isLoading true',
        (tester) async {
          var onSubmitCalled = false;

          await pumpApp(
            tester,
            Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AuthForm(
                    formType: AuthFormType.login,
                    isLoading: true,
                    onSubmit: (_, __, ___) {
                      onSubmitCalled = true;
                    },
                  ),
                ),
              ),
            ),
          );

          // Enter valid data
          final textFormFields = find.byType(TextFormField);
          await tester.enterText(textFormFields.at(0), 'test@example.com');
          await tester.pump();
          await tester.enterText(textFormFields.at(1), 'Password123');
          await tester.pump();

          // Try to find and tap the button - it should be disabled
          // The Login text might not be visible during loading, so find by widget
          final button = find.byType(ElevatedButton);
          if (button.evaluate().isNotEmpty) {
            await tester.tap(button);
            await tester.pump();
          }

          expect(onSubmitCalled, isFalse);
        },
      );

      testWidgets(
        'register form fields disabled when isLoading true',
        (tester) async {
          await pumpApp(
            tester,
            Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AuthForm(
                    formType: AuthFormType.register,
                    isLoading: true,
                    onSubmit: (_, __, ___) {},
                  ),
                ),
              ),
            ),
          );

          // Find all TextFormFields and verify they are disabled
          final textFormFields = tester.widgetList<TextFormField>(
            find.byType(TextFormField),
          );

          // Register form has 4 fields: name, email, password, confirm password
          expect(textFormFields.length, equals(4));

          for (final field in textFormFields) {
            expect(field.enabled, isFalse);
          }
        },
      );
    });

    group('Form Validation Edge Cases', () {
      testWidgets('shows email required error when empty', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AuthForm(
                  formType: AuthFormType.login,
                  onSubmit: (_, __, ___) {},
                ),
              ),
            ),
          ),
        );

        // Tap login button without entering anything
        await tester.tap(find.text('Login'));
        await tester.pump();

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets(
        'shows confirm password required error when empty',
        (tester) async {
          await pumpApp(
            tester,
            Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AuthForm(
                    formType: AuthFormType.register,
                    onSubmit: (_, __, ___) {},
                  ),
                ),
              ),
            ),
          );

          final textFormFields = find.byType(TextFormField);

          // Fill in name, email, password but leave confirm password empty
          await tester.enterText(textFormFields.at(0), 'John Doe');
          await tester.pump();
          await tester.enterText(textFormFields.at(1), 'john@example.com');
          await tester.pump();
          await tester.enterText(textFormFields.at(2), 'Password123');
          await tester.pump();

          // Tap Create Account button
          await tester.tap(find.text('Create Account'));
          await tester.pump();

          expect(find.text('Please confirm your password'), findsOneWidget);
        },
      );

      testWidgets(
        'password validation shows minimum length error',
        (tester) async {
          await pumpApp(
            tester,
            Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AuthForm(
                    formType: AuthFormType.login,
                    onSubmit: (_, __, ___) {},
                  ),
                ),
              ),
            ),
          );

          final textFormFields = find.byType(TextFormField);

          // Enter valid email
          await tester.enterText(textFormFields.at(0), 'test@example.com');
          await tester.pump();

          // Enter short password
          await tester.enterText(textFormFields.at(1), 'short');
          await tester.pump();

          // Tap login button
          await tester.tap(find.text('Login'));
          await tester.pump();

          expect(
            find.text('Password must be at least 8 characters'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'email trims whitespace before submission',
        (tester) async {
          String? submittedEmail;

          await pumpApp(
            tester,
            Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AuthForm(
                    formType: AuthFormType.login,
                    onSubmit: (email, _, __) {
                      submittedEmail = email;
                    },
                  ),
                ),
              ),
            ),
          );

          final textFormFields = find.byType(TextFormField);

          // Enter email with whitespace
          await tester.enterText(
            textFormFields.at(0),
            '  test@example.com  ',
          );
          await tester.pump();

          // Enter valid password
          await tester.enterText(textFormFields.at(1), 'Password123');
          await tester.pump();

          // Tap login button
          await tester.tap(find.text('Login'));
          await tester.pump();

          expect(submittedEmail, equals('test@example.com'));
        },
      );
    });
  });
}
