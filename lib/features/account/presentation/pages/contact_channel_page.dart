import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';

// ── Contact constants ──────────────────────────────────────────────
const _kWhatsApp  = '966542139388';
const _kEmail     = 'support@kdx-sa.com';
const _kSnapchat  = 'https://www.snapchat.com/add/kdx_sa';
const _kInstagram = 'https://www.instagram.com/kdx_sa';
const _kTikTok    = 'https://www.tiktok.com/@kdx_sa';
const _kTwitter   = 'https://twitter.com/kdx_sa';
const _kFacebook  = 'https://www.facebook.com/kdx_sa';
const _kYoutube   = 'https://www.youtube.com/@kdx_sa';

class ContactChannelPage extends StatelessWidget {
  const ContactChannelPage({super.key});

  Future<void> _openWhatsApp(BuildContext context) async {
    final uri = Uri.parse('https://wa.me/$_kWhatsApp');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) _snack(context, 'تعذّر فتح واتساب');
    }
  }

  Future<void> _openEmail(BuildContext context) async {
    final String subject = Uri.encodeComponent('استفسار من تطبيق KDX');
    final uri = Uri.parse('mailto:$_kEmail?subject=$subject');
    if (!await launchUrl(uri)) {
      if (context.mounted) _snack(context, 'تعذّر فتح تطبيق البريد');
    }
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) _snack(context, 'تعذّر فتح الرابط');
    }
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'معلومات التواصل',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero Card ──────────────────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 130,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0ABFBE), Color(0xFF018E8E)],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: -15,
                              bottom: -15,
                              child: Opacity(
                                opacity: 0.12,
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 120,
                                  height: 120,
                                ),
                              ),
                            ),
                            const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.headset_mic_rounded, color: Colors.white, size: 32),
                                  SizedBox(height: 8),
                                  Text(
                                    'فريق دعم KDX',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'نحن هنا لمساعدتك على مدار الساعة',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── رقم الهاتف card ────────────────────────────────────
                    _buildContactCard(
                      context: context,
                      icon: Icons.phone_rounded,
                      iconColor: const Color(0xFF25D366),
                      label: 'رقم الهاتف',
                      value: '0542139388',
                      subtitle: 'أيام العمل من 9 ص - 5 م',
                      actionLabel: 'اتصال',
                      actionColor: const Color(0xFF25D366),
                      onAction: () async {
                        final uri = Uri(scheme: 'tel', path: '+$_kWhatsApp');
                        await launchUrl(uri);
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── تابعنا على وسائل التواصل ───────────────────────────
                    _buildSectionHeader('تابعنا على وسائل التواصل'),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.1,
                      children: [
                        _buildSocialTile(Icons.music_note, 'تيك توك', Colors.black, Colors.white, () => _openUrl(context, _kTikTok)),
                        _buildSocialTile(Icons.photo_camera_rounded, 'انستقرام', const Color(0xFFE1306C), Colors.white, () => _openUrl(context, _kInstagram)),
                        _buildSocialTile(Icons.camera_alt_rounded, 'سناب شات', const Color(0xFFFFFC00), Colors.black, () => _openUrl(context, _kSnapchat)),
                        _buildSocialTile(Icons.play_circle_fill_rounded, 'يوتيوب', const Color(0xFFFF0000), Colors.white, () => _openUrl(context, _kYoutube)),
                        _buildSocialTile(Icons.facebook, 'فيسبوك', const Color(0xFF1877F2), Colors.white, () => _openUrl(context, _kFacebook)),
                        _buildSocialTile(Icons.close_rounded, 'تويتر / X', const Color(0xFF14171A), Colors.white, () => _openUrl(context, _kTwitter)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── ساعات العمل ────────────────────────────────────────
                    _buildSectionHeader('ساعات العمل'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        children: [
                          _buildHoursRow('الأحد - الخميس', '9:00 ص - 10:00 م', isFirst: true),
                          const Divider(height: 1, color: Color(0xFFEEEEEE), indent: 16, endIndent: 16),
                          _buildHoursRow('الجمعة - السبت', '11:00 ص - 6:00 م'),
                          const Divider(height: 1, color: Color(0xFFEEEEEE), indent: 16, endIndent: 16),
                          _buildHoursRow('الدعم الإلكتروني', 'على مدار الساعة', isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // ── Sticky bottom buttons ──────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -4))],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // إيميل button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openEmail(context),
                        icon: const Icon(Icons.email_rounded, color: Colors.white, size: 18),
                        label: const Text(
                          'إيميل',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1877F2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // واتساب button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openWhatsApp(context),
                        icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
                        label: const Text(
                          'واتساب',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
    required String actionLabel,
    required Color actionColor,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor.withValues(alpha: 0.15),
              foregroundColor: actionColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(actionLabel, style: TextStyle(color: actionColor, fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontFamily: 'Tajawal')),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark, fontFamily: 'Tajawal')),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontFamily: 'Tajawal')),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        fontFamily: 'Tajawal',
      ),
    );
  }

  Widget _buildSocialTile(IconData icon, String label, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 26),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Tajawal')),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursRow(String day, String hours, {bool isFirst = false, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontSize: 13, color: AppColors.textGrey, fontFamily: 'Tajawal')),
          Text(hours, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark, fontFamily: 'Tajawal')),
        ],
      ),
    );
  }
}
