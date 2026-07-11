import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/cart_item_entity.dart';

class SizeDistributionSheet extends StatefulWidget {
  final CartItemEntity item;
  final void Function(List<Map<String, dynamic>>) onSave;

  const SizeDistributionSheet({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  State<SizeDistributionSheet> createState() => _SizeDistributionSheetState();
}

class _SizeDistributionSheetState extends State<SizeDistributionSheet> {
  late List<Map<String, dynamic>> _breakdown;

  @override
  void initState() {
    super.initState();
    _breakdown = List.from(widget.item.breakdown.map((e) => Map<String, dynamic>.from(e)));
  }

  int get _totalDistributed {
    return _breakdown.fold<int>(0, (sum, b) => sum + (b['qty'] as int));
  }

  void _increase(String size) {
    if (_totalDistributed >= widget.item.quantity) return;
    
    setState(() {
      int idx = _breakdown.indexWhere((b) => b['size_name'] == size);
      if (idx >= 0) {
        _breakdown[idx]['qty'] = (_breakdown[idx]['qty'] as int) + 1;
      } else {
        _breakdown.add({'size_name': size, 'qty': 1});
      }
    });
  }

  void _decrease(String size) {
    setState(() {
      int idx = _breakdown.indexWhere((b) => b['size_name'] == size);
      if (idx >= 0) {
        int qty = _breakdown[idx]['qty'] as int;
        if (qty > 1) {
          _breakdown[idx]['qty'] = qty - 1;
        } else {
          _breakdown.removeAt(idx);
        }
      }
    });
  }

  int _getQty(String size) {
    int idx = _breakdown.indexWhere((b) => b['size_name'] == size);
    return idx >= 0 ? (_breakdown[idx]['qty'] as int) : 0;
  }

  @override
  Widget build(BuildContext context) {
    int remaining = widget.item.quantity - _totalDistributed;

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'توزيع المقاسات', // Distribute sizes
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'الكمية المتبقية للتوزيع: $remaining', // Remaining quantity to distribute
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: remaining == 0 ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(height: 24.h),
          
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: widget.item.productSizes.map((size) {
                  int qty = _getQty(size);
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'size_label'.tr()} $size',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        Container(
                          height: 32.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary, width: 1.w),
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.background,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: remaining > 0 ? () => _increase(size) : null,
                                child: Container(
                                  width: 32.w,
                                  color: Colors.transparent,
                                  alignment: Alignment.center,
                                  child: Icon(Icons.add, size: 16, color: remaining > 0 ? AppColors.textDark : AppColors.textGrey),
                                ),
                              ),
                              Text(
                                '$qty',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              GestureDetector(
                                onTap: qty > 0 ? () => _decrease(size) : null,
                                child: Container(
                                  width: 32.w,
                                  color: Colors.transparent,
                                  alignment: Alignment.center,
                                  child: Icon(Icons.remove, size: 16, color: qty > 0 ? AppColors.textDark : AppColors.textGrey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: remaining == 0
                ? () {
                    widget.onSave(_breakdown);
                    Navigator.of(context).pop();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: const Color(0xFFC7C7D9),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'حفظ التوزيع', // Save distribution
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
