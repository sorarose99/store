import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/colors.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'licenses'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.verified, // closest to the starburst badge
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'licenses'.tr(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'licenses_updated'.tr(),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 48),
            _buildLicenseItem('license_1'.tr()),
            _buildLicenseItem('license_2'.tr()),
            _buildLicenseItem('license_3'.tr()),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textMid,
          height: 1.8,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}
