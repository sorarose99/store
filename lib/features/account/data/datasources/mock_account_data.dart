import '../../domain/entities/account_entities.dart';

class MockAccountDataSource {
  // Mock User based on screenshot
  static final UserEntity currentUser = UserEntity(
    name: 'رنا الحربي', // From image "Rana Alharbi"
    email: 'ranaalharby@gmail.com',
    phone: '+966-505-1234',
    walletBalance: 356.00, // Image shows 356.00 and 140.00 in different screens, let's use 140.00 as requested
    ordersCount: 12,
    gender: 'أنثى',
    dateOfBirth: DateTime(2002, 11, 18), // Based on screenshot '18 نوفمبر 2002'
  );

  static final UserEntity alternateUser = UserEntity(
    name: 'Kamal', // From image "أهلاً بك Kamal"
    email: 'kamal@gmail.com',
    phone: '+966-505-1234',
    walletBalance: 140.00, // From image 1
    ordersCount: 12, // From image 1
    gender: 'ذكر',
    dateOfBirth: DateTime(1990, 1, 1),
  );

  static final List<OrderEntity> orders = [
    OrderEntity(
      id: '1',
      status: 'شحن المحطة الإلكترونية',
      date: DateTime(2023, 10, 19),
      time: '10:00 صباحاً',
      amount: 26.0,
      itemCount: 2,
      statusColorHex: '00BFA5', // Teal
    ),
    OrderEntity(
      id: '2',
      status: 'جاكيت جينز',
      date: DateTime(2023, 10, 19),
      time: '10:00 صباحاً',
      amount: 26.0,
      itemCount: 1,
      statusColorHex: 'FF5252', // Red
    ),
    OrderEntity(
      id: '3',
      status: 'شحن المحطة الإلكترونية',
      date: DateTime(2023, 10, 19),
      time: '10:00 صباحاً',
      amount: 26.0,
      itemCount: 2,
      statusColorHex: '00BFA5',
    ),
    OrderEntity(
      id: '4',
      status: 'جاكيت جينز',
      date: DateTime(2023, 10, 19),
      time: '10:00 صباحاً',
      amount: 26.0,
      itemCount: 1,
      statusColorHex: 'FF5252',
    ),
    OrderEntity(
      id: '5',
      status: 'شحن المحطة الإلكترونية',
      date: DateTime(2023, 10, 19),
      time: '10:00 صباحاً',
      amount: 26.0,
      itemCount: 2,
      statusColorHex: '00BFA5',
    ),
  ];

  static final List<CouponEntity> coupons = [
    CouponEntity(
      code: 'KDX10',
      title: 'خصم 10% على جميع المنتجات',
      subtitle: 'استخدم الكود للحصول على خصم إضافي',
      expiryDate: DateTime(2024, 1, 31), // "تنتهي الصلاحية 31 يناير 2024"
    ),
    CouponEntity(
      code: 'FREE50',
      title: 'شحن مجاني',
      subtitle: 'شحن مجاني للطلبات فوق 50 ريال',
      expiryDate: DateTime(2024, 1, 31),
    ),
  ];

  static final List<FaqEntity> faqs = [
    FaqEntity(
      question: 'متى طرق الدفع المتاحة في المتجر؟',
      answer: 'نوفر لك عدة طرق للدفع لتسهيل عملية التسوق: بطاقات الائتمان (فيزا، ماستركارد)، الدفع عند الاستلام، أبل باي، ومدى.',
    ),
    FaqEntity(
      question: 'كم تستغرق مدة التوصيل؟',
      answer: 'عادة ما تستغرق مدة التوصيل من 2 إلى 5 أيام عمل داخل المملكة. وقد تختلف المدة قليلاً للمناطق النائية.',
    ),
    FaqEntity(
      question: 'ما هي سياسة الإرجاع والاستبدال؟',
      answer: 'يمكنك إرجاع أو استبدال المنتجات خلال 14 يوماً من تاريخ استلامها بشرط أن تكون في حالتها الأصلية.',
    ),
    FaqEntity(
      question: 'هل المنتجات أصلية؟',
      answer: 'نعم، جميع المنتجات المتوفرة في المتجر أصلية 100% ومضمونة الجودة.',
    ),
    FaqEntity(
      question: 'كيف يمكنني التواصل مع خدمة العملاء؟',
      answer: 'يمكنك التواصل معنا عبر المحادثة المباشرة في التطبيق، أو إرسال بريد إلكتروني، أو الاتصال برقم العناية بالعملاء.',
    ),
    FaqEntity(
      question: 'هل يمكنني إلغاء طلبي؟',
      answer: 'نعم، يمكنك إلغاء طلبك قبل أن يتم شحنه من خلال صفحة "طلباتي".',
    ),
    FaqEntity(
      question: 'هل تتوافر لديكم خدمة الدفع عند الاستلام؟',
      answer: 'نعم، خدمة الدفع عند الاستلام متوفرة لجميع مناطق المملكة.',
    ),
  ];
}
