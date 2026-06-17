import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/filter_options_entity.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterOptionsEntity? initialFilters;

  const FilterBottomSheet({super.key, this.initialFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  late bool _showDiscountsOnly;
  late List<String> _selectedColors;
  late List<String> _selectedSizes;
  late List<int> _selectedRatings;

  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  final List<String> _availableSizes = [
    'XS', 'S', 'M', 'L', 'XL', '2XL',
    '3XL', '4XL', '5XL', '6XL', '7XL', '8XL'
  ];
  final List<int> _availableRatings = [1, 2, 3, 4, 5];
  final List<String> _availableColors = ['أسود', 'بني', 'أبيض', 'بيج', 'أحمر', 'كحلي'];

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters ?? const FilterOptionsEntity();
    _minPrice = filters.minPrice;
    _maxPrice = filters.maxPrice;
    _showDiscountsOnly = filters.showDiscountsOnly;
    
    // Parse initial color
    if (filters.selectedColor != null) {
      if (filters.selectedColor == 'الأسود والبني') {
        _selectedColors = ['أسود', 'بني'];
      } else {
        // Strip out 'أسود داكن' conversions if needed
        final color = filters.selectedColor == 'أسود داكن' ? 'أسود' : filters.selectedColor!;
        _selectedColors = [color];
      }
    } else {
      _selectedColors = [];
    }

    _selectedSizes = List.from(filters.selectedSizes);
    _selectedRatings = List.from(filters.selectedRatings);

    _minPriceController.text = _minPrice.toInt().toString();
    _maxPriceController.text = _maxPrice.toInt().toString();
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Color _getColorValue(String colorName) {
    switch (colorName) {
      case 'أسود':
        return Colors.black;
      case 'بني':
        return const Color(0xFF8B4513);
      case 'أبيض':
        return Colors.white;
      case 'بيج':
        return const Color(0xFFF5F5DC);
      case 'أحمر':
        return const Color(0xFFE53935);
      case 'كحلي':
        return const Color(0xFF002244);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(color: AppColors.border, height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Section
                    _buildSectionTitle('السعر'),
                    _buildPriceInputs(),
                    const SizedBox(height: 12),
                    _buildDiscountCheckbox(),
                    const Divider(color: AppColors.border, height: 32),
                    
                    // Colors Section
                    _buildSectionTitle('الألوان'),
                    _buildColorSelector(),
                    const Divider(color: AppColors.border, height: 32),
                    
                    // Sizes Section
                    _buildSectionTitle('المقاسات'),
                    _buildSizeSelector(),
                    const Divider(color: AppColors.border, height: 32),
                    
                    // Ratings Section
                    _buildSectionTitle('التقييم'),
                    _buildRatingSelector(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textDark, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Text(
            'تصفية النتائج',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(width: 48), // Spacer for centering
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    // Show subtitle hint if color is selected
    String? subtitle;
    if (title == 'الألوان' && _selectedColors.isNotEmpty) {
      if (_selectedColors.contains('أسود') && _selectedColors.contains('بني') && _selectedColors.length == 2) {
        subtitle = 'الأسود والبني';
      } else {
        subtitle = _selectedColors.join('، ');
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Text(
                  '($subtitle)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ],
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textDark),
        ],
      ),
    );
  }

  Widget _buildPriceInputs() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField('من', _minPriceController),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'إلى',
            style: TextStyle(
              color: AppColors.textGrey,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        Expanded(
          child: _buildTextField('إلى', _maxPriceController),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          fontFamily: 'Tajawal',
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          hintText: '0.0',
          hintStyle: const TextStyle(color: Color(0xFFC7C7CC)),
          prefixText: '   ',
          suffixText: '$label   ',
          suffixStyle: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountCheckbox() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showDiscountsOnly = !_showDiscountsOnly;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: _showDiscountsOnly,
              onChanged: (val) {
                setState(() {
                  _showDiscountsOnly = val ?? false;
                });
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'عرض التخفيضات فقط',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _availableColors.map((colorName) {
          final isSelected = _selectedColors.contains(colorName);
          final colorVal = _getColorValue(colorName);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedColors.remove(colorName);
                } else {
                  _selectedColors.add(colorName);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorVal,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorVal == Colors.white ? const Color(0xFFE5E5EA) : Colors.transparent,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: colorVal == Colors.white ? Colors.black : Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSizeSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _availableSizes.map((size) {
        final isSelected = _selectedSizes.contains(size);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedSizes.remove(size);
              } else {
                _selectedSizes.add(size);
              }
            });
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : const Color(0xFFF2F3F8),
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFFE5E5EA),
                width: 0.5,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              size,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textDark,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _availableRatings.map((rating) {
          final isSelected = _selectedRatings.contains(rating);
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedRatings.remove(rating);
                  } else {
                    _selectedRatings.add(rating);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFF9E6) : const Color(0xFFF2F3F8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFFCC00) : const Color(0xFFE5E5EA),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: isSelected ? const Color(0xFFFFCC00) : const Color(0xFFD1D1D6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$rating ★',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.textDark : AppColors.textGrey,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList().reversed.toList(),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _minPriceController.text = '0';
                  _maxPriceController.text = '1000';
                  _showDiscountsOnly = false;
                  _selectedColors.clear();
                  _selectedSizes.clear();
                  _selectedRatings.clear();
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.textDark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'مسح الفلاتر',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Determine selected color string representation
                String? finalColor;
                if (_selectedColors.isNotEmpty) {
                  if (_selectedColors.contains('أسود') && _selectedColors.contains('بني') && _selectedColors.length == 2) {
                    finalColor = 'الأسود والبني';
                  } else {
                    finalColor = _selectedColors.first;
                  }
                }

                Navigator.of(context).pop(FilterOptionsEntity(
                  minPrice: double.tryParse(_minPriceController.text) ?? 0,
                  maxPrice: double.tryParse(_maxPriceController.text) ?? 1000,
                  showDiscountsOnly: _showDiscountsOnly,
                  selectedColor: finalColor,
                  selectedSizes: _selectedSizes,
                  selectedRatings: _selectedRatings,
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text(
                'تصفية',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
