import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'earnings_page.dart';
import 'transactions_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class CommissionStatsEntity {
  final double totalEarnings;
  final double pendingBalance;
  final int referralCount;
  final int orderCount;
  final String referralCode;

  const CommissionStatsEntity({
    required this.totalEarnings,
    required this.pendingBalance,
    required this.referralCount,
    required this.orderCount,
    required this.referralCode,
  });
}

const _mockStats = CommissionStatsEntity(
  totalEarnings: 1000,
  pendingBalance: 1425,
  referralCount: 8,
  orderCount: 12,
  referralCode: 'RAYA2024',
);

// ─────────────────────────────────────────────────────────────────────────────
// Commissions Page
// ─────────────────────────────────────────────────────────────────────────────
class CommissionsPage extends StatelessWidget {
  const CommissionsPage({super.key});

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
          title: const Text('العمولات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Profile Card ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEEEEEE))),
                child: Column(
                  children: [
                    CircleAvatar(radius: 36, backgroundColor: AppColors.primary.withOpacity(0.12), child: const Text('ر', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary))),
                    const SizedBox(height: 12),
                    const Text('ريا العربي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    const Text('مسوّق محترف', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CommissionStat(label: 'المكسبات', value: '${_mockStats.totalEarnings.toInt()}'),
                        _divider(),
                        _CommissionStat(label: 'قيد التحصيل', value: '${_mockStats.pendingBalance.toInt()}'),
                        _divider(),
                        _CommissionStat(label: 'الإحالات', value: '${_mockStats.referralCount}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Referral Code ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('رابط الإحالة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Expanded(child: Text('https://app.link/ref/${_mockStats.referralCode}', style: const TextStyle(fontSize: 12, color: AppColors.textGrey))),
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _SocialBtn(icon: Icons.share, label: 'مشاركة', onTap: () {}),
                        const SizedBox(width: 12),
                        _SocialBtn(icon: Icons.qr_code_2_rounded, label: 'QR كود', onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Quick Actions ─────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'رصيد المكسبات',
                      value: '${_mockStats.totalEarnings} ر.س',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EarningsPage())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.receipt_long_outlined,
                      label: 'سجل المعاملات',
                      value: '${_mockStats.orderCount} عملية',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TransactionsPage())),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(height: 40, width: 1, color: const Color(0xFFEEEEEE));
}

class _CommissionStat extends StatelessWidget {
  final String label;
  final String value;
  const _CommissionStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
        ],
      );
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SocialBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const _QuickActionCard({required this.icon, required this.label, required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 10),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
            ],
          ),
        ),
      );
}
