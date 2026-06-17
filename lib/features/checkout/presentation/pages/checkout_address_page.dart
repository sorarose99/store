import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/checkout_entities.dart';
import 'checkout_location_search_page.dart';
import 'checkout_saved_address_page.dart';
import 'checkout_payment_page.dart';

class CheckoutAddressPage extends StatefulWidget {
  final bool isFromSavedPage;
  const CheckoutAddressPage({super.key, this.isFromSavedPage = false});

  @override
  State<CheckoutAddressPage> createState() => _CheckoutAddressPageState();
}

class _CheckoutAddressPageState extends State<CheckoutAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _zipController = TextEditingController();
  
  bool _isDefault = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _selectCity() async {
    final selectedCity = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CheckoutLocationSearchPage()),
    );
    if (selectedCity != null) {
      setState(() {
        _cityController.text = selectedCity;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newAddress = SavedAddressEntity(
        id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
        recipientName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        district: _areaController.text.trim(),
        street: _streetController.text.trim(),
        buildingNo: _buildingController.text.trim(),
        floor: '',
        zipCode: _zipController.text.trim(),
        isDefault: _isDefault,
      );

      if (widget.isFromSavedPage) {
        // Return to CheckoutSavedAddressPage
        Navigator.of(context).pop(newAddress);
      } else {
        // If coming directly from Cart, navigate to CheckoutSavedAddressPage with the new address added/selected
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CheckoutSavedAddressPage()),
        );
      }
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'عنوان الشحن',
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
                  _buildStep(1, 'العنوان', isActive: true, isCompleted: false),
                  _buildStepDivider(isActive: false),
                  _buildStep(2, 'الدفع', isActive: false, isCompleted: false),
                  _buildStepDivider(isActive: false),
                  _buildStep(3, 'المراجعة', isActive: false, isCompleted: false),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full name field
                      _buildLabel('الاسم بالكامل'),
                      _buildTextField(
                        controller: _fullNameController,
                        hintText: 'أدخل الاسم الثلاثي',
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textGrey, size: 20),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال الاسم' : null,
                      ),
                      const SizedBox(height: 14),

                      // Phone field
                      _buildLabel('رقم الجوال'),
                      _buildTextField(
                        controller: _phoneController,
                        hintText: '5xxxxxxxx',
                        prefixText: '+966 ',
                        prefixIcon: const Icon(Icons.phone_iphone_rounded, color: AppColors.textGrey, size: 20),
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'الرجاء إدخال رقم الجوال';
                          if (v.trim().length < 9) return 'رقم الجوال غير صحيح';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // City selection field (tappable to search page)
                      _buildLabel('المدينة'),
                      GestureDetector(
                        onTap: _selectCity,
                        child: AbsorbPointer(
                          child: _buildTextField(
                            controller: _cityController,
                            hintText: 'اختر المدينة',
                            prefixIcon: const Icon(Icons.location_city_outlined, color: AppColors.textGrey, size: 20),
                            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey, size: 24),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء اختيار المدينة' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Area field
                      _buildLabel('الحي / المنطقة'),
                      _buildTextField(
                        controller: _areaController,
                        hintText: 'مثال: حي النخيل',
                        prefixIcon: const Icon(Icons.explore_outlined, color: AppColors.textGrey, size: 20),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال الحي' : null,
                      ),
                      const SizedBox(height: 14),

                      // Street field
                      _buildLabel('الشارع'),
                      _buildTextField(
                        controller: _streetController,
                        hintText: 'مثال: شارع الملك فهد',
                        prefixIcon: const Icon(Icons.edit_road_outlined, color: AppColors.textGrey, size: 20),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال اسم الشارع' : null,
                      ),
                      const SizedBox(height: 14),

                      // Row for Building and Zip Code
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('رقم المبنى / الدور'),
                                _buildTextField(
                                  controller: _buildingController,
                                  hintText: 'مثال: مبنى 14، الدور 2',
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('الرمز البريدي (اختياري)'),
                                _buildTextField(
                                  controller: _zipController,
                                  hintText: '12345',
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Set as default checkbox
                      GestureDetector(
                        onTap: () => setState(() => _isDefault = !_isDefault),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _isDefault ? AppColors.primary : Colors.white,
                                border: Border.all(
                                  color: _isDefault ? AppColors.primary : const Color(0xFFD1D1D6),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: _isDefault
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'تعيين كعنوان توصيل افتراضي',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textDark,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Submit Button bottom panel
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
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      widget.isFromSavedPage ? 'إضافة العنوان' : 'متابعة الشراء',
                      style: const TextStyle(
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
    Widget? prefixIcon,
    String? prefixText,
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
        prefixIcon: prefixIcon,
        prefixText: prefixText,
        prefixStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF9F9FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E2EA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E2EA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF3B30)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
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
