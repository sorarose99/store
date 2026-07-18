import 'dart:async';
import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../cart/presentation/blocs/cart_bloc.dart';
import '../../../cart/presentation/blocs/cart_event.dart';
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

  /// When [requiresPolling] is true the page polls
  /// `GET /api/orders/{orderNumber}` until `payment_status == 'paid'`
  /// before revealing the success UI.
  ///
  /// Set to `true` for Tabby / Tamara whose backend webhooks arrive
  /// asynchronously after Flutter detects the authorized result.
  /// Set to `false` (default) for PayTabs whose `/callback` is synchronous —
  /// the order is already marked paid before Flutter navigates here.
  final bool requiresPolling;

  const CheckoutSuccessPage({
    super.key,
    required this.orderNumber,
    this.requiresPolling = false,
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

  // ── Payment-status polling state ──────────────────────────────────────────
  bool _isPolling = false;
  bool _pollTimedOut = false;
  Timer? _pollTimer;
  int _pollAttempts = 0;
  static const int _maxPollAttempts = 12;  // 12 × 1.5 s ≈ 18 s
  static const Duration _pollInterval = Duration(milliseconds: 1500);
  // ─────────────────────────────────────────────────────────────────────────

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

    if (widget.requiresPolling) {
      // Start polling before showing confetti — we wait for the webhook.
      setState(() => _isPolling = true);
      _startPolling();
    } else {
      // PayTabs: order is already confirmed server-side. Go straight to success.
      _launchConfetti();
    }
  }

  /// Polls `GET /api/orders/{orderNumber}` every [_pollInterval] up to
  /// [_maxPollAttempts] times waiting for `payment_status == 'paid'`.
  void _startPolling() {
    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      if (!mounted) {
        _pollTimer?.cancel();
        return;
      }

      _pollAttempts++;

      try {
        final response = await di.sl<ApiClient>().get(
          ApiEndpoints.orderDetail(widget.orderNumber),
        );

        final data = response.data;
        final orderMap = data is Map ? (data['order'] ?? data['data'] ?? data) : null;
        final paymentStatus =
            (orderMap is Map ? orderMap['payment_status'] : null) as String?;

        if (paymentStatus == 'paid') {
          _pollTimer?.cancel();
          // Backend webhook has confirmed payment — clear cart and show success.
          if (!mounted) return;
          context.read<CartBloc>().add(const CartCleared());
          setState(() {
            _isPolling = false;
          });
          _launchConfetti();
          return;
        }
      } catch (e) {
        debugPrint('[SuccessPage] Polling error: $e');
      }

      if (_pollAttempts >= _maxPollAttempts) {
        _pollTimer?.cancel();
        if (!mounted) return;
        setState(() {
          _isPolling = false;
          _pollTimedOut = true;
        });
      }
    });
  }

  void _launchConfetti() {
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
    _pollTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Polling: waiting for backend webhook to confirm payment ───────────────
    if (_isPolling) {
      return Directionality(
        textDirection: Directionality.of(context),
        child: Scaffold(
          backgroundColor: context.surfaceColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: context.primaryColor),
                SizedBox(height: 24.h),
                Text(
                  'verifying_payment'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Tajawal',
                    color: context.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'please_wait_a_moment'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'Tajawal',
                    color: context.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Timeout: webhook didn't arrive in time ─────────────────────────────
    if (_pollTimedOut) {
      return Directionality(
        textDirection: Directionality.of(context),
        child: Scaffold(
          backgroundColor: context.surfaceColor,
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hourglass_bottom_rounded,
                    size: 72,
                    color: context.primaryColor,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'payment_processing'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                      color: context.textDark,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'order_number_is'.tr(args: [widget.orderNumber]),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'Tajawal',
                      color: context.textGrey,
                      height: 1.5.h,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const OrdersListPage()),
                          (route) => route.isFirst,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'track_my_order'.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── Success UI (payment confirmed) ─────────────────────────────────────
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
                            'order_number_label'.tr(args: [widget.orderNumber]),
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
