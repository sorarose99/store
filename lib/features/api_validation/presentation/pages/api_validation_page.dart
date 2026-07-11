import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../cubit/api_validation_cubit.dart';
import '../cubit/api_validation_state.dart';
import '../../../../core/constants/colors.dart';

class ApiValidationPage extends StatelessWidget {
  const ApiValidationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ApiValidationCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('API Connection Test'),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Diagnostic Terminal',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: BlocBuilder<ApiValidationCubit, ApiValidationState>(
                  builder: (context, state) {
                    Color statusColor = context.textGrey;
                    IconData statusIcon = Icons.help_outline;
                    String logMessage = 'Ready to test connection...';

                    if (state is ApiValidationLoading) {
                      statusColor = context.primaryColor;
                      statusIcon = Icons.autorenew;
                      logMessage =
                          'Connecting to backend to validate API Key...';
                    } else if (state is ApiValidationSuccess) {
                      statusColor = context.successColor;
                      statusIcon = Icons.check_circle;
                      logMessage =
                          '200 OK: Authentication Successful.\nBackend is reachable and API Key is valid.';
                    } else if (state is ApiValidationFailure) {
                      statusColor = context.errorColor;
                      statusIcon = Icons.error;
                      logMessage =
                          'ERROR: Connection Failed.\nDetails: ${state.message}';
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0.w),
                            child: Row(
                              children: [
                                Icon(
                                  statusIcon,
                                  color: statusColor,
                                  size: 40,
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Text(
                                    state is ApiValidationSuccess
                                        ? 'Connected'
                                        : state is ApiValidationFailure
                                            ? 'Connection Failed'
                                            : state is ApiValidationLoading
                                                ? 'Testing...'
                                                : 'Idle'.tr(),
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.textDark.withValues(alpha: 0.87),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(12.w),
                            child: SingleChildScrollView(
                              child: Text(
                                '> $logMessage',
                                style: TextStyle(
                                  color: context.successColor,
                                  fontFamily: 'monospace',
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              BlocBuilder<ApiValidationCubit, ApiValidationState>(
                builder: (context, state) {
                  final isLoading = state is ApiValidationLoading;
                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<ApiValidationCubit>().testConnection();
                          },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: context.backgroundColor)
                        : Text(
                            'Test Connection',
                            style: TextStyle(fontSize: 18.sp),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
