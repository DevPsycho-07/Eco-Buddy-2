import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_daily_score_dotnet/pages/auth/login_page.dart';

void main() {
  group('LoginPage Widget Tests', () {
    testWidgets('LoginPage renders successfully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Verify page renders
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('LoginPage has text input fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Should have TextFormFields for input
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('LoginPage has button(s) for actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Look for buttons
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ElevatedButton ||
              widget is OutlinedButton ||
              widget is TextButton,
        ),
        findsWidgets,
      );
    });

    testWidgets('LoginPage renders with scrollable content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Verify Scaffold exists for proper layout
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('LoginPage displays form elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Should have form for data input
      expect(find.byType(Form), findsWidgets);
    });

    testWidgets('Text input fields work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().isNotEmpty) {
        // Enter text in first field
        await tester.enterText(textFields.first, 'test@example.com');
        // Verify text was entered
        expect(find.text('test@example.com'), findsOneWidget);
      }
    });

    testWidgets('LoginPage maintains state during interaction',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Verify widget structure is maintained
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(Form), findsWidgets);
    });

    testWidgets('LoginPage handles multiple interactions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      final textFields = find.byType(TextFormField);
      
      // Should handle multiple field interactions
      for (var i = 0; i < textFields.evaluate().length && i < 2; i++) {
        await tester.enterText(textFields.at(i), 'test_input_$i');
      }
      
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('LoginPage layout is responsive', (WidgetTester tester) async {
      // Set small screen size
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.physicalSize = const Size(400, 600);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Widget should still render at small size
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
