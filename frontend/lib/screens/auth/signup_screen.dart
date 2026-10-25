import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/brand_provider.dart';
import '../../widgets/glowing_button.dart';
import '../main_shell.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final company = _companyController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signup(
      email: email,
      fullName: name,
      password: password,
      companyName: company.isNotEmpty ? company : null,
    );

    if (!mounted) return;

    if (success) {
      await context.read<BrandProvider>().fetchBrands();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Signup failed'),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAubergine,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.borderAubergine),
                ),
                child: Text('FOUNDER ONBOARDING', style: AppTextStyles.badgeText.copyWith(color: AppColors.marigold)),
              ).animate().fadeIn().slideX(begin: -0.2),

              const SizedBox(height: 16),

              // Title
              RichText(
                text: TextSpan(
                  style: AppTextStyles.displayHero,
                  children: [
                    const TextSpan(text: 'Scale your\n'),
                    TextSpan(
                      text: 'Brand.',
                      style: AppTextStyles.displayHero.copyWith(
                        color: AppColors.marigold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 8),
              Text(
                'Deploy an autonomous AI Content Lead that builds strategy, visual creatives & schedules high-signal posts.',
                style: AppTextStyles.bodyMedium,
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 32),

              // Full Name
              Text('FULL NAME *', style: AppTextStyles.labelCaption),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: AppTextStyles.bodyBold,
                decoration: const InputDecoration(
                  hintText: 'Sarah Connor',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.textTertiary),
                ),
              ),

              const SizedBox(height: 20),

              // Work Email
              Text('WORK EMAIL *', style: AppTextStyles.labelCaption),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyBold,
                decoration: const InputDecoration(
                  hintText: 'sarah@hyperion.ai',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.textTertiary),
                ),
              ),

              const SizedBox(height: 20),

              // Company Name
              Text('COMPANY / BRAND NAME', style: AppTextStyles.labelCaption),
              const SizedBox(height: 8),
              TextField(
                controller: _companyController,
                style: AppTextStyles.bodyBold,
                decoration: const InputDecoration(
                  hintText: 'Hyperion AI Labs',
                  prefixIcon: Icon(Icons.business_outlined, color: AppColors.textTertiary),
                ),
              ),

              const SizedBox(height: 20),

              // Password
              Text('PASSWORD * (MIN 6 CHARACTERS)', style: AppTextStyles.labelCaption),
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
              ),

              const SizedBox(height: 36),

              // Signup Button
              SizedBox(
                width: double.infinity,
                child: GlowingButton(
                  text: 'Create Enterprise Account',
                  isLoading: auth.isLoading,
                  onPressed: _handleSignup,
                  icon: Icons.rocket_launch_rounded,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
