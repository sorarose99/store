import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../data/datasources/mock_checkout_data.dart';
import '../../domain/entities/checkout_entities.dart';
import 'checkout_address_page.dart';
import 'checkout_payment_page.dart';

class CheckoutSavedAddressPage extends StatefulWidget {
  const CheckoutSavedAddressPage({super.key});

  @override
  State<CheckoutSavedAddressPage> createState() => _CheckoutSavedAddressPageState();
}

class _CheckoutSavedAddressPageState extends State<CheckoutSavedAddressPage> {
  late List<SavedAddressEntity> _addresses;
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    _addresses = MockCheckoutDataSource.savedAddresses;
    // Pre-select the default address
    final defaultAddr = _addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first);
    _selectedAddressId = defaultAddr.id;
  }

  void _onAddNewAddress() async {
    // Navigate to full form address page and wait for result
    final newAddress = await Navigator.of(context).push<SavedAddressEntity>(
      MaterialPageRoute(builder: (_) => const CheckoutAddressPage(isFromSavedPage: true)),
    );

    if (newAddress != null) {
      setState(() {
        _addresses = [..._addresses, newAddress];
        _selectedAddressId = newAddress.id;
      });
    }
  }

  void _onContinue() {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار عنوان شحن للمتابعة', style: TextStyle(fontFamily: 'Tajawal'))),
      );
      return;
    }
    // Navigate to Payment Page
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CheckoutPaymentPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            'عنوان الشراء',
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
                  _buildStep(1, 'العنوان', isActive: true, isCompleted: true),
                  _buildStepDivider(isActive: false),
                  _buildStep(2, 'الدفع', isActive: false, isCompleted: false),
                  _buildStepDivider(isActive: false),
                  _buildStep(3, 'المراجعة', isActive: false, isCompleted: false),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content Scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اختر عنوان التوصيل المفضل:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Saved Addresses List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _addresses.length,
                      itemBuilder: (context, index) {
                        final address = _addresses[index];
                        final isSelected = address.id == _selectedAddressId;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedAddressId = address.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryLight : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : const Color(0xFFEEEEEE),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected ? AppColors.tealGlowShadow : AppColors.cardShadow,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Selection circle
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : const Color(0xFFD1D1D6),
                                      width: isSelected ? 6 : 2,
                                    ),
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Address Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            address.recipientName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppColors.textDark,
                                              fontFamily: 'Tajawal',
                                            ),
                                          ),
                                          if (address.isDefault) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'افتراضي',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.textMid,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Tajawal',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        address.fullAddress,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMid,
                                          fontFamily: 'Tajawal',
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'رقم الهاتف: ${address.phone}',
                                        style: const TextStyle(
                                          fontSize: 11,
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
                        );
                      },
                    ),

                    // Add new address button card (Dashed border)
                    GestureDetector(
                      onTap: _onAddNewAddress,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.5),
                            style: BorderStyle.solid, // dashed border simulated using outline/opacity
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'إضافة عنوان جديد',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Continue sticky bottom panel
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
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'متابعة للدفع',
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
