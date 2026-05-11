import 'package:client/config/app_env.dart';
import 'package:client/config/app_locale.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:client/ui/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();
  await AppLocale.load();

  final hasSupabaseConfig =
      AppEnv.supabaseUrl.isNotEmpty && AppEnv.supabaseAnonKey.isNotEmpty;
  if (hasSupabaseConfig) {
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }
  runApp(const GitPetApp());
}

class GitPetApp extends StatelessWidget {
  const GitPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: AppLocale.notifier,
          builder: (context, locale, _) {
            return MaterialApp(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appTitle,
              theme: _buildAppTheme(),
              debugShowCheckedModeBanner: false,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: locale,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}

ThemeData _buildAppTheme() {
  const darkNavy = Color(0xFF0F172A);
  const neonTeal = Color(0xFF22D3EE);
  const accentPurple = Color(0xFFA78BFA);
  const highlightPink = Color(0xFFF472B6);
  const rewardYellow = Color(0xFFFDE047);

  final scheme =
      ColorScheme.fromSeed(
        seedColor: neonTeal,
        brightness: Brightness.dark,
      ).copyWith(
        primary: neonTeal,
        onPrimary: darkNavy,
        secondary: accentPurple,
        onSecondary: darkNavy,
        tertiary: highlightPink,
        onTertiary: darkNavy,
        surface: darkNavy,
        onSurface: Colors.white,
        primaryContainer: rewardYellow,
        onPrimaryContainer: darkNavy,
        secondaryContainer: const Color(0xFF111B33),
        onSecondaryContainer: const Color(0xFFCBD5E1),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
