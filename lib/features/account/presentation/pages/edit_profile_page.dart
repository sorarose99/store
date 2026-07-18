import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/network/api_endpoints.dart';
import '../blocs/account_bloc.dart';
import '../blocs/account_state.dart';
import '../blocs/account_event.dart';
import 'edit_profile_gender_page.dart';
import 'edit_profile_dob_page.dart';

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
  late String _selectedDob;     // display  "d-m-yyyy"
  late String _selectedDobApi;  // API      "yyyy-mm-dd"

  File?   _avatarFile;  // newly picked local file
  String? _avatarUrl;   // existing remote URL

  final _picker = ImagePicker();

  // ── Init ─────────────────────────────────────────────────────────
  String _getDisplayProfilePhone(String phone) {
    String digits = phone.replaceAll(RegExp(r'\D'), '').trim();
    if (digits.startsWith('966')) {
      String rest = digits.substring(3);
      return '0$rest';
    }
    if (phone.startsWith('0')) {
      return phone;
    }
    if (phone.length == 9 && phone.startsWith('5')) {
      return '0$phone';
    }
    return phone;
  }

  String _formatProfilePhoneNumber(String phone) {
    String digits = phone.replaceAll(RegExp(r'\D'), '').trim();
    if (digits.startsWith('00966')) {
      digits = digits.substring(5);
    } else if (digits.startsWith('966')) {
      digits = digits.substring(3);
    } else if (digits.startsWith('05')) {
      digits = digits.substring(1);
    } else if (digits.startsWith('5')) {
      // normal
    }
    
    if (digits.length == 9 && digits.startsWith('5')) {
      return '+966$digits';
    }
    if (phone.startsWith('+')) {
      return phone;
    }
    return '+966$digits';
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<AccountBloc>().state;
    if (state is AccountLoaded) {
      final user = state.user;
      _nameController  = TextEditingController(text: user.name);
      _emailController = TextEditingController(text: user.email);
      _phoneController = TextEditingController(text: _getDisplayProfilePhone(user.phone));
      _selectedGender  = _genderLabel(user.gender);
      final dob        = user.dateOfBirth;
      _selectedDob     = '${dob.day}-${dob.month}-${dob.year}';
      _selectedDobApi  = _toApiDate(dob);
      _avatarUrl       = user.avatar;
    } else {
      _nameController  = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
      _selectedGender  = tr('male');
      _selectedDob     = '1-1-1990';
      _selectedDobApi  = '1990-01-01';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────
  String _genderLabel(String raw) {
    if (raw == 'male')   return tr('male');
    if (raw == 'female') return tr('female');
    return raw.isNotEmpty ? raw : tr('male');
  }

  String _toApiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Gender picker ─────────────────────────────────────────────────
  Future<void> _pickGender() async {
    final result = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        pageBuilder: (_, __, ___) =>
            EditProfileGenderPage(selectedGender: _selectedGender),
      ),
    );
    if (result != null) setState(() => _selectedGender = result);
  }

  // ── DOB picker ────────────────────────────────────────────────────
  Future<void> _pickDob() async {
    final result = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        pageBuilder: (_, __, ___) =>
            EditProfileDobPage(currentDob: _selectedDob),
      ),
    );
    if (result != null) {
      // result format "d-m-yyyy"
      final parts = result.split('-');
      if (parts.length == 3) {
        final parsed = DateTime.tryParse(
          '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}',
        );
        if (parsed != null) {
          setState(() {
            _selectedDob    = result;
            _selectedDobApi = _toApiDate(parsed);
          });
        }
      }
    }
  }

  // ── Avatar sheet ──────────────────────────────────────────────────
  void _showAvatarSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.textDark),
                title: Text(tr('take_photo'),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontSize: 14)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImage(ImageSource.camera);
                },
              ),
              const Divider(color: Color(0xFFF0F0F0)),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.textDark),
                title: Text(tr('choose_from_gallery'),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontSize: 14)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
        source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
    if (picked != null) setState(() => _avatarFile = File(picked.path));
  }

  // ── Save ─────────────────────────────────────────────────────────
  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final parts     = _nameController.text.trim().split(' ');
    final firstName = parts.first;
    final lastName  = parts.skip(1).join(' ');
    final genderApi = _selectedGender == tr('female') ? 'female' : 'male';

    final data = <String, dynamic>{
      'first_name': firstName,
      'last_name':  lastName,
      'name':       _nameController.text.trim(),
      'email':      _emailController.text.trim(),
      'phone':      _formatProfilePhoneNumber(_phoneController.text.trim()),
      'gender':     genderApi,
      'birth_date': _selectedDobApi,
    };

    if (_avatarFile != null) data['avatar'] = _avatarFile!.path;

    context.read<AccountBloc>().add(AccountUpdateProfileRequested(data));
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 20, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            tr('edit_profile'),
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.textDark),
          ),
        ),
        body: BlocListener<AccountBloc, AccountState>(
          listener: (context, state) {
            if (state is AccountActionSuccess) {
              context
                  .read<AccountBloc>()
                  .add(const AccountProfileRequested());
              Navigator.pop(context);
            } else if (state is AccountActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error),
              );
            }
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Avatar ────────────────────────────────
                        Center(
                          child: GestureDetector(
                            onTap: _showAvatarSheet,
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFF2F2F7)),
                                  child: ClipOval(child: _avatarWidget()),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: AppColors.elevatedShadow,
                                    ),
                                    child: const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 16,
                                        color: AppColors.textDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ── Name ──────────────────────────────────
                        _fieldLabel(tr('name')),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: _deco(tr('name')),
                          validator: (v) => v == null || v.isEmpty
                              ? tr('field_required')
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // ── Email ─────────────────────────────────
                        _fieldLabel(tr('email')),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _deco(tr('email')),
                          validator: (v) => v == null || !v.contains('@')
                              ? tr('invalid_email')
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // ── Phone ─────────────────────────────────
                        _fieldLabel(tr('mobile')),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _deco('05XXXXXXXX',
                              hintDir: TextDirection.ltr),
                          validator: (v) => v == null || v.length < 10
                              ? tr('invalid_phone')
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // ── DOB ───────────────────────────────────
                        _fieldLabel(tr('date_of_birth')),
                        const SizedBox(height: 8),
                        _selectTile(
                            value: _selectedDob, onTap: _pickDob),
                        const SizedBox(height: 20),

                        // ── Gender ────────────────────────────────
                        _fieldLabel(tr('gender')),
                        const SizedBox(height: 8),
                        _selectTile(
                            value: _selectedGender, onTap: _pickGender),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Save button ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: BlocBuilder<AccountBloc, AccountState>(
                  builder: (context, state) {
                    final loading = state is AccountActionLoading;
                    return ElevatedButton(
                      onPressed: loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.5),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              tr('save'),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────

  Widget _avatarWidget() {
    if (_avatarFile != null) {
      return Image.file(_avatarFile!,
          width: 100, height: 100, fit: BoxFit.cover);
    }
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return Image.network(
        ApiEndpoints.mediaUrl(_avatarUrl),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.person,
            size: 50, color: AppColors.textGrey),
      );
    }
    return const Icon(Icons.person, size: 50, color: AppColors.textGrey);
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark),
      );

  Widget _selectTile(
      {required String value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textDark)),
            const Icon(Icons.arrow_drop_down, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }

  InputDecoration _deco(String hint, {TextDirection? hintDir}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          color: AppColors.textGreyLight, fontSize: 14),
      hintTextDirection: hintDir,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
