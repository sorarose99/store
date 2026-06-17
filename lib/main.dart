import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/shell/presentation/pages/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  // Check if onboarding has already been seen
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;

  // DEV SHORTCUT: skip auth, go straight to shell
  // Change to `false` to restore login/onboarding flow
  const skipAuth = false;

  runApp(MyApp(
    showOnboarding: !skipAuth,
    skipAuth: skipAuth,
  ));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  final bool skipAuth;

  const MyApp({
    super.key,
    required this.showOnboarding,
    this.skipAuth = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'KDX Store',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        // ── Full Arabic RTL locale support ──────────────────────────────
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // ── Routing ─────────────────────────────────────────────────────
        home: skipAuth
            ? const MainShell()
            : showOnboarding
                ? const OnboardingPage()
                : const LoginPage(),
      ),
    );
  }
}
