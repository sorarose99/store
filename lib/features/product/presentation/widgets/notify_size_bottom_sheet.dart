import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class NotifySizeBottomSheet extends StatefulWidget {
  const NotifySizeBottomSheet({super.key});

  @override
  State<NotifySizeBottomSheet> createState() => _NotifySizeBottomSheetState();
}

class _NotifySizeBottomSheetState extends State<NotifySizeBottomSheet> {
  final List<String> _availableSizes = [
    '3S', '4S', '5S', '6S', '7S', '8S',
    '3M', 'L', 'XL', '2XL', '3XL', '4XL',
    '5XL', '6XL', '7XL', '8XL'
  ]; // Using mock data close to image. The image has 35, 4S, 5S, 6S, 7S, 8S, 1S, S, M, L, XL, 2XL, 3XL, 4XL, 5XL, 6XL, 7XL, 8XL.
  // Let's refine the list to exactly match image or similar grid.
  
  final List<String> _exactSizes = [
    '3S', '4S', '5S', '6S', '7S', '8S',
    '1S', 'S', 'M', 'L', 'XL', '2XL',
    '3XL', '4XL', '5XL', '6XL', '7XL', '8XL'
  ];

  String? _selectedSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textDark),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const Text(
                  'أخبرني بمقاسك',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 20), // Balance
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Subtitle
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'حدد الحجم',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Size Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Directionality(
              textDirection: TextDirection.ltr, // Align chips LTR as in design
              child: Wrap(
                spacing: 8,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _exactSizes.map((size) {
                  final isSelected = _selectedSize == size;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSize = size;
                      });
                    },
                    child: Container(
                      width: 48,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: isSelected ? AppColors.textDark : const Color(0xFFE5E5EA),
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        size,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.textDark : AppColors.textGrey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Send Button
          Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).padding.bottom + 16.0,
            ),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedSize != null
                    ? () {
                        // Action for Send
                        Navigator.of(context).pop();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: const Color(0xFFE5E5EA),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'إرسال',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
