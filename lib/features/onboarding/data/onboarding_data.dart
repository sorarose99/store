/// Data model representing a single onboarding slide.
class OnboardingSlide {
  final String imagePath;
  final String tag;        // e.g. "KDX"
  final String title;
  final String description;

  const OnboardingSlide({
    required this.imagePath,
    required this.tag,
    required this.title,
    required this.description,
  });
}

/// The three slides matching the mockup exactly.
const List<OnboardingSlide> onboardingSlides = [
  OnboardingSlide(
    imagePath: 'assets/images/onboarding_1.png',
    tag: 'KDX',
    title: 'هل أنت جاهز لتعرف ماذا تلبس غداً؟',
    description:
        'نحن هنا لنساعدك في اختيار ملابس مريحة وأنيقة تعكس شخصيتك الفريدة بكل ثقة.',
  ),
  OnboardingSlide(
    imagePath: 'assets/images/onboarding_2.png',
    tag: 'KDX',
    title: 'ماذا تريد أن تلبس بعد الآن؟',
    description:
        'استكشف أحدث صيحات الموضة واحصل على إطلالة لا تُنسى في كل مناسبة.',
  ),
  OnboardingSlide(
    imagePath: 'assets/images/onboarding_3.png',
    tag: 'KDX',
    title: 'ابدأ رحلتك مع KDX الآن',
    description:
        'سجّل الدخول أو أنشئ حساباً جديداً واستمتع بتجربة تسوق مميزة.',
  ),
];
