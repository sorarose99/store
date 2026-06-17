import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'edit_profile_gender_page.dart';
import 'edit_profile_dob_page.dart';
import '../../data/datasources/mock_account_data.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  late String _selectedGender;
  late String _selectedDob;

  @override
  void initState() {
    super.initState();
    final user = MockAccountDataSource.currentUser;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _selectedGender = user.gender;
    _selectedDob = '${user.dateOfBirth.day}-${user.dateOfBirth.month}-${user.dateOfBirth.year}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _navigateToGenderSelection() async {
    final result = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        pageBuilder: (context, _, __) => EditProfileGenderPage(selectedGender: _selectedGender),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedGender = result;
      });
    }
  }

  void _navigateToDobSelection() async {
    final result = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        pageBuilder: (context, _, __) => EditProfileDobPage(currentDob: _selectedDob),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedDob = result;
      });
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.textDark),
                title: const Text(
                  'التقاط صورة',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(color: Color(0xFFF0F0F0)),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.textDark),
                title: const Text(
                  'اختيار صورة من الجهاز',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
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
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'تعديل الملف الشخصي',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textDark),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avatar Upload Section
                      Center(
                        child: GestureDetector(
                          onTap: _showImageSourceActionSheet,
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFF2F2F7),
                                ),
                                child: const Center(
                                  child: Icon(Icons.person, size: 50, color: AppColors.textGrey),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.camera_alt_outlined, size: 16, color: AppColors.textDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Name Field
                      _buildFieldLabel('الاسم'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: _buildInputDecoration('أدخل الاسم'),
                        validator: (value) => value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      _buildFieldLabel('الايميل'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration('أدخل الايميل'),
                        validator: (value) => value == null || !value.contains('@') ? 'صيغة الايميل غير صحيحة' : null,
                      ),
                      const SizedBox(height: 20),

                      // Phone Field
                      _buildFieldLabel('الموبايل'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _buildInputDecoration('05XXXXXXXX', textDirection: TextDirection.ltr),
                        validator: (value) => value == null || value.length < 10 ? 'رقم جوال غير صحيح' : null,
                      ),
                      const SizedBox(height: 20),

                      // Date of Birth Field
                      _buildFieldLabel('تاريخ الميلاد'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _navigateToDobSelection,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDob,
                                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                              ),
                              const Icon(Icons.arrow_drop_down, color: AppColors.textGrey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Gender Field
                      _buildFieldLabel('الجنس'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _navigateToGenderSelection,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedGender,
                                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                              ),
                              const Icon(Icons.arrow_drop_down, color: AppColors.textGrey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed Save Button at the bottom
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'حفظ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, {TextDirection? textDirection}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
      hintTextDirection: textDirection,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
