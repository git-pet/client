import 'package:client/ui/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'http://118.34.15.14:8000',
);
const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzcxNzU2MjY2LCJleHAiOjE5Mjk0MzYyNjZ9.bPqPxAxyr07K20NTVcaM17k8vZeMvX_ae8xr1oR3bKc',
);
final _hasSupabaseConfig =
    _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_hasSupabaseConfig) {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
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
        return MaterialApp(
          title: 'GitPet',
          theme: _buildAppTheme(),
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
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
