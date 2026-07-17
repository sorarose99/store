import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/colors.dart';

class TamaraBanner extends StatelessWidget {
  final double totalAmount;
  final VoidCallback onTap;

  const TamaraBanner({
    super.key,
    required this.totalAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? context.accentColor.withValues(alpha: 0.1)
              : const Color(0xFFFFF7F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFFFFA670).withValues(alpha: 0.3)
                  : const Color(0xFFFFE0CC),
              width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFA670),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'T',
                      style: TextStyle(
                        color: context.surfaceColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${'split_in_3'.tr()} ${(totalAmount / 3).toStringAsFixed(2)} ${'sar'.tr()}',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textDark,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_back_ios,
                size: 12,
                color: context.textGrey),
          ],
        ),
      ),
    );
  }
}

class TabbyBanner extends StatelessWidget {
  final double totalAmount;
  final VoidCallback onTap;

  const TabbyBanner({
    super.key,
    required this.totalAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1BE39A).withValues(alpha: 0.1)
              : const Color(0xFFE8FAF4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1BE39A).withValues(alpha: 0.3)
                  : context.primaryLight,
              width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1BE39A), // Tabby green
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      't',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${'split_in_4'.tr()} ${(totalAmount / 4).toStringAsFixed(2)} ${'sar'.tr()}',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textDark,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_back_ios,
                size: 12,
                color: context.textGrey),
          ],
        ),
      ),
    );
  }
}
