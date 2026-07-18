import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/checkout_entities.dart';
import 'checkout_location_search_page.dart';
import 'checkout_saved_address_page.dart';

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
        title: 'Home', // default for now
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: '',
        country: 'SA',
        city: _cityController.text.trim(),
        zipCode: _zipController.text.trim(),
        detailedAddress: '${_areaController.text.trim()} - ${_streetController.text.trim()} - ${_buildingController.text.trim()}',
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
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: context.surfaceColor,
        appBar: AppBar(
          backgroundColor: context.surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'shipping_address'.tr(),
            style: TextStyle(
              color: context.textDark,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: Column(
          children: [
            // Breadcrumbs progress indicator
            Container(
              color: context.backgroundColor,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStep(1, 'address'.tr(),
                      isActive: true, isCompleted: false),
                  _buildStepDivider(isActive: false),
                  _buildStep(2, 'payment'.tr(),
                      isActive: false, isCompleted: false),
                  _buildStepDivider(isActive: false),
                  _buildStep(3, 'review'.tr(),
                      isActive: false, isCompleted: false),
                ],
              ),
            ),
            Divider(color: context.border, height: 1.h),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full name field
                      _buildLabel(context, 'full_name_2'.tr()),
                      _buildTextField(
                        controller: _fullNameController,
                        hintText: 'enter_the_full_name'.tr(),
                        prefixIcon: Icon(Icons.person_outline_rounded,
                            color: context.textGrey, size: 20),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'please_enter_name'.tr()
                            : null,
                      ),
                      SizedBox(height: 14.h),

                      // Phone field
                      _buildLabel(context, 'phone'.tr()),
                      _buildTextField(
                        controller: _phoneController,
                        hintText: '5xxxxxxxx',
                        prefixText: '966'.tr(),
                        prefixIcon: Icon(Icons.phone_iphone_rounded,
                            color: context.textGrey, size: 20),
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'please_enter_mobile_number'.tr();
                          }
                          if (v.trim().length < 9) {
                            return 'mobile_number_is_incorrect'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 14.h),

                      // City selection field (tappable to search page)
                      _buildLabel(context, 'city'.tr()),
                      GestureDetector(
                        onTap: _selectCity,
                        child: AbsorbPointer(
                          child: _buildTextField(
                            controller: _cityController,
                            hintText: 'select_city'.tr(),
                            prefixIcon: Icon(Icons.location_city_outlined,
                                color: context.textGrey, size: 20),
                            suffixIcon: Icon(Icons.keyboard_arrow_down_rounded,
                                color: context.textGrey, size: 24),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'please_select_a_city'.tr()
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // Area field
                      _buildLabel(context, 'district_region'.tr()),
                      _buildTextField(
                        controller: _areaController,
                        hintText: 'example_al_nakheel_neighborhood'.tr(),
                        prefixIcon: Icon(Icons.explore_outlined,
                            color: context.textGrey, size: 20),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'please_enter_the_neighborhood'.tr()
                            : null,
                      ),
                      SizedBox(height: 14.h),

                      // Street field
                      _buildLabel(context, 'street'.tr()),
                      _buildTextField(
                        controller: _streetController,
                        hintText: 'example_king_fahd_street'.tr(),
                        prefixIcon: Icon(Icons.edit_road_outlined,
                            color: context.textGrey, size: 20),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'please_enter_street_name'.tr()
                            : null,
                      ),
                      SizedBox(height: 14.h),

                      // Row for Building and Zip Code
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, 'building_floor'.tr()),
                                _buildTextField(
                                  controller: _buildingController,
                                  hintText: 'example_building_14_2nd'.tr(),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'required'.tr()
                                          : null,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, 'zip_code_optional'.tr()),
                                _buildTextField(
                                  controller: _zipController,
                                  hintText: '12345'.tr(),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // Set as default checkbox
                      GestureDetector(
                        onTap: () => setState(() => _isDefault = !_isDefault),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22.w,
                              height: 22.h,
                              decoration: BoxDecoration(
                                color: _isDefault
                                    ? context.primaryColor
                                    : context.backgroundColor,
                                border: Border.all(
                                  color: _isDefault
                                      ? context.primaryColor
                                      : context.primaryColor,
                                  width: 2.w,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: _isDefault
                                  ? Icon(Icons.check,
                                      size: 16, color: context.backgroundColor)
                                  : null,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'set_as_default_delivery'.tr(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: context.textDark,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ),

            // Submit Button bottom panel
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                boxShadow: [
                  BoxShadow(
                      color: context.shadowColor.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      widget.isFromSavedPage
                          ? 'add_title'.tr()
                          : 'purchase_followup'.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
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

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.0.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: context.textDark,
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
      style: TextStyle(
          fontSize: 14.sp, color: context.textDark, fontFamily: 'Tajawal'),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
            fontSize: 13.sp, color: context.textGrey, fontFamily: 'Tajawal'),
        prefixIcon: prefixIcon,
        prefixText: prefixText,
        prefixStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: context.textDark),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: context.surfaceColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.primaryColor, width: 1.5.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.primaryColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.primaryColor, width: 1.5.w),
        ),
      ),
    );
  }

  Widget _buildStep(int number, String label,
      {required bool isActive, required bool isCompleted}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22.w,
          height: 22.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? context.primaryColor
                : isActive
                    ? context.primaryColor.withValues(alpha: 0.1)
                    : context.cardBackground,
            border: Border.all(
              color: isCompleted || isActive
                  ? context.primaryColor
                  : context.border,
              width: 1.5.w,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, size: 12, color: Theme.of(context).colorScheme.onPrimary)
                : Text(
                    number.toString(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? context.primaryColor
                          : context.textGrey,
                      fontFamily: 'Tajawal',
                    ),
                  ),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight:
                isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isActive || isCompleted
                ? context.primaryColor
                : context.textGrey,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider({required bool isActive}) {
    return Container(
      width: 30.w,
      height: 1.5.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      color: isActive ? context.primaryColor : context.border,
    );
  }
}
