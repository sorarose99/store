import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../data/datasources/mock_account_data.dart';
import 'change_password_page.dart';
import 'delete_account_step1_page.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  bool _notifications = true;

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', false);
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = MockAccountDataSource.currentUser; // Rana Alharbi as per mockup

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'الإعدادات',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Profile Summary ─────────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF2F2F7),
                      ),
                      child: const Center(
                        child: Icon(Icons.person, size: 44, color: AppColors.textGrey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Security Level (مستوى الأمان) ───────────────────────────
              _buildSectionHeader('مستوى الأمان'),
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildNavigationTile(
                      icon: Icons.lock_outline,
                      title: 'تغيير كلمة المرور',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── App Settings (إعدادات التطبيق) ──────────────────────────
              _buildSectionHeader('إعدادات التطبيق'),
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildNavigationTile(
                      icon: Icons.language_outlined,
                      title: 'اللغة',
                      trailingText: 'العربية',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.monetization_on_outlined,
                      title: 'العملة',
                      trailingText: 'الريال السعودي',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildToggleTile(
                      icon: Icons.notifications_none_outlined,
                      title: 'الإشعارات',
                      value: _notifications,
                      onChanged: (val) {
                        setState(() {
                          _notifications = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Danger Zone ─────────────────────────────────────────────
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildNavigationTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'حذف الحساب',
                      titleColor: Colors.red,
                      iconColor: Colors.red,
                      hideChevron: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DeleteAccountStep1Page()),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.logout_rounded,
                      title: 'تسجيل الخروج',
                      titleColor: Colors.red,
                      iconColor: Colors.red,
                      hideChevron: true,
                      onTap: _handleLogout,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textGrey,
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
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
            Icon(icon, size: 22, color: iconColor ?? AppColors.textGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: titleColor ?? AppColors.textDark,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
            if (trailingText != null) const SizedBox(width: 8),
            if (!hideChevron)
              const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFFCCCCCC)),
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
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE), indent: 50);
  }
}
