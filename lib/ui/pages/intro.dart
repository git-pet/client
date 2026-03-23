import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key, required this.onComplete});

  final Future<void> Function() onComplete;

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final _pageController = PageController();
  int _currentPage = 0;
  // TODO: i18n 적용
  static const _pages = [
    _IntroData(
      icon: Icons.pets_rounded,
      title: 'GitPet에 오신 걸 환영해요!',
      description: '커밋할수록 성장하는 나만의 펫을\n키워보세요.',
    ),
    _IntroData(
      icon: Icons.code_rounded,
      title: '커밋으로 성장',
      description: 'Git 활동이 곧 펫의 경험치!\n꾸준한 개발이 펫을 더 강하게 만들어요.',
    ),
    _IntroData(
      icon: Icons.emoji_events_rounded,
      title: '목표를 달성하세요',
      description: '연속 커밋 기록을 세우고\n특별한 보상을 받아보세요.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skip() => widget.onComplete();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  '건너뛰기',
                  style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary.withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            page.icon,
                            size: 18.w,
                            color: colors.primary,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          page.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          page.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? colors.primary
                              : colors.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 1.5.h,
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? '시작하기' : '다음',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroData {
  const _IntroData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
