import 'package:flutter/material.dart';

class HomeTabSection extends StatelessWidget {
  const HomeTabSection({
    super.key,
    required this.height,
    required this.tabs,
    required this.selectedIndex,
    required this.isExpanded,
    required this.onTabSelected,
    required this.contentBuilder,
  });

  final double height;
  final List<String> tabs;
  final int selectedIndex;
  final bool isExpanded;
  final ValueChanged<int> onTabSelected;
  final Widget Function(BoxConstraints) contentBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(tabs.length, (index) {
              final isSelected = selectedIndex == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == tabs.length - 1 ? 0 : 8,
                  ),
                  child: GestureDetector(
                    onTap: () => onTabSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: isSelected
                            ? colors.primary.withValues(alpha: 0.18)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.55)
                              : Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Text(
                        tabs[index],
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
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
                vertical: isExpanded ? 16 : 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.black.withValues(alpha: 0.18),
              ),
              child: LayoutBuilder(
                builder: (context, contentConstraints) =>
                    contentBuilder(contentConstraints),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
