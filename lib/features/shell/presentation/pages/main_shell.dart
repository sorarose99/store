import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/blocs/home_bloc.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../../core/di/injection_container.dart';
import '../../../category/presentation/pages/category_navigation_page.dart';
import '../../../cart/presentation/blocs/cart_bloc.dart';
import '../../../cart/presentation/blocs/cart_state.dart';
import '../../../cart/presentation/pages/cart_filled_page.dart';
import '../../../wishlist/presentation/pages/wishlist_filled_page.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../../../core/constants/colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const CategoryNavigationPage(),
    const CartFilledPage(),
    const WishlistFilledPage(),
    const _AccountTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: _BottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

// ── Home tab with its own BLoC provider ──────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>(),
      child: const HomePage(),
    );
  }
}

// ── Account tab with its own BLoC provider ───────────────────────────────────
class _AccountTab extends StatelessWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context) {
    return const AccountPage();
  }
}

// ── Bottom Navigation Bar — Namshe floating pill style ────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.shadowColor.withAlpha(25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: context.primaryColor.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Row(
              children: List.generate(5, (i) {
                final isActive = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.symmetric(
                            horizontal: isActive ? 14 : 0,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? context.primaryColor.withAlpha(35)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: i == 2
                                ? _CartBadgeIcon(isActive: isActive)
                                : Icon(
                                    isActive
                                        ? _activeIcon(i)
                                        : _inactiveIcon(i),
                                    key: ValueKey(isActive),
                                    color: isActive
                                        ? context.primaryColor
                                        : context.textGrey,
                                    size: 22,
                                  ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w400,
                            color: isActive
                                ? context.primaryColor
                                : context.textGrey,
                          ),
                          child: Directionality(
                            textDirection: ui.TextDirection.rtl,
                            child: Text(_label(i)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  String _label(int i) {
    return [
      'home'.tr(),
      'الأقسام',
      'cart'.tr(),
      'wishlist'.tr(),
      'account'.tr()
    ][i];
  }

  IconData _inactiveIcon(int i) {
    return [
      Icons.home_outlined,
      Icons.grid_view_outlined,
      Icons.shopping_bag_outlined,
      Icons.favorite_outline_rounded,
      Icons.person_outline_rounded,
    ][i];
  }

  IconData _activeIcon(int i) {
    return [
      Icons.home_rounded,
      Icons.grid_view_rounded,
      Icons.shopping_bag_rounded,
      Icons.favorite_rounded,
      Icons.person_rounded,
    ][i];
  }
}

/// Cart tab icon with a live badge from [CartBloc]
class _CartBadgeIcon extends StatelessWidget {
  final bool isActive;
  const _CartBadgeIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (prev, curr) => curr is CartCountLoaded || curr is CartLoaded,
      builder: (context, state) {
        int count = 0;
        if (state is CartCountLoaded) {
          count = state.count;
        } else if (state is CartLoaded) {
          count = state.items.length;
        }

        final icon = Icon(
          isActive ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined,
          key: ValueKey(isActive),
          color: isActive ? context.primaryColor : context.textGrey,
          size: 22,
        );

        if (count <= 0) return icon;

        return Badge(
          label: Text(
            count > 99 ? '99+' : '$count',
            style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold),
          ),
          backgroundColor: context.primaryColor,
          child: icon,
        );
      },
    );
  }
}
