import 'dart:convert';

import 'package:client/models/pet.dart';
import 'package:client/ui/widgets/sprite_animator.dart';
import 'package:client/utils/secure_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _tabs = ['활동내역', '친구', '탐색', '상점'];
  static const _githubApiBaseUrl = 'https://api.github.com';

  bool _isLoggingOut = false;
  int _selectedTabIndex = 0;
  bool _isTabPanelExpanded = false;
  bool _isLoadingActivities = true;
  String? _githubLogin;
  String? _githubName;
  String? _activityError;
  List<GithubActivity> _activities = const [];

  // Pet state
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
      final storage = SecureStorage().storage;
      final login = await storage.read(key: SecureStorageKey.githubLogin.name);
      final name = await storage.read(key: SecureStorageKey.githubName.name);

      if (login == null || login.isEmpty) {
        throw Exception('GitHub 사용자 정보를 찾을 수 없습니다.');
      }

      final uri = Uri.parse(
        '$_githubApiBaseUrl/users/$login/events/public?per_page=20',
      );
      final response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('GitHub 활동을 불러오지 못했습니다. (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw Exception('GitHub 응답 형식이 올바르지 않습니다.');
      }

      final activities = decoded
          .whereType<Map<String, dynamic>>()
          .map(GithubActivity.fromJson)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _githubLogin = login;
        _githubName = (name != null && name.isNotEmpty) ? name : login;
        _activities = activities;
        _isLoadingActivities = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _activityError = error.toString().replaceFirst('Exception: ', '');
        _isLoadingActivities = false;
      });
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await Supabase.instance.client.auth.signOut();
      await SecureStorage().storage.delete(
        key: SecureStorageKey.githubAccessToken.name,
      );
      await SecureStorage().storage.delete(
        key: SecureStorageKey.githubLogin.name,
      );
      await SecureStorage().storage.delete(
        key: SecureStorageKey.githubName.name,
      );
      if (!mounted) {
        return;
      }
      widget.onLogout?.call();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그아웃에 실패하였습니다.')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  Future<void> _showPetSelector() async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.85,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '펫 선택 (Debug)',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: PetType.values.length,
                        itemBuilder: (context, index) {
                          final pet = PetType.values[index];
                          final selected = pet == _petType;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: selected
                                    ? colors.primary.withValues(alpha: 0.25)
                                    : colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.pets_rounded,
                                color: selected
                                    ? colors.primary
                                    : Colors.white54,
                              ),
                            ),
                            title: Text(
                              pet.displayName,
                              style: TextStyle(
                                color: selected
                                    ? colors.primary
                                    : Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${pet.frameSize}px',
                              style: const TextStyle(color: Colors.white38),
                            ),
                            trailing: selected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: colors.primary,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                _petType = pet;
                                _mood = PetMood.idle;
                              });
                              Navigator.of(sheetContext).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openSettings() async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '설정',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '계정과 앱 관련 기능을 여기서 관리합니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 20),
                if (kDebugMode) ...[
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.pets_rounded, color: colors.primary),
                    ),
                    title: const Text(
                      '펫 변경 (Debug)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      _petType.displayName,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white38,
                    ),
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await _showPetSelector();
                    },
                  ),
                  const Divider(color: Colors.white12),
                ],
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.logout_rounded, color: colors.primary),
                  ),
                  title: const Text(
                    '로그아웃',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    '현재 연결된 GitHub 계정을 해제합니다.',
                    style: TextStyle(color: Colors.white54),
                  ),
                  trailing: _isLoggingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white38,
                        ),
                  onTap: _isLoggingOut
                      ? null
                      : () async {
                          Navigator.of(sheetContext).pop();
                          await _logout();
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            children: [
              _HomeHeader(
                isLoggingOut: _isLoggingOut,
                onOpenSettings: _openSettings,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 18.0;
                    final collapsedPanelHeight = 172.0;
                    final expandedPanelHeight = constraints.maxHeight * 0.6;
                    final panelHeight = _isTabPanelExpanded
                        ? expandedPanelHeight
                        : collapsedPanelHeight;
                    final petRoomHeight =
                        constraints.maxHeight - panelHeight - gap;

                    return Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          height: petRoomHeight,
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colors.secondaryContainer,
                                colors.surface,
                                colors.surface,
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '나의 펫 룸',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (_isTabPanelExpanded) {
                                      setState(() {
                                        _isTabPanelExpanded = false;
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: Colors.white.withValues(
                                        alpha: 0.04,
                                      ),
                                      border: Border.all(
                                        color: colors.primary.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Stack(
                                        children: [
                                          // Background image
                                          Positioned.fill(
                                            child: Image.asset(
                                              'assets/images/backgrounds/Classic/1.png',
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.none,
                                            ),
                                          ),
                                          // Pet sprite
                                          Center(
                                            child: SpriteAnimator(
                                              assetPath: _petType.spritePath(
                                                _sprite.fileName,
                                              ),
                                              frameCount: _sprite.frameCount,
                                              size: _petType.frameSize <= 16
                                                  ? 64
                                                  : 96,
                                              fps: 6,
                                            ),
                                          ),
                                          // Debug mood selector
                                          if (kDebugMode)
                                            Positioned(
                                              bottom: 8,
                                              left: 8,
                                              right: 8,
                                              child: _DebugMoodSelector(
                                                current: _mood,
                                                petType: _petType,
                                                onChanged: (m) =>
                                                    setState(() => _mood = m),
                                              ),
                                            ),
                                          // Expand hint
                                          if (_isTabPanelExpanded)
                                            Positioned(
                                              bottom: 8,
                                              left: 0,
                                              right: 0,
                                              child: Text(
                                                '탭을 접으려면 이 영역을 누르세요.',
                                                textAlign: TextAlign.center,
                                                style: theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Colors.white60,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: gap),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          height: panelHeight,
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: List.generate(_tabs.length, (index) {
                                  final isSelected = _selectedTabIndex == index;
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: index == _tabs.length - 1
                                            ? 0
                                            : 8,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedTabIndex = index;
                                            _isTabPanelExpanded = true;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          curve: Curves.easeOut,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            color: isSelected
                                                ? colors.primary.withValues(
                                                    alpha: 0.18,
                                                  )
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isSelected
                                                  ? colors.primary.withValues(
                                                      alpha: 0.55,
                                                    )
                                                  : Colors.white.withValues(
                                                      alpha: 0.06,
                                                    ),
                                            ),
                                          ),
                                          child: Text(
                                            _tabs[index],
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                                  color: isSelected
                                                      ? colors.primary
                                                      : Colors.white70,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: _isTabPanelExpanded ? 16 : 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: Colors.black.withValues(alpha: 0.18),
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, contentConstraints) {
                                      return _buildTabContent(
                                        context,
                                        contentConstraints,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildTabContent(
    BuildContext context,
    BoxConstraints contentConstraints,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return _ActivityTabContent(
          isExpanded: _isTabPanelExpanded,
          isLoading: _isLoadingActivities,
          githubName: _githubName,
          githubLogin: _githubLogin,
          error: _activityError,
          activities: _activities,
          onRetry: _loadGithubActivities,
        );
      default:
        final theme = Theme.of(context);
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: contentConstraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _tabs[_selectedTabIndex],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_isTabPanelExpanded) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${_tabs[_selectedTabIndex]} 정보가 이 영역에 표시될 예정입니다.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white60,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
    }
  }
}

class GithubActivity {
  const GithubActivity({
    required this.type,
    required this.repoName,
    required this.createdAt,
    required this.title,
    required this.description,
  });

  final String type;
  final String repoName;
  final DateTime? createdAt;
  final String title;
  final String description;

  factory GithubActivity.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] ?? 'Event').toString();
    final repo = json['repo'];
    final payload = json['payload'];
    final repoName = repo is Map<String, dynamic>
        ? (repo['name'] ?? '알 수 없는 저장소').toString()
        : '알 수 없는 저장소';
    final createdAtRaw = json['created_at']?.toString();
    final createdAt = createdAtRaw == null
        ? null
        : DateTime.tryParse(createdAtRaw)?.toLocal();

    return GithubActivity(
      type: type,
      repoName: repoName,
      createdAt: createdAt,
      title: _buildTitle(type),
      description: _buildDescription(type, payload, repoName),
    );
  }

  static String _buildTitle(String type) {
    switch (type) {
      case 'PushEvent':
        return '커밋을 푸시했어요';
      case 'PullRequestEvent':
        return 'PR 활동이 있어요';
      case 'IssuesEvent':
        return '이슈 활동이 있어요';
      case 'IssueCommentEvent':
        return '이슈 댓글을 남겼어요';
      case 'PullRequestReviewEvent':
        return 'PR 리뷰를 남겼어요';
      case 'WatchEvent':
        return '저장소에 스타를 눌렀어요';
      case 'CreateEvent':
        return '브랜치 또는 태그를 생성했어요';
      case 'ForkEvent':
        return '저장소를 포크했어요';
      default:
        return type.replaceAll('Event', ' 활동');
    }
  }

  static String _buildDescription(
    String type,
    dynamic payload,
    String repoName,
  ) {
    if (payload is! Map<String, dynamic>) {
      return repoName;
    }

    switch (type) {
      case 'PushEvent':
        final commitCount = payload['size'];
        final commits = payload['commits'];
        if (commitCount is int && commitCount > 0) {
          if (commits is List && commits.isNotEmpty) {
            final firstCommit = commits.first;
            if (firstCommit is Map<String, dynamic>) {
              final message = firstCommit['message']?.toString().trim();
              if (message != null && message.isNotEmpty) {
                return '$repoName · $commitCount개 커밋 · $message';
              }
            }
          }
          return '$repoName · $commitCount개 커밋 푸시';
        }
        return '$repoName에 커밋을 푸시했습니다.';
      case 'PullRequestEvent':
        final action = payload['action']?.toString() ?? 'updated';
        final pullRequest = payload['pull_request'];
        final title = pullRequest is Map<String, dynamic>
            ? pullRequest['title']?.toString()
            : null;
        return '$repoName · PR $action${title == null || title.isEmpty ? '' : ' · $title'}';
      case 'IssuesEvent':
        final action = payload['action']?.toString() ?? 'updated';
        final issue = payload['issue'];
        final title = issue is Map<String, dynamic>
            ? issue['title']?.toString()
            : null;
        return '$repoName · 이슈 $action${title == null || title.isEmpty ? '' : ' · $title'}';
      case 'IssueCommentEvent':
        final issue = payload['issue'];
        final title = issue is Map<String, dynamic>
            ? issue['title']?.toString()
            : null;
        return '$repoName · 댓글 작성${title == null || title.isEmpty ? '' : ' · $title'}';
      case 'PullRequestReviewEvent':
        final review = payload['review'];
        final state = review is Map<String, dynamic>
            ? review['state']?.toString()
            : null;
        return '$repoName · 리뷰 ${state ?? '작성'}';
      case 'WatchEvent':
        return '$repoName · star';
      case 'CreateEvent':
        final refType = payload['ref_type']?.toString() ?? 'resource';
        final ref = payload['ref']?.toString();
        return '$repoName · $refType 생성${ref == null || ref.isEmpty ? '' : ' · $ref'}';
      case 'ForkEvent':
        return '$repoName · 포크 생성';
      default:
        return repoName;
    }
  }
}

class _ActivityTabContent extends StatelessWidget {
  const _ActivityTabContent({
    required this.isExpanded,
    required this.isLoading,
    required this.githubName,
    required this.githubLogin,
    required this.error,
    required this.activities,
    required this.onRetry,
  });

  final bool isExpanded;
  final bool isLoading;
  final String? githubName;
  final String? githubLogin;
  final String? error;
  final List<GithubActivity> activities;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (!isExpanded) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights_rounded, color: colors.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '탭을 확장하면 GitHub 활동을 불러옵니다.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '활동을 불러오지 못했습니다.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          githubName ?? 'GitHub 활동',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (githubLogin != null) ...[
          const SizedBox(height: 4),
          Text(
            '@$githubLogin의 최근 공개 활동',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
          ),
        ],
        const SizedBox(height: 16),
        if (activities.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                '표시할 공개 활동이 아직 없습니다.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRetry,
              child: ListView.separated(
                itemCount: activities.length,
                separatorBuilder: (_, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: colors.primary.withValues(alpha: 0.18),
                          ),
                          child: Icon(
                            _iconForActivity(activity.type),
                            color: colors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activity.description,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                              ),
                              if (activity.createdAt != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _formatRelativeTime(activity.createdAt!),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  static IconData _iconForActivity(String type) {
    switch (type) {
      case 'PushEvent':
        return Icons.upload_rounded;
      case 'PullRequestEvent':
        return Icons.merge_type_rounded;
      case 'IssuesEvent':
        return Icons.error_outline_rounded;
      case 'IssueCommentEvent':
        return Icons.chat_bubble_outline_rounded;
      case 'PullRequestReviewEvent':
        return Icons.rate_review_outlined;
      case 'WatchEvent':
        return Icons.star_border_rounded;
      case 'ForkEvent':
        return Icons.call_split_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }

  static String _formatRelativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return '방금 전';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    }
    if (difference.inDays < 30) {
      return '${difference.inDays}일 전';
    }
    final month = (difference.inDays / 30).floor();
    if (month < 12) {
      return '$month개월 전';
    }
    final year = (difference.inDays / 365).floor();
    return '$year년 전';
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.isLoggingOut, required this.onOpenSettings});

  final bool isLoggingOut;
  final Future<void> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withValues(alpha: 0.14),
            ),
            child: Icon(Icons.pets_rounded, color: colors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'GitPet Home',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: isLoggingOut ? null : onOpenSettings,
            style: IconButton.styleFrom(
              minimumSize: const Size(38, 38),
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white.withValues(alpha: 0.04),
              foregroundColor: Colors.white70,
            ),
            icon: isLoggingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.menu_rounded),
          ),
        ],
      ),
    );
  }
}

class _DebugMoodSelector extends StatelessWidget {
  const _DebugMoodSelector({
    required this.current,
    required this.onChanged,
    required this.petType,
  });

  final PetMood current;
  final ValueChanged<PetMood> onChanged;
  final PetType petType;

  @override
  Widget build(BuildContext context) {
    final available =
        PetMood.values.where((m) => petSprites[petType]!.containsKey(m));

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: available.map((mood) {
        final selected = mood == current;
        return Material(
          color: selected
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onChanged(mood),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                mood.label,
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
