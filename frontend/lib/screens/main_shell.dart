import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/brand_provider.dart';
import 'inbox/post_approval_inbox_screen.dart';
import 'strategy/strategy_blueprint_screen.dart';
import 'brand/brand_brain_vault_screen.dart';
import 'social/social_accounts_hub_screen.dart';
import 'brand/brand_setup_screen.dart';
import 'auth/login_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    PostApprovalInboxScreen(),
    StrategyBlueprintScreen(),
    BrandBrainVaultScreen(),
    SocialAccountsHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final brandProvider = context.watch<BrandProvider>();
    final authProvider = context.watch<AuthProvider>();
    final activeBrand = brandProvider.activeBrand;

    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      appBar: AppBar(
        titleSpacing: 20,
        title: GestureDetector(
          onTap: () => _showBrandSwitcher(context, brandProvider),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAubergine,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderAubergine),
                ),
                child: const Center(
                  child: Icon(Icons.blur_on_rounded, color: AppColors.marigold, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ACTIVE BRAND', style: AppTextStyles.labelCaption.copyWith(fontSize: 9, letterSpacing: 1.2)),
                  Row(
                    children: [
                      Text(
                        activeBrand?.name ?? 'Select Brand',
                        style: AppTextStyles.bodyBold.copyWith(fontSize: 15),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textTertiary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add New Brand',
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.marigold),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BrandSetupScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Log Out',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textTertiary, size: 20),
            onPressed: () async {
              await authProvider.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.obsidian,
          border: Border(top: BorderSide(color: AppColors.borderAubergine, width: 1)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: AppColors.marigoldGlow,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTextStyles.labelCaption.copyWith(color: AppColors.marigold, fontWeight: FontWeight.w700);
              }
              return AppTextStyles.labelCaption.copyWith(color: AppColors.textTertiary);
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: AppColors.marigold);
              }
              return const IconThemeData(color: AppColors.textTertiary);
            }),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.inbox_rounded),
                selectedIcon: Icon(Icons.inbox_rounded),
                label: 'Approval Inbox',
              ),
              NavigationDestination(
                icon: Icon(Icons.psychology_alt_rounded),
                selectedIcon: Icon(Icons.psychology_alt_rounded),
                label: 'AI Strategy',
              ),
              NavigationDestination(
                icon: Icon(Icons.hub_rounded),
                selectedIcon: Icon(Icons.hub_rounded),
                label: 'Brand Brain',
              ),
              NavigationDestination(
                icon: Icon(Icons.share_rounded),
                selectedIcon: Icon(Icons.share_rounded),
                label: 'Social Hub',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBrandSwitcher(BuildContext context, BrandProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceAubergine,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SWITCH BRAND OR CREATE NEW', style: AppTextStyles.labelCaption),
              const SizedBox(height: 16),
              ...provider.brands.map((b) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.deepAubergine,
                      child: Text(
                        b.name.isNotEmpty ? b.name[0].toUpperCase() : 'B',
                        style: AppTextStyles.bodyBold.copyWith(color: AppColors.marigold),
                      ),
                    ),
                    title: Text(b.name, style: AppTextStyles.bodyBold),
                    subtitle: Text(b.industry ?? 'General Brand', style: AppTextStyles.labelCaption),
                    trailing: provider.activeBrand?.id == b.id
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.marigold)
                        : null,
                    onTap: () {
                      provider.setActiveBrand(b);
                      Navigator.of(ctx).pop();
                    },
                  )),
              const Divider(color: AppColors.borderAubergine, height: 28),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.marigoldGlow,
                  child: Icon(Icons.add_rounded, color: AppColors.marigold),
                ),
                title: Text('Onboard New Brand', style: AppTextStyles.bodyBold.copyWith(color: AppColors.marigold)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BrandSetupScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
