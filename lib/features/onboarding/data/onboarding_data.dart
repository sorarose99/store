/// Data model representing a single onboarding slide.
class OnboardingSlide {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingSlide({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

/// The three slides matching the mockup exactly.
const List<OnboardingSlide> onboardingSlides = [
  OnboardingSlide(
    imagePath: 'assets/images/onboarding_1.png',
    title: 'هل أنت جاهز لتعرف ماذا تلبس غداً؟',
    description:
        'نحن هنا لنساعدك في اختيار ملابس مريحة وأنيقة تعكس شخصيتك الفريدة بكل ثقة.',
  ),
  OnboardingSlide(
    imagePath: 'assets/images/onboarding_2.png',
    title: 'ماذا تريد أن تلبس بعد الآن؟',
    description:
        'استكشف أحدث صيحات الموضة واحصل على إطلالة لا تُنسى في كل مناسبة.',
  ),
  OnboardingSlide(
    imagePath: 'assets/images/onboarding_3.png',
    title: 'ابدأ رحلتك الآن',
    description: 'سجّل الدخول أو أنشئ حساباً جديداً واستمتع بتجربة تسوق مميزة.',
  ),
  OnboardingSlide(
    imagePath: 'assets/images/onboarding_4.png',
    title: 'اكتشف أسلوبك',
    description: 'استمتع بتجربة تسوق فريدة ومميزة مع أحدث صيحات الموضة.',
  ),
];
