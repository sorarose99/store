import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class ShippingCountry {
  final String name;
  final String code;
  final String flag;
  final String currency;

  const ShippingCountry({
    required this.name,
    required this.code,
    required this.flag,
    required this.currency,
  });
}

const _shippingCountries = [
  ShippingCountry(name: 'المملكة العربية السعودية', code: 'SA', flag: '🇸🇦', currency: 'ريال سعودي (SAR)'),
  ShippingCountry(name: 'الإمارات العربية المتحدة', code: 'AE', flag: '🇦🇪', currency: 'درهم إماراتي (AED)'),
  ShippingCountry(name: 'الكويت', code: 'KW', flag: '🇰🇼', currency: 'دينار كويتي (KWD)'),
  ShippingCountry(name: 'البحرين', code: 'BH', flag: '🇧🇭', currency: 'دينار بحريني (BHD)'),
  ShippingCountry(name: 'قطر', code: 'QA', flag: '🇶🇦', currency: 'ريال قطري (QAR)'),
  ShippingCountry(name: 'عمان', code: 'OM', flag: '🇴🇲', currency: 'ريال عماني (OMR)'),
];

class ShipToPage extends StatefulWidget {
  const ShipToPage({super.key});

  @override
  State<ShipToPage> createState() => _ShipToPageState();
}

class _ShipToPageState extends State<ShipToPage> with SingleTickerProviderStateMixin {
  String _selectedCountryCode = 'SA';
  late TabController _tabController;

  final List<Map<String, dynamic>> _policies = [
    {
      'title': 'عتبة الشحن المجاني',
      'icon': Icons.card_giftcard_rounded,
      'content': 'نحن نقدم شحنًا عاديًا مجانيًا بالكامل لجميع الطلبات داخل المملكة العربية السعودية دون أي حد أدنى للشراء. بالنسبة للشحن السريع، فهو مجاني للطلبات التي تزيد قيمتها عن 300 ريال سعودي، وبتكلفة 25 ريال للطلبات الأقل من ذلك.',
    },
    {
      'title': 'تتبع الشحنات المباشر',
      'icon': Icons.map_outlined,
      'content': 'بمجرد تأكيد طلبك، يمكنك تتبع حالته لحظة بلحظة من خلال صفحة "طلباتي" عبر الجدول الزمني التفاعلي. سنرسل لك أيضًا رسالة نصية قصيرة (SMS) تحتوي على رابط التتبع المباشر الخاص بشركة الشحن بمجرد تسليم الشحنة لهم.',
    },
    {
      'title': 'الجمارك والرسوم الإضافية',
      'icon': Icons.receipt_long_outlined,
      'content': 'جميع الأسعار المعروضة في المتجر شاملة لضريبة القيمة المضافة (15%). بالنسبة للطلبات المشحونة إلى دول الخليج الأخرى، قد تخضع لرسوم جمركية محلية خفيفة عند نقطة الدخول وفقًا لقوانين بلدك، ويتم تسويتها مباشرة مع شركة التوصيل.',
    },
    {
      'title': 'سياسة عدم الاستلام والتوصيل المتكرر',
      'icon': Icons.assignment_return_outlined,
      'content': 'ستقوم شركة الشحن بمحاولة الاتصال بك لتسليم الطلب حتى 3 مرات متتالية. في حال عدم الاستجابة أو تعذر التسليم، سيتم إرجاع الطلب إلى مستودعاتنا. قد يتم فرض رسوم إرجاع بقيمة 15 ريالاً تخصم من قيمة المستردات في حال كان الإلغاء ناتجًا عن عدم استلام العميل المتعمد.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCountry = _shippingCountries.firstWhere((c) => c.code == _selectedCountryCode);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textDark,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'الشحن والتوصيل',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textGrey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Tajawal'),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13, fontFamily: 'Tajawal'),
            tabs: const [
              Tab(text: 'بلد الشحن'),
              Tab(text: 'الأسعار والرسوم'),
              Tab(text: 'سياسات التوصيل'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Country & Currency Selector
            _buildCountrySelectorTab(activeCountry),

            // Tab 2: Shipping Options & Rates
            _buildRatesTab(),

            // Tab 3: Detailed Policies
            _buildPoliciesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySelectorTab(ShippingCountry activeCountry) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Selected Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.tealGlowShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'وجهة الشحن الحالية',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      activeCountry.flag,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeCountry.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'العملة المحلية: ${activeCountry.currency}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'نشط',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'اختر وجهة شحن أخرى:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 12),

          // Country selection list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _shippingCountries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final country = _shippingCountries[index];
              final isSelected = country.code == _selectedCountryCode;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCountryCode = country.code;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم تغيير بلد الشحن والعملة بنجاح إلى ${country.name}',
                        style: const TextStyle(fontFamily: 'Tajawal'),
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : const Color(0xFFEEEEEE),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected ? AppColors.cardShadow : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9FC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          country.flag,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              country.name,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: AppColors.textDark,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              country.currency,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textGrey,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 22,
                        )
                      else
                        const Icon(
                          Icons.circle_outlined,
                          color: Color(0xFFCCCCCC),
                          size: 22,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRatesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'خيارات الشحن والرسوم المتاحة',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 14),

          // Standard Shipping Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECEEF5)),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FDF0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF34C759), size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'شحن ستاندرد (عادي)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'مدة التوصيل: 4 – 8 أيام عمل كحد أقصى للعنوان.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textGrey,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8FDF0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'مجاني بالكامل',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF34C759),
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Express Shipping Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECEEF5)),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.rocket_launch_outlined, color: Color(0xFF007AFF), size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'شحن إكسبريس (سريع)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'مدة التوصيل: 24 – 48 ساعة فقط (للمدن الرئيسية).',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textGrey,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F4FD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '25.00 ر.س',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF007AFF),
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '(مجاني للطلبات فوق 300 ر.س)',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textGrey,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'شركاء الخدمات اللوجستية المعتمدين',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 12),

          // Logistics partners badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPartnerLogo('Aramex', const Color(0xFFE31B23)),
              _buildPartnerLogo('SMSA Express', const Color(0xFF002B49)),
              _buildPartnerLogo('DHL Express', const Color(0xFFFFCC00), labelColor: Colors.black),
              _buildPartnerLogo('KDX Carrier', AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPoliciesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _policies.length,
      itemBuilder: (context, index) {
        final policy = _policies[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          color: Colors.white,
          child: ExpansionTile(
            leading: Icon(policy['icon'] as IconData, color: AppColors.primary),
            title: Text(
              policy['title'] as String,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Tajawal',
              ),
            ),
            iconColor: AppColors.primary,
            collapsedIconColor: AppColors.textGrey,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedAlignment: Alignment.topRight,
            children: [
              Text(
                policy['content'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMid,
                  height: 1.5,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPartnerLogo(String name, Color bg, {Color labelColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: bg.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Text(
        name,
        style: TextStyle(
          color: labelColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }
}
