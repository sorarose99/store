import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class TermsSection {
  final String title;
  final String body;

  const TermsSection({required this.title, required this.body});
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock data (replace with API call later)
// ─────────────────────────────────────────────────────────────────────────────
final List<TermsSection> _termsSections = [
  const TermsSection(
    title: '١. قبول الشروط',
    body:
        'بتسجيلك أو استخدامك لهذا التطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي جزء منها، يُرجى عدم استخدام الخدمة.',
  ),
  const TermsSection(
    title: '٢. استخدام الحساب',
    body:
        'أنت مسؤول عن الحفاظ على سرية بيانات حسابك وكلمة المرور الخاصة بك. يُحظر نقل حسابك أو السماح لأي طرف ثالث باستخدامه.',
  ),
  const TermsSection(
    title: '٣. السياسات التجارية',
    body:
        'تخضع جميع عمليات البيع والشراء لسياسة الاسترجاع والاستبدال المعتمدة لدينا. يتعهد المستخدم بعدم نشر محتوى مضلل أو مخالف للآداب العامة.',
  ),
  const TermsSection(
    title: '٤. الملكية الفكرية',
    body:
        'جميع المحتويات والشعارات والتصاميم المنشورة على المنصة هي ملكية حصرية للشركة ومحمية بموجب قوانين الملكية الفكرية المعمول بها.',
  ),
  const TermsSection(
    title: '٥. تحديد المسؤولية',
    body:
        'لا تتحمل الشركة أي مسؤولية عن الأضرار غير المباشرة أو التبعية الناجمة عن استخدام الخدمة أو عدم القدرة على استخدامها.',
  ),
  const TermsSection(
    title: '٦. التعديلات',
    body:
        'تحتفظ الشركة بالحق في تعديل هذه الشروط في أي وقت. سيتم إخطارك بأي تغييرات جوهرية عبر البريد الإلكتروني أو إشعار داخل التطبيق.',
  ),
  const TermsSection(
    title: '٧. القانون الحاكم',
    body:
        'تخضع هذه الشروط لأحكام النظام السعودي وتختص المحاكم السعودية بالفصل في أي نزاعات تنشأ عنها.',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Page — shown as full-screen when user taps "الشروط والأحكام" in register
// ─────────────────────────────────────────────────────────────────────────────
class TermsAcceptancePage extends StatefulWidget {
  const TermsAcceptancePage({super.key});

  @override
  State<TermsAcceptancePage> createState() => _TermsAcceptancePageState();
}

class _TermsAcceptancePageState extends State<TermsAcceptancePage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!_hasScrolledToBottom) {
        setState(() => _hasScrolledToBottom = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'الشروط والأحكام',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // ── Scrollable Terms Body ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Intro banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.primary.withAlpha(60)),
                      ),
                      child: const Text(
                        'يُرجى قراءة الشروط والأحكام بعناية قبل الموافقة. تُشكّل هذه الشروط اتفاقية ملزمة بينك وبين المنصة.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Terms sections
                    ..._termsSections.map(
                      (section) => _TermsSectionWidget(section: section),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Bottom Agreement Panel ────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.border.withAlpha(180)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkbox row
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _agreed,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            side: const BorderSide(
                                color: AppColors.border, width: 1.5),
                            onChanged: (v) =>
                                setState(() => _agreed = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'لقد قرأت وأوافق على جميع الشروط والأحكام',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Accept button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _agreed
                          ? () => Navigator.pop(context, true)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _agreed
                            ? AppColors.primary
                            : AppColors.border,
                        disabledBackgroundColor: AppColors.border,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'أوافق وأكمل التسجيل',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _agreed ? Colors.white : AppColors.textGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────
class _TermsSectionWidget extends StatelessWidget {
  final TermsSection section;
  const _TermsSectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          // Teal left bar + body text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 80,
                margin: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Text(
                  section.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                    height: 1.7,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 1),
        ],
      ),
    );
  }
}
