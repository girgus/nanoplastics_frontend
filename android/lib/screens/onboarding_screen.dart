import 'package:flutter/material.dart';
import 'dart:ui';
import '../config/app_colors.dart';
import '../widgets/nanosolve_logo.dart';
import '../l10n/app_localizations.dart';
import '../models/onboarding_slide.dart';
import '../services/settings_manager.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<OnboardingSlide> _getSlides(AppLocalizations l10n) {
    return [
      OnboardingSlide(
        imagePath: 'assets/onboarding/slide1_ocean_plastic.jpg',
        title: l10n.onboardingTitle1,
        titleHighlight: l10n.onboardingHighlight1,
        description: l10n.onboardingDescription1,
      ),
      OnboardingSlide(
        imagePath: 'assets/onboarding/slide2_missions.jpg',
        title: l10n.onboardingTitle2,
        titleHighlight: l10n.onboardingHighlight2,
        description: l10n.onboardingDescription2,
      ),
      OnboardingSlide(
        imagePath: 'assets/onboarding/slide3_collaboration.jpg',
        title: l10n.onboardingTitle3,
        titleHighlight: l10n.onboardingHighlight3,
        description: l10n.onboardingDescription3,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    final l10n = AppLocalizations.of(context)!;
    final slides = _getSlides(l10n);
    if (_currentPage < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _closeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _closeOnboarding() async {
    print('DEBUG: _closeOnboarding called');
    // Mark onboarding as shown
    await SettingsManager().setOnboardingShown(true);
    print('DEBUG: Onboarding marked as shown, navigating to MainScreen');

    _animationController.reverse().then((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background simulation (blurred)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  AppColors.pastelAqua.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: const Color(0xFF0A0A12).withValues(alpha: 0.6),
              ),
            ),
          ),

          // Modal overlay
          FadeTransition(
            opacity: _fadeAnimation,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: const Color(0xFF0A0A12).withValues(alpha: 0.6),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    constraints: const BoxConstraints(maxWidth: 550),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141928).withValues(alpha: 0.85),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 0,
                          offset: const Offset(0, 30),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildModalHeader(),
                          _buildSlidesContainer(),
                          _buildModalFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalHeader() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const NanosolveLogo(height: 50),
          IconButton(
            onPressed: _closeOnboarding,
            icon: const Icon(Icons.close, size: 32),
            color: AppColors.textMuted,
            hoverColor: AppColors.pastelAqua,
          ),
        ],
      ),
    );
  }

  Widget _buildSlidesContainer() {
    final l10n = AppLocalizations.of(context)!;
    final slides = _getSlides(l10n);
    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: slides.length,
        itemBuilder: (context, index) {
          return _buildSlide(slides[index]);
        },
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Media - Image or Icon
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: slide.imagePath != null
                  ? Image.asset(
                      slide.imagePath!,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.pastelAqua.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.pastelAqua.withValues(alpha: 0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: slide.icon != null
                            ? Icon(
                                slide.icon,
                                size: 30,
                                color: const Color(0xFF0A0A12),
                              )
                            : null,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 25),

          // Title with highlight using ShaderMask
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.pastelAqua, AppColors.pastelMint],
            ).createShader(bounds),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  TextSpan(
                    text: '${slide.title} ',
                    style: const TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: slide.titleHighlight,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Description
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              color: AppColors.textRed,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalFooter() {
    final l10n = AppLocalizations.of(context)!;
    final slides = _getSlides(l10n);
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: _currentPage == index ? 25 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.pastelAqua
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: _previousPage,
                  child: Text(
                    l10n.onboardingBack,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                const SizedBox(),
              ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  shadowColor: AppColors.pastelAqua.withValues(alpha: 0.5),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.pastelAqua, AppColors.pastelMint],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                    child: Text(
                      _currentPage == slides.length - 1
                          ? l10n.onboardingStart
                          : l10n.onboardingNext,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0A12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
