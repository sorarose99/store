import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class PaymentCardEntity {
  final String id;
  final String providerName;
  final String cardHolder;
  final String lastFourDigits;
  final String expiryDate;
  final Color cardColor;
  final String logoText; // Mock logo/text representing the provider

  const PaymentCardEntity({
    required this.id,
    required this.providerName,
    required this.cardHolder,
    required this.lastFourDigits,
    required this.expiryDate,
    required this.cardColor,
    required this.logoText,
  });
}

const _mockCards = [
  PaymentCardEntity(
    id: '1',
    providerName: 'مدى (Mada)',
    cardHolder: 'MOHAMMED AHMED',
    lastFourDigits: '4832',
    expiryDate: '12/27',
    cardColor: Color(0xFF16A085), // green
    logoText: 'Mada',
  ),
  PaymentCardEntity(
    id: '2',
    providerName: 'فيزا (Visa)',
    cardHolder: 'MOHAMMED AHMED',
    lastFourDigits: '9012',
    expiryDate: '09/26',
    cardColor: Color(0xFF2980B9), // blue
    logoText: 'VISA',
  ),
  PaymentCardEntity(
    id: '3',
    providerName: 'ماستركارد (Mastercard)',
    cardHolder: 'MOHAMMED AHMED',
    lastFourDigits: '5678',
    expiryDate: '04/28',
    cardColor: Color(0xFF2C3E50), // dark slate
    logoText: 'MC',
  ),
];

class PaymentCardsPage extends StatefulWidget {
  const PaymentCardsPage({super.key});

  @override
  State<PaymentCardsPage> createState() => _PaymentCardsPageState();
}

class _PaymentCardsPageState extends State<PaymentCardsPage> {
  final List<PaymentCardEntity> _cards = List.from(_mockCards);

  void _addNewCard() {
    // Show mock dialog or slide up adding sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  'إضافة بطاقة جديدة',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: _buildInputDecoration('اسم حامل البطاقة'),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: _buildInputDecoration('رقم البطاقة (16 خانة)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: _buildInputDecoration('تاريخ الانتهاء MM/YY'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: _buildInputDecoration('رمز الأمان CVV'),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _cards.add(
                        const PaymentCardEntity(
                          id: 'temp',
                          providerName: 'بطاقة جديدة',
                          cardHolder: 'MOHAMMED AHMED',
                          lastFourDigits: '1111',
                          expiryDate: '10/29',
                          cardColor: Color(0xFF8E44AD), // Purple
                          logoText: 'Card',
                        ),
                      );
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('إضافة البطاقة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'بطاقات الدفع',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Saved cards list
              const Text(
                'البطاقات المحفوظة',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    height: 180,
                    decoration: BoxDecoration(
                      color: card.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: card.cardColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              card.providerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              card.logoText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        // Card Number
                        Text(
                          '••••  ••••  ••••  ${card.lastFourDigits}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'حامل البطاقة',
                                  style: TextStyle(color: Colors.white70, fontSize: 9),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card.cardHolder,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'تاريخ الانتهاء',
                                  style: TextStyle(color: Colors.white70, fontSize: 9),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card.expiryDate,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Add card button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _addNewCard,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'إضافة بطاقة جديدة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
