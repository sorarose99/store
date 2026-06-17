import 'package:equatable/equatable.dart';

class FilterOptionsEntity extends Equatable {
  final double minPrice;
  final double maxPrice;
  final bool showDiscountsOnly;
  final String? selectedColor;
  final List<String> selectedSizes;
  final List<int> selectedRatings;

  const FilterOptionsEntity({
    this.minPrice = 0,
    this.maxPrice = 1000,
    this.showDiscountsOnly = false,
    this.selectedColor,
    this.selectedSizes = const [],
    this.selectedRatings = const [],
  });

  FilterOptionsEntity copyWith({
    double? minPrice,
    double? maxPrice,
    bool? showDiscountsOnly,
    String? selectedColor,
    List<String>? selectedSizes,
    List<int>? selectedRatings,
  }) {
    return FilterOptionsEntity(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      showDiscountsOnly: showDiscountsOnly ?? this.showDiscountsOnly,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSizes: selectedSizes ?? this.selectedSizes,
      selectedRatings: selectedRatings ?? this.selectedRatings,
    );
  }

  @override
  List<Object?> get props => [
        minPrice,
        maxPrice,
        showDiscountsOnly,
        selectedColor,
        selectedSizes,
        selectedRatings,
      ];
}
