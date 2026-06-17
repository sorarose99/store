import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

/// Renders Apple Pay (black) or Google (white bordered) social auth buttons
/// matching the exact style in the mockup.
class SocialAuthButton extends StatelessWidget {
  final bool isApple;
  final VoidCallback onTap;

  const SocialAuthButton({super.key, required this.isApple, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isApple ? AppColors.appleBlack : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isApple
              ? null
              : Border.all(color: AppColors.border, width: 1),
          boxShadow: isApple
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: isApple ? _appleContent() : _googleContent(),
        ),
      ),
    );
  }

  List<Widget> _appleContent() => [
        const Icon(Icons.apple, color: Colors.white, size: 22),
        const SizedBox(width: 8),
        const Text(
          'Apple',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ];

  List<Widget> _googleContent() => [
        // Inline SVG-style Google "G" drawn with a custom painter
        const _GoogleGLogo(),
        const SizedBox(width: 10),
        const Text(
          'Google',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ];
}

/// Draws the Google "G" multicolor logo inline — no network dependency.
class _GoogleGLogo extends StatelessWidget {
  const _GoogleGLogo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Blue arc (top-right to bottom-right)
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -1.57, 3.14,
      false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.25,
    );

    // Red arc (top)
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -1.57, -1.2,
      false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.25,
    );

    // Yellow arc (bottom)
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      1.57, 1.2,
      false,
      Paint()
        ..color = const Color(0xFFFBBC05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.25,
    );

    // Green arc (bottom-right)
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -0.37, 0.37,
      false,
      Paint()
        ..color = const Color(0xFF34A853)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.25,
    );

    // White horizontal bar (the crossbar of the G)
    canvas.drawRect(
      Rect.fromLTWH(c.dx, c.dy - size.height * 0.12,
          size.width * 0.5, size.height * 0.24),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
