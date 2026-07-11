import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../orders/presentation/pages/orders_list_page.dart';

class ConfettiParticle {
  final Color color;
  final double speedX;
  final double speedY;
  final double spin;
  double x;
  double y;
  double rotation = 0;

  ConfettiParticle({
    required this.color,
    required this.speedX,
    required this.speedY,
    required this.spin,
    required this.x,
    required this.y,
  });

  void update() {
    x += speedX;
    y += speedY;
    rotation += spin;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      paint.color = particle.color;
      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);
      
      // Draw a tiny rect/chip
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 8.w, height: 6.h),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CheckoutSuccessPage extends StatefulWidget {
  final String orderNumber;

  const CheckoutSuccessPage({
    super.key,
    required this.orderNumber,
  });

  @override
  State<CheckoutSuccessPage> createState() => _CheckoutSuccessPageState();
}

class _CheckoutSuccessPageState extends State<CheckoutSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<ConfettiParticle> _particles = [];
  final List<Color> _colors = [
    const Color(0xFF43C1CD),
    const Color(0xFFFF6B6B),
    const Color(0xFF00C48C),
    const Color(0xFFFFD166),
    const Color(0xFF118AB2),
    const Color(0xFF073B4C),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        for (final p in _particles) {
          p.update();
        }
        setState(() {});
      });

    // Generate particles
    final random = math.Random();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 80; i++) {
        _particles.add(
          ConfettiParticle(
            color: _colors[random.nextInt(_colors.length)],
            speedX: (random.nextDouble() - 0.5) * 5,
            speedY: random.nextDouble() * 4 + 2.5,
            spin: (random.nextDouble() - 0.5) * 0.15,
            x: random.nextDouble() * size.width,
            y: -random.nextDouble() * 200,
          ),
        );
      }
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: context.surfaceColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Teal Gradient Header with success background
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [context.primaryColor, context.primaryDark],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Green circle check icon
                        Container(
                          width: 90.w,
                          height: 90.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: context.primaryColor,
                              size: 72,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        Text(
                          'payment_completed_successfully'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        SizedBox(height: 8.h),

                        Text(
                          'thank_you_for_shopping'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xEFFFFFFF), // White color with high opacity
                            fontSize: 13.sp,
                            fontFamily: 'Tajawal',
                            height: 1.4.h,
                          ),
                        ),
                        SizedBox(height: 18.h),

                        // Order number chip
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'رقم الطلب: ${widget.orderNumber}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Middle Illustration or Summary
                  Padding(
                    padding: EdgeInsets.all(24.0.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 96,
                          color: context.textGrey.withValues(alpha: 0.3),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'easily_track_the_status'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textDark,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'we_will_send_you'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: context.textGrey,
                            fontFamily: 'Tajawal',
                            height: 1.5.h,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: EdgeInsets.all(24.0.w),
                    child: Column(
                      children: [
                        // Order history button ('my_orders'.tr())
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to OrdersListPage
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const OrdersListPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(
                              'my_orders_order_tracking'.tr(),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Continue Shopping button
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: OutlinedButton(
                            onPressed: () {
                              // Pop all the way back to main shell
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: context.primaryColor, width: 1.5.w),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(
                              'continue_shopping_1'.tr(),
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.primaryColor,
                                  fontFamily: 'Tajawal'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                painter: ConfettiPainter(particles: _particles),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
