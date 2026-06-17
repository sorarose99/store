import '../../domain/entities/checkout_entities.dart';

// =============================================================================
// DATA LAYER — Mock Checkout Data Source
// Replace static lists with real API calls when integrating backend
// =============================================================================

class MockCheckoutDataSource {
  // ── Saved Addresses ─────────────────────────────────────────────────────────
  static final List<SavedAddressEntity> savedAddresses = [
    const SavedAddressEntity(
      id: 'addr_1',
      recipientName: 'محمد أحمد',
      phone: '+966 50 123 4567',
      city: 'الرياض',
      district: 'حي النخيل',
      street: 'شارع الملك فهد',
      buildingNo: '15',
      floor: '3',
      zipCode: '12345',
      isDefault: true,
    ),
    const SavedAddressEntity(
      id: 'addr_2',
      recipientName: 'محمد أحمد',
      phone: '+966 50 765 4321',
      city: 'جدة',
      district: 'حي الزهراء',
      street: 'شارع التحلية',
      buildingNo: '7',
      floor: '1',
      zipCode: '21432',
      isDefault: false,
    ),
  ];

  // ── Cart Items ──────────────────────────────────────────────────────────────
  static const List<CartItemEntity> cartItems = [
    CartItemEntity(
      productId: 'p1',
      name: 'هودي زيبر رجالي',
      size: 'M',
      color: 'رمادي',
      quantity: 1,
      unitPrice: 26.8,
      imageUrl: 'assets/images/cat_fashion.png',
    ),
    CartItemEntity(
      productId: 'p2',
      name: 'محدل الزراع',
      size: 'Free',
      color: 'أسود',
      quantity: 1,
      unitPrice: 9.0,
      imageUrl: 'assets/images/cat_fashion.png',
    ),
  ];

  // ── Checkout Summary ────────────────────────────────────────────────────────
  static const CheckoutSummaryEntity summary = CheckoutSummaryEntity(
    subtotal: 26.8,
    discount: 0.0,
    shippingFee: 0.0,
    tax: 10.0,
    total: 50.6,
    itemCount: 2,
  );

  // ── Payment Methods ─────────────────────────────────────────────────────────
  static const List<PaymentMethodEntity> paymentMethods = [
    PaymentMethodEntity(
      id: 'pm_apple',
      name: 'Apple Pay',
      type: PaymentMethodType.applePay,
    ),
    PaymentMethodEntity(
      id: 'pm_card',
      name: 'بطاقة الائتمان / مدى',
      subtitle: 'Visa · Mastercard · Mada',
      type: PaymentMethodType.creditCard,
    ),
    PaymentMethodEntity(
      id: 'pm_cod',
      name: 'الدفع عند الاستلام',
      subtitle: 'ادفع نقداً عند وصول طلبك',
      type: PaymentMethodType.cashOnDelivery,
    ),
  ];

  // ── Saudi Cities ────────────────────────────────────────────────────────────
  static const List<String> saudiCities = [
    'الرياض',
    'جدة',
    'مكة المكرمة',
    'المدينة المنورة',
    'الدمام',
    'الخبر',
    'الظهران',
    'تبوك',
    'أبها',
    'القصيم',
    'حائل',
    'الطائف',
    'نجران',
    'جيزان',
    'الجوف',
  ];
}
