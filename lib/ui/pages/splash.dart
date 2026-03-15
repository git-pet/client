import 'package:client/ui/pages/home.dart';
import 'package:client/ui/pages/intro.dart';
import 'package:client/ui/pages/login.dart';
import 'package:client/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _Phase { splash, intro, login, home }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  _Phase _phase = _Phase.splash;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _resolvePhase();
      }
    });
  }

  Future<void> _resolvePhase() async {
    final introSeen =
        await SecureStorage().storage.read(
          key: SecureStorageKey.introSeen.name,
        ) ==
        'true';
    final session = Supabase.instance.client.auth.currentSession;
    final githubAccessToken = await SecureStorage().storage.read(
      key: SecureStorageKey.githubAccessToken.name,
    );
    if (!mounted) return;
    setState(() {
      if ((session?.accessToken.isNotEmpty ?? false) ||
          (githubAccessToken != null && githubAccessToken.isNotEmpty)) {
        _phase = _Phase.home;
      } else {
        _phase = introSeen ? _Phase.login : _Phase.intro;
      }
    });
  }

  Future<void> _handleIntroCompleted() async {
    await SecureStorage().storage.write(
      key: SecureStorageKey.introSeen.name,
      value: 'true',
    );
    if (!mounted) return;
    setState(() {
      _phase = _Phase.login;
    });
  }

  void _handleLoginSuccess() {
    if (!mounted) {
      return;
    }
    setState(() {
      _phase = _Phase.home;
    });
  }

  void _handleLogout() {
    if (!mounted) {
      return;
    }
    setState(() {
      _phase = _Phase.login;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.intro:
        return IntroPage(onComplete: _handleIntroCompleted);
      case _Phase.login:
        return LoginPage(onLoginSuccess: _handleLoginSuccess);
      case _Phase.home:
        return HomePage(onLogout: _handleLogout);
      case _Phase.splash:
        return Scaffold(
          body: Center(
            child: Lottie.asset(
              'assets/animations/splash.json',
              controller: _controller,
              onLoaded: (composition) {
                _controller.duration = composition.duration;
                _controller.forward();
              },
              width: 320,
              height: 320,
            ),
          ),
        );
    }
  }
}
