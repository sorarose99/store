import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'business_profile_step2_page.dart';

class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({super.key});

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController(text: 'متجر الأزياء الراقية');
  final _businessEmailController = TextEditingController(text: 'info@fashionstore.com');
  final _licenseNumberController = TextEditingController(text: 'CN-1204859');
  final _descriptionController = TextEditingController(text: 'بيع وتصميم ملابس عصرية وراقية تناسب جميع الأذواق.');

  String _selectedActivity = 'ملابس وأزياء';

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessEmailController.dispose();
    _licenseNumberController.dispose();
    _descriptionController.dispose();
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
                // Step Indicator Progress Bar
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
                          color: const Color(0xFFEEEEEE),
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
                    Text('البيانات الأساسية', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                    Text('روابط التواصل والتحقق', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  ],
                ),
                const SizedBox(height: 32),

                // Trade Name
                _buildLabel('الاسم التجاري'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _businessNameController,
                  decoration: _buildInputDecoration('أدخل الاسم التجاري للمتجر'),
                  validator: (value) => value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
                ),
                const SizedBox(height: 20),

                // Business Email
                _buildLabel('البريد التجاري'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _businessEmailController,
                  decoration: _buildInputDecoration('example@business.com'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
                ),
                const SizedBox(height: 20),

                // License Number
                _buildLabel('رقم الترخيص التجاري (اختياري)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _licenseNumberController,
                  decoration: _buildInputDecoration('أدخل رقم السجل / الترخيص'),
                ),
                const SizedBox(height: 20),

                // Activity Type
                _buildLabel('نوع النشاط'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedActivity,
                  decoration: _buildInputDecoration('اختر نوع النشاط'),
                  items: ['ملابس وأزياء', 'إلكترونيات', 'مستحضرات تجميل', 'ألعاب وهدايا']
                      .map((act) => DropdownMenuItem(value: act, child: Text(act)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedActivity = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Description
                _buildLabel('وصف المتجر'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: _buildInputDecoration('اكتب نبذة مختصرة عن متجرك ومنتجاتك...'),
                ),
                const SizedBox(height: 36),

                // Continue button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BusinessProfileStep2Page(
                              businessName: _businessNameController.text,
                              businessEmail: _businessEmailController.text,
                              activity: _selectedActivity,
                              description: _descriptionController.text,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'متابعة',
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

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
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
