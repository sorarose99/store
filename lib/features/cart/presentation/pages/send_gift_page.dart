import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class SendGiftPage extends StatefulWidget {
  final Map<String, dynamic>? initialGiftDetails;

  const SendGiftPage({
    super.key,
    this.initialGiftDetails,
  });

  @override
  State<SendGiftPage> createState() => _SendGiftPageState();
}

class _SendGiftPageState extends State<SendGiftPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _messageController;
  bool _wrapAsGift = false;

  @override
  void initState() {
    super.initState();
    final details = widget.initialGiftDetails;
    _nameController = TextEditingController(text: details?['recipientName'] ?? '');
    _phoneController = TextEditingController(text: details?['recipientPhone'] ?? '');
    _messageController = TextEditingController(text: details?['message'] ?? '');
    _wrapAsGift = details?['wrap'] ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _saveDetails() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'recipientName': _nameController.text.trim(),
        'recipientPhone': _phoneController.text.trim(),
        'message': _messageController.text.trim(),
        'wrap': _wrapAsGift,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'أرسلها كهدية',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Elegant Card Header Design (like a gift card envelope)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.card_giftcard_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'اجعل طلبك مميزاً',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'أدخل تفاصيل المستلم والرسالة لنقوم بتوصيلها بشكل أنيق ومميز كهدية.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textDark,
                                height: 1.4,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Recipient Name Field
                _buildFieldLabel('اسم المستلم'),
                TextFormField(
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'الرجاء إدخال اسم المستلم';
                    }
                    return null;
                  },
                  decoration: _buildInputDecoration('أدخل الاسم الكامل'),
                  style: const TextStyle(fontSize: 13, fontFamily: 'Tajawal'),
                ),
                const SizedBox(height: 16),

                // Recipient Phone Field
                _buildFieldLabel('رقم هاتف المستلم'),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    if (val.trim().length < 9) {
                      return 'رقم الهاتف غير صالح';
                    }
                    return null;
                  },
                  decoration: _buildInputDecoration('مثال: 05XXXXXXXX'),
                  style: const TextStyle(fontSize: 13, fontFamily: 'Tajawal'),
                ),
                const SizedBox(height: 16),

                // Gift Message Area
                _buildFieldLabel('رسالة الهدية (اختياري)'),
                TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: _buildInputDecoration('أكتب كلمتك الطيبة هنا...'),
                  style: const TextStyle(fontSize: 13, fontFamily: 'Tajawal'),
                ),
                const SizedBox(height: 24),

                // Wrap Option Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.celebration_rounded,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'تغليف الهدية بشكل فاخر',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'تغليف أنيق مع كرت إهداء مطبوع (+15.0 ر.س)',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textGrey,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _wrapAsGift,
                        onChanged: (val) {
                          setState(() => _wrapAsGift = val);
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Save button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'حفظ التفاصيل وتأكيد الهدية',
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
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 12, fontFamily: 'Tajawal'),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E5EA), width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E5EA), width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 0.8),
      ),
    );
  }
}
