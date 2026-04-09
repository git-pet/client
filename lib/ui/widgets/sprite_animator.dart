import 'package:flutter/material.dart';

/// Renders a horizontal sprite sheet as an animation.
///
/// The sprite sheet is a single row of equal-sized frames laid out
/// left-to-right. [frameCount] defines how many frames the sheet contains,
/// and [fps] controls the playback speed.
class SpriteAnimator extends StatefulWidget {
  const SpriteAnimator({
    super.key,
    required this.assetPath,
    required this.frameCount,
    this.fps = 8,
    this.size = 64,
    this.flipX = false,
  });

  /// Path to the sprite sheet asset (e.g. 'assets/pets/cats/...').
  final String assetPath;

  /// Number of frames in the horizontal strip.
  final int frameCount;

  /// Frames per second for the animation.
  final double fps;

  /// Display size (width & height) of each frame.
  final double size;

  /// Whether to mirror the sprite horizontally.
  final bool flipX;

  @override
  State<SpriteAnimator> createState() => _SpriteAnimatorState();
}

class _SpriteAnimatorState extends State<SpriteAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentFrame = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (widget.frameCount * 1000 / widget.fps).round(),
      ),
    )..repeat();

    _controller.addListener(_onTick);
  }

  @override
  void didUpdateWidget(SpriteAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath ||
        oldWidget.frameCount != widget.frameCount ||
        oldWidget.fps != widget.fps) {
      _controller.duration = Duration(
        milliseconds: (widget.frameCount * 1000 / widget.fps).round(),
      );
      _currentFrame = 0;
      _controller
        ..reset()
        ..repeat();
    }
  }

  void _onTick() {
    final frame =
        (_controller.value * widget.frameCount).floor() % widget.frameCount;
    if (frame != _currentFrame) {
      setState(() {
        _currentFrame = frame;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget sprite = SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.topLeft,
          child: Transform.translate(
            offset: Offset(-_currentFrame * widget.size, 0),
            child: Image.asset(
              widget.assetPath,
              width: widget.size * widget.frameCount,
              height: widget.size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
            ),
          ),
        ),
      ),
    );

    if (widget.flipX) {
      sprite = Transform.flip(flipX: true, child: sprite);
    }

    return sprite;
  }
}
