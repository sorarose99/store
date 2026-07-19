import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/colors.dart';
import '../blocs/account_bloc.dart';
import '../blocs/account_event.dart';
import '../blocs/account_state.dart';
import 'delete_account_success_page.dart';

class DeleteAccountPasswordPage extends StatefulWidget {
  const DeleteAccountPasswordPage({super.key});

  @override
  State<DeleteAccountPasswordPage> createState() => _DeleteAccountPasswordPageState();
}

class _DeleteAccountPasswordPageState extends State<DeleteAccountPasswordPage> {
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  /// Whether the current Firebase user signed in via email/password.
  /// Social users (Google, Apple) have no password and skip that field.
  bool get _isEmailPasswordUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return true; // Treat unknown as email/password (safer)
    return user.providerData.any((p) => p.providerId == 'password');
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submitDelete() {
    final password = _isEmailPasswordUser ? _passwordController.text.trim() : '';
    if (_isEmailPasswordUser && password.isEmpty) return;
    context.read<AccountBloc>().add(AccountDeleteRequested(password: password));
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isEmailUser = _isEmailPasswordUser;

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
          isArabic ? 'حذف الحساب' : 'Delete Account',
          style: TextStyle(color: context.textDark, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountActionSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const DeleteAccountSuccessPage()),
              (route) => false,
            );
          } else if (state is AccountActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AccountActionLoading;

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isArabic ? 'تأكيد حذف الحساب' : 'Confirm Account Deletion',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isEmailUser
                              ? (isArabic
                                  ? 'يرجى إدخال كلمة المرور الخاصة بحسابك لتأكيد عملية الحذف. هذا الإجراء لا يمكن التراجع عنه.'
                                  : 'Please enter your password to confirm deletion. This action cannot be undone.')
                              : (isArabic
                                  ? 'أنت مسجل الدخول عبر حساب اجتماعي (جوجل / آبل). اضغط على تأكيد لحذف حسابك نهائياً. هذا الإجراء لا يمكن التراجع عنه.'
                                  : 'You are signed in via a social account (Google / Apple). Tap confirm to permanently delete your account. This action cannot be undone.'),
                          style: TextStyle(fontSize: 13, height: 1.6, color: context.textMid),
                        ),
                        if (isEmailUser) ...[
                          const SizedBox(height: 36),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            style: TextStyle(color: context.textDark),
                            decoration: InputDecoration(
                              hintText: isArabic ? 'كلمة المرور' : 'Password',
                              hintStyle: TextStyle(color: context.textGrey, fontSize: 14),
                              prefixIcon: Icon(Icons.lock_outline, color: context.textGrey),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: context.textGrey,
                                ),
                                onPressed: () => setState(() => _obscureText = !_obscureText),
                              ),
                              filled: true,
                              fillColor: context.surfaceColor,
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
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.errorColor,
                        disabledBackgroundColor: context.errorColor.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              isArabic ? 'حذف الحساب نهائياً' : 'Permanently Delete Account',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
    );
  }
}
