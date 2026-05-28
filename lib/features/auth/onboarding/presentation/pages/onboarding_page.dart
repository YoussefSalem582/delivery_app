import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/models/onboarding_slide_data.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/widgets/onboarding_background.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/widgets/onboarding_bottom_bar.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/widgets/onboarding_logo_layer.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/widgets/onboarding_slide_content.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/widgets/onboarding_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  final _stackKey = GlobalKey();
  final _centerAnchorKey = GlobalKey();
  final _topAnchorKey = GlobalKey();

  late final AnimationController _logoMoveController;

  int _currentPage = 0;
  bool _isMovingLogo = false;
  bool _logoHandoffToOverlay = false;

  int get _pageCount => kOnboardingSlides.length;
  bool get _isLastPage => _currentPage >= _pageCount - 1;

  @override
  void initState() {
    super.initState();
    _logoMoveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _logoMoveController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    if (index > 0 && _logoMoveController.value < 1) {
      _logoMoveController.value = 1;
    }
  }

  void _goToAuthChoice() {
    context.goNamed(RouteNames.authSelect);
  }

  Future<void> _animateLogoToTop() async {
    if (_logoMoveController.isAnimating || _logoMoveController.value == 1) {
      return;
    }
    _isMovingLogo = true;
    await _logoMoveController.forward();
    _isMovingLogo = false;
  }

  Future<void> _goNext() async {
    if (_isMovingLogo) return;

    if (_isLastPage) {
      _goToAuthChoice();
      return;
    }

    if (_currentPage == 0 && _logoMoveController.value == 0) {
      setState(() => _logoHandoffToOverlay = true);
      await _animateLogoToTop();
      if (!mounted) return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showCenterHero = _currentPage == 0 &&
        !_logoHandoffToOverlay &&
        _logoMoveController.value == 0;
    final showOverlayLogo =
        _logoHandoffToOverlay || _logoMoveController.value > 0;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const OnboardingBackground(),
          SafeArea(
            child: Stack(
              key: _stackKey,
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    OnboardingTopBar(
                      onSkip: _goToAuthChoice,
                      topAnchorKey: _topAnchorKey,
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pageCount,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, index) {
                          final slide = kOnboardingSlides[index];
                          return OnboardingSlideContent(
                            slide: slide,
                            pageIndex: index,
                            showBrandCircle: index == 0,
                            showBrandHero: index == 0 && showCenterHero,
                            centerAnchorKey:
                                index == 0 ? _centerAnchorKey : null,
                          );
                        },
                      ),
                    ),
                    OnboardingBottomBar(
                      pageCount: _pageCount,
                      activeIndex: _currentPage,
                      isLastPage: _isLastPage,
                      onNext: _goNext,
                      onFinish: _goToAuthChoice,
                    ),
                  ],
                ),
                if (showOverlayLogo)
                  OnboardingLogoLayer(
                    stackKey: _stackKey,
                    centerAnchorKey: _centerAnchorKey,
                    topAnchorKey: _topAnchorKey,
                    progress: _logoMoveController,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
