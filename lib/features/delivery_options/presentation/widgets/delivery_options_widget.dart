import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/delivery_options_cubit.dart';
import '../cubit/delivery_options_state.dart';
import '../../domain/entities/delivery_option.dart';
import '../../../../core/di/injection_container.dart';

class DeliveryOptionsWidget extends StatelessWidget {
  const DeliveryOptionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeliveryOptionsCubit>()..fetchDeliveryOptions(),
      child: const _DeliveryOptionsView(),
    );
  }
}

class _DeliveryOptionsView extends StatelessWidget {
  const _DeliveryOptionsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Spacer for centering or just balance
                Text(
                  'delivery_options_title'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.local_shipping_outlined,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant,
          ),
          
          // Body
          BlocBuilder<DeliveryOptionsCubit, DeliveryOptionsState>(
            builder: (context, state) {
              if (state is DeliveryOptionsLoading) {
                return Padding(
                  padding: EdgeInsets.all(24.w),
                  child: const Center(child: CircularProgressIndicator()),
                );
              } else if (state is DeliveryOptionsError) {
                return Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Center(
                    child: Text(
                      state.message,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                );
              } else if (state is DeliveryOptionsLoaded) {
                if (state.options.isEmpty) {
                  return const SizedBox();
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.options.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  itemBuilder: (context, index) {
                    final option = state.options[index];
                    final isSelected = state.selectedOption?.id == option.id;

                    return _DeliveryOptionTile(
                      option: option,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<DeliveryOptionsCubit>().selectOption(option);
                      },
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}

class _DeliveryOptionTile extends StatelessWidget {
  final DeliveryOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeliveryOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    option.description.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              size: 24.w,
            ),
          ],
        ),
      ),
    );
  }
}
