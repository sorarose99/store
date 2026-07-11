import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';

class CheckoutLocationSearchPage extends StatefulWidget {
  const CheckoutLocationSearchPage({super.key});

  @override
  State<CheckoutLocationSearchPage> createState() =>
      _CheckoutLocationSearchPageState();
}

class _CheckoutLocationSearchPageState
    extends State<CheckoutLocationSearchPage> {
  List<String> get saudiCities => [
    'riyadh_1'.tr(),
    'grandmother'.tr(),
    'mecca'.tr(),
    'al_madinah_al_munawwarah'.tr(),
    'dammam'.tr(),
    'the_news'.tr(),
    'jubail'.tr(),
    'alhofuf'.tr(),
    'taif'.tr(),
    'tabuk'.tr(),
    'khamis_mushayt'.tr(),
    'hail'.tr(),
    'najran'.tr(),
    'jazan'.tr(),
    'abha'.tr(),
    'buraidah'.tr(),
    'unayzah'.tr(),
    'al_kharj'.tr(),
    'it_stems'.tr(),
    'qatif'.tr(),
  ];

  final _searchController = TextEditingController();
  List<String> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _filteredCities = saudiCities;
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
        _filteredCities = saudiCities;
      } else {
        _filteredCities = saudiCities
            .where((city) => city.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: context.surfaceColor,
        appBar: AppBar(
          backgroundColor: context.surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'shipping_address'.tr(),
            style: TextStyle(
              color: context.textDark,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: Column(
          children: [
            // Search Input container
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 12.0.h),
              child: Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.border),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: context.textDark,
                      fontFamily: 'Tajawal'),
                  decoration: InputDecoration(
                    hintText: 'search_for_a_city'.tr(),
                    hintStyle: TextStyle(
                        fontSize: 13.sp,
                        color: context.textGrey,
                        fontFamily: 'Tajawal'),
                    prefixIcon: Icon(Icons.location_on_outlined,
                        color: context.primaryColor, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: context.textGrey, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                  ),
                ),
              ),
            ),

            // Top indicator / Subtitle
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
              child: Row(
                children: [
                  Icon(Icons.my_location_rounded,
                      color: context.primaryColor, size: 18),
                  SizedBox(width: 8.w),
                  Text(
                    'available_cities_in_the'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: context.textMid,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: context.border, height: 16.h, thickness: 1),

            // Cities List
            Expanded(
              child: _filteredCities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off_outlined,
                              color: context.textGrey.withValues(alpha: 0.5),
                              size: 64),
                          SizedBox(height: 16.h),
                          Text(
                            'no_results_found'.tr(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: context.textGrey,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'make_sure_you_type'.tr(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: context.textGrey,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: _filteredCities.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1.h, color: context.border),
                      itemBuilder: (context, index) {
                        final city = _filteredCities[index];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 4.h, horizontal: 8.w),
                          leading: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: context.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.map_outlined,
                                color: context.primaryColor, size: 18),
                          ),
                          title: Text(
                            city,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: context.textDark,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 14, color: context.textGrey),
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
