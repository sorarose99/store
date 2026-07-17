import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../checkout/domain/entities/checkout_entities.dart';
import '../blocs/address_bloc.dart';
import '../blocs/address_event.dart';
import '../blocs/address_state.dart';

class AddAddressPage extends StatefulWidget {
  final SavedAddressEntity? addressToEdit;

  const AddAddressPage({super.key, this.addressToEdit});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _detailedAddressController = TextEditingController();

  String _selectedCountry = 'SA';
  bool _isDefault = false;
  bool _submitted = false;

  static const List<Map<String, String>> _countries = [
    {'code': 'SA', 'name': 'المملكة العربية السعودية', 'dial': '+966'},
    {'code': 'AE', 'name': 'الإمارات العربية المتحدة', 'dial': '+971'},
    {'code': 'KW', 'name': 'الكويت', 'dial': '+965'},
    {'code': 'QA', 'name': 'قطر', 'dial': '+974'},
    {'code': 'BH', 'name': 'البحرين', 'dial': '+973'},
    {'code': 'OM', 'name': 'عُمان', 'dial': '+968'},
    {'code': 'EG', 'name': 'مصر', 'dial': '+20'},
    {'code': 'JO', 'name': 'الأردن', 'dial': '+962'},
  ];

  String get _selectedDial =>
      _countries.firstWhere((c) => c['code'] == _selectedCountry,
          orElse: () => _countries.first)['dial']!;

  @override
  void initState() {
    super.initState();
    if (widget.addressToEdit != null) {
      final addr = widget.addressToEdit!;
      _titleController.text = addr.title;
      _fullNameController.text = addr.fullName;
      _phoneController.text = addr.phone;
      _emailController.text = addr.email;
      _cityController.text = addr.city;
      _zipCodeController.text = addr.zipCode;
      _detailedAddressController.text = addr.detailedAddress;
      _selectedCountry = addr.country.isNotEmpty ? addr.country : 'SA';
      _isDefault = addr.isDefault;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _detailedAddressController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    setState(() => _submitted = true);

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'يرجى إكمال جميع الخانات المطلوبة قبل حفظ العنوان',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final newAddr = SavedAddressEntity(
      id: widget.addressToEdit?.id ?? '',
      title: _titleController.text.trim(),
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      country: _selectedCountry,
      city: _cityController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      detailedAddress: _detailedAddressController.text.trim(),
      isDefault: _isDefault,
    );

    if (widget.addressToEdit != null) {
      context.read<AddressBloc>().add(UpdateAddress(id: newAddr.id, address: newAddr));
    } else {
      context.read<AddressBloc>().add(AddAddress(newAddr));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.addressToEdit != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            isEditing ? 'تعديل العنوان' : 'إضافة عنوان جديد',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: BlocConsumer<AddressBloc, AddressState>(
          listener: (context, state) {
            if (state is AddressActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text('تم حفظ العنوان بنجاح', style: TextStyle(fontFamily: 'Tajawal')),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
              Navigator.of(context).pop();
            } else if (state is AddressActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message, style: const TextStyle(fontFamily: 'Tajawal')),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AddressActionLoading;

            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Section: Recipient Details ───────────────
                            _buildSectionHeader('معلومات المستلم', Icons.person_pin_outlined),
                            const SizedBox(height: 12),
                            _buildCard([
                              _buildTextField(
                                controller: _titleController,
                                label: 'عنوان العنوان',
                                hint: 'مثال: المنزل، العمل، ...',
                                icon: Icons.label_outline,
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty) ? 'عنوان العنوان مطلوب' : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _fullNameController,
                                label: 'الاسم الكامل',
                                hint: 'أدخل الاسم الكامل للمستلم',
                                icon: Icons.person_outline,
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty) ? 'الاسم الكامل مطلوب' : null,
                              ),
                              const SizedBox(height: 16),
                              // Phone with country code prefix
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('رقم الهاتف'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    textDirection: TextDirection.ltr,
                                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14),
                                    autovalidateMode: _submitted
                                        ? AutovalidateMode.onUserInteraction
                                        : AutovalidateMode.disabled,
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'رقم الهاتف مطلوب';
                                      }
                                      if (val.trim().length < 8) {
                                        return 'رقم الهاتف غير صحيح';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: '5XXXXXXXX',
                                      hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(10),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _selectedDial,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            fontFamily: 'Tajawal',
                                          ),
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: _inputBorder(),
                                      enabledBorder: _inputBorder(),
                                      focusedBorder: _focusedBorder(),
                                      errorBorder: _errorBorder(),
                                      focusedErrorBorder: _errorBorder(),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _emailController,
                                label: 'البريد الإلكتروني',
                                hint: 'أدخل البريد الإلكتروني',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'البريد الإلكتروني مطلوب';
                                  }
                                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                  if (!emailRegex.hasMatch(val.trim())) {
                                    return 'البريد الإلكتروني غير صحيح';
                                  }
                                  return null;
                                },
                              ),
                            ]),

                            const SizedBox(height: 20),

                            // ── Section: Address Details ─────────────────
                            _buildSectionHeader('تفاصيل العنوان', Icons.location_on_outlined),
                            const SizedBox(height: 12),
                            _buildCard([
                              // Country dropdown
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('الدولة'),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE8E8E8)),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedCountry,
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.flag_outlined, color: AppColors.primary, size: 20),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                                      ),
                                      dropdownColor: Colors.white,
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 14,
                                        color: AppColors.textDark,
                                      ),
                                      items: _countries.map((c) {
                                        return DropdownMenuItem<String>(
                                          value: c['code'],
                                          child: Text('${c['name']} (${c['dial']})'),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedCountry = val);
                                      },
                                      validator: (val) =>
                                          (val == null || val.isEmpty) ? 'الدولة مطلوبة' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _cityController,
                                label: 'المدينة',
                                hint: 'أدخل اسم المدينة',
                                icon: Icons.location_city_outlined,
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty) ? 'المدينة مطلوبة' : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _zipCodeController,
                                label: 'الرمز البريدي',
                                hint: 'مثال: 12345',
                                icon: Icons.markunread_mailbox_outlined,
                                keyboardType: TextInputType.number,
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty) ? 'الرمز البريدي مطلوب' : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _detailedAddressController,
                                label: 'العنوان التفصيلي',
                                hint: 'الحي، الشارع، رقم المبنى / الدور',
                                icon: Icons.home_outlined,
                                maxLines: 3,
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty) ? 'العنوان التفصيلي مطلوب' : null,
                              ),
                            ]),

                            const SizedBox(height: 20),

                            // ── Default address toggle ───────────────────
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE8E8E8)),
                              ),
                              child: Row(
                                children: [
                                  Switch(
                                    value: _isDefault,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) => setState(() => _isDefault = val),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'تعيين كعنوان افتراضي',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textDark,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ),
                                  if (_isDefault)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'الافتراضي',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Tajawal',
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Save Button ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          offset: const Offset(0, -4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEditing ? 'حفظ التعديلات' : 'حفظ العنوان',
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        fontFamily: 'Tajawal',
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          validator: validator,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            prefixIcon: maxLines == 1 ? Icon(icon, color: AppColors.primary, size: 20) : null,
            filled: true,
            fillColor: Colors.white,
            border: _inputBorder(),
            enabledBorder: _inputBorder(),
            focusedBorder: _focusedBorder(),
            errorBorder: _errorBorder(),
            focusedErrorBorder: _errorBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 14 : 14,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _inputBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
      );

  OutlineInputBorder _focusedBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      );

  OutlineInputBorder _errorBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      );
}
