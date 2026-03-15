import 'dart:async';

import 'package:client/config/app_env.dart';
import 'package:client/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.onLoginSuccess});

  final VoidCallback? onLoginSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  static final _isSupabaseConfigured =
      AppEnv.supabaseUrl.isNotEmpty &&
      AppEnv.supabaseAnonKey.isNotEmpty &&
      AppEnv.supabaseRedirectUrl.isNotEmpty;

  SupabaseClient? _supabase;
  StreamSubscription<AuthState>? _authSubscription;
  Timer? _oauthResumeTimer;
  Timer? _oauthFailureTimer;
  bool _isSubmitting = false;
  bool _awaitingOAuthResult = false;
  bool _didLeaveAppForOAuth = false;
  bool _didNotifyLoginSuccess = false;
  String? _statusMessage;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!_isSupabaseConfigured) {
      _statusMessage = '';
      return;
    }

    _supabase = Supabase.instance.client;
    _currentUser = _supabase!.auth.currentUser;
    _persistUser(_currentUser);
    _notifyLoginSuccessIfNeeded();
    _authSubscription = _supabase!.auth.onAuthStateChange.listen((data) async {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          await _persistUser(data.session?.user ?? _supabase!.auth.currentUser);
          if (!mounted) {
            return;
          }
          setState(() {
            _currentUser = data.session?.user ?? _supabase!.auth.currentUser;
            _resetOAuthFlow();
            _statusMessage = _currentUser == null
                ? null
                : 'GitHub 로그인 완료: @${_displayLogin(_currentUser!)}';
          });
          _notifyLoginSuccessIfNeeded();
          break;
        case AuthChangeEvent.signedOut:
          await _clearStoredUser();
          if (!mounted) {
            return;
          }
          setState(() {
            _currentUser = null;
            _didNotifyLoginSuccess = false;
            _resetOAuthFlow();
            _statusMessage = '로그아웃되었습니다.';
          });
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    _oauthResumeTimer?.cancel();
    _oauthFailureTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_awaitingOAuthResult) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _didLeaveAppForOAuth = true;
      return;
    }

    if (state == AppLifecycleState.resumed && _didLeaveAppForOAuth) {
      _oauthResumeTimer?.cancel();
      _oauthResumeTimer = Timer(const Duration(seconds: 1), () {
        if (!mounted || !_awaitingOAuthResult) {
          return;
        }
        if (_supabase?.auth.currentSession != null) {
          _resetOAuthFlow();
          return;
        }
        _scheduleOAuthFailureCheck();
      });
    }
  }

  Future<void> _signInWithGithub() async {
    if (_isSubmitting) {
      return;
    }

    if (!_isSupabaseConfigured || _supabase == null) {
      _showSnackBar('Supabase 설정이 없어 GitHub 로그인을 시작할 수 없습니다.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _awaitingOAuthResult = true;
      _didLeaveAppForOAuth = false;
      _statusMessage = 'GitHub 로그인 페이지를 여는 중입니다.';
    });

    try {
      final launched = await _supabase!.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: AppEnv.supabaseRedirectUrl,
        scopes: 'read:user user:email',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _handleLoginFailure();
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = '브라우저에서 GitHub 로그인을 완료하세요.';
      });
    } on AuthException catch (error) {
      _handleLoginFailure(error.message);
    } catch (_) {
      _handleLoginFailure();
    }
  }

  void _resetOAuthFlow() {
    _oauthResumeTimer?.cancel();
    _oauthFailureTimer?.cancel();
    _isSubmitting = false;
    _awaitingOAuthResult = false;
    _didLeaveAppForOAuth = false;
  }

  void _scheduleOAuthFailureCheck() {
    _oauthFailureTimer?.cancel();
    _oauthFailureTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted || !_awaitingOAuthResult) {
        return;
      }
      if (_supabase?.auth.currentSession != null) {
        _resetOAuthFlow();
        return;
      }
      _handleLoginFailure();
    });
  }

  void _notifyLoginSuccessIfNeeded() {
    if (_currentUser == null || _didNotifyLoginSuccess) {
      return;
    }
    _didNotifyLoginSuccess = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onLoginSuccess?.call();
    });
  }

  void _handleLoginFailure([String message = '로그인에 실패하였습니다']) {
    if (!mounted) {
      return;
    }
    setState(() {
      _resetOAuthFlow();
      _statusMessage = message;
    });
    _showSnackBar(message);
  }

  Future<void> _persistUser(User? user) async {
    if (user == null) {
      return;
    }

    final login = _displayLogin(user);
    final name = _displayName(user);
    final accessToken = _supabase?.auth.currentSession?.accessToken;

    if (accessToken != null) {
      await SecureStorage().storage.write(
        key: SecureStorageKey.githubAccessToken.name,
        value: accessToken,
      );
    }
    await SecureStorage().storage.write(
      key: SecureStorageKey.githubLogin.name,
      value: login,
    );
    await SecureStorage().storage.write(
      key: SecureStorageKey.githubName.name,
      value: name ?? '',
    );
  }

  Future<void> _clearStoredUser() async {
    await SecureStorage().storage.delete(
      key: SecureStorageKey.githubAccessToken.name,
    );
    await SecureStorage().storage.delete(
      key: SecureStorageKey.githubLogin.name,
    );
    await SecureStorage().storage.delete(key: SecureStorageKey.githubName.name);
  }

  String _displayLogin(User user) {
    final metadata = user.userMetadata ?? <String, dynamic>{};
    return (metadata['user_name'] ??
            metadata['preferred_username'] ??
            metadata['name'] ??
            user.email ??
            user.id)
        .toString();
  }

  String? _displayName(User user) {
    final metadata = user.userMetadata ?? <String, dynamic>{};
    final value = metadata['full_name'] ?? metadata['name'] ?? user.email;
    return value?.toString();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _currentUser;
    final login = user == null ? null : _displayLogin(user);
    final name = user == null ? null : _displayName(user);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'GitHub Login',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Supabase Auth로 GitHub 계정을 연결합니다.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '@$login',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                          if (name != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting || !_isSupabaseConfigured
                        ? null
                        : _signInWithGithub,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.code),
                    label: Text(
                      _isSubmitting ? 'GitHub 연결 중...' : 'GitHub로 로그인',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
