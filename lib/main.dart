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
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/push_notification_service.dart';
import 'core/config/payment_config.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

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
                     home: StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Scaffold(
                            body: Center(child: CircularProgressIndicator()),
                          );
                        }
                        
                        final hasFirebase = snapshot.hasData && snapshot.data != null;
                        final hasSanctum = di.sl<TokenService>().getSanctumToken() != null;

                        if (hasFirebase || hasSanctum) {
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
