import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';
import '../../data/repositories/contact_us_repository.dart';

const _kWhatsApp  = '966542139388';
const _kEmail     = 'support@kdx-sa.com';
const _kSnapchat  = 'https://www.snapchat.com/add/kdx_sa';
const _kInstagram = 'https://www.instagram.com/kdx_sa';
const _kTikTok    = 'https://www.tiktok.com/@kdx_sa';
const _kTwitter   = 'https://twitter.com/kdx_sa';
const _kFacebook  = 'https://www.facebook.com/kdx_sa';
const _kYoutube   = 'https://www.youtube.com/@kdx_sa';

class ContactInfoPage extends StatefulWidget {
  const ContactInfoPage({super.key});

  @override
  State<ContactInfoPage> createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends State<ContactInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _selectedType = 'general';

  bool _isLoading = false;
  final _repository = ContactUsRepository();

  Future<void> _submitForm(bool isArabic) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await _repository.submitContactForm(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        type: _selectedType,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'تم إرسال رسالتك بنجاح!' : 'Your message was sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _subjectController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ── URL launchers ─────────────────────────────────────────────────
  Future<void> _openWhatsApp(BuildContext context, bool isArabic) async {
    final uri = Uri.parse('https://wa.me/$_kWhatsApp');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) _snack(context, isArabic ? 'تعذّر فتح واتساب' : 'Could not open WhatsApp');
    }
  }

  Future<void> _openEmail(BuildContext context, bool isArabic) async {
    final String subject = Uri.encodeComponent('استفسار من تطبيق KDX');
    final uri = Uri.parse('mailto:$_kEmail?subject=$subject');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) _snack(context, isArabic ? 'تعذّر فتح تطبيق البريد' : 'Could not open email application');
    }
  }

  Future<void> _openUrl(BuildContext context, String url, bool isArabic) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) _snack(context, isArabic ? 'تعذّر فتح الرابط' : 'Could not open link');
    }
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          isArabic ? 'اتصل بنا' : 'Contact Us',
          style: TextStyle(color: context.textDark, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Branded Hero Card ─────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.primaryColor, context.primaryDark],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Stack(
                  children: [
                    // Logo watermark in background
                    Positioned(
                      left: -20,
                      bottom: -20,
                      child: Opacity(
                        opacity: 0.12,
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 160,
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -10,
                      top: -30,
                      child: Opacity(
                        opacity: 0.07,
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // Content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.headset_mic_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isArabic ? 'فريق دعم KDX' : 'KDX Support Team',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isArabic ? 'نحن هنا لمساعدتك على مدار الساعة' : 'We are here to help you 24/7',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Contact Form
            Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: context.primaryColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Text(
                      isArabic ? 'أرسل لنا رسالة' : 'Send us a message',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(isArabic ? 'الاسم الكامل' : 'Full Name', context),
                          _buildTextField(_nameController, context, required: true, isArabic: isArabic),
                          const SizedBox(height: 16),
                          
                          _buildLabel(isArabic ? 'البريد الإلكتروني' : 'Email Address', context),
                          _buildTextField(_emailController, context, required: true, isEmail: true, isArabic: isArabic),
                          const SizedBox(height: 16),
                          
                          _buildLabel(isArabic ? 'الهاتف' : 'Phone Number', context),
                          _buildTextField(_phoneController, context, required: false, isPhone: true, isArabic: isArabic),
                          const SizedBox(height: 16),
                          
                          _buildLabel(isArabic ? 'نوع الاستفسار' : 'Inquiry Type', context),
                          _buildDropdown(isArabic, context),
                          const SizedBox(height: 16),
                          
                          _buildLabel(isArabic ? 'الموضوع' : 'Subject', context),
                          _buildTextField(_subjectController, context, required: true, hint: isArabic ? 'موضوع الرسالة' : 'Subject', isArabic: isArabic),
                          const SizedBox(height: 16),
                          
                          _buildLabel(isArabic ? 'الرسالة' : 'Message', context),
                          _buildTextField(
                            _messageController,
                            context,
                            required: true,
                            maxLines: 4,
                            hint: isArabic ? 'اكتب رسالتك هنا...' : 'Write your message here...',
                            isArabic: isArabic,
                          ),
                          const SizedBox(height: 24),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : () => _submitForm(isArabic),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              icon: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.send, color: Colors.white, size: 18),
                              label: Text(
                                _isLoading
                                  ? (isArabic ? 'جاري الإرسال...' : 'Sending...')
                                  : (isArabic ? 'إرسال' : 'Send'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Contact Info
            Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: context.primaryColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Text(
                      isArabic ? 'معلومات الاتصال' : 'Contact Information',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(context, Icons.location_on, isArabic ? 'العنوان' : 'Address', isArabic ? 'المملكة العربية السعودية' : 'Saudi Arabia'),
                        Divider(height: 32, color: context.border),
                        
                        GestureDetector(
                          onTap: () => _openWhatsApp(context, isArabic),
                          child: _buildInfoRow(context, Icons.phone, isArabic ? 'الهاتف' : 'Phone', '+966542139388', isClickable: true),
                        ),
                        Divider(height: 32, color: context.border),
                        
                        GestureDetector(
                          onTap: () => _openEmail(context, isArabic),
                          child: _buildInfoRow(context, Icons.email, isArabic ? 'البريد الإلكتروني' : 'Email Address', 'support@kdx-sa.com', isClickable: true),
                        ),
                        const SizedBox(height: 32),
                        
                        // Social Media
                        Text(
                          isArabic ? 'تابعنا على وسائل التواصل' : 'Follow Us on Social Media',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.1,
                          children: [
                            _buildBrandedSocialTile(
                              label: isArabic ? 'تيك توك' : 'TikTok',
                              fallbackIcon: Icons.music_note,
                              bgColor: Colors.black,
                              iconColor: Colors.white,
                              onTap: () => _openUrl(context, _kTikTok, isArabic),
                            ),
                            _buildBrandedSocialTile(
                              label: isArabic ? 'انستقرام' : 'Instagram',
                              fallbackIcon: Icons.photo_camera_rounded,
                              bgColor: const Color(0xFFE1306C),
                              iconColor: Colors.white,
                              onTap: () => _openUrl(context, _kInstagram, isArabic),
                            ),
                            _buildBrandedSocialTile(
                              label: isArabic ? 'سناب شات' : 'Snapchat',
                              fallbackIcon: Icons.camera_alt_rounded,
                              bgColor: const Color(0xFFFFFC00),
                              iconColor: Colors.black,
                              onTap: () => _openUrl(context, _kSnapchat, isArabic),
                            ),
                            _buildBrandedSocialTile(
                              label: isArabic ? 'يوتيوب' : 'YouTube',
                              fallbackIcon: Icons.play_circle_fill,
                              bgColor: const Color(0xFFFF0000),
                              iconColor: Colors.white,
                              onTap: () => _openUrl(context, _kYoutube, isArabic),
                            ),
                            _buildBrandedSocialTile(
                              label: isArabic ? 'فيسبوك' : 'Facebook',
                              fallbackIcon: Icons.facebook,
                              bgColor: const Color(0xFF1877F2),
                              iconColor: Colors.white,
                              onTap: () => _openUrl(context, _kFacebook, isArabic),
                            ),
                            _buildBrandedSocialTile(
                              label: isArabic ? 'تويتر / X' : 'Twitter / X',
                              fallbackIcon: Icons.close_rounded,
                              bgColor: const Color(0xFF14171A),
                              iconColor: Colors.white,
                              onTap: () => _openUrl(context, _kTwitter, isArabic),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: context.textDark),
      ),
    );
  }
  
  Widget _buildTextField(
    TextEditingController controller,
    BuildContext context, {
    bool required = false,
    bool isEmail = false,
    bool isPhone = false,
    int maxLines = 1,
    String? hint,
    required bool isArabic,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: context.textDark),
      keyboardType: isEmail
        ? TextInputType.emailAddress
        : isPhone
          ? TextInputType.phone
          : TextInputType.text,
      validator: required ? (v) {
        if (v == null || v.trim().isEmpty) return isArabic ? 'هذا الحقل مطلوب' : 'This field is required';
        if (isEmail && !v.contains('@')) return isArabic ? 'البريد الإلكتروني غير صحيح' : 'Invalid email address';
        return null;
      } : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.textGrey, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: context.primaryColor),
        ),
        filled: true,
        fillColor: context.surfaceColor,
      ),
    );
  }
  
  Widget _buildDropdown(bool isArabic, BuildContext context) {
    final inquiryTypes = isArabic
        ? ['استفسار عام', 'استفسار عن طلب', 'شكوى', 'اقتراح', 'دعم فني']
        : ['General Inquiry', 'Order Inquiry', 'Complaint', 'Suggestion', 'Technical Support'];
    
    // Ensure default matches list
    if (!inquiryTypes.contains(_selectedType)) {
      _selectedType = inquiryTypes.first;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.border),
        color: context.surfaceColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          dropdownColor: context.surfaceColor,
          style: TextStyle(color: context.textDark, fontSize: 14),
          icon: Icon(Icons.keyboard_arrow_down, color: context.textGrey),
          items: inquiryTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedType = val);
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {bool isClickable = false}) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textDark)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isClickable ? context.textDark : context.textGrey,
                fontWeight: isClickable ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildBrandedSocialTile({
    required String label,
    required IconData fallbackIcon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(fallbackIcon, color: iconColor, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: iconColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
