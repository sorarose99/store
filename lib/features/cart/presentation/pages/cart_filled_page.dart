import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/token_service.dart';
import '../blocs/cart_bloc.dart';
import '../blocs/cart_event.dart';
import '../blocs/cart_state.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/bnpl_payment_banners.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/tamara_bottom_sheet.dart';
import '../widgets/tabby_bottom_sheet.dart';
import 'bnpl_promo_page.dart';
import '../../../checkout/presentation/pages/checkout_saved_address_page.dart';
import '../../../checkout/presentation/pages/checkout_region_page.dart';
import '../../../shell/presentation/pages/main_shell.dart' as kdx_shell;

class CartFilledPage extends StatefulWidget {
  const CartFilledPage({super.key});

  @override
  State<CartFilledPage> createState() => _CartFilledPageState();
}

class _CartFilledPageState extends State<CartFilledPage> {
  final TextEditingController _couponController = TextEditingController();

  // Gift State
  Map<String, dynamic>? _giftDetails;

  CartLoaded? get _cartLoadedState {
    final state = context.read<CartBloc>().state;
    if (state is CartLoaded) return state;
    return null;
  }

  List<CartItemEntity> get _cartItems => _cartLoadedState?.items ?? [];
  String? get _appliedCouponCode => _cartLoadedState?.appliedCouponCode;
  double get _couponDiscount => _cartLoadedState?.couponDiscount ?? 0.0;

  double get _subtotal => _cartLoadedState?.subtotal ?? 0.0;
  double get _discount => _couponDiscount;
  double get _giftWrapFee => (_giftDetails?['wrap'] ?? false) ? 15.0 : 0.0;
  double get _shippingFee => _cartLoadedState?.shippingCost ?? 0.0;
  double get _fastDeliveryFee {
    final items = _cartLoadedState?.items ?? [];
    bool hasFastDelivery = items.any((item) => item.options['delivery_type'] == 'fast');
    return hasFastDelivery ? 50.0 : 0.0;
  }
  double get _total => (_subtotal + _giftWrapFee + _shippingFee + _fastDeliveryFee - _discount).clamp(0.0, double.infinity);

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const CartRequested());
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _showTamaraSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TamaraBottomSheet(installmentAmount: (_total / 3)),
    );
  }

  void _showTabbySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TabbyBottomSheet(installmentAmount: (_total / 4)),
    );
  }

  void _showBnplOptions(String provider) {
    final isTabby = provider.toLowerCase() == 'tabby';
    final name = isTabby ? 'تابي' : 'تمارا';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'خيارات الدفع عبر $name',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.info_outline_rounded,
                    color: isTabby
                        ? const Color(0xFF1BE39A)
                        : const Color(0xFFFFA670)),
                title: const Text(
                  'كيف يعمل الدفع بالتقسيط؟ (نافذة سريعة)',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal'),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  if (isTabby) {
                    _showTabbySheet();
                  } else {
                    _showTamaraSheet();
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.explore_outlined,
                    color: isTabby
                        ? const Color(0xFF1BE39A)
                        : const Color(0xFFFFA670)),
                title: Text(
                  'عرض دليل الخدمة الكامل ($name)',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal'),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BnplPromoPage(provider: provider),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _increaseQuantity(CartItemEntity item, String? sizeName) {
    if (sizeName == null) {
      final newQty = item.quantity + 1;
      // If there's a single-entry breakdown, scale its qty to match the new total.
      // This keeps checkout validation happy (breakdown total must == item quantity).
      List<Map<String, dynamic>> newBreakdown = item.breakdown;
      if (item.breakdown.length == 1) {
        newBreakdown = [{
          ...item.breakdown.first,
          'qty': newQty,
        }];
      } else if (item.breakdown.isEmpty) {
        newBreakdown = [{
          'size_name': 'مقاس واحد',
          'qty': newQty,
        }];
      }
      context.read<CartBloc>().add(CartItemUpdated(
            productId: item.id,
            quantity: newQty,
            breakdown: newBreakdown,
          ));
    } else {
      final newBreakdown = item.breakdown.map((b) {
        final map = Map<String, dynamic>.from(b);
        if (map['size_name'] == sizeName) {
          map['qty'] = (map['qty'] as int) + 1;
        }
        return map;
      }).toList();
      context.read<CartBloc>().add(CartItemUpdated(
            productId: item.id,
            quantity: item.quantity + 1,
            breakdown: newBreakdown,
          ));
    }
  }

  void _decreaseQuantity(CartItemEntity item, String? sizeName) {
    if (sizeName == null) {
      if (item.quantity <= 1) return;
      final newQty = item.quantity - 1;
      // If there's a single-entry breakdown, scale its qty to match the new total.
      List<Map<String, dynamic>> newBreakdown = item.breakdown;
      if (item.breakdown.length == 1) {
        newBreakdown = [{
          ...item.breakdown.first,
          'qty': newQty,
        }];
      } else if (item.breakdown.isEmpty) {
        newBreakdown = [{
          'size_name': 'مقاس واحد',
          'qty': newQty,
        }];
      }
      context.read<CartBloc>().add(CartItemUpdated(
            productId: item.id,
            quantity: newQty,
            breakdown: newBreakdown,
          ));
    } else {
      final newBreakdown = item.breakdown.map((b) {
        final map = Map<String, dynamic>.from(b);
        if (map['size_name'] == sizeName) {
          map['qty'] = (map['qty'] as int) - 1;
        }
        return map;
      }).where((element) => (element['qty'] as int) > 0).toList();
      context.read<CartBloc>().add(CartItemUpdated(
            productId: item.id,
            quantity: item.quantity - 1,
            breakdown: newBreakdown,
          ));
    }
  }

  void _deleteItem(String cartItemId) {
    context.read<CartBloc>().add(CartItemRemoved(productId: cartItemId));
  }

  void _applyCoupon() {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    FocusScope.of(context).unfocus();
    context.read<CartBloc>().add(CartCouponApplied(code: code));
  }

  void _removeCoupon() {
    context.read<CartBloc>().add(const CartCouponRemoved());
    _couponController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تمت إزالة كوبون الخصم',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartLoaded) {
          if (state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.actionError!.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state.actionSuccess != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.actionSuccess!.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
                ),
                backgroundColor: const Color(0xFF1BE39A),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is CartLoading) {
          return Scaffold(
            backgroundColor: context.surfaceColor,
            body: Center(
              child: CircularProgressIndicator(color: context.primaryColor),
            ),
          );
        }
        if (state is CartError) {
          final isUnauthorized = state.message.contains('تسجيل') || 
                              state.message.contains('الجلسة') ||
                              state.message.contains('Unauthorized') ||
                              state.message.contains('401');
          if (isUnauthorized) {
            return Scaffold(
              backgroundColor: context.surfaceColor,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 80, color: context.primaryColor),
                      const SizedBox(height: 24),
                      Text(
                        'يرجى تسجيل الدخول لعرض السلة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textDark,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'قم بتسجيل الدخول لتتمكن من إضافة المنتجات وعرض سلة التسوق الخاصة بك',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textGrey,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () async {
                          final tokenService = di.sl<TokenService>();
                          await tokenService.clearAll();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: context.surfaceColor,
            body: Center(
              child: Text(
                state.message,
                style: TextStyle(fontFamily: 'Tajawal', color: context.textDark),
              ),
            ),
          );
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: context.surfaceColor,
            appBar: AppBar(
              backgroundColor: context.surfaceColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: context.textDark, size: 20),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              centerTitle: true,
              title: Text(
                'cart'.tr(),
                style: TextStyle(
                  color: context.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            body: _cartItems.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Item count summary header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_cartItems.length} ${'item_in_cart'.tr()}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: context.textGrey,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (dialogContext) => Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: AlertDialog(
                                            title: const Text('تفريغ السلة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold)),
                                            content: const Text('هل أنت متأكد من رغبتك في حذف جميع المنتجات من السلة؟', style: TextStyle(fontFamily: 'Tajawal')),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(dialogContext).pop(),
                                                child: Text('إلغاء', style: TextStyle(color: context.textGrey, fontFamily: 'Tajawal')),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(dialogContext).pop();
                                                  context.read<CartBloc>().add(const CartCleared());
                                                },
                                                child: Text('تفريغ', style: TextStyle(color: context.errorColor, fontFamily: 'Tajawal', fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.delete_sweep_outlined, size: 18, color: context.errorColor),
                                    label: Text(
                                      'حذف الكل',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: context.errorColor,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Cart Items List
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = _cartItems[index];
                                  return Dismissible(
                                    key: Key('cart_item_${item.id}_$index'),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      margin: EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.error,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.delete_outline, color: Colors.white),
                                    ),
                                    onDismissed: (_) => _deleteItem(item.id),
                                    child: CartItemCard(
                                      item: item,
                                      onQuantityIncrease: (sizeName) =>
                                          _increaseQuantity(item, sizeName),
                                      onQuantityDecrease: (sizeName) =>
                                          _decreaseQuantity(item, sizeName),
                                      onDelete: () => _deleteItem(item.id),
                                      onShare: () {},
                                    ),
                                  );
                                },
                              ),
                          const SizedBox(height: 16),

                          // Coupon input header
                          Text(
                            'كوبون الخصم',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: context.textDark,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Coupon Section
                          _appliedCouponCode == null
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: context.cardBackground,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: context.borderColor,
                                              width: 0.5),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        alignment: Alignment.centerRight,
                                        child: TextField(
                                          controller: _couponController,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: context.textDark,
                                            fontFamily: 'Tajawal',
                                          ),
                                          decoration:  InputDecoration(
                                            hintText: 'أدخل كوبون الخصم',
                                            hintStyle: TextStyle(
                                                fontSize: 12,
                                                color: context.textGrey,
                                                fontFamily: 'Tajawal'),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      height: 44,
                                      width: 90,
                                      child: ElevatedButton(
                                        onPressed: _applyCoupon,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: context.primaryColor,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'تطبيق',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: context.surfaceColor,
                                            fontSize: 13,
                                            fontFamily: 'Tajawal',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                        0xFFE8FAF4), // Light mint green
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: context.primaryLight,
                                        width: 0.8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle_rounded,
                                          color: context.primaryColor, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'كوبون الخصم فعال: $_appliedCouponCode',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                color: context.textDark,
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                            Text(
                                              'لقد وفرت ${_couponDiscount.toStringAsFixed(1)} ﷼',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: context.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.cancel_outlined,
                                            color: context.textGrey,
                                            size: 20),
                                        onPressed: _removeCoupon,
                                      ),
                                    ],
                                  ),
                                ),
                          const SizedBox(height: 16),

                          /* 
// Send as gift option
                          _giftDetails == null
                              ? Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: context.surfaceColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: context.textDark, width: 1),
                                  ),
                                  child: OutlinedButton(
                                    onPressed: _navigateToGiftPage,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide.none,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: const [
                                        Text(
                                          'أرسلها كهدية',
                                          style: TextStyle(
                                            color: context.textDark,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            fontFamily: 'Tajawal',
                                          ),
                                        ),
                                        Icon(Icons.edit_note_rounded, color: context.textDark, size: 20),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: context.surfaceColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: context.primaryLight, width: 1.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.card_giftcard_rounded, color: context.primaryColor, size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            'الطلب مجهز كهدية 🎁',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: context.textDark,
                                              fontFamily: 'Tajawal',
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton(
                                            onPressed: _navigateToGiftPage,
                                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                            child: Text(
                                              'تعديل',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: context.primaryColor,
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          TextButton(
                                            onPressed: () => setState(() => _giftDetails = null),
                                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                            child: const Text(
                                              'حذف',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 18),
                                      Text(
                                        'المستلم: ${_giftDetails!['recipientName']}',
                                        style: TextStyle(fontSize: 12, color: context.textDark, fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'رقم الجوال: ${_giftDetails!['recipientPhone']}',
                                        style: TextStyle(fontSize: 11, color: context.textGrey, fontFamily: 'Tajawal'),
                                      ),
                                      if (_giftDetails!['message'].isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          'الرسالة: "${_giftDetails!['message']}"',
                                          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: context.textDark, fontFamily: 'Tajawal'),
                                        ),
                                      ],
                                      if (_giftDetails!['wrap']) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'مع تغليف هدية فاخر (+15.0 ﷼)',
                                            style: TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                          const SizedBox(height: 24),

                          */
// Price breakdowns
                          _buildSummaryRow('subtotal'.tr(),
                              '${_subtotal.toStringAsFixed(1)} ﷼'),
                          if (_couponDiscount > 0) ...[
                            const SizedBox(height: 10),
                            _buildSummaryRow(
                              'coupon_discount_applied'
                                  .tr(args: [_appliedCouponCode ?? '']),
                              '−${_couponDiscount.toStringAsFixed(1)} ﷼',
                              isDiscount: true,
                            ),
                          ],
                          if (_giftWrapFee > 0) ...[
                            const SizedBox(height: 10),
                            _buildSummaryRow('gift_wrap'.tr(), '+15.0 ﷼'),
                          ],
                          if (_fastDeliveryFee > 0) ...[
                            const SizedBox(height: 10),
                            _buildSummaryRow('fast_shipping'.tr(), '+50.0 ﷼'),
                          ],
                          const SizedBox(height: 10),

                          // Distinct Grand Total row in order summary
                          const Divider(
                              color: AppColors.border,
                              height: 32,
                              thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'المجموع الإجمالي',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: context.textDark,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              Text(
                                '${_total.toStringAsFixed(1)} ﷼',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: context.primaryColor,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                              color: AppColors.border,
                              height: 32,
                              thickness: 1),

                          // Split installment payment banners (Stacked Tamara & Tabby)
                          _buildTamaraBanner(),
                          const SizedBox(height: 10),
                          _buildTabbyBanner(),
                          const SizedBox(height: 24),

                          // Trust banner "تسوق بأمان واستدامة"
                          Text(
                            'تسوق بأمان واستدامة',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: context.textDark,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTrustGrid(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  _buildStickyBottomBar(),
                ],
              ),
            ),
          );
        },
      );
    }

  Widget _buildTamaraBanner() {
    return TamaraBanner(
      totalAmount: _total,
      onTap: () => _showBnplOptions('tamara'),
    );
  }

  Widget _buildTabbyBanner() {
    return TabbyBanner(
      totalAmount: _total,
      onTap: () => _showBnplOptions('tabby'),
    );
  }

  // ── Task 3: Dual Shipping Model Picker ──────────────────────────────────────

  Widget _buildSummaryRow(String title, String value,
      {bool isDiscount = false, bool isFreeShipping = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (isDiscount) ...[
              Icon(Icons.local_offer_outlined,
                  color: context.primaryColor, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                color: context.textDark,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: isDiscount
                ? context.errorColor
                : isFreeShipping
                    ? context.primaryColor
                    : context.textDark,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildTrustGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildTrustBox(Icons.local_shipping_outlined, 'ضمان التوصيل الآمن'),
        _buildTrustBox(Icons.shield_outlined, 'ضمان أمان الدفع'),
        _buildTrustBox(Icons.lock_outline, 'الأمان والخصوصية'),
        _buildTrustBox(Icons.headset_mic_outlined, 'دعم العملاء'),
      ],
    );
  }

  Widget _buildTrustBox(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderColor, width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: context.textDark),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: context.textDark,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar() {
    // If there is any out-of-stock items, we disable purchase
    final hasUnavailable = _cartItems.any((item) => !item.isAvailable);
    final unavailableCount = _cartItems.where((item) => !item.isAvailable).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Out-of-stock warning banner
            if (hasUnavailable) ...[              
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: context.errorColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.errorColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: context.errorColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        unavailableCount == 1
                            ? 'يوجد منتج غير متوفر. أزله لإتمام الطلب.'
                            : 'يوجد $unavailableCount منتجات غير متوفرة. أزلها لإتمام الطلب.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: context.errorColor,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Faint subtotal + shipping summary
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المجموع الفرعي: ${_subtotal.toStringAsFixed(1)} ﷼',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.textGrey,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  if (_shippingFee > 0)
                    Text(
                      'شحن: ${_shippingFee.toStringAsFixed(1)} ﷼',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textGrey,
                        fontFamily: 'Tajawal',
                      ),
                    )
                  else
                    Text(
                      'شحن مجاني',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Total + Checkout row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المجموع الإجمالي',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textGrey,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_total.toStringAsFixed(1)} ﷼',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: context.textDark,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 44,
                  width: 150,
                  child: ElevatedButton(
                    onPressed: hasUnavailable
                        ? null
                        : () {
                            // Only validate breakdown distribution when an item has
                            // multiple size options AND user hasn't assigned quantities.
                            // Single-size products (watches, accessories, etc.) skip this.
                            for (final item in _cartItems) {
                              if (item.productSizes.length > 1 && item.breakdown.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('يرجى توزيع الكميات على المقاسات لمنتج ${item.name}', style: const TextStyle(fontFamily: 'Tajawal')),
                                    backgroundColor: context.errorColor,
                                  ),
                                );
                                return;
                              }
                            }

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const CheckoutRegionPage()),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      disabledBackgroundColor: context.textGreyLight,
                    ),
                    child: Text(
                      'إتمام الدفع',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.surfaceColor,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: context.cardBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_bag_outlined,
                  color: context.primaryColor, size: 52),
            ),
            const SizedBox(height: 28),
            Text(
              'سلتك فارغة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: context.textDark,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'ابدأ التسوق وأضف منتجاتك المفضلة إلى السلة!',
              style: TextStyle(
                fontSize: 13,
                color: context.textGrey,
                fontFamily: 'Tajawal',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Pop all the way back to the root (shell/home)
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const kdx_shell.MainShell(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.explore_outlined, size: 20),
                label: Text(
                  'تصفح المنتجات',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.surfaceColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'رجوع',
                style: TextStyle(
                  fontSize: 13,
                  color: context.textGrey,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
