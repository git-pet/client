import 'package:client/models/pet.dart';
import 'package:client/ui/widgets/sprite_animator.dart';
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
  bool _isLoggingOut = false;

  // Pet state
  final PetType _petType = PetType.classicalCat;
  PetMood _mood = PetMood.idle;

  SpriteInfo get _sprite => petSprites[_petType]![_mood]!;

  // ── Logout ──────────────────────────────────────────────────────────

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

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
      if (!mounted) return;
      widget.onLogout?.call();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃에 실패하였습니다.')),
      );
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgrounds/Classic/1.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
              ),
            ),

            // Pet (centred in the room)
            Center(
              child: SpriteAnimator(
                assetPath: _petType.spritePath(_sprite.fileName),
                frameCount: _sprite.frameCount,
                size: _petType.frameSize * 4.0,
                fps: 6,
              ),
            ),

            // Mood selector chips at the bottom
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: _MoodSelector(
                current: _mood,
                onChanged: (m) => setState(() => _mood = m),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoggingOut ? null : _logout,
        icon: _isLoggingOut
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout),
        label: Text(_isLoggingOut ? '로그아웃 중...' : '로그아웃'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ── Mood selector ───────────────────────────────────────────────────────

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({required this.current, required this.onChanged});

  final PetMood current;
  final ValueChanged<PetMood> onChanged;

  static const _icons = {
    PetMood.idle: Icons.self_improvement,
    PetMood.happy: Icons.sentiment_very_satisfied,
    PetMood.sad: Icons.sentiment_dissatisfied,
    PetMood.sleeping: Icons.bedtime,
    PetMood.eating: Icons.restaurant,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: PetMood.values.map((mood) {
        final selected = mood == current;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            avatar: Icon(
              _icons[mood],
              size: 18,
              color: selected ? Colors.white : null,
            ),
            label: Text(mood.name),
            selected: selected,
            onSelected: (_) => onChanged(mood),
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: selected ? Colors.white : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
