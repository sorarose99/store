import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Earnings Page
// ─────────────────────────────────────────────────────────────────────────────
class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
          centerTitle: true,
          title: const Text('رصيد المكسبات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)], begin: Alignment.topRight, end: Alignment.bottomLeft),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إجمالي المكسبات', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    SizedBox(height: 8),
                    Text('1,000.00 ر.س', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BalanceStat(label: 'متاح للسحب', value: '575.00'),
                        _BalanceStat(label: 'قيد التحصيل', value: '425.00'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Withdraw Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.account_balance_outlined),
                  label: const Text('طلب سحب', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Breakdown list
              const Align(alignment: Alignment.centerRight, child: Text('تفاصيل العمولات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              const SizedBox(height: 12),
              ...List.generate(4, (i) => _EarningRow(
                label: 'عمولة طلب #22125${i + 1}',
                date: '${i + 1}/06/2024',
                amount: (25.0 + i * 12.5),
                status: i == 0 ? 'قيد التحصيل' : 'مكتمل',
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final String value;
  const _BalanceStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text('$value ر.س', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      );
}

class _EarningRow extends StatelessWidget {
  final String label;
  final String date;
  final double amount;
  final String status;
  const _EarningRow({required this.label, required this.date, required this.amount, required this.status});

  @override
  Widget build(BuildContext context) {
    final isComplete = status == 'مكتمل';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.attach_money_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('+ $amount ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF34C759), fontSize: 13)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isComplete ? const Color(0xFF34C759) : const Color(0xFFFF9500)).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isComplete ? const Color(0xFF34C759) : const Color(0xFFFF9500))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
