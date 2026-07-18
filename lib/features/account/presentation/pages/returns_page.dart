import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class ReturnsPage extends StatelessWidget {
  const ReturnsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: context.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          isArabic ? 'الإرجاع والاستبدال' : 'Returns & Exchanges',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.textDark),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Package return graphic
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: context.cardBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.border, width: 1),
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.swap_horizontal_circle_outlined,
                      size: 44,
                      color: context.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isArabic ? 'لا يوجد طلب للإرجاع' : 'No Return Requests Found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? 'هل ترغب في تقديم طلب إرجاع أو استبدال جديد؟ يمكنك إدارتها من هنا بكل سهولة.'
                    : 'Would you like to submit a new return or exchange request? You can manage them easily from here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to select order for return
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isArabic ? 'تقديم طلب إرجاع جديد' : 'Submit New Return Request',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
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
