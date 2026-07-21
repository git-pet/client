import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/github_activity.dart';
import 'package:client/models/pet.dart';
import 'package:client/models/pet_state.dart';
import 'package:client/screens/stats/activity_stats_screen.dart';
import 'package:client/services/github_service.dart';
import 'package:client/services/pet_service.dart';
import 'package:client/ui/widgets/activity_tab.dart';
import 'package:client/ui/widgets/friend_feed_tab.dart';
import 'package:client/ui/widgets/friends_tab.dart';
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
  final PetService _petService = PetService();

  List<String> _tabs(AppLocalizations l10n) => [
    l10n.homeTabActivity,
    l10n.homeTabFriends,
    l10n.homeTabFriendFeed,
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

  // 서버가 관리하는 펫 상태 (level/exp/stage/mood).
  // null 이면 로드 실패 or 로드 전 — 스프라이트는 로컬 값으로 계속 렌더한다.
  PetState? _petProgress;
  bool _isLoadingPetProgress = true;
  String? _petProgressError;

  SpriteInfo get _sprite => petSprites[_petType]![_mood]!;

  @override
  void initState() {
    super.initState();
    _refreshHomeData();
  }

  // pet-progress GET 은 조회 전용. XP 적용은 서버 webhook 경로가 담당한다.
  Future<void> _loadPetProgress() async {
    if (!mounted) return;
    setState(() {
      _isLoadingPetProgress = true;
      _petProgressError = null;
    });

    try {
      final progress = await _petService.loadPetProgress();
      if (!mounted) return;
      setState(() {
        _petProgress = progress;
        _mood = _moodFromApi(progress.mood) ?? _mood;
        _isLoadingPetProgress = false;
      });
    } on PetAuthRequiredException {
      if (!mounted) return;
      setState(() => _isLoadingPetProgress = false);
      await _handleUnauthorized(retry: _loadPetProgress);
    } on PetServiceException catch (error) {
      _setPetProgressError(error.toString());
    } catch (error) {
      _setPetProgressError(error.toString().replaceFirst('Exception: ', ''));
    }
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
      _setActivityError(AppLocalizations.of(context).homeActivityUserNotFound);
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

  void _setPetProgressError(String message) {
    if (!mounted) return;
    setState(() {
      _petProgress = null;
      _petProgressError = message;
      _isLoadingPetProgress = false;
    });
  }

  Future<void> _refreshHomeData() async {
    await _loadGithubActivities();
    if (!mounted) return;
    await _loadPetProgress();
  }

  PetMood? _moodFromApi(String? raw) {
    switch (raw) {
      case 'happy':
        return PetMood.excited;
      case 'normal':
        return PetMood.idle;
      case 'sad':
        return PetMood.sad;
      case 'sleeping':
        return PetMood.sleep;
    }
    for (final mood in PetMood.values) {
      if (mood.name == raw) return mood;
    }
    return null;
  }

  // 갱신 재시도 사이클에서 두 번째 401이 다시 여기로 들어와 무한 루프가 되는 걸
  // 막는 재진입 가드. 첫 401이면 refresh 시도, 재시도까지 실패하면 로그아웃.
  bool _refreshInFlight = false;

  Future<void> _handleUnauthorized({Future<void> Function()? retry}) async {
    if (!mounted) return;

    if (!_refreshInFlight) {
      _refreshInFlight = true;
      try {
        await _githubService.refreshAccessToken();
        await (retry ?? _loadGithubActivities)();
        return;
      } catch (_) {
        // fallthrough — refresh 실패 시 아래 로그아웃 흐름으로.
      } finally {
        _refreshInFlight = false;
      }
    }

    if (!mounted) return;
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

  void _openStats() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ActivityStatsScreen()));
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
      _isTabPanelExpanded = true;
    });
  }

  Widget _buildTabContent(
    BoxConstraints contentConstraints,
    List<String> tabs,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return ActivityTab(
          isExpanded: _isTabPanelExpanded,
          isLoading: _isLoadingActivities,
          githubName: _githubName,
          githubLogin: _githubLogin,
          error: _activityError,
          activities: _activities,
          onRetry: _refreshHomeData,
        );
      case 1:
        return FriendsTab(isExpanded: _isTabPanelExpanded);
      case 2:
        return FriendFeedTab(isExpanded: _isTabPanelExpanded);
      default:
        return PlaceholderTabContent(
          label: tabs[_selectedTabIndex],
          isExpanded: _isTabPanelExpanded,
          contentConstraints: contentConstraints,
        );
    }
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
                onOpenStats: _openStats,
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
                          progress: _petProgress,
                          isLoadingProgress: _isLoadingPetProgress,
                          progressError: _petProgressError,
                          mood: _mood,
                          showCollapseHint: _isTabPanelExpanded,
                          onMoodChanged: (m) => setState(() => _mood = m),
                          onRetryProgress: _loadPetProgress,
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
