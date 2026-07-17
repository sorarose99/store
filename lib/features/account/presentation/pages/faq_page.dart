import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';

class FaqItem {
  final String question;
  final String answer;
  bool isExpanded;

  FaqItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final List<FaqItem> _faqItems = [
    FaqItem(
      question:
          'هل تتوفر لديكم خدمة التوصيل لجميع مناطق المملكة العربية السعودية ودول الخليج العربي ؟',
      answer:
          'نعم، نوفر خدمة التوصيل والشحن لكافة مدن ومناطق المملكة العربية السعودية ودول الخليج العربي بالتعاون مع أفضل شركات الشحن السريع.',
    ),
    FaqItem(
      question: 'كم يستغرق التوصيل؟',
      answer:
          'يستغرق الشحن والتوصيل عادةً من 3 إلى 5 أيام عمل داخل المملكة العربية السعودية، ومن 5 إلى 7 أيام عمل لباقي دول الخليج العربي.',
    ),
    FaqItem(
      question: 'هل تتوفر خدمة التوصيل المجاني؟',
      answer:
          'نعم، نوفر توصيلاً مجانياً بالكامل لجميع الطلبات التي تتجاوز قيمتها 300 ﷼ أو ما يعادلها بالعملات الأخرى.',
    ),
    FaqItem(
      question: 'ما هي شروط الاستبدال والاسترجاع؟',
      answer:
          'يمكنك طلب استبدال أو استرجاع المنتجات خلال 14 يوماً من تاريخ استلام الطلب، بشرط أن تكون المنتجات بحالتها الأصلية وغير مستخدمة ومعها كافة التغليفات والملصقات الأصلية.',
    ),
    FaqItem(
      question: 'كيف يمكنني تتبع طلبي؟',
      answer:
          'يمكنك تتبع شحنتك بكل سهولة من خلال الانتقال إلى صفحة "طلباتي" في حسابك والضغط على تفاصيل الطلب لمشاهدة خط التتبع المباشر،  التتبع   ',
    ),
    FaqItem(
      question: 'هل يمكنني إلغاء طلبي؟',
      answer:
          'نعم، يمكنك إلغاء الطلب مباشرةً من التطبيق طالما أنه في مرحلة "قيد المعالجة" ولم يتم شحنه أو تسليمه لشركة الشحن بعد. في حال تم الشحن، يرجى التواصل مع الدعم الفني.',
    ),
    FaqItem(
      question: 'ما هي وسائل الدفع المتاحة؟',
      answer:
          'نوفر خيارات دفع متعددة وآمنة تشمل: ، فيزا (Visa)، ماستركارد (Mastercard)، آبل باي   (Apple Pay).',
    ),
    FaqItem(
      question: 'هل يمكنني الشراء بالتقسيط؟',
      answer:
          'نعم، يمكنك تقسيم فاتورتك على دفعات ميسرة بدون فوائد أو رسوم إضافية عبر اختيار خدمة تابي (Tabby) أو تمارا (Tamara) عند الانتقال لصفحة الدفع.',
    ),
  ];

  String _searchQuery = '';

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/966542139388');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openEmail() async {
    final String subject = Uri.encodeComponent('استفسار من تطبيق KDX');
    final uri = Uri.parse('mailto:support@kdx-sa.com?subject=$subject');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _faqItems
        .where((item) =>
            item.question.contains(_searchQuery) ||
            item.answer.contains(_searchQuery))
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                size: 20, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'الأسئلة الشائعة',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textDark),
          ),
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'ابحث عن سؤالك هنا...',
                    hintStyle:
                        TextStyle(color: AppColors.textGrey, fontSize: 13),
                    prefixIcon:
                        Icon(Icons.search, color: AppColors.textGrey, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // FAQs List
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد نتائج تطابق بحثك',
                        style:
                            TextStyle(color: AppColors.textGrey, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return Material(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                key: Key(item.question),
                                initiallyExpanded: item.isExpanded,
                                onExpansionChanged: (expanded) {
                                  setState(() {
                                    item.isExpanded = expanded;
                                  });
                                },
                                title: Text(
                                  item.question,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
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
                                      item.answer,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.textGrey,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ), // close inner Container
                        );
                      },
                    ),
            ),
            // Bottom Contact Support box
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'لم تجد إجابة لاستفسارك؟',
                      style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _openWhatsApp,
                        icon: const Icon(Icons.chat_bubble_outline, size: 20),
                        label: const Text(
                          'تواصل معنا عبر الواتساب',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
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
                        icon: const Icon(Icons.email_outlined, size: 20),
                        label: const Text(
                          'تواصل معنا عبر البريد',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
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
      ),
    );
  }
}
