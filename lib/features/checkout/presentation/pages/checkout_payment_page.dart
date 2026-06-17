import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'checkout_review_page.dart';

// ── 7 Payment Methods as required ──────────────────────────────────────────
enum PaymentMethod { applePay, mada, visa, maestro, mastercard, tamara, tabby }

extension PaymentMethodExt on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.applePay:    return 'Apple Pay';
      case PaymentMethod.mada:        return 'بطاقة مدى';
      case PaymentMethod.visa:        return 'Visa';
      case PaymentMethod.maestro:     return 'Maestro';
      case PaymentMethod.mastercard:  return 'MasterCard';
      case PaymentMethod.tamara:      return 'تمارا';
      case PaymentMethod.tabby:       return 'تابي';
    }
  }

  String get badgeText {
    switch (this) {
      case PaymentMethod.applePay:    return ' Pay';
      case PaymentMethod.mada:        return 'mada';
      case PaymentMethod.visa:        return 'VISA';
      case PaymentMethod.maestro:     return 'Maestro';
      case PaymentMethod.mastercard:  return 'MC';
      case PaymentMethod.tamara:      return 'tamara';
      case PaymentMethod.tabby:       return 'tabby';
    }
  }

  Color get badgeBg {
    switch (this) {
      case PaymentMethod.applePay:    return Colors.black;
      case PaymentMethod.mada:        return const Color(0xFF0070B8);
      case PaymentMethod.visa:        return const Color(0xFF1A1F71);
      case PaymentMethod.maestro:     return const Color(0xFF0099DF);
      case PaymentMethod.mastercard:  return const Color(0xFFEB001B);
      case PaymentMethod.tamara:      return const Color(0xFFFF6E26);
      case PaymentMethod.tabby:       return const Color(0xFF3DF2B6);
    }
  }

  Color get badgeFg {
    switch (this) {
      case PaymentMethod.tabby: return Colors.black;
      default: return Colors.white;
    }
  }

  bool get isBNPL => this == PaymentMethod.tamara || this == PaymentMethod.tabby;
  bool get needsCardForm => this == PaymentMethod.visa || this == PaymentMethod.maestro || this == PaymentMethod.mastercard || this == PaymentMethod.mada;
}

class CheckoutPaymentPage extends StatefulWidget {
  const CheckoutPaymentPage({super.key});

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardNameController = TextEditingController();

  PaymentMethod _selectedMethod = PaymentMethod.applePay;
  bool _saveCard = true;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_selectedMethod.needsCardForm) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CheckoutReviewPage()),
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
            'طريقة الدفع',
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
            // Breadcrumb steps
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStep(1, 'العنوان', isActive: false, isCompleted: true),
                  _buildStepDivider(isActive: true),
                  _buildStep(2, 'الدفع', isActive: true, isCompleted: false),
                  _buildStepDivider(isActive: false),
                  _buildStep(3, 'المراجعة', isActive: false, isCompleted: false),
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
                    // ── Payment Methods List ─────────────────────────────────
                    ...PaymentMethod.values.map((method) => _buildMethodRow(method)),

                    // ── Card form (shown for card-type methods) ──────────────
                    if (_selectedMethod.needsCardForm) ...[
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('الاسم على البطاقة'),
                              _buildTextField(
                                controller: _cardNameController,
                                hintText: 'مثال: محمد أحمد',
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال الاسم' : null,
                              ),
                              const SizedBox(height: 12),
                              _buildLabel('رقم البطاقة'),
                              _buildTextField(
                                controller: _cardNumberController,
                                hintText: '0000 0000 0000 0000',
                                keyboardType: TextInputType.number,
                                suffixIcon: const Icon(Icons.credit_card_rounded, color: AppColors.textGrey),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'الرجاء إدخال رقم البطاقة';
                                  if (v.replaceAll(' ', '').length < 16) return 'رقم البطاقة غير مكتمل';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('تاريخ الانتهاء'),
                                        _buildTextField(
                                          controller: _expiryController,
                                          hintText: 'MM/YY',
                                          keyboardType: TextInputType.number,
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) return 'مطلوب';
                                            if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$').hasMatch(v)) return 'صيغة غير صحيحة';
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('الرمز السري (CVV)'),
                                        _buildTextField(
                                          controller: _cvvController,
                                          hintText: '123',
                                          keyboardType: TextInputType.number,
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) return 'مطلوب';
                                            if (v.trim().length < 3) return 'غير صحيح';
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () => setState(() => _saveCard = !_saveCard),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _saveCard ? AppColors.primary : Colors.white,
                                        border: Border.all(
                                          color: _saveCard ? AppColors.primary : const Color(0xFFD1D1D6),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: _saveCard
                                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'حفظ البطاقة للاستخدام لاحقاً',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textDark,
                                        fontFamily: 'Tajawal',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // BNPL info snippet
                    if (_selectedMethod.isBNPL) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedMethod.badgeBg.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _selectedMethod.badgeBg.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: _selectedMethod.badgeBg, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedMethod == PaymentMethod.tamara
                                    ? 'ادفع على 3 دفعات بدون فوائد مع تمارا'
                                    : 'ادفع على 4 دفعات بدون فوائد مع تابي',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _selectedMethod.badgeBg,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // معلومات التواصل tile
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 14),
                            SizedBox(width: 12),
                            Text(
                              'معلومات التواصل',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Sticky bottom bar
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
                  child: ElevatedButton.icon(
                    onPressed: _onContinue,
                    icon: _selectedMethod == PaymentMethod.applePay
                        ? const Icon(Icons.apple, color: Colors.white, size: 20)
                        : const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18),
                    label: Text(
                      'المتابعة / ${_selectedMethod.label}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedMethod.badgeBg,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  Widget _buildMethodRow(PaymentMethod method) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? method.badgeBg.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? method.badgeBg : const Color(0xFFEEEEEE),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: method.badgeBg.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 3))]
              : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            // Radio dot
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? method.badgeBg : const Color(0xFFD1D1D6),
                  width: isSelected ? 6 : 2,
                ),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            // Label
            Expanded(
              child: Text(
                method.label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isSelected ? AppColors.textDark : AppColors.textMid,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            // Branded badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: method.badgeBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                method.badgeText,
                style: TextStyle(
                  color: method.badgeFg,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      textAlign: TextAlign.start,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark, fontFamily: 'Tajawal'),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textGrey, fontFamily: 'Tajawal'),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF9F9FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E2EA))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E2EA))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF3B30))),
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
            color: Colors.white,
            border: Border.all(
              color: isCompleted || isActive ? AppColors.primary : const Color(0xFFD1D1D6),
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 12, color: AppColors.primary)
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
