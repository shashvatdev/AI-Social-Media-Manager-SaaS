import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/widgets/glowing_button.dart';
import 'package:frontend/widgets/editorial_badge.dart';

void main() {
  testWidgets('Luxury Light Theme & GlowingButton component test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.luxuryLightTheme,
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

  testWidgets('EditorialBadge status render tests', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.luxuryLightTheme,
        home: Scaffold(
          body: Column(
            children: [
              EditorialBadge.status('APPROVED'),
              EditorialBadge.status('SCHEDULED'),
              EditorialBadge.status('PENDING_APPROVAL'),
              EditorialBadge.funnel('TOFU'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('APPROVED'), findsOneWidget);
    expect(find.text('SCHEDULED QUEUE'), findsOneWidget);
    expect(find.text('WAITING YOUR APPROVAL'), findsOneWidget);
    expect(find.text('TOFU'), findsOneWidget);
  });

  test('Luxury Light Color Palette sanity checks', () {
    expect(AppColors.darkCanvas, const Color(0xFFF8FAFC));
    expect(AppColors.surfaceAubergine, const Color(0xFFFFFFFF));
    expect(AppColors.textPrimary, const Color(0xFF0F172A));
    expect(AppColors.borderAubergine, const Color(0xFFE2E8F0));
  });
}
