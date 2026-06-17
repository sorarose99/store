import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../data/datasources/mock_account_data.dart';
import '../pages/edit_profile_page.dart';
import '../../../orders/presentation/pages/orders_list_page.dart';
import '../pages/returns_page.dart';
import '../../../wishlist/presentation/pages/wishlist_filled_page.dart';
import '../pages/payment_cards_page.dart';
import '../pages/reviews_detail_page.dart';
import '../pages/terms_page.dart';
import '../pages/about_us_page.dart';
import '../pages/privacy_page.dart';
import '../pages/faq_page.dart';
import 'account_settings_page.dart';
import 'wallet_balance_page.dart';
import 'contact_info_page.dart';
import '../pages/delivery_addresses_page.dart';
import '../pages/coupons_page.dart';
import '../pages/complaints_page.dart';
import '../pages/ship_to_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockAccountDataSource.alternateUser; // Using Kamal from the mockup

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9), // Light background
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountSettingsPage()),
            ),
          ),
          centerTitle: true,
          title: const Text(
            'حسابي',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Section (User Info Card) ─────────────────────────
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top Row: Avatar & Greeting
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF2F2F7),
                              ),
                              child: const Icon(Icons.person, color: AppColors.textGrey, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'مرحباً بك، ${user.name}!',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
                      // Bottom Row: Wallet & Points
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const WalletBalancePage()),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      '140.00 ر.س',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'محفظة',
                                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: const Color(0xFFEEEEEE),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    '12',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'نقاطك',
                                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Group 1: Main Actions ──────────────────────────────────
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildProfileListTile(
                      icon: Icons.person_outline,
                      title: 'الملف الشخصي',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
                    ),
                    _buildDivider(),
                    _buildProfileListTile(
                      icon: Icons.local_shipping_outlined,
                      title: 'الشحن إلى',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShipToPage())),
                    ),
                    _buildDivider(),
                    _buildProfileListTile(
                      icon: Icons.inventory_2_outlined,
                      title: 'طلباتي',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersListPage())),
                    ),
                    _buildDivider(),
                    _buildProfileListTile(
                      icon: Icons.keyboard_return_outlined,
                      title: 'الإرجاع',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReturnsPage())),
                    ),
                    _buildDivider(),
                    _buildProfileListTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'المحفظة',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletBalancePage())),
                    ),
                    _buildDivider(),
                    _buildProfileListTile(
                      icon: Icons.location_on_outlined,
                      title: 'عناوين التوصيل',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryAddressesPage())),
                    ),
                    _buildDivider(),
                    _buildProfileListTile(
                      icon: Icons.credit_card_outlined,
                      title: 'بطاقات الدفع',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentCardsPage())),
                    ),
                    _buildDivider(),
                    _buildProfileListTile(
                      icon: Icons.local_offer_outlined,
                      title: 'كوبوناتي',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CouponsPage())),
                    ),
                    _buildDivider(),
                    _buildProfileListTile(
                      icon: Icons.favorite_border_outlined,
                      title: 'المفضلات',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistFilledPage())),
                    ),
                    _buildDivider(),
                    _buildProfileListTile(
                      icon: Icons.description_outlined,
                      title: 'الشروط والأحكام',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsPage())),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Group 2: Secondary Actions ─────────────────────────────
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildProfileListTile(
                      icon: Icons.info_outline,
                      title: 'من نحن',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsPage())),
                    ),
                    _buildDivider(),
                    _buildProfileListTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'سياسة الخصوصية والاستخدام',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPage())),
                    ),
                    _buildDivider(),
                    _buildProfileListTile(
                      icon: Icons.report_problem_outlined,
                      title: 'الشكاوى والاقتراحات',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintsPage())),
                    ),
                    _buildDivider(),
                    _buildProfileListTile(
                      icon: Icons.help_outline,
                      title: 'الأسئلة الشائعة',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqPage())),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),

              // ── Logout ──────────────────────────────────────────────────
              Container(
                color: Colors.white,
                child: _buildProfileListTile(
                  icon: Icons.logout_rounded,
                  title: 'تسجيل الخروج',
                  titleColor: Colors.red,
                  iconColor: Colors.red,
                  hideChevron: true,
                  onTap: () {
                    // Navigate to settings which handles logout for now
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountSettingsPage()));
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── Contact Us Footer ───────────────────────────────────────
              _buildContactFooter(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
    bool hideChevron = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? AppColors.textGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: titleColor ?? AppColors.textDark,
                ),
              ),
            ),
            if (!hideChevron)
              const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE), indent: 50);
  }

  Widget _buildContactFooter() {
    return Column(
      children: [
        const Text(
          'تواصل معنا',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        const Text(
          'لمتابعة مشترياتك ومعرفة المزيد من المعلومات\nيرجى التواصل معنا عبر القنوات التالية:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.5),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildContactIcon(Icons.call_outlined),
            const SizedBox(width: 16),
            _buildContactIcon(Icons.email_outlined),
            const SizedBox(width: 16),
            _buildContactIcon(Icons.chat_bubble_outline),
          ],
        ),
        const SizedBox(height: 32),
        // ── بطاقات الدفع ──────────────────────────────────────────────
        Row(
          children: const [
            Icon(Icons.chevron_left, size: 20, color: AppColors.textDark),
            SizedBox(width: 4),
            Text(
              'بطاقات الدفع',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Row 1
        Row(
          children: [
            Expanded(
              child: _buildPaymentTile(
                label: 'Apple Pay',
                brandWidget: const Text(
                  '\u{F8FF}Pay  Apple Pay',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildPaymentTile(
                label: 'بطاقة مدى البنكية',
                brandWidget: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D6F37),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'mada',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2
        Row(
          children: [
            Expanded(
              child: _buildPaymentTile(
                label: 'تحويل بنكي',
                brandWidget: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.account_balance, size: 14, color: Color(0xFF4CAF50)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildPaymentTile(
                label: 'تابي',
                brandWidget: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3CFFD0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'tabby',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Row 3
        Row(
          children: [
            Expanded(
              child: _buildPaymentTile(
                label: 'تمارا',
                brandWidget: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'tamara',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildPaymentTile(
                label: 'بطاقة إئتمانية',
                brandWidget: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F71),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'VISA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: AppColors.textDark),
    );
  }

  Widget _buildPaymentTile({required String label, required Widget brandWidget}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          brandWidget,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                fontFamily: 'Tajawal',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
