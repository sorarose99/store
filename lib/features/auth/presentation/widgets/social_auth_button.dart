import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';

/// Renders Apple Pay (black) or Google (white bordered) social auth buttons
/// matching the exact style in the mockup.
class SocialAuthButton extends StatelessWidget {
  final bool isApple;
  final VoidCallback onTap;

  const SocialAuthButton(
      {super.key, required this.isApple, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isApple ? context.primaryColor : context.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border:
              isApple ? null : Border.all(color: context.border, width: 1.w),
          boxShadow: isApple
              ? null
              : [
                  BoxShadow(
                    color: context.textDark.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: isApple ? _appleContent(context) : _googleContent(context),
        ),
      ),
    );
  }

  List<Widget> _appleContent(BuildContext context) => [
        Icon(Icons.apple, color: context.backgroundColor, size: 22),
        SizedBox(width: 8.w),
        Text(
          'Apple',
          style: TextStyle(
            color: context.backgroundColor,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ];

  List<Widget> _googleContent(BuildContext context) => [
        // Inline SVG-style Google "G" drawn with a custom painter
        _GoogleGLogo(context),
        SizedBox(width: 10.w),
        Text(
          'Google',
          style: TextStyle(
            color: context.textDark,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ];
}

/// Draws the Google "G" multicolor logo inline — no network dependency.
class _GoogleGLogo extends StatelessWidget {
  final BuildContext parentContext;
  const _GoogleGLogo(this.parentContext);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _GoogleLogoPainter(parentContext),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  final BuildContext context;
  _GoogleLogoPainter(this.context);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Blue arc (top-right to bottom-right)
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -1.57,
      3.14,
      false,
      Paint()
        ..color = context.primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.25,
    );

    // Red arc (top)
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -1.57,
      -1.2,
      false,
      Paint()
        ..color = context.primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.25,
    );

    // Yellow arc (bottom)
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      1.57,
      1.2,
      false,
      Paint()
        ..color = context.primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.25,
    );

    // Green arc (bottom-right)
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -0.37,
      0.37,
      false,
      Paint()
        ..color = context.primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.25,
    );

    // White horizontal bar (the crossbar of the G)
    canvas.drawRect(
      Rect.fromLTWH(c.dx, c.dy - size.height * 0.12, size.width * 0.5,
          size.height * 0.24),
      Paint()..color = context.primaryColor,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
