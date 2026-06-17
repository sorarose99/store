import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class SearchEmptyPage extends StatelessWidget {
  const SearchEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Composed Document Search X Illustration
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Document File Background
                    const Icon(
                      Icons.description_outlined,
                      size: 110,
                      color: Color(0xFFE5E5EA),
                    ),
                    
                    // Overlapping Search Circle
                    Positioned(
                      bottom: 8,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: const [
                            // Circular search ring base
                            Icon(
                              Icons.radio_button_unchecked_rounded,
                              size: 38,
                              color: Color(0xFFC7C7CC),
                            ),
                            // Small X mark inside the search lens
                            Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Color(0xFFC7C7CC),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Error Heading Message
                const Text(
                  'عذراً، لم يتم العثور على نتائج بحث',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Try Again Teal Button
                SizedBox(
                  width: 150,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'أعد المحاولة',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60), // Shifting content slightly upwards for a balanced layout
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Container(
        height: 38,
        margin: const EdgeInsets.only(left: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F3F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textGrey, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textDark,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(text: 'ابحث'),
                    TextSpan(
                      text: ' |',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
