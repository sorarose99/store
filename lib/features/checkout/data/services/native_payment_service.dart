import 'package:flutter/material.dart';
import '../../../../core/config/env.dart';
import 'package:flutter_paytabs_bridge/BaseBillingShippingInfo.dart';
import 'package:flutter_paytabs_bridge/PaymentSDKNetworks.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkConfigurationDetails.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkLocale.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkTokeniseType.dart';
import 'package:flutter_paytabs_bridge/flutter_paytabs_bridge.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';
import '../../domain/entities/checkout_entities.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

class NativePaymentService {
  NativePaymentService();

  Future<void> initTabby() async {
    final tabbyApiKey = Env.tabbyApiKey;
    if (tabbyApiKey.isNotEmpty) {
      try {
        await TabbySDK().setup(
          withApiKey: tabbyApiKey,
        );
      } catch (e) {
        debugPrint('Failed to initialize Tabby SDK: $e');
      }
    }
  }

  Future<void> initTamara() async {
    final tamaraToken = Env.tamaraApiToken;
    if (tamaraToken.isNotEmpty) {
      try {
        // Example initialization; adjust to exact SDK signature if needed
        // TamaraSdk.initSdk(...);
      } catch (e) {
        debugPrint('Failed to initialize Tamara SDK: $e');
      }
    }
  }

  Future<String?> createTamaraSession({
    required String orderNumber,
    required double amount,
    required SavedAddressEntity address,
    required String customerEmail,
    required List<CartItemEntity> items,
  }) async {
    // Production endpoint — matches the production JWT in .env.
    // Sandbox: https://api-sandbox.tamara.co/checkout
    const endpoint = 'https://api.tamara.co/checkout';

    final tamaraToken = Env.tamaraApiToken;
    if (tamaraToken.isEmpty) {
      debugPrint('[Tamara] API token is missing in .env');
      return null;
    }

    final names = address.fullName.trim().split(RegExp(r'\s+'));
    final firstName = names.isNotEmpty ? names.first : 'Customer';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : 'Doe';

    // Normalize phone to Saudi E.164 (+966XXXXXXXXX).
    // Tamara production rejects bare local numbers like 0501234567.
    String phone = address.phone.replaceAll(RegExp(r'\s+|-'), '');
    if (phone.startsWith('00966')) {
      phone = '+${phone.substring(2)}';
    } else if (phone.startsWith('0') && !phone.startsWith('+')) {
      phone = '+966${phone.substring(1)}';
    } else if (!phone.startsWith('+')) {
      phone = '+966$phone';
    }

    final String line1 =
        address.detailedAddress.isNotEmpty ? address.detailedAddress : address.fullAddress;
    final String city = address.city.isNotEmpty ? address.city : 'Riyadh';

    // Shared address block — Tamara production requires BOTH
    // shipping_address AND billing_address.
    final addressBlock = {
      'first_name': firstName,
      'last_name': lastName,
      'line1': line1.isNotEmpty ? line1 : 'Street 1',
      'city': city,
      'country_code': 'SA',
    };

    final body = {
      'order_reference_id': orderNumber,
      'total_amount': {
        'amount': double.parse(amount.toStringAsFixed(2)),
        'currency': 'SAR',
      },
      'description': 'Order $orderNumber',
      'country_code': 'SA',
      'payment_type': 'PAY_BY_INSTALMENTS',
      'locale': 'ar_SA',
      'items': items.map((e) {
        final lineTotal =
            double.parse((e.unitPrice * e.quantity).toStringAsFixed(2));
        return {
          'reference_id': e.productId,
          'type': 'Physical',
          'name': e.name,
          'sku': e.productId,
          'quantity': e.quantity,
          'unit_price': {
            'amount': double.parse(e.unitPrice.toStringAsFixed(2)),
            'currency': 'SAR',
          },
          'total_amount': {'amount': lineTotal, 'currency': 'SAR'},
        };
      }).toList(),
      'consumer': {
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phone,
        'email':
            customerEmail.isNotEmpty ? customerEmail : 'customer@example.com',
      },
      'shipping_address': addressBlock,
      'billing_address': addressBlock, // required by Tamara production
      'merchant_url': {
        'success': 'kdxstore://payment/success',
        'failure': 'kdxstore://payment/failure',
        'cancel': 'kdxstore://payment/cancel',
        'notification': 'https://kdx-sa.com/api/payments/tamara/webhook',
      },
    };

    debugPrint('[Tamara] Sending to $endpoint');
    debugPrint('[Tamara] Payload: $body');

    try {
      // validateStatus at BaseOptions level — works on ALL Dio versions.
      final dio = Dio(BaseOptions(validateStatus: (_) => true));

      final response = await dio.post(
        endpoint,
        options: Options(headers: {
          'Authorization': 'Bearer $tamaraToken',
          'Content-Type': 'application/json',
        }),
        data: body,
      );

      debugPrint(
          '[Tamara] Response [${response.statusCode}]: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final checkoutUrl = response.data['checkout_url'] as String?;
        debugPrint('[Tamara] checkout_url: $checkoutUrl');
        return checkoutUrl;
      }

      debugPrint(
          '[Tamara] FAILED — status: ${response.statusCode}\nbody: ${response.data}');
      return null;
    } on DioException catch (e) {
      // DioException still thrown on network errors (no internet, DNS fail, etc.)
      debugPrint('[Tamara] DioException: ${e.type} — ${e.message}');
      if (e.response != null) {
        debugPrint('[Tamara] Error response body: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      debugPrint('[Tamara] Unexpected error: $e');
      return null;
    }
  }

  Future<TabbySession?> createTabbySession({
    required String orderNumber,
    required double amount,
    required SavedAddressEntity address,
    required String customerEmail,
    required List<CartItemEntity> items,
  }) async {
    try {
      final session = await TabbySDK().createSession(TabbyCheckoutPayload(
        merchantCode:
            Env.tabbyMerchantCode.isNotEmpty ? Env.tabbyMerchantCode : 'SA',
        lang: Lang.ar,
        payment: Payment(
          amount: amount.toStringAsFixed(2),
          currency: Currency.sar,
          buyer: Buyer(
            email: customerEmail.isNotEmpty
                ? customerEmail
                : 'customer@example.com',
            phone: address.phone,
            name: address.fullName,
            dob: '2000-01-01',
          ),
          buyerHistory: BuyerHistory(
            registeredSince: '2020-01-01T00:00:00Z',
            loyaltyLevel: 0,
          ),
          orderHistory: [
            // optional
          ],
          shippingAddress: ShippingAddress(
            city: address.city,
            address: address.fullAddress,
            zip: address.zipCode.isNotEmpty ? address.zipCode : '00000',
          ),
          order: Order(
            referenceId: orderNumber,
            taxAmount: '0.00',
            shippingAmount: '0.00',
            discountAmount: '0.00',
            items: items
                .map((item) => OrderItem(
                      title: item.name,
                      quantity: item.quantity,
                      unitPrice: item.unitPrice.toStringAsFixed(2),
                      referenceId: item.productId,
                      category: 'General',
                    ))
                .toList(),
          ),
        ),
      ));
      return session;
    } catch (e) {
      debugPrint('Tabby createSession error: $e');
      return null;
    }
  }

  Future<void> startPayTabsCardPayment({
    required BuildContext context,
    required String orderNumber,
    required double amount,
    required SavedAddressEntity address,
    required String customerEmail,
    bool isMada = false,
    required Function(String transactionRef) onSuccess,
    required Function(String error) onError,
    required VoidCallback onCancel,
  }) async {
    final profileId = Env.paytabsProfileId;
    final serverKey = Env.paytabsServerKey;
    final clientKey = Env.paytabsClientKey;

    if (profileId.isEmpty || serverKey.isEmpty || clientKey.isEmpty) {
      onError('PayTabs credentials are missing in .env');
      return;
    }

    final names = address.fullName.trim().split(' ');
    final firstName = names.isNotEmpty && names.first.trim().isNotEmpty
        ? names.first.trim()
        : 'Customer';

    // The current entity might not have a country field, let's assume SA
    final safePhone = address.phone.isNotEmpty ? address.phone : '0500000000';
    final safeStreet = address.detailedAddress.isNotEmpty
        ? address.detailedAddress
        : (address.fullAddress.isNotEmpty ? address.fullAddress : 'Street 1');
    final safeCity = address.city.isNotEmpty ? address.city : 'Riyadh';
    final safeDistrict = address.city.isNotEmpty ? address.city : 'Riyadh';
    final safeZip = address.zipCode.isNotEmpty ? address.zipCode : '00000';

    final billingDetails = BillingDetails(
      firstName,
      customerEmail.isNotEmpty ? customerEmail : 'customer@example.com',
      safePhone,
      safeStreet,
      'SA', // Country
      safeCity,
      safeDistrict,
      safeZip,
    );

    final shippingDetails = ShippingDetails(
      firstName,
      customerEmail.isNotEmpty ? customerEmail : 'customer@example.com',
      safePhone,
      safeStreet,
      'SA',
      safeCity,
      safeDistrict,
      safeZip,
    );

    final configuration = PaymentSdkConfigurationDetails(
      profileId: profileId,
      serverKey: serverKey,
      clientKey: clientKey,
      cartId: orderNumber,
      cartDescription: 'Order $orderNumber',
      merchantName: 'Store',
      screentTitle: 'Pay with Card',
      amount: amount,
      showBillingInfo: false,
      forceShippingInfo: false,
      currencyCode: 'SAR',
      merchantCountryCode: 'SA',
      billingDetails: billingDetails,
      shippingDetails: shippingDetails,
      tokeniseType: PaymentSdkTokeniseType.NONE,
      locale: PaymentSdkLocale.AR,
      paymentNetworks: isMada
          ? [PaymentSDKNetworks.mada]
          : [
              PaymentSDKNetworks.visa,
              PaymentSDKNetworks.masterCard,
              PaymentSDKNetworks.mada
            ],
    );

    FlutterPaytabsBridge.startCardPayment(configuration, (event) {
      final status = event['status'];
      if (status == 'success') {
        final transactionDetails = event['data'];
        if (transactionDetails != null &&
            transactionDetails['isSuccess'] == true) {
          final transactionRef =
              event['trace'] ?? event['transactionRef'] ?? orderNumber;
          onSuccess(transactionRef.toString());
        } else {
          onError('payment_declined'.tr());
        }
      } else if (status == 'error') {
        onError(event['message'] ?? 'payment_error'.tr());
      } else if (status == 'event') {
        if (event['message'] == 'Cancelled') {
          onCancel();
        }
      }
    });
  }

  Future<void> startPayTabsApplePayPayment({
    required BuildContext context,
    required String orderNumber,
    required double amount,
    required SavedAddressEntity address,
    required String customerEmail,
    required Function(String transactionRef) onSuccess,
    required Function(String error) onError,
    required VoidCallback onCancel,
  }) async {
    final profileId = Env.paytabsProfileId;
    final serverKey = Env.paytabsServerKey;
    final clientKey = Env.paytabsClientKey;

    if (profileId.isEmpty || serverKey.isEmpty || clientKey.isEmpty) {
      onError('PayTabs credentials are missing in .env');
      return;
    }

    final names = address.fullName.trim().split(' ');
    final firstName = names.isNotEmpty && names.first.trim().isNotEmpty
        ? names.first.trim()
        : 'Customer';

    final safePhone = address.phone.isNotEmpty ? address.phone : '0500000000';
    final safeStreet = address.detailedAddress.isNotEmpty
        ? address.detailedAddress
        : (address.fullAddress.isNotEmpty ? address.fullAddress : 'Street 1');
    final safeCity = address.city.isNotEmpty ? address.city : 'Riyadh';
    final safeDistrict = address.city.isNotEmpty ? address.city : 'Riyadh';
    final safeZip = address.zipCode.isNotEmpty ? address.zipCode : '00000';

    final billingDetails = BillingDetails(
      firstName,
      customerEmail.isNotEmpty ? customerEmail : 'customer@example.com',
      safePhone,
      safeStreet,
      'SA',
      safeCity,
      safeDistrict,
      safeZip,
    );

    final configuration = PaymentSdkConfigurationDetails(
      profileId: profileId,
      serverKey: serverKey,
      clientKey: clientKey,
      cartId: orderNumber,
      cartDescription: 'Order $orderNumber',
      merchantName: 'Store',
      screentTitle: 'Apple Pay',
      amount: amount,
      showBillingInfo: false,
      forceShippingInfo: false,
      currencyCode: 'SAR',
      merchantCountryCode: 'SA',
      merchantApplePayIndentifier:
          'merchant.com.example.store', // TODO: Update this
      simplifyApplePayValidation: true,
      billingDetails: billingDetails,
      tokeniseType: PaymentSdkTokeniseType.NONE,
      locale: PaymentSdkLocale.AR,
      paymentNetworks: [
        PaymentSDKNetworks.visa,
        PaymentSDKNetworks.masterCard,
        PaymentSDKNetworks.mada
      ],
    );

    FlutterPaytabsBridge.startApplePayPayment(configuration, (event) {
      final status = event['status'];
      if (status == 'success') {
        final transactionDetails = event['data'];
        if (transactionDetails != null &&
            transactionDetails['isSuccess'] == true) {
          final transactionRef =
              event['trace'] ?? event['transactionRef'] ?? orderNumber;
          onSuccess(transactionRef.toString());
        } else {
          onError('payment_declined'.tr());
        }
      } else if (status == 'error') {
        onError(event['message'] ?? 'payment_error'.tr());
      } else if (status == 'event') {
        if (event['message'] == 'Cancelled') {
          onCancel();
        }
      }
    });
  }
}
