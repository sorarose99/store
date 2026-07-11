import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class CountryEntity {
  final String name;
  final String code;
  final String flag; // Emoji or asset path

  const CountryEntity({
    required this.name,
    required this.code,
    required this.flag,
  });
}

const _countries = [
  CountryEntity(name: 'المملكة العربية السعودية', code: 'SA', flag: '🇸🇦'),
  CountryEntity(name: 'البحرين', code: 'BH', flag: '🇧🇭'),
  CountryEntity(name: 'الكويت', code: 'KW', flag: '🇰🇼'),
  CountryEntity(name: 'قطر', code: 'QA', flag: '🇶🇦'),
  CountryEntity(name: 'الإمارات العربية المتحدة', code: 'AE', flag: '🇦🇪'),
  CountryEntity(name: 'عمان', code: 'OM', flag: '🇴🇲'),
];

class CountrySelectorPage extends StatefulWidget {
  final String selectedCountryCode;
  final String selectedLanguage;

  const CountrySelectorPage({
    super.key,
    required this.selectedCountryCode,
    required this.selectedLanguage,
  });

  @override
  State<CountrySelectorPage> createState() => _CountrySelectorPageState();
}

class _CountrySelectorPageState extends State<CountrySelectorPage> {
  late String _currentLanguage;
  late String _currentCountryCode;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.selectedLanguage;
    _currentCountryCode = widget.selectedCountryCode;
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
            'اللغة والبلد',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Language section
              const Text(
                'اللغة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _currentLanguage,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                decoration: InputDecoration(
                  hintText: 'اختر اللغة',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'ar', child: Text('عربي', style: TextStyle(fontSize: 14))),
                  DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(fontSize: 14))),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _currentLanguage = val);
                },
              ),
              const SizedBox(height: 24),

              // Country section
              const Text(
                'البلد / المنطقة',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _countries.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final country = _countries[index];
                  final isSelected = _currentCountryCode == country.code;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      setState(() {
                        _currentCountryCode = country.code;
                      });
                    },
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      country.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: AppColors.textDark,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primary, size: 22)
                        : const Icon(Icons.circle_outlined, color: AppColors.textGrey, size: 22),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Save button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'language': _currentLanguage,
                      'countryCode': _currentCountryCode,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'تطبيق التغييرات',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
