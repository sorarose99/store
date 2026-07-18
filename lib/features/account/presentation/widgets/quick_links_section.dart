import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

// Pages
import '../pages/about_us_page.dart';
import '../pages/contact_info_page.dart';
import '../pages/terms_page.dart';
import '../pages/privacy_page.dart';
import '../pages/returns_page.dart';
import '../pages/complaints_page.dart';
import '../pages/faq_page.dart';
import '../pages/delete_account_step1_page.dart';

/// A self-contained "روابط سريعة" (Quick Links) section widget.
/// Drop it anywhere in the account page — all navigation lives here.
class QuickLinksSection extends StatelessWidget {
  const QuickLinksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: isArabic ? 'روابط سريعة' : 'Quick Links'),
        _SectionBox(
          children: [
            _QuickLinkTile(
              icon: Icons.storefront_outlined,
              label: isArabic ? 'من نحن' : 'About Us',
              onTap: () => _push(context, const AboutUsPage()),
            ),
            _divider(context),
            _QuickLinkTile(
              icon: Icons.headset_mic_outlined,
              label: isArabic ? 'اتصل بنا' : 'Contact Us',
              onTap: () => _push(context, const ContactInfoPage()),
            ),
            _divider(context),
            _QuickLinkTile(
              icon: Icons.description_outlined,
              label: isArabic ? 'الشروط والأحكام' : 'Terms & Conditions',
              onTap: () => _push(context, const TermsPage()),
            ),
            _divider(context),
            _QuickLinkTile(
              icon: Icons.privacy_tip_outlined,
              label: isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
              onTap: () => _push(context, const PrivacyPage()),
            ),
            _divider(context),
            _QuickLinkTile(
              icon: Icons.swap_horizontal_circle_outlined,
              label: isArabic ? 'سياسات الاستبدال والاسترجاع' : 'Returns & Exchanges',
              onTap: () => _push(context, const ReturnsPage()),
            ),
            _divider(context),
            _QuickLinkTile(
              icon: Icons.chat_bubble_outline_rounded,
              label: isArabic ? 'الشكاوى والاقتراحات' : 'Complaints & Suggestions',
              onTap: () => _push(context, const ComplaintsPage()),
            ),
            _divider(context),
            _QuickLinkTile(
              icon: Icons.help_outline_rounded,
              label: isArabic ? 'الأسئلة الشائعة' : 'FAQs',
              onTap: () => _push(context, const FaqPage()),
            ),
            _divider(context),
            _QuickLinkTile(
              icon: Icons.delete_outline_rounded,
              label: isArabic ? 'حذف الحساب' : 'Delete Account',
              labelColor: context.errorColor,
              iconColor: context.errorColor,
              onTap: () => _push(context, const DeleteAccountStep1Page()),
            ),
          ],
        ),
      ],
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Widget _divider(BuildContext context) => Divider(
        height: 1,
        thickness: 0.5,
        color: context.border,
        indent: 50,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets (scoped to this file)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          color: context.textGrey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionBox extends StatelessWidget {
  final List<Widget> children;
  const _SectionBox({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      child: Column(children: children),
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  const _QuickLinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor ?? context.textDark.withValues(alpha: 0.87),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: labelColor ?? context.textDark.withValues(alpha: 0.87),
                ),
              ),
            ),
            Icon(
              isArabic ? Icons.chevron_left : Icons.chevron_right,
              size: 18,
              color: context.textGrey,
            ),
          ],
        ),
      ),
    );
  }
}
