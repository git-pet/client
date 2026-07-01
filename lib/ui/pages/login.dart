import 'dart:async';

import 'package:client/config/app_env.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:client/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
          final l10n = AppLocalizations.of(context);
          setState(() {
            _currentUser = data.session?.user ?? _supabase!.auth.currentUser;
            _resetOAuthFlow();
            _statusMessage = _currentUser == null
                ? null
                : l10n.loginStatusSignedIn(_displayLogin(_currentUser!));
          });
          _notifyLoginSuccessIfNeeded();
          break;
        case AuthChangeEvent.signedOut:
          await _clearStoredUser();
          if (!mounted) {
            return;
          }
          final l10n = AppLocalizations.of(context);
          setState(() {
            _currentUser = null;
            _didNotifyLoginSuccess = false;
            _resetOAuthFlow();
            _statusMessage = l10n.loginStatusSignedOut;
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

    final l10n = AppLocalizations.of(context);

    if (!_isSupabaseConfigured || _supabase == null) {
      _showSnackBar(l10n.loginErrorSupabaseUnconfigured);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _awaitingOAuthResult = true;
      _didLeaveAppForOAuth = false;
      _statusMessage = l10n.loginStatusOpeningBrowser;
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
        _statusMessage = l10n.loginStatusCompleteInBrowser;
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

  void _handleLoginFailure([String? message]) {
    if (!mounted) {
      return;
    }
    final resolved = message ?? AppLocalizations.of(context).loginErrorGeneric;
    setState(() {
      _resetOAuthFlow();
      _statusMessage = resolved;
    });
    _showSnackBar(resolved);
  }

  Future<void> _persistUser(User? user) async {
    if (user == null) {
      return;
    }

    final login = _displayLogin(user);
    final name = _displayName(user);
    final storage = SecureStorage();

    final session = _supabase?.auth.currentSession;
    final providerToken = session?.providerToken;
    final providerRefreshToken = session?.providerRefreshToken;

    if (providerToken != null && providerToken.isNotEmpty) {
      await storage.write(SecureStorageKey.githubAccessToken, providerToken);
    }
    if (providerRefreshToken != null && providerRefreshToken.isNotEmpty) {
      await storage.write(
        SecureStorageKey.githubRefreshToken,
        providerRefreshToken,
      );
    }
    await storage.write(SecureStorageKey.githubLogin, login);
    await storage.write(SecureStorageKey.githubName, name ?? '');
  }

  Future<void> _clearStoredUser() => SecureStorage().clearGithubCredentials();

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
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final user = _currentUser;
    final login = user == null ? null : _displayLogin(user);
    final name = user == null ? null : _displayName(user);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/cat_pixel.png',
                  width: 120,
                  height: 120,
                  filterQuality: FilterQuality.medium,
                ),
                const SizedBox(height: 20),

                Text(
                  l10n.appTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.loginTagline,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white38,
                  ),
                ),

                if (user != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.github,
                          size: 24,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                login ?? '',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              if (name != null)
                                Text(
                                  name,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white38,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.loginConnectedBadge,
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _isSubmitting || !_isSupabaseConfigured
                        ? null
                        : _signInWithGithub,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1B1F23),
                      disabledBackgroundColor: Colors.white24,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1B1F23),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.github,
                                size: 20,
                                color: const Color(0xFF1B1F23),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l10n.loginContinueWithGithub,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                if (_statusMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _statusMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white30,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
