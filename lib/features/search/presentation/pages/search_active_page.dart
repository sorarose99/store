import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart';
import '../blocs/search_bloc.dart';
import '../../../search_filter/presentation/pages/product_grid_page.dart';
import '../../../camera_search/presentation/pages/camera_search_page.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';

class SearchActivePage extends StatelessWidget {
  const SearchActivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchBloc>()..add(SearchHistoryRequested()),
      child: const _SearchActiveView(),
    );
  }
}

class _SearchActiveView extends StatefulWidget {
  const _SearchActiveView();

  @override
  State<_SearchActiveView> createState() => _SearchActiveViewState();
}

class _SearchActiveViewState extends State<_SearchActiveView> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _popularSearchesMap = [];


  @override
  void initState() {
    super.initState();
    _loadPopularSearches();
  }

  Future<void> _loadPopularSearches() async {
    try {
      final getCategoriesUseCase = sl<GetCategoriesUseCase>();
      final result = await getCategoriesUseCase(page: 1);
      result.fold(
        (failure) {
          // Fallback if API fails
          if (mounted) {
            setState(() {
              _popularSearchesMap = [];
            });
          }
        },
        (data) {
          if (mounted) {
            setState(() {
              _popularSearchesMap = data.mainCategories
                  .take(8)
                  .map((e) => {'id': e.id, 'name': e.name, 'slug': e.slug})
                  .toList();
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Failed to load popular searches: $e');
    }
  }

  void _handleSearch(String query,
      {bool isCategory = false, String? displayName}) {
    if (query.trim().isEmpty) return;

    context.read<SearchBloc>().add(SearchQueryAdded(displayName ?? query));

    final filters = <String, dynamic>{};
    // Workaround: Backend category_name is too strict for main categories.
    // Use text search for both to ensure products are found.
    filters['search'] = query;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductGridPage(
          title: displayName ?? query,
          filters: filters,
        ),
      ),
    );
  }

  void _removeSuggestion(String query) {
    context.read<SearchBloc>().add(SearchQueryRemoved(query));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: context.surfaceColor,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Divider(color: context.border, height: 1.h, thickness: 1),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  List<String> history = [];
                  if (state is SearchHistoryLoaded) {
                    history = state.history;
                  }

                  if (_searchController.text.isEmpty && history.isEmpty) {
                    return _buildRecentAndPopularSection(context, history);
                  }

                  return _buildAutocompleteSuggestionsList(context, history);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.surfaceColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Container(
        height: 38.h,
        margin: EdgeInsets.only(left: 16.w),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.border, width: 0.8.w),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _handleSearch,
          onChanged: (val) {
            setState(() {});
          },
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: context.textDark,
            fontFamily: 'Tajawal',
          ),
          decoration: InputDecoration(
            filled: false,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10.h),
            prefixIcon: Icon(Icons.search, color: context.textGrey, size: 20),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, color: context.textGrey, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.camera_alt_outlined,
                      color: context.primaryColor, size: 20),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CameraSearchPage()),
                    );
                  },
                ),
              ],
            ),
            hintText: 'search_for_products_brands'.tr(),
            hintStyle: TextStyle(
              color: context.textGrey,
              fontSize: 12.sp,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutocompleteSuggestionsList(
      BuildContext context, List<String> history) {
    final query = _searchController.text.toLowerCase();
    final suggestions =
        history.where((h) => h.toLowerCase().contains(query)).toList();

    if (suggestions.isEmpty) {
      if (query.isNotEmpty) {
// If typing but no history matches, just show a "search for..." tile
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
          title: Text('البحث عن "$query"',
              style: TextStyle(fontFamily: 'Tajawal', color: context.textDark)),
          leading: Icon(Icons.search, color: context.textGrey, size: 18),
          onTap: () => _handleSearch(query),
        );
      }
      return Center(
        child: Text(
          'there_are_no_research'.tr(),
          style: TextStyle(
              fontFamily: 'Tajawal', color: context.textGrey, fontSize: 13.sp),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: suggestions.length + (query.isNotEmpty ? 1 : 0),
      separatorBuilder: (context, index) =>
          Divider(height: 1.h, color: context.border),
      itemBuilder: (context, index) {
// Always show "search now" tile first when user has typed something
        if (query.isNotEmpty && index == 0) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'البحث عن "$query"',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: context.primaryColor,
                fontFamily: 'Tajawal',
              ),
            ),
            leading: Icon(Icons.search, color: context.primaryColor, size: 18),
            onTap: () => _handleSearch(query),
          );
        }
        final suggestion = suggestions[query.isNotEmpty ? index - 1 : index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            suggestion,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: context.textDark,
              fontFamily: 'Tajawal',
            ),
          ),
          leading: Icon(Icons.history, color: context.textGrey, size: 18),
          trailing: IconButton(
            icon: Icon(Icons.close_rounded, color: context.textGrey, size: 16),
            onPressed: () => _removeSuggestion(suggestion),
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

  Widget _buildRecentAndPopularSection(
      BuildContext context, List<String> history) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (history.isNotEmpty) ...[
            Text(
              'search_history'.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: context.textDark,
                fontFamily: 'Tajawal',
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 10.w,
              children: history.map((tag) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = tag;
                    _handleSearch(tag);
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.border),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.textDark,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24.h),
          ],
          if (_popularSearchesMap.isNotEmpty) ...[
            Text(
              'popular_search'.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: context.textDark,
                fontFamily: 'Tajawal',
              ),
            ),
            SizedBox(height: 12.h),
          ],
          Wrap(
            spacing: 8.w,
            runSpacing: 10.w,
            children: _popularSearchesMap.map((tagMap) {
              final tag = tagMap['name'] as String;
              final slug = tagMap['slug'] as String?;
              return GestureDetector(
                onTap: () {
                  _searchController.text = tag;
                  _handleSearch(tag,
                      isCategory: true, displayName: tag);
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: context.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.border),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.textDark,
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
