import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/brand_provider.dart';
import '../../widgets/glowing_button.dart';
import 'signup_screen.dart';
import '../main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(email: email, password: password);

    if (!mounted) return;

    if (success) {
      await context.read<BrandProvider>().fetchBrands();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login failed'),
          backgroundColor: AppColors.crimsonReject,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Aesthetic Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAubergine,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.borderAubergine),
                ),
                child: Text('ENTERPRISE ACCESS', style: AppTextStyles.badgeText.copyWith(color: AppColors.marigold)),
              ).animate().fadeIn().slideX(begin: -0.2),

              const SizedBox(height: 20),

              // Title
              RichText(
                text: TextSpan(
                  style: AppTextStyles.displayHero,
                  children: [
                    const TextSpan(text: 'Welcome\n'),
                    TextSpan(
                      text: 'back.',
                      style: AppTextStyles.displayHero.copyWith(
                        color: AppColors.marigold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 12),
              Text(
                'Log in to orchestrate autonomous brand growth & review strategic posts.',
                style: AppTextStyles.bodyMedium,
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 40),

              // Email Field
              Text('WORK EMAIL', style: AppTextStyles.labelCaption),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyBold,
                decoration: const InputDecoration(
                  hintText: 'founder@company.io',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.textTertiary),
                ),
              ).animate().fadeIn(delay: 450.ms),

              const SizedBox(height: 22),

              // Password Field
              Text('PASSWORD', style: AppTextStyles.labelCaption),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: AppTextStyles.bodyBold,
                decoration: InputDecoration(
                  hintText: '••••••••••••',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textTertiary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ).animate().fadeIn(delay: 550.ms),

              const SizedBox(height: 36),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: GlowingButton(
                  text: 'Access Command Center',
                  isLoading: auth.isLoading,
                  onPressed: _handleLogin,
                  icon: Icons.arrow_forward_rounded,
                ),
              ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.1),

              const SizedBox(height: 30),

              // Switch to Signup
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium,
                      children: [
                        const TextSpan(text: "Don't have an enterprise account? "),
                        TextSpan(
                          text: 'Sign Up',
                          style: AppTextStyles.bodyBold.copyWith(color: AppColors.marigold),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 750.ms),
            ],
          ),
        ),
      ),
    );
  }
}
