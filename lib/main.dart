import 'core/network/token_service.dart';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/language_cubit.dart';
import 'features/auth/domain/entities/user.dart' as auth_user;
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/presentation/pages/language_selection_page.dart';
import 'features/shell/presentation/pages/main_shell.dart';
import 'features/cart/presentation/blocs/cart_bloc.dart';
import 'features/cart/presentation/blocs/cart_event.dart';
import 'features/wishlist/presentation/blocs/wishlist_bloc.dart';
import 'features/wishlist/presentation/blocs/wishlist_event.dart';
import 'features/account/presentation/blocs/account_bloc.dart';
import 'features/account/presentation/blocs/address_bloc.dart';
import 'features/notifications/presentation/blocs/notifications_bloc.dart';
import 'features/notifications/presentation/blocs/notifications_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/push_notification_service.dart';
import 'core/config/payment_config.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart' as import_auth_remote;
import 'features/auth/data/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();


  if (PaymentConfig.isTabbyConfigured) {
    try {
      await TabbySDK().setup(withApiKey: PaymentConfig.tabbyPublicKey);
    } catch (_) {}
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await di.init();

  // Initialize Push Notifications
  await di.sl<PushNotificationService>().init();

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingDone = prefs.getBool('onboarding_done') ?? false;
  final bool languageSelected = prefs.getString('app_language') != null;

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: MyApp(
        showLanguageSelection: !languageSelected,
        showOnboarding: !onboardingDone,
      ),
    ),
  );

  // Background auth sync: if the user is signed into Firebase as a SOCIAL user
  // (Google/Apple) but is missing a Sanctum token in prefs, re-sync with the
  // backend and restore the full user session so the app boots into MainShell.
  // Email/password users cannot be re-synced without their password.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final tokenService = di.sl<TokenService>();
    if (currentUser == null) return;
    if (tokenService.getSanctumToken() != null) return;

    final provider = currentUser.providerData.isNotEmpty
        ? currentUser.providerData.first.providerId
        : '';

    // Skip email/password users — we cannot re-authenticate without the password.
    if (provider == 'password' || provider.isEmpty) {
      debugPrint('Background sync skipped: email/password user needs manual login.');
      await tokenService.clearAll(); // Force logout so they see LoginPage
      return;
    }

    // Social user (Google / Apple) — sync via firebase-sync endpoint
    try {
      final idToken = await currentUser.getIdToken();
      if (idToken != null && idToken.isNotEmpty) {
        final authDataSource = di.sl<import_auth_remote.AuthRemoteDataSource>();
        final isApple = provider.contains('apple');

        // Step 1: Get Sanctum token
        final sanctumToken = await authDataSource.socialLogin(
          provider: isApple ? 'apple' : 'google',
          token: idToken,
          name: currentUser.displayName ?? '',
          email: currentUser.email ?? '',
          firebaseUid: currentUser.uid,
        );

        // Temporarily set token so /account/profile is authenticated
        await tokenService.saveSanctumToken(sanctumToken);

        // Step 2: Fetch full backend user
        UserModel backendUser;
        try {
          backendUser = await authDataSource.getProfile();
          backendUser = UserModel(
            id: backendUser.id,
            uuid: backendUser.uuid,
            firstName: backendUser.firstName,
            lastName: backendUser.lastName,
            email: backendUser.email,
            phone: backendUser.phone,
            avatar: backendUser.avatar,
            gender: backendUser.gender,
            birthDate: backendUser.birthDate,
            token: sanctumToken,
          );
        } catch (_) {
          final nameParts = (currentUser.displayName ?? '').trim().split(' ');
          backendUser = UserModel(
            id: currentUser.uid,
            uuid: currentUser.uid,
            firstName: nameParts.isNotEmpty ? nameParts.first : '',
            lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
            email: currentUser.email ?? '',
            token: sanctumToken,
          );
        }

        // Step 3: Persist full user session — notifies root StreamBuilder
        await tokenService.saveAuthSession(
          sanctumToken: sanctumToken,
          user: backendUser,
        );
        debugPrint('Background sync succeeded: ${backendUser.email}');
      }
    } catch (e) {
      debugPrint('Background sync failed: $e');
    }
  });
}

class MyApp extends StatelessWidget {
  final bool showLanguageSelection;
  final bool showOnboarding;

  const MyApp({
    super.key,
    required this.showLanguageSelection,
    required this.showOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit()..loadSavedTheme(),
        ),
        BlocProvider<LanguageCubit>(
          create: (_) => LanguageCubit()..loadSavedLanguage(),
        ),
        BlocProvider<CartBloc>(
          create: (_) => di.sl<CartBloc>()..add(const CartRequested()),
        ),
        BlocProvider<WishlistBloc>(
          create: (_) => di.sl<WishlistBloc>()..add(const WishlistRequested()),
        ),
        BlocProvider<AccountBloc>(
          create: (_) => di.sl<AccountBloc>(),
        ),
        BlocProvider<AddressBloc>(
          create: (_) => di.sl<AddressBloc>(),
        ),
        BlocProvider<NotificationsBloc>(
          create: (_) => di.sl<NotificationsBloc>()..add(const NotificationsRequested()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LanguageCubit, Locale>(
            builder: (context, locale) {
              // 1. Wrap your MaterialApp inside ScreenUtilInit
              return ScreenUtilInit(
                designSize: const Size(360,
                    690), // Change this to your UI design (Figma) dimensions
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (context, child) {
                  return MaterialApp(
                    title: 'KDX',
                    debugShowCheckedModeBanner: false,

                    // ── Theme ────────────────────────────────────────────────
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeMode,

                    // ── Localization ─────────────────────────────────────────
                    locale: context.locale,
                    supportedLocales: context.supportedLocales,
                    localizationsDelegates: [
                      ...context.localizationDelegates,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],

                    // ── Routing / Global Builders ──────────────────────────
                    builder: (context, child) {
                      return Directionality(
                        textDirection:
                            ui.TextDirection.ltr, // Force LTR layout everywhere
                        child: child!,
                      );
                    },
                     home: StreamBuilder<auth_user.User?>(
                      stream: di.sl<TokenService>().authUserChanges,
                      initialData: di.sl<TokenService>().currentUser,
                      builder: (context, snapshot) {
                        final activeUser = snapshot.data;

                        if (activeUser != null) {
                          return const MainShell();
                        }

                        if (showLanguageSelection) {
                          return const LanguageSelectionPage();
                        }
                        if (showOnboarding) {
                          return const OnboardingPage();
                        }
                        return const LoginPage();
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
