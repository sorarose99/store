import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class CountryInfo {
  final String code;
  final String name;
  final String flag;

  const CountryInfo({required this.code, required this.name, required this.flag});
}

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(CountryInfo) onCountryChanged;
  final String? Function(String?)? validator;
  final String labelText;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.onCountryChanged,
    this.validator,
    this.labelText = 'رقم الهاتف',
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  final List<CountryInfo> _countries = const [
    CountryInfo(code: '+966', name: 'السعودية', flag: '🇸🇦'),
    CountryInfo(code: '+971', name: 'الإمارات العربية المتحدة', flag: '🇦🇪'),
    CountryInfo(code: '+965', name: 'الكويت', flag: '🇰🇼'),
    CountryInfo(code: '+968', name: 'عمان', flag: '🇴🇲'),
    CountryInfo(code: '+973', name: 'البحرين', flag: '🇧🇭'),
    CountryInfo(code: '+974', name: 'قطر', flag: '🇶🇦'),
    CountryInfo(code: '+962', name: 'الأردن', flag: '🇯🇴'),
  ];

  late CountryInfo _selectedCountry;
  List<CountryInfo> _filteredCountries = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries.first;
    _filteredCountries = _countries;
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _countries;
      } else {
        _filteredCountries = _countries.where((c) {
          return c.name.toLowerCase().contains(query) || c.code.contains(query);
        }).toList();
      }
    });
  }

  // Renders the searchable dropdown exactly matching the mockup list layout
  void _showCountryDropdown() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.15),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                backgroundColor: Colors.white,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 400),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search box inside the country list popup
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setStateBuilder(() {});
                          },
                          decoration: const InputDecoration(
                            hintText: 'ابحث عن رمز الدولة',
                            prefixIcon: Icon(Icons.search, color: AppColors.textGrey, size: 20),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            filled: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // List of countries
                      Expanded(
                        child: ListView.builder(
                          itemCount: _filteredCountries.length,
                          itemBuilder: (context, index) {
                            final country = _filteredCountries[index];
                            final isSelected = country.code == _selectedCountry.code;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCountry = country;
                                });
                                widget.onCountryChanged(country);
                                _searchController.clear();
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      country.flag,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        country.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      country.code,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: AppColors.textGrey,
                                      ),
                                      textDirection: TextDirection.ltr,
                                    ),
                                  ],
                                ),
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.labelText,
          style: const TextStyle(
            fontSize: 13.0,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            // Country Dropdown Box (Left Side in RTL Layout)
            GestureDetector(
              onTap: _showCountryDropdown,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _selectedCountry.code,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedCountry.flag,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Phone Input Field (Right Side in RTL Layout)
            Expanded(
              child: SizedBox(
                height: 50,
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  validator: widget.validator,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0512341126', // Mockup placeholder number
                    suffixIcon: Icon(Icons.phone_outlined, color: AppColors.textGrey, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
