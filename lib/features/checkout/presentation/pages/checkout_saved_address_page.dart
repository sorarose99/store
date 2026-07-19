import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/models/saved_address_model.dart';
import '../../domain/entities/checkout_entities.dart';
import '../blocs/checkout_bloc.dart';
import '../blocs/checkout_event.dart';
import '../blocs/checkout_state.dart';
import 'checkout_address_page.dart';
import 'checkout_payment_page.dart';
import '../../../../core/widgets/app_shimmer.dart';

class CheckoutSavedAddressPage extends StatelessWidget {
  const CheckoutSavedAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<CheckoutBloc>()..add(const CheckoutDataRequested()),
      child: const _CheckoutSavedAddressView(),
    );
  }
}

class _CheckoutSavedAddressView extends StatefulWidget {
  const _CheckoutSavedAddressView();

  @override
  State<_CheckoutSavedAddressView> createState() =>
      _CheckoutSavedAddressViewState();
}

class _CheckoutSavedAddressViewState extends State<_CheckoutSavedAddressView> {
  String? _selectedAddressId;

  void _onAddNewAddress() async {
    final newAddress = await Navigator.of(context).push<SavedAddressEntity>(
      MaterialPageRoute(
          builder: (_) => const CheckoutAddressPage(isFromSavedPage: true)),
    );

    if (newAddress != null && mounted) {
      context.read<CheckoutBloc>().add(CheckoutAddressAdded(newAddress));
    }
  }

  void _onContinue(List<SavedAddressEntity> addresses, List<String> activeGateways) {
    if (_selectedAddressId == null) {
      showCustomSnackBar(
        context,
        'please_choose_a_shipping'.tr(),
        isError: true,
      );
      return;
    }
    final selectedAddress =
        addresses.firstWhere((a) => a.id == _selectedAddressId);
    // Navigate to Payment Page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutPaymentPage(
          address: selectedAddress,
          activeGateways: activeGateways,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutDataLoaded) {
          final addressesList = state.data['addresses'] is List 
            ? (state.data['addresses'] as List)
            : [];
          final addresses = addressesList.map((e) => SavedAddressModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();

          if (addresses.isNotEmpty) {
            SavedAddressEntity? preferred;
            for (var a in addresses) {
              if (a.isDefault) {
                preferred = a;
                break;
              }
            }
            preferred ??= addresses.first;
            setState(() {
              _selectedAddressId = preferred!.id;
            });
          }
        } else if (state is CheckoutError) {
          showCustomSnackBar(
            context,
            getLocalizedError(state.message),
            isError: true,
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
        }
      },
      child: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          if (state is CheckoutLoading ||
              state is CheckoutInitial ||
              state is CheckoutError) {
            return Scaffold(
              backgroundColor: context.backgroundColor,
              appBar: AppBar(
                backgroundColor: context.surfaceColor.withValues(alpha: 0.8),
                elevation: 0,
                scrolledUnderElevation: 0,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      color: context.textDark, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                centerTitle: true,
                title: Text(
                  'purchase_address'.tr(),
                  style: TextStyle(
                    color: context.textDark,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              body: Padding(
                padding: EdgeInsets.all(16.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer(
                        width: double.infinity,
                        height: 200.h,
                        borderRadius: 12),
                    SizedBox(height: 16.h),
                    AppShimmer(
                        width: double.infinity,
                        height: 200.h,
                        borderRadius: 12),
                  ],
                ),
              ),
            );
          } else if (state is CheckoutDataLoaded) {
            // Try both camelCase and snake_case keys for API compatibility
            final rawAddresses = state.data['addresses']
                ?? state.data['user_addresses']
                ?? state.data['data']?['addresses']
                ?? [];
            final addressesList = rawAddresses is List ? rawAddresses : [];
            final addresses = addressesList.map((e) => SavedAddressModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();

            final rawGateways = state.data['paymentGateways']
                ?? state.data['payment_gateways']
                ?? state.data['data']?['payment_gateways']
                ?? [];
            final paymentGatewaysList = rawGateways is List ? rawGateways : [];
            final activeGateways = paymentGatewaysList
              .map((e) => e['name']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toList();

            return Directionality(
              textDirection: Directionality.of(context),
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: context.surfaceColor,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: context.textDark, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  centerTitle: true,
                  title: Text(
                    'purchase_address'.tr(),
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
                    Container(
                      color: context.backgroundColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildStep(context, 1, 'address'.tr(),
                              isActive: true, isCompleted: true),
                          buildStepDivider(isActive: false),
                          buildStep(context, 2, 'payment'.tr(),
                              isActive: false, isCompleted: false),
                          buildStepDivider(isActive: false),
                          buildStep(context, 3, 'review'.tr(),
                              isActive: false, isCompleted: false),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'choose_your_preferred_delivery'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textDark,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                            SizedBox(height: 12.h),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: addresses.length,
                              itemBuilder: (context, index) {
                                final address = addresses[index];
                                final isSelected =
                                    address.id == _selectedAddressId;

                                return GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedAddressId = address.id),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: EdgeInsets.only(bottom: 12.h),
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? context.primaryColor.withValues(alpha: 0.1)
                                          : context.backgroundColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? context.primaryColor
                                            : context.primaryColor.withValues(alpha: 0.2),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [BoxShadow(color: context.primaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
                                          : [BoxShadow(color: context.shadowColor.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 20.w,
                                          height: 20.h,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? context.primaryColor
                                                  : context.primaryColor.withValues(alpha: 0.3),
                                              width: isSelected ? 6 : 2,
                                            ),
                                            color: context.backgroundColor,
                                          ),
                                        ),
                                        SizedBox(width: 14.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      address.fullName,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14.sp,
                                                        color: context.textDark,
                                                        fontFamily: 'Tajawal',
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (address.isDefault) ...[
                                                    SizedBox(width: 8.w),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8.w,
                                                              vertical: 2.h),
                                                      decoration: BoxDecoration(
                                                        color: context.primaryColor.withValues(alpha: 0.12),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Text(
                                                        'default'.tr(),
                                                        style: TextStyle(
                                                          fontSize: 10.sp,
                                                          color: context.primaryColor,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontFamily: 'Tajawal',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              SizedBox(height: 6.h),
                                              Text(
                                                address.fullAddress,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: context.textDark87,
                                                  fontFamily: 'Tajawal',
                                                  height: 1.4.h,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                '${'phone'.tr()}: ${address.phone}',
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  color: context.textDark54,
                                                  fontFamily: 'Tajawal',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            GestureDetector(
                              onTap: _onAddNewAddress,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 20.h),
                                decoration: BoxDecoration(
                                  color: context.backgroundColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: context.primaryColor
                                        .withValues(alpha: 0.5),
                                    style: BorderStyle.solid,
                                    width: 1.5.w,
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_circle_outline_rounded,
                                          color: context.primaryColor,
                                          size: 22),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'add_a_new_address'.tr(),
                                        style: TextStyle(
                                          color: context.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                          fontFamily: 'Tajawal',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 32.h),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        boxShadow: [
                          BoxShadow(
                              color: context.shadowColor.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -4)),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _onContinue(addresses, activeGateways),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'continue_btn'.tr(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget buildStep(BuildContext context, int number, String label,
      {required bool isActive, required bool isCompleted}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22.w,
          height: 22.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? context.primaryColor
                : isActive
                    ? context.backgroundColor
                    : context.backgroundColor,
            border: Border.all(
              color: isCompleted || isActive
                  ? context.primaryColor
                  : context.primaryColor.withValues(alpha: 0.3),
              width: 2.w,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, size: 12, color: context.backgroundColor)
                : Text(
                    number.toString(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? context.primaryColor
                          : context.primaryColor.withValues(alpha: 0.5),
                      fontFamily: 'Tajawal',
                    ),
                  ),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight:
                isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isActive || isCompleted
                ? context.textDark
                : context.primaryColor.withValues(alpha: 0.5),
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget buildStepDivider({required bool isActive}) {
    return Container(
      width: 30.w,
      height: 1.5.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      color: isActive ? context.primaryColor : context.primaryColor.withValues(alpha: 0.2),
    );
  }
}
