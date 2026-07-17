import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../data/datasources/mock_account_data.dart';
import 'transactions_page.dart';

class WalletBalancePage extends StatelessWidget {
  const WalletBalancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockAccountDataSource.alternateUser; // Kamal

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: Column(
          children: [
            // Header Section with Gradient & Stack for overlapping card
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Curved Teal Gradient Header
                Container(
                  height: 240,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, Color(0xFF1F8D98)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            'رصيد الحساب',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 40), // Placeholder to center title
                        ],
                      ),
                      const Spacer(),
                      // Center Balance Amount
                      Column(
                        children: [
                          const Text(
                            'الرصيد المتاح',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${user.walletBalance.toStringAsFixed(2)} ﷼',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),

                // Overlapping balance statistics cards
                Positioned(
                  bottom: -40,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      // Points Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'مجموع نقاطك',
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.stars, color: Colors.orange, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    '12 نقطة',
                                    style: TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Available Balance Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'الرصيد المتاح',
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user.walletBalance.toStringAsFixed(2)} ﷼',
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            // Transactions Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'سجل التعاملات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsPage()));
                    },
                    child: const Text(
                      'عرض الكل',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Transactions List
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: 4,
                  separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE), indent: 70),
                  itemBuilder: (context, index) {
                    final isDeposit = index % 2 == 0;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2F2F7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: AppColors.textGrey,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        isDeposit ? 'شحن المحفظة (الكترونياً)' : 'طلب شراء',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      subtitle: const Text(
                        '12 اكتوبر 2023 10:30 صباحاً',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textGrey,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isDeposit ? '+ 25.0 ﷼' : '- 12.0 ﷼',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDeposit ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'ناجح',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
