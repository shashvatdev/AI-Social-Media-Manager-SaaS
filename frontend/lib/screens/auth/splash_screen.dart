import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/brand_provider.dart';
import 'login_screen.dart';
import '../main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleBoot();
  }

  Future<void> _handleBoot() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = await authProvider.checkAuth();

    if (!mounted) return;
    if (isAuthenticated) {
      await context.read<BrandProvider>().fetchBrands();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background subtle luxury aura
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.marigold.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.deepAubergine.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Central Editorial Branding
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Emblem
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAubergine,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderAubergine, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.marigold.withValues(alpha: 0.25),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 40,
                    color: AppColors.marigold,
                  ),
                )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.easeOutBack)
                    .then()
                    .shimmer(duration: 1200.ms, color: AppColors.iceSilver.withValues(alpha: 0.4)),

                const SizedBox(height: 36),

                // Editorial Title
                Text('AUTONOMOUS AI', style: AppTextStyles.labelCaption.copyWith(letterSpacing: 4))
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms),

                const SizedBox(height: 8),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.displayHero,
                    children: [
                      const TextSpan(text: 'Social '),
                      TextSpan(
                        text: 'Lead.',
                        style: AppTextStyles.displayHero.copyWith(
                          color: AppColors.marigold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 700.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 12),

                Text(
                  'Strategy. Creatives. Human-in-the-Loop.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                ).animate().fadeIn(delay: 800.ms, duration: 600.ms),

                const SizedBox(height: 48),

                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppColors.marigold,
                    strokeWidth: 2,
                  ),
                ).animate().fadeIn(delay: 1100.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
