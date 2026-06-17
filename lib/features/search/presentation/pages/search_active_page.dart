import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'search_empty_page.dart';
import '../../../search_filter/presentation/pages/product_grid_page.dart';
import '../../../camera_search/presentation/pages/camera_search_page.dart';

class SearchActivePage extends StatefulWidget {
  const SearchActivePage({super.key});

  @override
  State<SearchActivePage> createState() => _SearchActivePageState();
}

class _SearchActivePageState extends State<SearchActivePage> {
  final TextEditingController _searchController = TextEditingController();
  
  // Default autocomplete items matching Screen 4
  List<String> _suggestions = [
    'فساتين تاجوال',
    'فساتين زفاف',
    'فساتين حفلات',
  ];

  // Backup popular lists for when input is cleared
  final List<String> _popularSearches = [
    'فساتين سهرة',
    'هوديز رجالي',
    'حقائب جلدية',
    'أحذية رياضية',
    'عطور عربية',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-populate with the query from the mockup to show the autocomplete layout directly
    _searchController.text = 'فساتين كاجوال';
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;

    // Direct routing mocks: if query is empty/not found, open empty page
    if (query.trim() == 'فارغ' || query.trim() == 'empty') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SearchEmptyPage()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductGridPage(categoryName: query),
        ),
      );
    }
  }

  void _removeSuggestion(int index) {
    setState(() {
      _suggestions.removeAt(index);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            const Divider(color: AppColors.border, height: 1, thickness: 1),
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildRecentAndPopularSection()
                  : _buildAutocompleteSuggestionsList(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
        decoration: BoxDecoration(
          color: const Color(0xFFF2F3F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _handleSearch,
          onChanged: (val) {
            setState(() {}); // trigger rebuild to switch lists if input becomes empty
          },
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: 'Tajawal',
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            prefixIcon: const Icon(Icons.search, color: AppColors.textGrey, size: 20),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textGrey, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 20),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CameraSearchPage()),
                    );
                  },
                ),
              ],
            ),
            hintText: 'ابحث عن منتجات، ماركات...',
            hintStyle: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutocompleteSuggestionsList() {
    if (_suggestions.isEmpty) {
      return Center(
        child: Text(
          'لا توجد اقتراحات بحثية متاحة',
          style: TextStyle(fontFamily: 'Tajawal', color: AppColors.textGrey, fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _suggestions.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            suggestion,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              fontFamily: 'Tajawal',
            ),
          ),
          leading: const Icon(Icons.search, color: AppColors.textGrey, size: 18),
          trailing: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textGrey, size: 16),
            onPressed: () => _removeSuggestion(index),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
          onTap: () {
            _searchController.text = suggestion;
            _handleSearch(suggestion);
          },
        );
      },
    );
  }

  Widget _buildRecentAndPopularSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'البحث الشائع',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _popularSearches.map((tag) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = tag;
                  _handleSearch(tag);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
