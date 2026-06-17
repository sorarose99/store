import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../data/datasources/mock_checkout_data.dart';

class CheckoutLocationSearchPage extends StatefulWidget {
  const CheckoutLocationSearchPage({super.key});

  @override
  State<CheckoutLocationSearchPage> createState() => _CheckoutLocationSearchPageState();
}

class _CheckoutLocationSearchPageState extends State<CheckoutLocationSearchPage> {
  final _searchController = TextEditingController();
  List<String> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _filteredCities = MockCheckoutDataSource.saudiCities;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCities = MockCheckoutDataSource.saudiCities;
      } else {
        _filteredCities = MockCheckoutDataSource.saudiCities
            .where((city) => city.toLowerCase().contains(query))
            .toList();
      }
    });
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
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'عنوان الشحن',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: Column(
          children: [
            // Search Input container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 14, color: AppColors.textDark, fontFamily: 'Tajawal'),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن المدينة أو المنطقة...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textGrey, fontFamily: 'Tajawal'),
                    prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textGrey, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
              ),
            ),

            // Top indicator / Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'المدن المتاحة في المملكة العربية السعودية',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMid,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 16, thickness: 1),

            // Cities List
            Expanded(
              child: _filteredCities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off_outlined, color: AppColors.textGrey.withOpacity(0.5), size: 64),
                          const SizedBox(height: 16),
                          const Text(
                            'لم يتم العثور على نتائج',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'تأكد من كتابة اسم المدينة بشكل صحيح',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredCities.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final city = _filteredCities[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.map_outlined, color: AppColors.primary, size: 18),
                          ),
                          title: Text(
                            city,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
                          onTap: () {
                            // Return selected city to the calling screen
                            Navigator.of(context).pop(city);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
