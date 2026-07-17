import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/colors.dart';
import '../../features/search/presentation/pages/search_active_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/cart/presentation/pages/cart_filled_page.dart';

class KdxAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final Widget? bottom;
  final double height;

  const KdxAppBar({
    super.key,
    this.showBackButton = true,
    this.bottom,
    this.height = kToolbarHeight + 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [context.primaryColor, context.backgroundColor],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTopRow(context),
              if (bottom != null) bottom!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    return Row(
      children: [
        if (showBackButton)
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          )
        else
          Image.asset(
            'assets/images/logo.png',
            height: 32.h,
            fit: BoxFit.contain,
          ),
        SizedBox(width: 12.w),
        // Search Bar
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchActivePage()),
            ),
            child: Container(
              height: 38.h,
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 4,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: 12.w),
                  Icon(Icons.search, color: context.textDark, size: 20),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'search_2'.tr(),
                      style: TextStyle(
                          color: context.textGrey,
                          fontSize: 13.sp,
                          fontFamily: 'Tajawal'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Notification
        _buildIconWithBadge(
          context,
          icon: Icons.notifications_outlined,
          badgeCount: '1', // TODO: dynamic
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsPage()),
          ),
        ),
        SizedBox(width: 12.w),
        // Cart
        _buildIconWithBadge(
          context,
          icon: Icons.shopping_cart_outlined,
          badgeCount: '2', // TODO: dynamic
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CartFilledPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildIconWithBadge(BuildContext context,
      {required IconData icon,
      required String badgeCount,
      required VoidCallback onTap}) {
    final int count = int.tryParse(badgeCount) ?? 0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(icon, color: context.textDark, size: 24),
        ),
        if (count > 0)
          Positioned(
            top: -4,
            left: -4,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: context.accentColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeCount,
                style: TextStyle(
                    color: context.backgroundColor,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + (bottom != null ? 40.h : 0));
}

class KdxSliverAppBar extends StatelessWidget {
  final bool isScrolled;
  final Widget? bottom;
  final double bottomHeight;

  const KdxSliverAppBar({
    super.key,
    required this.isScrolled,
    this.bottom,
    this.bottomHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 60.h,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [context.primaryColor, context.backgroundColor],
          ),
          boxShadow: isScrolled ? AppColors.elevatedShadow : null,
        ),
      ),
      title: const KdxAppBar(showBackButton: false)._buildTopRow(context),
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight + 12.h),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: bottom!,
              ),
            )
          : null,
    );
  }
}
