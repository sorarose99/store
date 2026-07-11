import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart';
import '../blocs/notifications_bloc.dart';
import '../blocs/notifications_event.dart';
import '../blocs/notifications_state.dart';
import '../../../../core/widgets/app_shimmer.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<NotificationsBloc>()..add(const NotificationsRequested()),
      child: const _NotificationsContentView(),
    );
  }
}

class _NotificationsContentView extends StatelessWidget {
  const _NotificationsContentView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.surfaceColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'notifications'.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: context.textDark,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading ||
                state is NotificationsInitial) {
              return ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) => const ListTileShimmer(),
              );
            } else if (state is NotificationsError) {
              return Center(child: Text(state.message));
            } else if (state is NotificationsLoaded) {
              if (state.notifications.isEmpty) {
                return Center(child: Text('no_notifications'.tr()));
              }
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final notif = state.notifications[index];
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: context.primaryColor.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.local_offer_outlined,
                            color: context.primaryColor,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.title,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.textDark,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                notif.message,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: context.textGrey,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                notif.date,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: context.textGreyLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
