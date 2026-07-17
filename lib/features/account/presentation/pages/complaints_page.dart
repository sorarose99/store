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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'الشكاوى والاقتراحات',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocConsumer<AccountBloc, AccountState>(
          listener: (context, state) {
            if (state is AccountActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      'تم إرسال رسالتك بنجاح. سنقوم بالرد عليك في أقرب وقت ممكن.'),
                  backgroundColor: AppColors.success,
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
                  backgroundColor: AppColors.error,
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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: const Text(
                    'أرسل لنا رسالة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                          _label('الاسم الكامل'),
                          const SizedBox(height: 8),
                          _field(
                            controller: _nameController,
                            hint: 'الاسم الكامل',
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'يرجى إدخال الاسم الكامل'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _label('البريد الإلكتروني'),
                          const SizedBox(height: 8),
                          _field(
                            controller: _emailController,
                            hint: 'البريد الإلكتروني',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'يرجى إدخال البريد الإلكتروني';
                              }
                              if (!v.contains('@')) return 'البريد غير صالح';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _label('الهاتف'),
                          const SizedBox(height: 8),
                          _field(
                            controller: _phoneController,
                            hint: 'الهاتف',
                            keyboardType: TextInputType.phone,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'يرجى إدخال رقم الهاتف'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _label('نوع الاستفسار'),
                          const SizedBox(height: 8),
                          _dropdownField(),
                          const SizedBox(height: 16),
                          _label('الموضوع'),
                          const SizedBox(height: 8),
                          _field(
                            controller: _subjectController,
                            hint: 'موضوع الرسالة',
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'يرجى إدخال الموضوع'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _label('الرسالة'),
                          const SizedBox(height: 8),
                          _field(
                            controller: _messageController,
                            hint: 'اكتب رسالتك هنا...',
                            maxLines: 5,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'يرجى كتابة تفاصيل الرسالة'
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
                  color: Colors.white,
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
                        isLoading ? 'جاري الإرسال...' : 'إرسال',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.5),
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
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
        hintTextDirection: TextDirection.rtl,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFECEEF5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFECEEF5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      validator: validator,
    );
  }

  Widget _dropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFECEEF5)),
      ),
      child: DropdownButton<String>(
        value: _selectedType,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey),
        items: const [
          DropdownMenuItem(value: 'general',    child: Text('استفسار عام')),
          DropdownMenuItem(value: 'complaint',  child: Text('شكوى')),
          DropdownMenuItem(value: 'suggestion', child: Text('اقتراح')),
          DropdownMenuItem(value: 'order',      child: Text('طلب')),
          DropdownMenuItem(value: 'return',     child: Text('إرجاع أو استبدال')),
        ],
        onChanged: (val) {
          if (val != null) setState(() => _selectedType = val);
        },
      ),
    );
  }
}
