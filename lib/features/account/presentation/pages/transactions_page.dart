import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class TransactionEntity {
  final String id;
  final String title;
  final String date;
  final double amount;
  final String type; // 'order' or 'credit' or 'withdraw'
  final String imageUrl;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    required this.imageUrl,
  });
}

const _mockTransactions = [
  TransactionEntity(
    id: '1',
    title: 'جاكيت جينز',
    date: '19 أكتوبر 2023 | 05:00 مساءً',
    amount: 26.8,
    type: 'order',
    imageUrl: 'assets/images/cat_fashion.png',
  ),
  TransactionEntity(
    id: '2',
    title: 'شحن المحفظة الإلكترونية',
    date: '18 أكتوبر 2023 | 02:30 مساءً',
    amount: 50.0,
    type: 'credit',
    imageUrl: '',
  ),
  TransactionEntity(
    id: '3',
    title: 'جاكيت جينز',
    date: '15 أكتوبر 2023 | 11:00 صباحاً',
    amount: 26.8,
    type: 'order',
    imageUrl: 'assets/images/cat_fashion.png',
  ),
  TransactionEntity(
    id: '4',
    title: 'جاكيت جينز',
    date: '12 أكتوبر 2023 | 04:15 مساءً',
    amount: 26.8,
    type: 'order',
    imageUrl: 'assets/images/cat_fashion.png',
  ),
  TransactionEntity(
    id: '5',
    title: 'جاكيت جينز',
    date: '10 أكتوبر 2023 | 01:20 مساءً',
    amount: 26.8,
    type: 'order',
    imageUrl: 'assets/images/cat_fashion.png',
  ),
  TransactionEntity(
    id: '6',
    title: 'شحن المحفظة الإلكترونية',
    date: '08 أكتوبر 2023 | 09:00 صباحاً',
    amount: 100.0,
    type: 'credit',
    imageUrl: '',
  ),
  TransactionEntity(
    id: '7',
    title: 'جاكيت جينز',
    date: '05 أكتوبر 2023 | 06:45 مساءً',
    amount: 26.8,
    type: 'order',
    imageUrl: 'assets/images/cat_fashion.png',
  ),
  TransactionEntity(
    id: '8',
    title: 'جاكيت جينز',
    date: '01 أكتوبر 2023 | 12:10 مساءً',
    amount: 26.8,
    type: 'order',
    imageUrl: 'assets/images/cat_fashion.png',
  ),
];

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'سجل المعاملات',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.textDark),
              onPressed: () {},
            ),
          ],
        ),
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: _mockTransactions.length,
          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
          itemBuilder: (context, index) {
            final tx = _mockTransactions[index];
            final isCredit = tx.type == 'credit';
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  // Image / Icon
                  if (isCredit)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F8F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wallet, color: Color(0xFF1ABC9C), size: 22),
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: const Color(0xFFF9F9F9),
                        child: tx.imageUrl.isNotEmpty
                            ? Image.asset(
                                tx.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.shopping_bag_outlined, color: AppColors.textGrey),
                              )
                            : const Icon(Icons.shopping_bag_outlined, color: AppColors.textGrey),
                      ),
                    ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tx.date,
                          style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                  // Amount and Type badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isCredit ? '+${tx.amount} د.إ' : '${tx.amount} د.إ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCredit ? const Color(0xFF2ECC71) : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCredit ? const Color(0xFFE8F8F5) : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isCredit ? 'شحن' : 'طلب',
                          style: TextStyle(
                            fontSize: 10,
                            color: isCredit ? const Color(0xFF1ABC9C) : AppColors.textGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
