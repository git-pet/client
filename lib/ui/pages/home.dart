import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/github_activity.dart';
import 'package:client/models/pet.dart';
import 'package:client/services/github_service.dart';
import 'package:client/ui/widgets/activity_tab.dart';
import 'package:client/ui/widgets/home_header.dart';
import 'package:client/ui/widgets/home_tab_section.dart';
import 'package:client/ui/widgets/pet_room_card.dart';
import 'package:client/ui/widgets/placeholder_tab_content.dart';
import 'package:client/ui/widgets/sheets/home_settings_sheet.dart';
import 'package:client/ui/widgets/sheets/language_selector_sheet.dart';
import 'package:client/ui/widgets/sheets/pet_selector_sheet.dart';
import 'package:client/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _tabPanelGap = 18.0;
  static const _collapsedTabPanelHeight = 172.0;
  static const _expandedTabPanelRatio = 0.6;

  final GithubService _githubService = GithubService();

  List<String> _tabs(AppLocalizations l10n) => [
    l10n.homeTabActivity,
    l10n.homeTabFriends,
    l10n.homeTabExplore,
    l10n.homeTabShop,
  ];

  bool _isLoggingOut = false;
  int _selectedTabIndex = 0;
  bool _isTabPanelExpanded = false;
  bool _isLoadingActivities = true;
  String? _githubLogin;
  String? _githubName;
  String? _activityError;
  List<GithubActivity> _activities = const [];

  PetType _petType = PetType.classicalCat;
  PetMood _mood = PetMood.idle;

  SpriteInfo get _sprite => petSprites[_petType]![_mood]!;

  @override
  void initState() {
    super.initState();
    _loadGithubActivities();
  }

  Future<void> _loadGithubActivities() async {
    setState(() {
      _isLoadingActivities = true;
      _activityError = null;
    });

    try {
      final feed = await _githubService.fetchPublicActivities();
      if (!mounted) return;
      setState(() {
        _githubLogin = feed.login;
        _githubName = feed.name;
        _activities = feed.activities;
        _isLoadingActivities = false;
      });
    } on GithubAuthRequiredException {
      await _handleUnauthorized();
    } on GithubUserNotConfiguredException {
      _setActivityError(
        AppLocalizations.of(context).homeActivityUserNotFound,
      );
    } on GithubApiException catch (e) {
      _setActivityError(
        AppLocalizations.of(context).homeActivityFetchFailed(e.statusCode),
      );
    } on GithubInvalidResponseException {
      _setActivityError(
        AppLocalizations.of(context).homeActivityInvalidResponse,
      );
    } catch (error) {
      _setActivityError(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _setActivityError(String message) {
    if (!mounted) return;
    setState(() {
      _activityError = message;
      _isLoadingActivities = false;
    });
  }

  Future<void> _handleUnauthorized() async {
    if (!mounted) return;
    // TODO: githubRefreshToken을 활용해 GitHub access token 재발급 로직 추가.
    //  현재는 임시로 강제 로그아웃 후 재로그인 유도. 재발급 성공 시에는
    //  새 토큰을 저장하고 _loadGithubActivities를 재시도하도록 변경할 것.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).homeSessionExpired)),
    );
    await _logout();
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await Supabase.instance.client.auth.signOut();
      await SecureStorage().clearGithubCredentials();
      if (!mounted) return;
      widget.onLogout?.call();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).homeLogoutFailed)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  Future<void> _openSettings() async {
    final action = await showHomeSettingsSheet(context, currentPet: _petType);
    if (action == null || !mounted) return;
    switch (action) {
      case HomeSettingsAction.changePet:
        await _pickPet();
        break;
      case HomeSettingsAction.changeLanguage:
        await showLanguageSelectorSheet(context);
        break;
      case HomeSettingsAction.logout:
        await _logout();
        break;
    }
  }

  Future<void> _pickPet() async {
    final selected = await showPetSelectorSheet(context, currentPet: _petType);
    if (selected == null || !mounted) return;
    setState(() {
      _petType = selected;
      _mood = PetMood.idle;
    });
  }

  void _collapseTabPanel() {
    if (_isTabPanelExpanded) {
      setState(() => _isTabPanelExpanded = false);
    }
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
      _isTabPanelExpanded = true;
    });
  }

  Widget _buildTabContent(BoxConstraints contentConstraints, List<String> tabs) {
    if (_selectedTabIndex == 0) {
      return ActivityTab(
        isExpanded: _isTabPanelExpanded,
        isLoading: _isLoadingActivities,
        githubName: _githubName,
        githubLogin: _githubLogin,
        error: _activityError,
        activities: _activities,
        onRetry: _loadGithubActivities,
      );
    }
    return PlaceholderTabContent(
      label: tabs[_selectedTabIndex],
      isExpanded: _isTabPanelExpanded,
      contentConstraints: contentConstraints,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = _tabs(l10n);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            children: [
              HomeHeader(
                isLoggingOut: _isLoggingOut,
                onOpenSettings: _openSettings,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final panelHeight = _isTabPanelExpanded
                        ? constraints.maxHeight * _expandedTabPanelRatio
                        : _collapsedTabPanelHeight;
                    final petRoomHeight =
                        constraints.maxHeight - panelHeight - _tabPanelGap;

                    return Column(
                      children: [
                        PetRoomCard(
                          height: petRoomHeight,
                          petType: _petType,
                          sprite: _sprite,
                          mood: _mood,
                          showCollapseHint: _isTabPanelExpanded,
                          onMoodChanged: (m) => setState(() => _mood = m),
                          onTap: _collapseTabPanel,
                        ),
                        const SizedBox(height: _tabPanelGap),
                        HomeTabSection(
                          height: panelHeight,
                          tabs: tabs,
                          selectedIndex: _selectedTabIndex,
                          isExpanded: _isTabPanelExpanded,
                          onTabSelected: _selectTab,
                          contentBuilder: (c) => _buildTabContent(c, tabs),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
