import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart';
import '../blocs/account_bloc.dart';
import '../blocs/account_event.dart';
import '../blocs/account_state.dart';

class ComplaintsPage extends StatelessWidget {
  const ComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scoped BLoC so it doesn't clash with the main account tab bloc
    return BlocProvider(
      create: (_) => sl<AccountBloc>(),
      child: const _ComplaintsView(),
    );
  }
}

class _ComplaintsView extends StatefulWidget {
  const _ComplaintsView();

  @override
  State<_ComplaintsView> createState() => _ComplaintsViewState();
}

class _ComplaintsViewState extends State<_ComplaintsView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController    = TextEditingController();
  final _emailController   = TextEditingController();
  final _phoneController   = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedType = 'general';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AccountBloc>().add(AccountSendContactRequested(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          type: _selectedType,
          subject: _subjectController.text.trim(),
          message: _messageController.text.trim(),
        ));
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
          isArabic ? 'الشكاوى والاقتراحات' : 'Complaints & Suggestions',
          style: TextStyle(
              color: context.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isArabic
                      ? 'تم إرسال رسالتك بنجاح. سنقوم بالرد عليك في أقرب وقت ممكن.'
                      : 'Your message has been sent successfully. We will reply as soon as possible.',
                ),
                backgroundColor: context.primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
            Navigator.of(context).pop();
          } else if (state is AccountActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AccountActionLoading;
          return Column(
            children: [
              // ── Gradient header ────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.primaryColor, context.primaryDark],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
                child: Text(
                  isArabic ? 'أرسل لنا رسالة' : 'Send us a message',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),

              // ── Form ───────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label(isArabic ? 'الاسم الكامل' : 'Full Name', context),
                        const SizedBox(height: 8),
                        _field(
                          controller: _nameController,
                          hint: isArabic ? 'الاسم الكامل' : 'Full Name',
                          context: context,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? (isArabic ? 'يرجى إدخال الاسم الكامل' : 'Please enter full name')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _label(isArabic ? 'البريد الإلكتروني' : 'Email Address', context),
                        const SizedBox(height: 8),
                        _field(
                          controller: _emailController,
                          hint: isArabic ? 'البريد الإلكتروني' : 'Email Address',
                          context: context,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return isArabic ? 'يرجى إدخال البريد الإلكتروني' : 'Please enter email address';
                            }
                            if (!v.contains('@')) return isArabic ? 'البريد غير صالح' : 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _label(isArabic ? 'الهاتف' : 'Phone Number', context),
                        const SizedBox(height: 8),
                        _field(
                          controller: _phoneController,
                          hint: isArabic ? 'الهاتف' : 'Phone Number',
                          context: context,
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? (isArabic ? 'يرجى إدخال رقم الهاتف' : 'Please enter phone number')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _label(isArabic ? 'نوع الاستفسار' : 'Inquiry Type', context),
                        const SizedBox(height: 8),
                        _dropdownField(isArabic, context),
                        const SizedBox(height: 16),
                        _label(isArabic ? 'الموضوع' : 'Subject', context),
                        const SizedBox(height: 8),
                        _field(
                          controller: _subjectController,
                          hint: isArabic ? 'موضوع الرسالة' : 'Subject',
                          context: context,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? (isArabic ? 'يرجى إدخال الموضوع' : 'Please enter subject')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _label(isArabic ? 'الرسالة' : 'Message', context),
                        const SizedBox(height: 8),
                        _field(
                          controller: _messageController,
                          hint: isArabic ? 'اكتب رسالتك هنا...' : 'Write your message here...',
                          context: context,
                          maxLines: 5,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? (isArabic ? 'يرجى كتابة تفاصيل الرسالة' : 'Please enter message details')
                              : null,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Send button ────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                color: context.surfaceColor,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _submit,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded,
                            size: 20, color: Colors.white),
                    label: Text(
                      isLoading
                          ? (isArabic ? 'جاري الإرسال...' : 'Sending...')
                          : (isArabic ? 'إرسال' : 'Send'),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      disabledBackgroundColor:
                          context.primaryColor.withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _label(String text, BuildContext context) => Text(
        text,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.textDark),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required BuildContext context,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: context.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.textGrey, fontSize: 13),
        filled: true,
        fillColor: context.surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.errorColor),
        ),
      ),
      validator: validator,
    );
  }

  Widget _dropdownField(bool isArabic, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.border),
      ),
      child: DropdownButton<String>(
        value: _selectedType,
        isExpanded: true,
        dropdownColor: context.surfaceColor,
        style: TextStyle(color: context.textDark, fontSize: 14),
        underline: const SizedBox.shrink(),
        icon: Icon(Icons.keyboard_arrow_down, color: context.textGrey),
        items: [
          DropdownMenuItem(value: 'general',    child: Text(isArabic ? 'استفسار عام' : 'General Inquiry')),
          DropdownMenuItem(value: 'complaint',  child: Text(isArabic ? 'شكوى' : 'Complaint')),
          DropdownMenuItem(value: 'suggestion', child: Text(isArabic ? 'اقتراح' : 'Suggestion')),
          DropdownMenuItem(value: 'order',      child: Text(isArabic ? 'طلب' : 'Order')),
          DropdownMenuItem(value: 'return',     child: Text(isArabic ? 'إرجاع أو استبدال' : 'Return or Exchange')),
        ],
        onChanged: (val) {
          if (val != null) setState(() => _selectedType = val);
        },
      ),
    );
  }
}
