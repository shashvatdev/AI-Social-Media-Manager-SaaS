import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/brand_provider.dart';
import '../../providers/social_provider.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/editorial_badge.dart';

class SocialAccountsHubScreen extends StatefulWidget {
  const SocialAccountsHubScreen({super.key});

  @override
  State<SocialAccountsHubScreen> createState() => _SocialAccountsHubScreenState();
}

class _SocialAccountsHubScreenState extends State<SocialAccountsHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brand = context.read<BrandProvider>().activeBrand;
      if (brand != null) {
        context.read<SocialProvider>().fetchAccounts(brand.id);
      }
    });
  }

  void _showConnectDialog(BuildContext context, String brandId) {
    String selectedPlatform = 'LINKEDIN';
    final handleController = TextEditingController();
    final nameController = TextEditingController();
    final tokenController = TextEditingController(text: 'oauth2_token_${DateTime.now().millisecondsSinceEpoch}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceAubergine,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONNECT SOCIAL HANDLE', style: AppTextStyles.labelCaption),
                  const SizedBox(height: 6),
                  Text('OAuth Account Linking', style: AppTextStyles.displaySub),
                  const SizedBox(height: 20),

                  // Platform Selector
                  Row(
                    children: [
                      _buildPlatformChip('LINKEDIN', selectedPlatform, (p) => setModalState(() => selectedPlatform = p)),
                      const SizedBox(width: 8),
                      _buildPlatformChip('TWITTER', selectedPlatform, (p) => setModalState(() => selectedPlatform = p)),
                      const SizedBox(width: 8),
                      _buildPlatformChip('INSTAGRAM', selectedPlatform, (p) => setModalState(() => selectedPlatform = p)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Handle
                  Text('ACCOUNT HANDLE (@username)', style: AppTextStyles.labelCaption),
                  const SizedBox(height: 6),
                  TextField(
                    controller: handleController,
                    style: AppTextStyles.bodyBold,
                    decoration: const InputDecoration(hintText: 'e.g. acme_corp'),
                  ),

                  const SizedBox(height: 16),

                  // Display Name
                  Text('DISPLAY NAME', style: AppTextStyles.labelCaption),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    style: AppTextStyles.bodyBold,
                    decoration: const InputDecoration(hintText: 'e.g. Acme AI Global Page'),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: GlowingButton(
                      text: 'Authorize & Link Handle',
                      onPressed: () async {
                        final handle = handleController.text.trim();
                        if (handle.isEmpty) return;

                        final success = await context.read<SocialProvider>().connectAccount(
                              brandId: brandId,
                              platform: selectedPlatform,
                              accountHandle: handle,
                              accountName: nameController.text.trim().isNotEmpty ? nameController.text.trim() : null,
                              accessToken: tokenController.text.trim(),
                            );

                        if (!ctx.mounted) return;
                        Navigator.of(ctx).pop();
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Connected $selectedPlatform @$handle successfully!'),
                              backgroundColor: AppColors.emeraldSuccess,
                            ),
                          );
                        }
                      },
                      icon: Icons.link_rounded,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlatformChip(String platform, String selected, ValueChanged<String> onSelect) {
    final isSelected = platform == selected;
    return ChoiceChip(
      label: Text(platform, style: AppTextStyles.badgeText.copyWith(color: isSelected ? AppColors.textOnMarigold : AppColors.textPrimary)),
      selected: isSelected,
      selectedColor: AppColors.marigold,
      backgroundColor: AppColors.darkCanvas,
      side: const BorderSide(color: AppColors.borderAubergine),
      onSelected: (_) => onSelect(platform),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.watch<BrandProvider>().activeBrand;
    final socialProvider = context.watch<SocialProvider>();

    if (brand == null) {
      return Center(child: Text('Select a brand first', style: AppTextStyles.bodyBold));
    }

    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      body: RefreshIndicator(
        color: AppColors.marigold,
        backgroundColor: AppColors.surfaceAubergine,
        onRefresh: () => socialProvider.fetchAccounts(brand.id),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DISTRIBUTION CHANNELS', style: AppTextStyles.labelCaption),
                      const SizedBox(height: 4),
                      Text('Social Accounts Hub.', style: AppTextStyles.displayTitle),
                    ],
                  ),
                  GlowingButton(
                    text: 'Connect',
                    isSecondary: true,
                    onPressed: () => _showConnectDialog(context, brand.id),
                    icon: Icons.add_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (socialProvider.isLoading) ...[
                const SizedBox(height: 60),
                const Center(child: CircularProgressIndicator(color: AppColors.marigold)),
              ] else if (socialProvider.accounts.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAubergine,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderAubergine),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.link_off_rounded, color: AppColors.textTertiary, size: 40),
                      const SizedBox(height: 14),
                      Text('No Social Media Handles Linked', style: AppTextStyles.bodyBold),
                      const SizedBox(height: 6),
                      Text(
                        'Link your LinkedIn, Twitter, or Instagram handles so approved posts can be dispatched autonomously.',
                        style: AppTextStyles.labelCaption,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      GlowingButton(
                        text: 'Connect Your First Handle',
                        onPressed: () => _showConnectDialog(context, brand.id),
                        icon: Icons.add_link_rounded,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: socialProvider.accounts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final acc = socialProvider.accounts[index];

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAubergine,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderAubergine),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFFFFBEB),
                            child: Icon(
                              acc.platform == 'LINKEDIN'
                                  ? Icons.work_rounded
                                  : acc.platform == 'TWITTER'
                                      ? Icons.chat_bubble_rounded
                                      : Icons.photo_camera_rounded,
                              color: AppColors.marigold,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('@${acc.accountHandle}', style: AppTextStyles.bodyBold),
                                    const SizedBox(width: 8),
                                    EditorialBadge(
                                      label: acc.platform,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      textColor: AppColors.textPrimary,
                                    ),
                                  ],
                                ),
                                if (acc.accountName != null) ...[
                                  const SizedBox(height: 2),
                                  Text(acc.accountName!, style: AppTextStyles.labelCaption),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.crimsonReject, size: 20),
                            onPressed: () => socialProvider.disconnectAccount(acc.id, brand.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
