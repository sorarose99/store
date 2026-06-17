import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/tamara_bottom_sheet.dart';
import '../widgets/tabby_bottom_sheet.dart';
import '../widgets/coupon_confirmation_sheet.dart';
import 'send_gift_page.dart';
import 'bnpl_promo_page.dart';
import '../../../checkout/presentation/pages/checkout_address_page.dart';

class CartFilledPage extends StatefulWidget {
  const CartFilledPage({super.key});

  @override
  State<CartFilledPage> createState() => _CartFilledPageState();
}

class _CartFilledPageState extends State<CartFilledPage> {
  late List<CartItemEntity> _cartItems;
  final TextEditingController _couponController = TextEditingController();
  
  // Coupon State
  String? _appliedCouponCode;
  double _couponDiscount = 0.0;

  // Gift State
  Map<String, dynamic>? _giftDetails;

  // Shipping State
  int _selectedShippingModel = 0; // 0 = Standard, 1 = Express
  static const List<Map<String, dynamic>> _shippingModels = [
    {
      'title': 'شحن عادي',
      'subtitle': 'خلال 4–8 أيام عمل',
      'fee': 0.0,
      'feeLabel': 'مجاني',
      'icon': Icons.local_shipping_outlined,
      'color': 0xFF34C759,
      'carrier': 'KDX ستاندرد',
    },
    {
      'title': 'شحن سريع',
      'subtitle': 'خلال 24–48 ساعة',
      'fee': 25.0,
      'feeLabel': '25.0 ر.س',
      'icon': Icons.rocket_launch_outlined,
      'color': 0xFF007AFF,
      'carrier': 'KDX إكسبريس',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cartItems = [
      const CartItemEntity(
        id: '1',
        productId: 'p1',
        name: 'جاكيت رجالي',
        size: 'M',
        color: 'أسود',
        price: 26.8,
        quantity: 1,
        imageUrl: 'assets/images/cat_fashion.png',
        isAvailable: true,
      ),
      const CartItemEntity(
        id: '2',
        productId: 'p2',
        name: 'جاكيت رجالي',
        size: 'M',
        color: 'أسود',
        price: 26.8,
        quantity: 1,
        imageUrl: 'assets/images/cat_fashion.png',
        isAvailable: false,
      ),
    ];
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'خيارات الدفع عبر $name',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.info_outline_rounded, color: isTabby ? const Color(0xFF1BE39A) : const Color(0xFFFFA670)),
                title: const Text(
                  'كيف يعمل الدفع بالتقسيط؟ (نافذة سريعة)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
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
                leading: Icon(Icons.explore_outlined, color: isTabby ? const Color(0xFF1BE39A) : const Color(0xFFFFA670)),
                title: Text(
                  'عرض دليل الخدمة الكامل ($name)',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
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

  double get _subtotal {
    return _cartItems
        .where((item) => item.isAvailable)
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get _discount {
    return _couponDiscount;
  }

  double get _giftWrapFee {
    return (_giftDetails?['wrap'] ?? false) ? 15.0 : 0.0;
  }

  double get _shippingFee {
    return (_shippingModels[_selectedShippingModel]['fee'] as double);
  }

  double get _total {
    return (_subtotal + _giftWrapFee + _shippingFee - _discount).clamp(0.0, double.infinity);
  }

  void _increaseQuantity(int index) {
    setState(() {
      final item = _cartItems[index];
      _cartItems[index] = CartItemEntity(
        id: item.id,
        productId: item.productId,
        name: item.name,
        size: item.size,
        color: item.color,
        price: item.price,
        quantity: item.quantity + 1,
        imageUrl: item.imageUrl,
        isAvailable: item.isAvailable,
      );
    });
  }

  void _decreaseQuantity(int index) {
    if (_cartItems[index].quantity <= 1) return;
    setState(() {
      final item = _cartItems[index];
      _cartItems[index] = CartItemEntity(
        id: item.id,
        productId: item.productId,
        name: item.name,
        size: item.size,
        color: item.color,
        price: item.price,
        quantity: item.quantity - 1,
        imageUrl: item.imageUrl,
        isAvailable: item.isAvailable,
      );
    });
  }

  void _deleteItem(String id) {
    setState(() {
      _cartItems.removeWhere((item) => item.id == id);
    });
  }

  void _applyCoupon() {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    // Standard 10% discount dynamic calculation
    final calculatedDiscount = _subtotal * 0.10;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CouponConfirmationSheet(
        couponCode: code,
        discountAmount: calculatedDiscount,
        onAccept: () {
          setState(() {
            _appliedCouponCode = code;
            _couponDiscount = calculatedDiscount;
          });
        },
        onCancel: () {
          setState(() {
            _couponController.clear();
            _appliedCouponCode = null;
            _couponDiscount = 0.0;
          });
        },
      ),
    );
  }

  void _removeCoupon() {
    setState(() {
      _couponController.clear();
      _appliedCouponCode = null;
      _couponDiscount = 0.0;
    });
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

  Future<void> _navigateToGiftPage() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => SendGiftPage(initialGiftDetails: _giftDetails),
      ),
    );
    if (result != null) {
      setState(() {
        _giftDetails = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          centerTitle: true,
          title: const Text(
            'السلة',
            style: TextStyle(
              color: AppColors.textDark,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Cart Items List
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              return CartItemCard(
                                item: item,
                                onQuantityIncrease: () => _increaseQuantity(index),
                                onQuantityDecrease: () => _decreaseQuantity(index),
                                onDelete: () => _deleteItem(item.id),
                                onShare: () {},
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Coupon input header
                          const Text(
                            'كوبون الخصم',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
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
                                          color: const Color(0xFFF2F3F8),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        alignment: Alignment.centerRight,
                                        child: TextField(
                                          controller: _couponController,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textDark,
                                            fontFamily: 'Tajawal',
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: 'أدخل كوبون الخصم',
                                            hintStyle: TextStyle(fontSize: 12, color: AppColors.textGrey, fontFamily: 'Tajawal'),
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
                                          backgroundColor: AppColors.primary,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'تطبيق',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontFamily: 'Tajawal',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8FAF4), // Light mint green
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFB2DFDB), width: 0.8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'كوبون الخصم فعال: $_appliedCouponCode',
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textDark,
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                            Text(
                                              'لقد وفرت ${_couponDiscount.toStringAsFixed(1)} ر.س',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel_outlined, color: AppColors.textGrey, size: 20),
                                        onPressed: _removeCoupon,
                                      ),
                                    ],
                                  ),
                                ),
                          const SizedBox(height: 16),
                          
                          // Send as gift option
                          _giftDetails == null
                              ? Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.textDark, width: 1),
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
                                            color: AppColors.textDark,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            fontFamily: 'Tajawal',
                                          ),
                                        ),
                                        Icon(Icons.edit_note_rounded, color: AppColors.textDark, size: 20),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFB2DFDB), width: 1.2),
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
                                          const Icon(Icons.card_giftcard_rounded, color: AppColors.primary, size: 18),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'الطلب مجهز كهدية 🎁',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textDark,
                                              fontFamily: 'Tajawal',
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton(
                                            onPressed: _navigateToGiftPage,
                                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                            child: const Text(
                                              'تعديل',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
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
                                        style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'رقم الجوال: ${_giftDetails!['recipientPhone']}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontFamily: 'Tajawal'),
                                      ),
                                      if (_giftDetails!['message'].isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          'الرسالة: "${_giftDetails!['message']}"',
                                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textDark, fontFamily: 'Tajawal'),
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
                                            'مع تغليف هدية فاخر (+15.0 ر.س)',
                                            style: TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                          const SizedBox(height: 24),

                          // Price breakdowns
                          _buildSummaryRow('المجموع الفرعي', '${_subtotal.toStringAsFixed(1)} ر.س'),
                          if (_couponDiscount > 0) ...[
                            const SizedBox(height: 10),
                            _buildSummaryRow(
                              'تخفيض الكوبون ($_appliedCouponCode)',
                              '−${_couponDiscount.toStringAsFixed(1)} ر.س',
                              isDiscount: true,
                            ),
                          ],
                          if (_giftWrapFee > 0) ...[
                            const SizedBox(height: 10),
                            _buildSummaryRow('تغليف الهدية', '+15.0 ر.س'),
                          ],
                          const SizedBox(height: 10),
                          // ── Dual Shipping Model Picker (Task 3) ─────────────
                          _buildShippingModelPicker(),
                          const SizedBox(height: 10),
                          
                          // Distinct Grand Total row in order summary
                          const Divider(color: AppColors.border, height: 32, thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'المجموع الإجمالي',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              Text(
                                '${_total.toStringAsFixed(1)} ر.س',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.border, height: 32, thickness: 1),
                          
                          // Split installment payment banners (Stacked Tamara & Tabby)
                          _buildTamaraBanner(),
                          const SizedBox(height: 10),
                          _buildTabbyBanner(),
                          const SizedBox(height: 24),

                          // Trust banner "تسوق بأمان واستدامة"
                          const Text(
                            'تسوق بأمان واستدامة',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
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
                  
                  // Sticky bottom bar
                  _buildStickyBottomBar(),
                ],
              ),
      ),
    );
  }

  Widget _buildTamaraBanner() {
    return GestureDetector(
      onTap: () => _showBnplOptions('tamara'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFE0CC), width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFA670),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'T',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'قسم فاتورتك على 3 دفعات بقيمة ${(_total / 3).toStringAsFixed(2)} SAR بدون فوائد. عرض المزيد',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios, size: 12, color: AppColors.textGrey, textDirection: TextDirection.ltr),
          ],
        ),
      ),
    );
  }

  Widget _buildTabbyBanner() {
    return GestureDetector(
      onTap: () => _showBnplOptions('tabby'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8FAF4), // Light mint green
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFB2DFDB), width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1BE39A), // Tabby green
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      't',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'قسم فاتورتك على 4 دفعات بقيمة ${(_total / 4).toStringAsFixed(2)} SAR بدون فوائد. عرض المزيد',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios, size: 12, color: AppColors.textGrey, textDirection: TextDirection.ltr),
          ],
        ),
      ),
    );
  }

  // ── Task 3: Dual Shipping Model Picker ──────────────────────────────────────
  Widget _buildShippingModelPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'وسيلة الشحن',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: 'Tajawal',
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(_shippingModels.length, (index) {
            final model = _shippingModels[index];
            final isSelected = _selectedShippingModel == index;
            final brandColor = Color(model['color'] as int);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedShippingModel = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: EdgeInsets.only(left: index == 0 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? brandColor.withValues(alpha: 0.07)
                        : const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? brandColor : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: brandColor.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            model['icon'] as IconData,
                            color: isSelected ? brandColor : AppColors.textGrey,
                            size: 20,
                          ),
                          const Spacer(),
                          if (isSelected)
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: brandColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 11,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        model['title'] as String,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? AppColors.textDark : AppColors.textMid,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        model['subtitle'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textGrey,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: brandColor.withValues(alpha: isSelected ? 0.12 : 0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          model['feeLabel'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: brandColor,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String title, String value,
      {bool isDiscount = false, bool isFreeShipping = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (isDiscount) ...[
              const Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textDark,
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
                ? const Color(0xFFE53935)
                : isFreeShipping
                    ? AppColors.primary
                    : AppColors.textDark,
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
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFECEEF5), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.textDark),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المجموع الإجمالي',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_total.toStringAsFixed(1)} ر.س',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
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
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CheckoutAddressPage()),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  disabledBackgroundColor: const Color(0xFFC7C7D9),
                ),
                child: const Text(
                  'إتمام الدفع',
                  style: TextStyle(
                    fontSize: 14,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F3F8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: AppColors.textGrey, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'سلتك فارغة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'أضف منتجات إلى السلة لبدء التسوق!',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'اذهب للتسوق',
                  style: TextStyle(
                    fontSize: 13,
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
    );
  }
}
