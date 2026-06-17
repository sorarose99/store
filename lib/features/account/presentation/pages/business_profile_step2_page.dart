import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class BusinessProfileStep2Page extends StatefulWidget {
  final String businessName;
  final String businessEmail;
  final String activity;
  final String description;

  const BusinessProfileStep2Page({
    super.key,
    required this.businessName,
    required this.businessEmail,
    required this.activity,
    required this.description,
  });

  @override
  State<BusinessProfileStep2Page> createState() => _BusinessProfileStep2PageState();
}

class _BusinessProfileStep2PageState extends State<BusinessProfileStep2Page> {
  final _formKey = GlobalKey<FormState>();
  final _instagramController = TextEditingController(text: 'https://instagram.com/fashionstore');
  final _tiktokController = TextEditingController(text: 'https://tiktok.com/@fashionstore');
  final _websiteController = TextEditingController(text: 'https://fashionstore.com');

  bool _agreeToTerms = true;

  @override
  void dispose() {
    _instagramController.dispose();
    _tiktokController.dispose();
    _websiteController.dispose();
    super.dispose();
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
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'تكميل الملف التجاري',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Bar - Step 2 (both active)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('البيانات الأساسية', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    Text('روابط التواصل والتحقق', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 32),

                // Instagram Link
                _buildLabel('رابط حساب إنستغرام (Instagram)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _instagramController,
                  decoration: _buildInputDecoration('https://instagram.com/yourstore', Icons.camera_alt_outlined),
                ),
                const SizedBox(height: 20),

                // TikTok Link
                _buildLabel('رابط حساب تيك توك (TikTok)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tiktokController,
                  decoration: _buildInputDecoration('https://tiktok.com/@yourstore', Icons.video_library_outlined),
                ),
                const SizedBox(height: 20),

                // Website Link
                _buildLabel('الموقع الإلكتروني أو المتجر الحالي (إن وجد)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _websiteController,
                  decoration: _buildInputDecoration('https://yourstore.com', Icons.language_outlined),
                ),
                const SizedBox(height: 24),

                // Upload Verification Document
                _buildLabel('المستندات الثبوتية (صورة الهوية الوطنية / جواز السفر)'),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    // Trigger native file/photo picker
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.primary),
                        const SizedBox(height: 8),
                        const Text(
                          'اضغط هنا لرفع الملفات',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'الحجم الأقصى للملف 5 ميجابايت (PDF, JPG, PNG)',
                          style: TextStyle(fontSize: 10, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Agree to terms checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _agreeToTerms = val;
                          });
                        }
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'أوافق على شروط وأحكام البيع والخصوصية المنظمة لعمليات المتجر.',
                        style: TextStyle(fontSize: 11, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Save button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _agreeToTerms
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              // Success overlay or back to Account
                              showDialog(
                                context: context,
                                builder: (context) => Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: const Text('تم بنجاح'),
                                    content: const Text('لقد تم تحديث ملفك التجاري وإرساله للمراجعة بنجاح!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); // Close dialog
                                          Navigator.pop(context); // Back to Step 1
                                          Navigator.pop(context); // Back to Account Page
                                        },
                                        child: const Text('موافق', style: TextStyle(color: AppColors.primary)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'حفظ وإنشاء الحساب',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
