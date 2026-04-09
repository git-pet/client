import 'package:client/models/pet.dart';
import 'package:client/ui/widgets/sprite_animator.dart';
import 'package:client/utils/secure_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _tabs = ['활동내역', '친구', '탐색', '상점'];

  bool _isLoggingOut = false;
  int _selectedTabIndex = 0;
  bool _isTabPanelExpanded = false;

  // Pet state
  PetType _petType = PetType.classicalCat;
  PetMood _mood = PetMood.idle;

  SpriteInfo get _sprite => petSprites[_petType]![_mood]!;

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
                                      return SingleChildScrollView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight:
                                                contentConstraints.maxHeight,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _tabs[_selectedTabIndex],
                                                textAlign: TextAlign.center,
                                                style: theme
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              if (_isTabPanelExpanded) ...[
                                                const SizedBox(height: 12),
                                                Text(
                                                  '${_tabs[_selectedTabIndex]} 정보가 이 영역에 표시될 예정입니다.',
                                                  textAlign: TextAlign.center,
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Colors.white60,
                                                        height: 1.5,
                                                      ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
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

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}
