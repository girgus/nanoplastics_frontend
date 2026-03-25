import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_spacing.dart';
import '../utils/app_typography.dart';
import '../utils/app_theme_colors.dart';
import '../utils/responsive_config.dart';
import 'settings_manager.dart';

/// DEBUG: Set to true to always show the tour, false to respect SharedPreferences
const bool debugForceShowTour = false;

/// Extended tour state — tracks which step of the multi-screen tour we're on
enum ExtendedTourStep {
  mainScreen, // Step 0-6: Main screen tour (6 steps)
  brainstormBox, // Step 7-9: Brainstorm/idea posting (3 steps)
  sourcesScreen, // Step 10-12: Sources screen (3 steps)
  leaderboard, // Step 13-15: Leaderboard screen (3 steps)
  settings, // Step 16-18: User settings & sharing (3 steps)
  complete, // Tour finished
}

/// Keys bundle for extended tour across multiple screens
class ExtendedTourKeys {
  // MainScreen keys (already exist, reuse from main tour)
  final GlobalKey logoKey;
  final GlobalKey categoryGridKey;
  final GlobalKey humanButtonKey;
  final GlobalKey planetButtonKey;
  final GlobalKey humanPlanetRowKey;
  final GlobalKey sourcesButtonKey;
  final GlobalKey resultsButtonKey;
  final GlobalKey centerKnobKey;

  // BrainstormBox keys
  final GlobalKey? brainstormTitleKey;
  final GlobalKey? ideaInputKey;
  final GlobalKey? attachmentButtonKey;

  // SourcesScreen keys
  final GlobalKey? sourcesTitleKey;
  final GlobalKey? searchBarKey;
  final GlobalKey? pdfDownloadKey;

  // LeaderboardScreen keys
  final GlobalKey? leaderboardTitleKey;
  final GlobalKey? solverCardKey;
  final GlobalKey? rankingKey;

  // SettingsScreen keys
  final GlobalKey? settingsTitleKey;
  final GlobalKey? shareAppKey;
  final GlobalKey? profileSectionKey;

  const ExtendedTourKeys({
    required this.logoKey,
    required this.categoryGridKey,
    required this.humanButtonKey,
    required this.planetButtonKey,
    required this.humanPlanetRowKey,
    required this.sourcesButtonKey,
    required this.resultsButtonKey,
    required this.centerKnobKey,
    this.brainstormTitleKey,
    this.ideaInputKey,
    this.attachmentButtonKey,
    this.sourcesTitleKey,
    this.searchBarKey,
    this.pdfDownloadKey,
    this.leaderboardTitleKey,
    this.solverCardKey,
    this.rankingKey,
    this.settingsTitleKey,
    this.shareAppKey,
    this.profileSectionKey,
  });
}

/// Extended tour service for guiding users through entire app flow
class ExtendedTourService {
  static ExtendedTourService? _instance;
  ExtendedTourStep _currentStep = ExtendedTourStep.mainScreen;
  int _stepIndex = 0;
  VoidCallback? _onNavigate;
  VoidCallback? _onComplete;

  ExtendedTourService._internal();

  factory ExtendedTourService() {
    _instance ??= ExtendedTourService._internal();
    return _instance!;
  }

  static bool get _shouldSuppressTourUi {
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    return bindingType.contains('TestWidgetsFlutterBinding');
  }

  /// Get current tour step
  ExtendedTourStep get currentStep => _currentStep;
  int get stepIndex => _stepIndex;

  /// Set callbacks for navigation between screens and tab switching
  void setNavigationCallbacks({
    required VoidCallback onNavigate,
    required VoidCallback onComplete,
    VoidCallback? onSwitchToHuman,
  }) {
    _onNavigate = onNavigate;
    _onComplete = onComplete;
    _onSwitchToHuman = onSwitchToHuman;
  }

  VoidCallback? _onSwitchToHuman;

  /// Show extended tour if user hasn't seen it yet
  static Future<void> showIfNeeded(
    BuildContext context,
    ExtendedTourKeys keys, {
    VoidCallback? onSwitchToHuman,
  }) async {
    final settings = SettingsManager();

    // DEBUG: Skip cache check if debugForceShowTour is true
    if (!debugForceShowTour && settings.hasShownAdvisorTour) return;

    if (!context.mounted) return;

    // Mark tour as shown immediately so a language change (app restart) mid-tour
    // does not re-trigger it. Safe to do before startTour since the user has
    // already seen the tour begin.
    // Capture context-dependent objects before the async gap.
    final service = ExtendedTourService();
    service.setNavigationCallbacks(
      onNavigate: () {},
      onComplete: () {},
      onSwitchToHuman: onSwitchToHuman,
    );

    await settings.setAdvisorTourShown(true);

    if (!context.mounted) return;
    if (_shouldSuppressTourUi) return;

    service.startTour(context, keys);
  }

  /// Start the extended tour from the beginning
  void startTour(BuildContext context, ExtendedTourKeys keys) {
    _currentStep = ExtendedTourStep.mainScreen;
    _stepIndex = 0;
    // Delay to allow iOS page-transition animation (~400ms) to complete before
    // calling localToGlobal. Without this, the category grid spotlight appears
    // at the right edge of the screen because the page is still sliding in.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!context.mounted) return;
      _showMainScreenTour(context, keys);
    });
  }

  /// Move to next screen in tour
  void nextScreen(BuildContext context, ExtendedTourKeys keys) {
    switch (_currentStep) {
      case ExtendedTourStep.mainScreen:
        _currentStep = ExtendedTourStep.brainstormBox;
        _stepIndex = 0;
        _onNavigate?.call();
        // Tour for brainstorm screen will be shown when screen navigates
        break;
      case ExtendedTourStep.brainstormBox:
        _currentStep = ExtendedTourStep.sourcesScreen;
        _stepIndex = 0;
        _onNavigate?.call();
        break;
      case ExtendedTourStep.sourcesScreen:
        _currentStep = ExtendedTourStep.leaderboard;
        _stepIndex = 0;
        _onNavigate?.call();
        break;
      case ExtendedTourStep.leaderboard:
        _currentStep = ExtendedTourStep.settings;
        _stepIndex = 0;
        _onNavigate?.call();
        break;
      case ExtendedTourStep.settings:
        _currentStep = ExtendedTourStep.complete;
        _onComplete?.call();
        break;
      case ExtendedTourStep.complete:
        break;
    }
  }

  /// Show appropriate tour based on current screen (call from each screen's initState)
  void showCurrentScreenTour(BuildContext context, ExtendedTourKeys keys) {
    if (_shouldSuppressTourUi) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!context.mounted) return;
      switch (_currentStep) {
        case ExtendedTourStep.brainstormBox:
          showBrainstormTour(context, keys);
          break;
        case ExtendedTourStep.sourcesScreen:
          showSourcesTour(context, keys);
          break;
        case ExtendedTourStep.leaderboard:
          showLeaderboardTour(context, keys);
          break;
        case ExtendedTourStep.settings:
          showSettingsTour(context, keys);
          break;
        default:
          break;
      }
    });
  }

  void _showMainScreenTour(BuildContext context, ExtendedTourKeys keys) {
    final typography = AppTypography.of(context);
    final tc = AppThemeColors.of(context);
    final targets = <TargetFocus>[
      TargetFocus(
        identify: 'tour_category_grid',
        keyTarget: keys.categoryGridKey,
        shape: ShapeLightFocus.RRect,
        paddingFocus: 4,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign
                .bottom, // grid is at top of screen — always show below
            builder: (context, controller) => _TourTooltip(
              body: AppLocalizations.of(context)!.tourCategoryGridBody,
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'tour_human_planet_row',
        keyTarget: keys.humanPlanetRowKey,
        shape: ShapeLightFocus.RRect,
        paddingFocus: 8,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body: AppLocalizations.of(context)!.tourHumanPlanetBody,
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'tour_sources_button',
        keyTarget: keys.sourcesButtonKey,
        shape: ShapeLightFocus.Circle,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body: AppLocalizations.of(context)!.tourSourcesButtonBody,
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'tour_results_button',
        keyTarget: keys.resultsButtonKey,
        shape: ShapeLightFocus.Circle,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body: AppLocalizations.of(context)!.tourResultsButtonBody,
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'tour_center_knob',
        keyTarget: keys.centerKnobKey,
        shape: ShapeLightFocus.Circle,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body: AppLocalizations.of(context)!.tourSettingsBody,
              typography: typography,
              tc: tc,
              controller: controller,
              isFinal: true,
            ),
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.85,
      textSkip: AppLocalizations.of(context)!.tourBtnSkipTour,
      alignSkip: Alignment.topRight,
      paddingFocus: 4,
      focusAnimationDuration: const Duration(milliseconds: 300),
      pulseAnimationDuration: const Duration(milliseconds: 800),
      onClickTarget: (target) {
        // Auto-switch tabs when viewing category explanations
        if (target.identify == 'tour_human_planet_row') {
          _onSwitchToHuman?.call();
        }
      },
      onFinish: () {
        _currentStep = ExtendedTourStep.complete;
        _onComplete?.call();
      },
      onSkip: () => true,
    ).show(context: context);
  }

  /// Show tour for brainstorm/idea posting screen
  void showBrainstormTour(BuildContext context, ExtendedTourKeys keys) {
    if (keys.brainstormTitleKey == null || keys.ideaInputKey == null) return;

    final typography = AppTypography.of(context);
    final tc = AppThemeColors.of(context);

    final targets = <TargetFocus>[
      TargetFocus(
        identify: 'tour_brainstorm_title',
        keyTarget: keys.brainstormTitleKey!,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body:
                  'Submit your innovative solutions to combat nanoplastic pollution.',
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'tour_idea_input',
        keyTarget: keys.ideaInputKey!,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body: 'Write a detailed description of your solution.',
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'tour_attachments',
        keyTarget: keys.attachmentButtonKey ?? keys.ideaInputKey!,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body: 'Attach photos, videos, or documents to support your idea.',
              typography: typography,
              tc: tc,
              controller: controller,
              isFinal: false,
            ),
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.85,
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 300),
      pulseAnimationDuration: const Duration(milliseconds: 800),
      onFinish: () => nextScreen(context, keys),
      onSkip: () => true,
    ).show(context: context);
  }

  /// Show tour for sources screen
  void showSourcesTour(BuildContext context, ExtendedTourKeys keys) {
    if (keys.sourcesTitleKey == null || keys.searchBarKey == null) return;

    final typography = AppTypography.of(context);
    final tc = AppThemeColors.of(context);

    final targets = <TargetFocus>[
      TargetFocus(
        identify: 'tour_sources_title',
        keyTarget: keys.sourcesTitleKey!,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body: 'Access peer-reviewed research on nanoplastics.',
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'tour_search_bar',
        keyTarget: keys.searchBarKey!,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body: 'Find references by impact category or keyword.',
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'tour_pdf_download',
        keyTarget: keys.pdfDownloadKey ?? keys.searchBarKey!,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body: 'Download full research reports in your language.',
              typography: typography,
              tc: tc,
              controller: controller,
              isFinal: false,
            ),
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.85,
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 300),
      pulseAnimationDuration: const Duration(milliseconds: 800),
      onFinish: () => nextScreen(context, keys),
      onSkip: () => true,
    ).show(context: context);
  }

  /// Show tour for leaderboard screen
  void showLeaderboardTour(BuildContext context, ExtendedTourKeys keys) {
    if (keys.leaderboardTitleKey == null || keys.solverCardKey == null) return;

    final typography = AppTypography.of(context);
    final tc = AppThemeColors.of(context);

    final targets = <TargetFocus>[
      TargetFocus(
        identify: 'tour_leaderboard_title',
        keyTarget: keys.leaderboardTitleKey!,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body: 'Compete with other innovators to rank by contributions.',
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'tour_solver_card',
        keyTarget: keys.solverCardKey!,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body: 'See who is leading the community with their ideas.',
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'tour_rankings',
        keyTarget: keys.rankingKey ?? keys.solverCardKey!,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body:
                  'Submit quality ideas to climb the rankings and get recognized.',
              typography: typography,
              tc: tc,
              controller: controller,
              isFinal: false,
            ),
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.85,
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 300),
      pulseAnimationDuration: const Duration(milliseconds: 800),
      onFinish: () => nextScreen(context, keys),
      onSkip: () => true,
    ).show(context: context);
  }

  /// Show tour for settings screen with QR code sharing
  void showSettingsTour(BuildContext context, ExtendedTourKeys keys) {
    if (keys.settingsTitleKey == null || keys.shareAppKey == null) return;

    final typography = AppTypography.of(context);
    final tc = AppThemeColors.of(context);

    final targets = <TargetFocus>[
      TargetFocus(
        identify: 'tour_settings_title',
        keyTarget: keys.settingsTitleKey!,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body: 'Manage your account and app settings.',
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'tour_share_app',
        keyTarget: keys.shareAppKey!,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body:
                  'Scan QR code or share link to invite friends to join the community.',
              typography: typography,
              tc: tc,
              controller: controller,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'tour_profile_section',
        keyTarget: keys.profileSectionKey ?? keys.shareAppKey!,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _TourTooltip(
              body:
                  'You\'re ready to explore and contribute. Happy innovating!',
              typography: typography,
              tc: tc,
              controller: controller,
              isFinal: true,
            ),
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.85,
      textSkip: AppLocalizations.of(context)!.tourBtnSkipTour,
      alignSkip: Alignment.topRight,
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 300),
      pulseAnimationDuration: const Duration(milliseconds: 800),
      onFinish: () {
        _currentStep = ExtendedTourStep.complete;
        _onComplete?.call();
      },
      onSkip: () => true,
    ).show(context: context);
  }
}

/// Glassmorphism tooltip widget for tour steps
class _TourTooltip extends StatelessWidget {
  final String body;
  final AppTypography typography;
  final AppThemeColors tc;
  final dynamic controller;
  final bool isFinal;

  const _TourTooltip({
    required this.body,
    required this.typography,
    required this.tc,
    required this.controller,
    this.isFinal = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveConfig.fromContext(context);
    final spacing = AppSpacing.of(context);
    final isCompact = responsive.isCompact;
    final tooltipWidth = responsive.isBig
        ? spacing.lg * 25
        : (isCompact ? spacing.lg * 17.5 : spacing.lg * 20);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: tooltipWidth),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.xs,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tc.cardBackground.withValues(alpha: 0.92),
              tc.surfaceMid.withValues(alpha: 0.96),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.pastelAqua.withValues(alpha: 0.12),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              body,
              style: typography.body.copyWith(
                color: tc.textMuted,
                fontSize: isCompact ? 10 : 11,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(44, 24),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                onPressed: () => controller.next(),
                child: Text(
                  isFinal
                      ? AppLocalizations.of(context)!.tourBtnDone
                      : AppLocalizations.of(context)!.tourBtnNext,
                  style: typography.label.copyWith(
                    color: AppColors.pastelAqua,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
