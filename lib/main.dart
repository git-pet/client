import 'package:client/ui/pages/intro.dart';
import 'package:client/ui/pages/login.dart';
import 'package:client/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 118, 143, 248),
            ),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: const AppEntryGate(),
        );
      },
    );
  }
}

enum _EntryTarget { intro, login }

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
