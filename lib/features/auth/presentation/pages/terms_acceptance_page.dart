import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class TermsSection {
  final String title;
  final String body;

  TermsSection({required this.title, required this.body});
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock data (replace with API call later)
// ─────────────────────────────────────────────────────────────────────────────
final List<TermsSection> _termsSections = [
  TermsSection(
    title: '1_accept_the_terms'.tr(),
    body: 'by_registering_or_using'.tr(),
  ),
  TermsSection(
    title: '2_use_the_account'.tr(),
    body: 'you_are_responsible_for'.tr(),
  ),
  TermsSection(
    title: '3_trade_policies'.tr(),
    body: 'all_purchases_and_sales'.tr(),
  ),
  TermsSection(
    title: '4_intellectual_property'.tr(),
    body: 'all_content_logos_and'.tr(),
  ),
  TermsSection(
    title: '5_limitation_of_liability'.tr(),
    body: 'the_company_does_not'.tr(),
  ),
  TermsSection(
    title: '6_modifications'.tr(),
    body: 'the_company_reserves_the'.tr(),
  ),
  TermsSection(
    title: '7_governing_law'.tr(),
    body: 'these_terms_are_subject'.tr(),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Page — shown as full-screen when user taps 'terms_conditions'.tr() in register
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
      backgroundColor: context.surfaceColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'terms_conditions'.tr(),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: context.textDark,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Directionality(
        textDirection: Directionality.of(context),
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
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: context.primaryColor.withAlpha(60)),
                      ),
                      child: Text(
                        'please_read_the_terms'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: context.primaryColor,
                          height: 1.6.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Terms sections
                    ..._termsSections.map(
                      (section) => _TermsSectionWidget(section: section),
                    ),

                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),

            // ── Bottom Agreement Panel ────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: context.backgroundColor,
                border: Border(
                  top: BorderSide(color: context.border.withAlpha(180)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.textDark.withAlpha(12),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkbox row
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22.w,
                          height: 22.h,
                          child: Checkbox(
                            value: _agreed,
                            activeColor: context.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            side:
                                BorderSide(color: context.border, width: 1.5.w),
                            onChanged: (v) =>
                                setState(() => _agreed = v ?? false),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'i_have_read_and'.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: context.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Accept button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed:
                          _agreed ? () => Navigator.pop(context, true) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _agreed ? context.primaryColor : context.border,
                        disabledBackgroundColor: context.border,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'i_agree_and_complete'.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: _agreed
                              ? context.backgroundColor
                              : context.textGrey,
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
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            section.title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: context.textDark,
              height: 1.3.h,
            ),
          ),
          SizedBox(height: 8.h),
          // Teal left bar + body text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3.w,
                height: 80.h,
                margin: EdgeInsets.only(left: 10.w),
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Text(
                  section.body,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: context.textGrey,
                    height: 1.7.h,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: context.border, height: 1.h),
        ],
      ),
    );
  }
}
