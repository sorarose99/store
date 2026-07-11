import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';

class ContactInfoPage extends StatelessWidget {
  const ContactInfoPage({super.key});

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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.tealGlowShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.headset_mic_outlined, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'فريق دعم KDX',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'نحن هنا لمساعدتك على مدار الساعة',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section: Direct Contact
              _buildSectionTitle('تواصل مباشر'),
              const SizedBox(height: 12),

              _buildContactCard(
                context: context,
                icon: Icons.email_outlined,
                iconColor: const Color(0xFF4285F4),
                title: 'البريد الإلكتروني',
                value: 'support@kdx-sa.com',
                subtitle: 'نرد خلال 24 ساعة عمل',
                onTap: () => _copyToClipboard(context, 'support@kdx-sa.com'),
                actionLabel: 'نسخ',
              ),
              const SizedBox(height: 12),

              _buildContactCard(
                context: context,
                customIcon: const _WhatsAppIcon(size: 24, color: Color(0xFF25D366)),
                iconColor: const Color(0xFF25D366),
                title: 'واتساب',
                value: '0542139388',
                subtitle: 'متاح من 9 ص – 10 م',
                onTap: () => _copyToClipboard(context, '0542139388'),
                actionLabel: 'نسخ',
              ),
              const SizedBox(height: 12),

              _buildContactCard(
                context: context,
                icon: Icons.phone_outlined,
                iconColor: const Color(0xFF34C759),
                title: 'رقم الهاتف',
                value: '0542139388',
                subtitle: 'أيام العمل من 9 ص – 5 م',
                onTap: () => _copyToClipboard(context, '0542139388'),
                actionLabel: 'نسخ',
              ),
              const SizedBox(height: 28),

              // Section: Social Media
              _buildSectionTitle('تابعنا على وسائل التواصل'),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                children: [
                  _buildSocialTile('سناب شات', Icons.camera, const Color(0xFFFFFC00), Colors.black),
                  _buildSocialTile('انستقرام', Icons.photo_camera_outlined, const Color(0xFFE1306C), Colors.white),
                  _buildSocialTile('تيك توك', Icons.music_note_outlined, Colors.black, Colors.white),
                  _buildSocialTile('تويتر / X', Icons.close, Colors.black, Colors.white),
                  _buildSocialTile('فيسبوك', Icons.facebook, const Color(0xFF1877F2), Colors.white),
                  _buildSocialTile('يوتيوب', Icons.play_circle_outline, const Color(0xFFFF0000), Colors.white),
                ],
              ),
              const SizedBox(height: 28),

              // Section: Working Hours
              _buildSectionTitle('ساعات العمل'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildHoursRow('الأحد – الخميس', '9:00 ص – 10:00 م'),
                    const Divider(height: 20, color: AppColors.border),
                    _buildHoursRow('الجمعة – السبت', '11:00 ص – 6:00 م'),
                    const Divider(height: 20, color: AppColors.border),
                    _buildHoursRow('الدعم الإلكتروني', 'على مدار الساعة'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Quick CTA buttons
              Row(
                children: [
                  Expanded(
                    child: _buildCTAButton(
                      customIcon: const _WhatsAppIcon(size: 20, color: Colors.white),
                      label: 'واتساب',
                      color: const Color(0xFF25D366),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCTAButton(
                      icon: Icons.email_outlined,
                      label: 'إيميل',
                      color: const Color(0xFF4285F4),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
        fontFamily: 'Tajawal',
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    IconData? icon,
    Widget? customIcon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
    required String actionLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: customIcon ?? Icon(icon, color: iconColor, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textGrey,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialTile(String label, IconData icon, Color bg, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: iconColor,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursRow(String label, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textMid,
            fontFamily: 'Tajawal',
          ),
        ),
        Text(
          hours,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButton({
    IconData? icon,
    Widget? customIcon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customIcon ?? Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ "$text"', style: const TextStyle(fontFamily: 'Tajawal')),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _WhatsAppIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _WhatsAppIcon({this.size = 24, this.color = const Color(0xFF25D366)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: CustomPaint(
          size: Size(size, size),
          painter: _WhatsAppPainter(color),
        ),
      ),
    );
  }
}

class _WhatsAppPainter extends CustomPainter {
  final Color color;
  _WhatsAppPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final double w = size.width;
    final double h = size.height;
    
    // Draw bubble
    final bubblePath = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..cubicTo(w * 0.77, h * 0.05, w * 0.95, h * 0.23, w * 0.95, h * 0.5)
      ..cubicTo(w * 0.95, h * 0.77, w * 0.77, h * 0.95, w * 0.5, h * 0.95)
      ..cubicTo(w * 0.41, h * 0.95, w * 0.33, h * 0.92, w * 0.26, h * 0.88)
      ..lineTo(w * 0.05, h * 0.95)
      ..lineTo(w * 0.12, h * 0.74)
      ..cubicTo(w * 0.08, h * 0.67, w * 0.05, h * 0.59, w * 0.05, h * 0.5)
      ..cubicTo(w * 0.05, h * 0.23, w * 0.23, h * 0.05, w * 0.5, h * 0.05)
      ..close();
      
    canvas.drawPath(bubblePath, paint);
    
    // Draw phone receiver in white
    final phonePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    final phonePath = Path()
      ..moveTo(w * 0.38, h * 0.38)
      ..quadraticBezierTo(w * 0.38, h * 0.55, w * 0.48, h * 0.62)
      ..quadraticBezierTo(w * 0.55, h * 0.62, w * 0.62, h * 0.58);
      
    canvas.drawPath(phonePath, phonePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
