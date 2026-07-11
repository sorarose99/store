import 'package:kdx/core/constants/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/filter_options_entity.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterOptionsEntity? initialFilters;
  final List<String> initialSelectedBrands;
  final List<String> availableSizes;
  final List<String> availableColors;
  final List<String> initialSelectedColors;

  const FilterBottomSheet({
    super.key,
    this.initialFilters,
    this.initialSelectedBrands = const [],
    this.availableSizes = const [],
    this.availableColors = const [],
    this.initialSelectedColors = const [],
  });

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
  final FocusNode _minPriceFocus = FocusNode();
  final FocusNode _maxPriceFocus = FocusNode();

  late List<String> _availableSizes;
  final List<int> _availableRatings = [1, 2, 3, 4, 5];
  late List<String> _availableColors;

  @override
  void initState() {
    super.initState();
    // Split the dummy string into an actual list of sizes if needed
    List<String> rawSizes = widget.availableSizes.isNotEmpty
        ? widget.availableSizes
        : ['XS', 'S', 'M', 'L', 'XL', '2XL', '3XL', '4XL', '5XL'];
        
    _availableSizes = rawSizes.expand((s) => s.split(',')).map((s) => s.trim()).toList();

    _availableColors = widget.availableColors.isNotEmpty
        ? widget.availableColors
        : [
            'black'.tr(),
            'brown'.tr(),
            'white'.tr(),
            'beige'.tr(),
            'red'.tr(),
            'navy_blue'.tr()
          ];

    final filters = widget.initialFilters ?? const FilterOptionsEntity();
    _minPrice = filters.minPrice;
    _maxPrice = filters.maxPrice;
    _showDiscountsOnly = filters.showDiscountsOnly;

    // Parse initial color
    if (filters.selectedColor != null) {
      if (filters.selectedColor == 'black_and_brown'.tr()) {
        _selectedColors = ['black'.tr(), 'brown'.tr()];
      } else {
        final color = filters.selectedColor == 'dark_black'.tr()
            ? 'black'.tr()
            : filters.selectedColor!;
        _selectedColors = [color];
      }
    } else {
      _selectedColors = [];
    }

    _selectedSizes = List.from(filters.selectedSizes);
    _selectedRatings = List.from(filters.selectedRatings);

    _minPriceController.text = _minPrice.toInt().toString();
    _maxPriceController.text = _maxPrice.toInt().toString();

    _minPriceFocus.addListener(() => setState(() {}));
    _maxPriceFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minPriceFocus.dispose();
    _maxPriceFocus.dispose();
    super.dispose();
  }

  Color _getColorValue(String colorName) {
    final lower = colorName.toLowerCase();
    if (lower.contains('black') || lower.contains('أسود')) return Colors.black;
    if (lower.contains('brown') || lower.contains('بني')) return Colors.brown;
    if (lower.contains('white') || lower.contains('أبيض')) return Colors.white;
    if (lower.contains('beige') || lower.contains('بيج')) return const Color(0xFFF5F5DC);
    if (lower.contains('red') || lower.contains('أحمر')) return Colors.red;
    if (lower.contains('navy') || lower.contains('أزرق')) return Colors.indigo;
    
    // Fallback logic for arbitrary colors
    final hash = lower.hashCode;
    return Color((hash & 0xFFFFFF) + 0xFF000000); 
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Container(
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Divider(color: context.borderColor, height: 1.h),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Section
                    _buildSectionTitle('the_price'.tr()),
                    _buildPriceInputs(),
                    SizedBox(height: 12.h),
                    _buildDiscountCheckbox(),
                    Divider(color: context.borderColor, height: 32.h),

                    // Colors Section
                    _buildSectionTitle('colors'.tr()),
                    _buildColorSelector(),
                    Divider(color: context.borderColor, height: 32.h),

                    // Sizes Section
                    _buildSectionTitle('sizes'.tr()),
                    _buildSizeSelector(),
                    Divider(color: context.borderColor, height: 32.h),

                    // Ratings Section
                    _buildSectionTitle('evaluation'.tr()),
                    _buildRatingSelector(),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.close, color: context.textDark, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'filter_results'.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: context.textDark,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(width: 48.w), // Spacer for centering
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    // Show subtitle hint if color is selected
    String? subtitle;
    if (title == 'colors'.tr() && _selectedColors.isNotEmpty) {
      if (_selectedColors.contains('black'.tr()) &&
          _selectedColors.contains('brown'.tr()) &&
          _selectedColors.length == 2) {
        subtitle = 'black_and_brown'.tr();
      } else {
        subtitle = _selectedColors.join(', ');
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(width: 8.w),
                Text(
                  '($subtitle)',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ],
          ),
          Icon(Icons.keyboard_arrow_down, size: 18, color: context.textDark),
        ],
      ),
    );
  }

  Widget _buildPriceInputs() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField('from'.tr(), _minPriceController, _minPriceFocus),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'to'.tr(),
            style: TextStyle(
              color: context.textGrey,
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        Expanded(
          child: _buildTextField('to'.tr(), _maxPriceController, _maxPriceFocus),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, FocusNode focusNode) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: focusNode.hasFocus ? context.primaryColor.withValues(alpha: 0.05) : context.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: focusNode.hasFocus ? context.primaryColor : context.primaryColor.withValues(alpha: 0.3), 
          width: 1.w
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: context.textDark,
          fontFamily: 'Tajawal',
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          hintText: '00_1'.tr(),
          hintStyle: TextStyle(color: context.textGreyLight),
          prefixText: '   ',
          suffixText: '$label   ',
          suffixStyle: TextStyle(
            color: context.textGrey,
            fontSize: 11.sp,
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
            width: 22.w,
            height: 22.h,
            child: Checkbox(
              value: _showDiscountsOnly,
              onChanged: (val) {
                setState(() {
                  _showDiscountsOnly = val ?? false;
                });
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              activeColor: context.primaryColor,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'show_discounts_only'.tr(),
            style: TextStyle(
              fontSize: 13.sp,
              color: context.textDark,
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: 12.w),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? context.primaryColor : Colors.transparent,
                  width: 2.w,
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 36.w : 32.w,
                height: isSelected ? 36.h : 32.h,
                decoration: BoxDecoration(
                  color: colorVal,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorVal == Colors.white || colorVal == context.backgroundColor
                        ? context.borderColor
                        : Colors.transparent,
                    width: 1.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.textDark.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        color: colorVal.computeLuminance() > 0.5
                            ? Colors.black87
                            : Colors.white,
                        size: 20,
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
      spacing: 10.w,
      runSpacing: 10.w,
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? context.primaryColor : context.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? context.primaryColor : context.borderColor,
                width: 1.w,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: context.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ] : [],
            ),
            child: Text(
              size,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : context.textDark,
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
        children: _availableRatings
            .map((rating) {
              final isSelected = _selectedRatings.contains(rating);
              return Padding(
                padding: EdgeInsets.only(left: 8.0.w),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected ? context.primaryColor : context.cardBackground,
                      border: Border.all(
                        color:
                            isSelected ? context.primaryColor : context.borderColor,
                        width: 1.w,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: isSelected
                              ? context.backgroundColor
                              : context.primaryColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '$rating ★',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? context.backgroundColor
                                : context.textDark,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            })
            .toList()
            .reversed
            .toList(),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        border: Border(top: BorderSide(color: context.borderColor, width: 1.w)),
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
                padding: EdgeInsets.symmetric(vertical: 14.h),
                side: BorderSide(color: context.textDark),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'clear_filters'.tr(),
                style: TextStyle(
                  color: context.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Determine selected color string representation
                String? finalColor;
                if (_selectedColors.isNotEmpty) {
                  if (_selectedColors.contains('black'.tr()) &&
                      _selectedColors.contains('brown'.tr()) &&
                      _selectedColors.length == 2) {
                    finalColor = 'black_and_brown'.tr();
                  } else {
                    finalColor = _selectedColors.join(',');
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
                backgroundColor: context.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                'filtering'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14.sp,
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
