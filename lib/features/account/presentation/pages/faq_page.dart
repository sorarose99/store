import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';

class FaqItem {
  final String questionAr;
  final String questionEn;
  final String answerAr;
  final String answerEn;
  bool isExpanded;

  FaqItem({
    required this.questionAr,
    required this.questionEn,
    required this.answerAr,
    required this.answerEn,
    this.isExpanded = false,
  });

  String getQuestion(bool isArabic) => isArabic ? questionAr : questionEn;
  String getAnswer(bool isArabic) => isArabic ? answerAr : answerEn;
}

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final List<FaqItem> _faqItems = [
    FaqItem(
      questionAr: 'هل تتوفر لديكم خدمة التوصيل لجميع مناطق المملكة العربية السعودية ودول الخليج العربي ؟',
      questionEn: 'Do you deliver to all regions of Saudi Arabia and the Arabian Gulf countries?',
      answerAr: 'نعم، نوفر خدمة التوصيل والشحن لكافة مدن ومناطق المملكة العربية السعودية ودول الخليج العربي بالتعاون مع أفضل شركات الشحن السريع.',
      answerEn: 'Yes, we provide delivery and shipping to all cities and regions of Saudi Arabia and the Gulf countries in cooperation with the best express shipping companies.',
    ),
    FaqItem(
      questionAr: 'كم يستغرق التوصيل؟',
      questionEn: 'How long does delivery take?',
      answerAr: 'يستغرق الشحن والتوصيل عادةً من 3 إلى 5 أيام عمل داخل المملكة العربية السعودية، ومن 5 إلى 7 أيام عمل لباقي دول الخليج العربي.',
      answerEn: 'Shipping and delivery usually take 3 to 5 business days within Saudi Arabia, and 5 to 7 business days to other Gulf countries.',
    ),
    FaqItem(
      questionAr: 'هل تتوفر خدمة التوصيل المجاني؟',
      questionEn: 'Is free delivery available?',
      answerAr: 'نعم، نوفر توصيلاً مجانياً بالكامل لجميع الطلبات التي تتجاوز قيمتها 300 ﷼ أو ما يعادلها بالعملات الأخرى.',
      answerEn: 'Yes, we provide free delivery for all orders exceeding 300 SAR or equivalent in other currencies.',
    ),
    FaqItem(
      questionAr: 'ما هي شروط الاستبدال والاسترجاع؟',
      questionEn: 'What are the terms of return and exchange?',
      answerAr: 'يمكنك طلب استبدال أو استرجاع المنتجات خلال 14 يوماً من تاريخ استلام الطلب، بشرط أن تكون المنتجات بحالتها الأصلية وغير مستخدمة ومعها كافة التغليفات والملصقات الأصلية.',
      answerEn: 'You can request a return or exchange within 14 days of receiving your order, provided that the products are in their original, unused condition with all original packaging and tags.',
    ),
    FaqItem(
      questionAr: 'كيف يمكنني تتبع طلبي؟',
      questionEn: 'How can I track my order?',
      answerAr: 'يمكنك تتبع شحنتك بكل سهولة من خلال الانتقال إلى صفحة "طلباتي" في حسابك والضغط على تفاصيل الطلب لمشاهدة خط التتبع المباشر.',
      answerEn: 'You can easily track your shipment by going to "My Orders" in your account and clicking on the order details to see the live tracking line.',
    ),
    FaqItem(
      questionAr: 'هل يمكنني إلغاء طلبي؟',
      questionEn: 'Can I cancel my order?',
      answerAr: 'نعم، يمكنك إلغاء الطلب مباشرةً من التطبيق طالما أنه في مرحلة "قيد المعالجة" ولم يتم شحنه أو تسليمه لشركة الشحن بعد. في حال تم الشحن، يرجى التواصل مع الدعم الفني.',
      answerEn: 'Yes, you can cancel the order directly from the app as long as it is in the "Processing" stage and has not been shipped or handed over to the shipping company yet. If shipped, please contact customer support.',
    ),
    FaqItem(
      questionAr: 'ما هي وسائل الدفع المتاحة؟',
      questionEn: 'What payment methods are available?',
      answerAr: 'نوفر خيارات دفع متعددة وآمنة تشمل: فيزا (Visa)، ماستركارد (Mastercard)، آبل باي (Apple Pay).',
      answerEn: 'We offer multiple secure payment options, including: Visa, Mastercard, and Apple Pay.',
    ),
    FaqItem(
      questionAr: 'هل يمكنني الشراء بالتقسيط؟',
      questionEn: 'Can I pay in installments?',
      answerAr: 'نعم، يمكنك تقسيم فاتورتك على دفعات ميسرة بدون فوائد أو رسوم إضافية عبر اختيار خدمة تابي (Tabby) أو تمارا (Tamara) عند الانتقال لصفحة الدفع.',
      answerEn: 'Yes, you can split your bill into easy interest-free payments by choosing Tabby or Tamara at checkout.',
    ),
  ];

  String _searchQuery = '';

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/966542139388');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch WhatsApp: $e');
    }
  }

  Future<void> _openEmail() async {
    final String subject = Uri.encodeComponent('استفسار من تطبيق KDX');
    final uri = Uri.parse('mailto:support@kdx-sa.com?subject=$subject');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch Email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final filteredItems = _faqItems
        .where((item) =>
            item.getQuestion(isArabic).toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.getAnswer(isArabic).toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: context.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          isArabic ? 'الأسئلة الشائعة' : 'FAQs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: context.textDark,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: context.surfaceColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: context.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: TextStyle(color: context.textDark),
                decoration: InputDecoration(
                  hintText: isArabic ? 'ابحث عن سؤالك هنا...' : 'Search your question here...',
                  hintStyle: TextStyle(color: context.textGrey, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: context.textGrey, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // FAQs List
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Text(
                      isArabic ? 'لا توجد نتائج تطابق بحثك' : 'No results match your search',
                      style: TextStyle(color: context.textGrey, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: context.surfaceColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: context.border),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              key: Key(item.getQuestion(isArabic)),
                              initiallyExpanded: item.isExpanded,
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  item.isExpanded = expanded;
                                });
                              },
                              iconColor: context.primaryColor,
                              collapsedIconColor: context.textGrey,
                              title: Text(
                                item.getQuestion(isArabic),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: context.textDark,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16.0,
                                    right: 16.0,
                                    bottom: 16.0,
                                  ),
                                  child: Text(
                                    item.getAnswer(isArabic),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: context.textGrey,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Bottom Contact Support box
          Container(
            padding: const EdgeInsets.all(16),
            color: context.surfaceColor,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isArabic ? 'لم تجد إجابة لاستفسارك؟' : 'Didn\'t find an answer to your inquiry?',
                    style: TextStyle(fontSize: 13, color: context.textGrey),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _openWhatsApp,
                      icon: const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.white),
                      label: Text(
                        isArabic ? 'تواصل معنا عبر الواتساب' : 'Contact us via WhatsApp',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _openEmail,
                      icon: const Icon(Icons.email_outlined, size: 20, color: Colors.white),
                      label: Text(
                        isArabic ? 'تواصل معنا عبر البريد' : 'Contact us via Email',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
