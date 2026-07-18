import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../home/presentation/blocs/home_bloc.dart';
import '../../../home/presentation/blocs/home_event.dart';
import '../../../home/presentation/blocs/home_state.dart';
import '../../../home/presentation/widgets/product_list_widgets.dart';
import '../../../shell/presentation/pages/main_shell.dart' as kdx_shell;

class CartEmptyPage extends StatelessWidget {
  const CartEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<HomeBloc>()..add(const HomeStarted()),
      child: Directionality(
        textDirection: Directionality.of(context),
        child: Scaffold(
          backgroundColor: context.surfaceColor,
          appBar: AppBar(
            backgroundColor: context.surfaceColor,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'cart'.tr(),
              style: TextStyle(
                color: context.textDark,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 50.h),

                // Custom Illustration (browser window with X mark and shopping basket icon overlay)
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Browser window outline
                      Container(
                        width: 110.w,
                        height: 110.h,
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: context.primaryColor, width: 1.5.w),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Browser header bar
                            Container(
                              height: 18.h,
                              decoration: BoxDecoration(
                                color: context.primaryColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Row(
                                children: [
                                  Container(
                                    width: 5.w,
                                    height: 5.h,
                                    decoration: BoxDecoration(
                                      color: context.backgroundColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Container(
                                    width: 5.w,
                                    height: 5.h,
                                    decoration: BoxDecoration(
                                      color: context.backgroundColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Container(
                                    width: 5.w,
                                    height: 5.h,
                                    decoration: BoxDecoration(
                                      color: context.backgroundColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Icon(
                                  Icons.shopping_basket_outlined,
                                  size: 40,
                                  color: context.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Basket overlay at top-right
                      Positioned(
                        top: -10,
                        right: -10,
                        child: Container(
                          width: 32.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            color: context.backgroundColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: context.textDark.withValues(alpha: 0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.shopping_basket,
                            color: context.primaryColor,
                            size: 16,
                          ),
                        ),
                      ),
                      // X mark overlay at bottom-left
                      Positioned(
                        bottom: -10,
                        left: -10,
                        child: Container(
                          width: 32.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            color: context.backgroundColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: context.textDark.withValues(alpha: 0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: context.textGrey,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 36.h),

                // Empty State Text
                Text(
                  'sorry_your_shopping_cart'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textDark,
                    fontFamily: 'Tajawal',
                  ),
                ),
                SizedBox(height: 24.h),

                // Go Shopping Button
                SizedBox(
                  width: 140.w, // Match mockup button width
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to home shell
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const kdx_shell.MainShell(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'go_shopping'.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: context.backgroundColor,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 48.h),

                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoaded && state.products.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              'similar_products_1'.tr(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textDark,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Padding(
                            padding: EdgeInsets.only(bottom: 40.h),
                            child: ProductHorizontalRow(
                              heroTagPrefix: 'cart_empty_rec',
                              products: state.products,
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                SizedBox(height: 48.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
