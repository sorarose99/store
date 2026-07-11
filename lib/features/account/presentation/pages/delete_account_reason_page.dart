import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'delete_account_success_page.dart';

class DeleteAccountReasonPage extends StatefulWidget {
  const DeleteAccountReasonPage({super.key});

  @override
  State<DeleteAccountReasonPage> createState() => _DeleteAccountReasonPageState();
}

class _DeleteAccountReasonPageState extends State<DeleteAccountReasonPage> {
  String? _selectedReason;
  final _otherController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  bool _isButtonEnabled() {
    if (_selectedReason == null) return false;
    if (_selectedReason == 'other') {
      return _otherController.text.trim().isNotEmpty;
    }
    return true;
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
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textDark,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'حذف الحساب',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'يرجى اختيار سبب الحذف',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Options
                      _buildRadioOption('kdx_multiple', 'أمتلك أكثر من حساب في KDX'),
                      const Divider(color: Color(0xFFF9F9F9), height: 1),
                      _buildRadioOption('privacy_security', 'مخاوف تتعلق بالخصوصية والأمان'),
                      const Divider(color: Color(0xFFF9F9F9), height: 1),
                      _buildRadioOption('incorrect_info', 'معلومات تسجيل غير صحيحة'),
                      const Divider(color: Color(0xFFF9F9F9), height: 1),
                      _buildRadioOption('no_longer_buying', 'لم أعد أرغب في الشراء'),
                      const Divider(color: Color(0xFFF9F9F9), height: 1),
                      _buildRadioOption('other', 'أخرى'),
                      
                      // Other text field
                      AnimatedCrossFade(
                        firstChild: const SizedBox(width: double.infinity),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextFormField(
                            controller: _otherController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'يرجى إدخال السبب الآخر',
                              hintStyle: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF9F9F9),
                              contentPadding: const EdgeInsets.all(16),
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
                            ),
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),
                        ),
                        crossFadeState: _selectedReason == 'other'
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled()
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const DeleteAccountSuccessPage(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'التالي',
                      style: TextStyle(
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
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value, String label) {
    bool isSelected = _selectedReason == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedReason = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textGrey,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isSelected
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
