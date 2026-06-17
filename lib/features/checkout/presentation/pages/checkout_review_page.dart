import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../data/datasources/mock_checkout_data.dart';
import 'checkout_success_page.dart';

class CheckoutReviewPage extends StatelessWidget {
  const CheckoutReviewPage({super.key});

  void _onOrderNow(BuildContext context) {
    // Navigate to full-screen success page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CheckoutSuccessPage(orderNumber: '#KDX-892401')),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = MockCheckoutDataSource.cartItems;
    final summary = MockCheckoutDataSource.summary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'مراجعة الطلب',
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
            // Breadcrumbs progress indicator
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStep(1, 'العنوان', isActive: false, isCompleted: true),
                  _buildStepDivider(isActive: true),
                  _buildStep(2, 'الدفع', isActive: false, isCompleted: true),
                  _buildStepDivider(isActive: true),
                  _buildStep(3, 'المراجعة', isActive: true, isCompleted: false),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery Section Card
                    _buildSectionHeader('عنوان التوصيل'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'محمد أحمد',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'شارع الملك فهد، حي النخيل، الرياض، المملكة العربية السعودية',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Mode Card
                    _buildSectionHeader('طريقة الدفع'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.credit_card, color: AppColors.primary, size: 22),
                              SizedBox(width: 12),
                              Text(
                                'مدى / بطاقة ائتمان (Visa ···· 5678)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'نشط',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Product listings title
                    _buildSectionHeader('المنتجات في الطلب'),
                    
                    // Product items cards
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  item.imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 70,
                                    height: 70,
                                    color: const Color(0xFFF0F0F0),
                                    child: const Icon(Icons.shopping_bag_outlined, color: AppColors.textGrey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                        fontFamily: 'Tajawal',
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          'المقاس: ${item.size}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontFamily: 'Tajawal'),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'اللون: ${item.color}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontFamily: 'Tajawal'),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'الكمية: ${item.quantity}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontFamily: 'Tajawal'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item.totalPrice.toStringAsFixed(1)} ر.س',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Order Price Breakdown Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('المجموع الفرعي', '${summary.subtotal.toStringAsFixed(2)} ر.س'),
                          const SizedBox(height: 10),
                          _buildSummaryRow('الخصم', '−${summary.discount.toStringAsFixed(2)} ر.س', isDiscount: true),
                          const SizedBox(height: 10),
                          _buildSummaryRow('رسوم الشحن', summary.shippingFee == 0 ? 'مجاني' : '${summary.shippingFee.toStringAsFixed(2)} ر.س', isFreeShipping: summary.shippingFee == 0),
                          const SizedBox(height: 10),
                          _buildSummaryRow('ضريبة القيمة المضافة (15%)', '${summary.tax.toStringAsFixed(2)} ر.س'),
                          const Divider(height: 24, color: AppColors.border),
                          _buildSummaryRow('المجموع الإجمالي', '${summary.total.toStringAsFixed(2)} ر.س', isTotal: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Checkout action bottom panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _onOrderNow(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'اطلب الآن',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 8, right: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value,
      {bool isDiscount = false, bool isFreeShipping = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            color: isTotal ? AppColors.textDark : AppColors.textMid,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500,
            fontFamily: 'Tajawal',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 17 : 13,
            fontWeight: (isTotal || isDiscount || isFreeShipping) ? FontWeight.w900 : FontWeight.bold,
            color: isDiscount
                ? AppColors.accent
                : isFreeShipping
                    ? AppColors.success
                    : AppColors.textDark,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildStep(int number, String label, {required bool isActive, required bool isCompleted}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.primary
                : isActive
                    ? Colors.white
                    : Colors.white,
            border: Border.all(
              color: isCompleted || isActive ? AppColors.primary : const Color(0xFFD1D1D6),
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : Text(
                    number.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.primary : const Color(0xFF8E8E93),
                      fontFamily: 'Tajawal',
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isActive || isCompleted ? AppColors.textDark : const Color(0xFF8E8E93),
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider({required bool isActive}) {
    return Container(
      width: 30,
      height: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isActive ? AppColors.primary : const Color(0xFFD1D1D6),
    );
  }
}
