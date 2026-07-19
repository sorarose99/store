import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/token_service.dart';
import '../blocs/account_bloc.dart';
import '../blocs/account_state.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_event.dart';
import 'change_password_page.dart';
import 'delete_account_step1_page.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/widgets/app_shimmer.dart';
import 'notifications_page.dart';
import 'licenses_page.dart';
class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('logout'.tr()),
        content: Text('logout_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'logout'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Dispatch LogoutRequested to AuthBloc:
    // This calls backend /logout, then clears Firebase session + Sanctum token.
    // TokenService.clearAll() emits to authStateChanges stream → whole app reacts.
    context.read<AuthBloc>().add(const LogoutRequested());

    // Reset onboarding so returning users see it again
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', false);

    // Navigate to LoginPage and clear stack to avoid black screen and orphaned routes
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: context.surfaceColor,
        appBar: AppBar(
          backgroundColor: context.surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: context.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'settings'.tr(),
            style: TextStyle(
              color: context.textDark,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            final loadedState = (state is AccountLoaded) 
                ? state 
                : context.read<AccountBloc>().lastLoadedState;

            if (loadedState != null) {
              final user = loadedState.user;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Profile Summary ─────────────────────────────────────────
                    Container(
                      color: context.backgroundColor,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.surfaceColor,
                            ),
                            child: user.avatar != null && user.avatar!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      user.avatar!,
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                      errorBuilder: (_, __, ___) => Icon(
                                          Icons.person,
                                          size: 44,
                                          color: context.textGrey),
                                    ),
                                  )
                                : Center(
                                    child: Icon(Icons.person,
                                        size: 44, color: context.textGrey),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: context.textDark,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: context.textGrey,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Security Level (مستوى الأمان) ───────────────────────────
                    _buildSectionHeader(context, 'security_level'.tr()),
                    Container(
                      color: context.backgroundColor,
                      child: Column(
                        children: [
                          _buildNavigationTile(
                            context: context,
                            icon: Icons.lock_outline,
                            title: 'change_password'.tr(),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const ChangePasswordPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── App Settings (إعدادات التطبيق) ──────────────────────────
                    _buildSectionHeader(context, 'app_settings'.tr()),
                    Container(
                      color: context.backgroundColor,
                      child: Column(
                        children: [
                          _buildNavigationTile(
                            context: context,
                            icon: Icons.language_outlined,
                            title: 'language'.tr(),
                            trailingText: context.locale.languageCode == 'ar' ? 'العربية' : 'English',
                            onTap: () {},
                          ),
                          _buildDivider(context),
                          _buildNavigationTile(
                            context: context,
                            icon: Icons.monetization_on_outlined,
                            title: 'currency'.tr(),
                            trailingText: '﷼',
                            onTap: () {},
                          ),
                          _buildDivider(context),
                          _buildNavigationTile(
                            context: context,
                            icon: Icons.notifications_none_outlined,
                            title: 'notifications'.tr(),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsPage(),
                                ),
                              );
                            },
                          ),
                          _buildDivider(context),
                          _buildNavigationTile(
                            context: context,
                            icon: Icons.verified_outlined,
                            title: 'licenses'.tr(),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LicensesPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Danger Zone ─────────────────────────────────────────────
                    Container(
                      color: context.backgroundColor,
                      child: Column(
                        children: [
                          _buildNavigationTile(
                            context: context,
                            icon: Icons.delete_outline_rounded,
                            title: 'delete_account'.tr(),
                            titleColor: context.errorColor,
                            iconColor: context.errorColor,
                            hideChevron: true,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const DeleteAccountStep1Page()),
                              );
                            },
                          ),
                          _buildDivider(context),
                          _buildNavigationTile(
                            context: context,
                            icon: Icons.logout_rounded,
                            title: 'logout'.tr(),
                            titleColor: context.errorColor,
                            iconColor: context.errorColor,
                            hideChevron: true,
                            onTap: _handleLogout,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            }
            
            // If we have no data at all (e.g. AccountInitial or AccountLoading before any data is loaded)
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: context.textGrey,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? trailingText,
    Color? titleColor,
    Color? iconColor,
    bool hideChevron = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? context.textGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: titleColor ?? context.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: context.textGrey,
                  fontFamily: 'Tajawal',
                ),
              ),
            if (trailingText != null) const SizedBox(width: 8),
            if (!hideChevron)
              Icon(Icons.arrow_back_ios_new,
                  size: 16, color: context.textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
        height: 1, thickness: 0.5, color: context.border, indent: 50);
  }
}
