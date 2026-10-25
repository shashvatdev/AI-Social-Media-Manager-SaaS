// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/widgets/glowing_button.dart';

void main() {
  testWidgets('Luxury UI GlowingButton component test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.luxuryDarkTheme,
        home: Scaffold(
          body: GlowingButton(
            text: 'Generate Content Blueprint',
            onPressed: () {},
          ),
        ),
      ),
    );
    expect(find.text('Generate Content Blueprint'), findsOneWidget);
    expect(find.byType(GlowingButton), findsOneWidget);
  });
}
