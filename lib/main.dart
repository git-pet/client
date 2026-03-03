import 'package:client/ui/pages/intro.dart';
import 'package:client/ui/pages/login.dart';
import 'package:client/utils/secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GitPetApp());
}

enum _EntryTarget { intro, login }

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
          home: const AppEntryGate(),
        );
      },
    );
  }
}

class AppEntryGate extends StatefulWidget {
  const AppEntryGate({super.key});

  @override
  State<AppEntryGate> createState() => _AppEntryGateState();
}

class _AppEntryGateState extends State<AppEntryGate> {
  late Future<_EntryTarget> _entryFuture;

  @override
  void initState() {
    super.initState();
    _entryFuture = _resolveEntryTarget();
  }

  Future<_EntryTarget> _resolveEntryTarget() async {
    final storage = SecureStorage().storage;
    final introSeen =
        await storage.read(key: SecureStorageKey.introSeen) == 'true';

    if (!introSeen) {
      return _EntryTarget.intro;
    }
    return _EntryTarget.login;
  }

  Future<void> _handleIntroCompleted() async {
    await SecureStorage().storage.write(
      key: SecureStorageKey.introSeen,
      value: 'true',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _entryFuture = Future.value(_EntryTarget.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_EntryTarget>(
      future: _entryFuture,
      builder: (context, snapshot) {
        if (kDebugMode) {
          return IntroPage(onComplete: _handleIntroCompleted);
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        switch (snapshot.data) {
          case _EntryTarget.intro:
            return IntroPage(onComplete: _handleIntroCompleted);
          case _EntryTarget.login:
            return const LoginPage();
          default:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
        }
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

  final scheme = ColorScheme.fromSeed(
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}

