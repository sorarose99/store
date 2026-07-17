import 'dart:io';
import 'package:dio/io.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../network/token_service.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/send_register_otp_usecase.dart';
import '../../features/auth/domain/usecases/social_login_usecase.dart';
import '../../features/auth/presentation/blocs/auth_bloc.dart';

import '../../features/api_validation/data/datasources/api_validation_remote_datasource.dart';
import '../../features/api_validation/data/repositories/api_validation_repository_impl.dart';
import '../../features/api_validation/domain/repositories/api_validation_repository.dart';
import '../../features/api_validation/domain/usecases/validate_api_key_usecase.dart';
import '../../features/api_validation/presentation/cubit/api_validation_cubit.dart';
import '../../features/search/presentation/blocs/search_bloc.dart';

import '../../features/product/data/datasources/product_remote_datasource.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/get_product_details_usecase.dart';
import '../../features/product/presentation/blocs/product_details_cubit.dart';

import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_data.dart';
import '../../features/home/presentation/blocs/home_bloc.dart';

import '../../features/category/data/datasources/category_remote_datasource.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/domain/usecases/get_categories_usecase.dart';
import '../../features/category/domain/usecases/get_subcategories_usecase.dart';
import '../../features/category/domain/usecases/get_category_products_usecase.dart';
import '../../features/category/presentation/blocs/category_bloc.dart';
import '../../features/category/presentation/blocs/category_products_bloc.dart';

import '../../features/account/data/datasources/account_remote_datasource.dart';
import '../../features/account/data/datasources/address_remote_datasource.dart';
import '../../features/account/data/repositories/account_repository_impl.dart';
import '../../features/account/data/repositories/address_repository_impl.dart';
import '../../features/account/domain/repositories/account_repository.dart';
import '../../features/account/domain/repositories/address_repository.dart';
import '../../features/account/domain/usecases/get_profile_usecase.dart';
import '../../features/account/domain/usecases/get_dashboard_usecase.dart';
import '../../features/account/domain/usecases/update_profile_usecase.dart';
import '../../features/account/domain/usecases/change_password_usecase.dart';
import '../../features/account/domain/usecases/delete_account_usecase.dart';
import '../../features/account/domain/usecases/save_fcm_token_usecase.dart';
import '../../features/account/domain/usecases/send_contact_message_usecase.dart';
import '../../features/search_filter/presentation/blocs/shop_bloc.dart';
import '../../features/product/domain/usecases/get_shop_products_usecase.dart';
import '../../features/product/domain/usecases/get_sub_category_products_usecase.dart';
import '../../features/account/presentation/blocs/account_bloc.dart';
import '../../features/account/presentation/blocs/address_bloc.dart';

import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/presentation/blocs/notifications_bloc.dart';

import '../../features/orders/data/datasources/order_remote_datasource.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/usecases/order_usecases.dart';
import '../../features/orders/presentation/blocs/orders_bloc.dart';

import '../../features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import '../../features/wishlist/data/repositories/wishlist_repository_impl.dart';
import '../../features/wishlist/domain/repositories/wishlist_repository.dart';
import '../../features/wishlist/domain/usecases/wishlist_usecases.dart';
import '../../features/wishlist/presentation/blocs/wishlist_bloc.dart';

import '../../features/cart/data/datasources/cart_remote_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/cart_usecases.dart';
import '../../features/cart/presentation/blocs/cart_bloc.dart';

import '../../features/checkout/data/datasources/checkout_remote_datasource.dart';
import '../../features/checkout/data/services/payment_redirect_service.dart';
import '../../features/checkout/data/services/native_payment_service.dart';
import '../../features/checkout/data/repositories/checkout_repository_impl.dart';
import '../../features/checkout/domain/repositories/checkout_repository.dart';
import '../../features/checkout/domain/usecases/checkout_usecases.dart';
import '../../features/checkout/presentation/blocs/checkout_bloc.dart';
import '../services/push_notification_service.dart';

import '../../features/delivery_options/data/repositories/delivery_options_repository_impl.dart';
import '../../features/delivery_options/domain/repositories/delivery_options_repository.dart';
import '../../features/delivery_options/domain/usecases/get_delivery_options.dart';
import '../../features/delivery_options/presentation/cubit/delivery_options_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==========================================
  // EXTERNAL DEPENDENCIES (init first)
  // ==========================================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.sendTimeout = const Duration(seconds: 15);
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 15);
        client.idleTimeout = const Duration(seconds: 60);
        return client;
      },
    );
    return dio;
  });
  sl.registerLazySingleton(() => TokenService(sl()));
  sl.registerLazySingleton(() => ApiClient(sl(), sl()));

  sl.registerLazySingleton(() => PushNotificationService(sl()));

  // ==========================================
  // DATA LAYER (DATASOURCES)
  // ==========================================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ApiValidationRemoteDataSource>(
    () => ApiValidationRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<WishlistRemoteDataSource>(
    () => WishlistRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<CheckoutRemoteDataSource>(
    () => CheckoutRemoteDataSourceImpl(apiClient: sl()),
  );

  // ==========================================
  // DOMAIN/DATA LAYER (REPOSITORIES)
  // ==========================================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<ApiValidationRepository>(
    () => ApiValidationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<WishlistRepository>(
    () => WishlistRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<DeliveryOptionsRepository>(
    () => DeliveryOptionsRepositoryImpl(),
  );

  // ==========================================
  // DOMAIN LAYER (USECASES)
  // ==========================================
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SendRegisterOtpUseCase(sl()));
  sl.registerLazySingleton(() => SocialLoginUseCase(sl()));
  sl.registerLazySingleton(() => ValidateApiKeyUseCase(sl()));
  sl.registerLazySingleton(() => GetProductDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetShopProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetSubCategoryProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetHomeData(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetSubCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoryProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => SaveFcmTokenUseCase(sl()));
  sl.registerLazySingleton(() => SendContactMessageUseCase(sl()));

  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderDetailUseCase(sl()));
  sl.registerLazySingleton(() => CancelOrderUseCase(sl()));
  sl.registerLazySingleton(() => SubmitReviewUseCase(sl()));
  sl.registerLazySingleton(() => DownloadInvoiceUseCase(sl()));
  sl.registerLazySingleton(() => GetWishlistUseCase(sl()));
  sl.registerLazySingleton(() => ToggleWishlistUseCase(sl()));

  sl.registerLazySingleton(() => GetCartUseCase(sl()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBreakdownUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl()));
  sl.registerLazySingleton(() => ApplyCouponUseCase(sl()));
  sl.registerLazySingleton(() => RemoveCouponUseCase(sl()));
  sl.registerLazySingleton(() => UpdateShippingZoneUseCase(sl()));
  sl.registerLazySingleton(() => GetCartCountUseCase(sl()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl()));
  sl.registerLazySingleton(() => GetAddressesUseCase(sl()));
  sl.registerLazySingleton(() => AddAddressUseCase(sl()));
  sl.registerLazySingleton(() => SubmitCheckoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCheckoutDataUseCase(sl()));
  sl.registerLazySingleton(() => EditAddressUseCase(sl()));
  sl.registerLazySingleton(() => GetDeliveryOptions(sl()));

  // ==========================================
  // PRESENTATION LAYER (BLOCs)
  // ==========================================
  sl.registerFactory(() => ApiValidationCubit(validateApiKeyUseCase: sl()));
  sl.registerFactory(() => ProductDetailsCubit(getProductDetailsUseCase: sl()));

  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        sendRegisterOtpUseCase: sl(),
        forgotPasswordUseCase: sl(),
        verifyOtpUseCase: sl(),
        resetPasswordUseCase: sl(),
        socialLoginUseCase: sl(),
      ));

  sl.registerFactory(() => HomeBloc(getHomeData: sl()));
  sl.registerFactory(() => CategoryBloc(
        getCategoriesUseCase: sl(),
        getSubCategoriesUseCase: sl(),
      ));
  sl.registerFactory(
      () => CategoryProductsBloc(getCategoryProductsUseCase: sl()));
  sl.registerFactory(() => ShopBloc(getShopProductsUseCase: sl()));
  sl.registerFactory(() => SearchBloc());
  sl.registerFactory(() => AccountBloc(
        getProfileUseCase: sl(),
        getDashboardUseCase: sl(),
        updateProfileUseCase: sl(),
        changePasswordUseCase: sl(),
        deleteAccountUseCase: sl(),
        saveFcmTokenUseCase: sl(),
        sendContactMessageUseCase: sl(),
      ));
  sl.registerFactory(() => AddressBloc(addressRepository: sl()));

  sl.registerFactory(() => NotificationsBloc(
        getNotificationsUseCase: sl(),
      ));

  sl.registerFactory(() => OrdersBloc(
        getOrdersUseCase: sl(),
        getOrderDetailUseCase: sl(),
        cancelOrderUseCase: sl(),
        submitReviewUseCase: sl(),
        downloadInvoiceUseCase: sl(),
      ));

  sl.registerLazySingleton(() => WishlistBloc(
        getWishlistUseCase: sl(),
        toggleWishlistUseCase: sl(),
      ));

  sl.registerLazySingleton(() => CartBloc(
        getCartUseCase: sl(),
        addToCartUseCase: sl(),
        updateCartUseCase: sl(),
        updateBreakdownUseCase: sl(),
        removeFromCartUseCase: sl(),
        applyCouponUseCase: sl(),
        removeCouponUseCase: sl(),
        updateShippingZoneUseCase: sl(),
        getCartCountUseCase: sl(),
        clearCartUseCase: sl(),
      ));

  sl.registerLazySingleton(() => PaymentRedirectService(sl()));
  sl.registerLazySingleton(() => NativePaymentService());

  sl.registerFactory(() => CheckoutBloc(
        getAddressesUseCase: sl(),
        addAddressUseCase: sl(),
        submitCheckoutUseCase: sl(),
        getCheckoutDataUseCase: sl(),
        editAddressUseCase: sl(),
      ));
      
  sl.registerFactory(() => DeliveryOptionsCubit(getDeliveryOptions: sl()));
}
