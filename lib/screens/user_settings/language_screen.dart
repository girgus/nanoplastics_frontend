import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_typography.dart';
import '../../widgets/nanosolve_logo.dart';
import '../../widgets/glowing_header_separator.dart';
import '../../utils/app_theme_colors.dart';
import '../../mixins/language_selection_mixin.dart';

class LanguageScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;

  const LanguageScreen({super.key, this.onLanguageChanged});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with LanguageSelectionMixin {
  final List<LanguageOption> _languages = [
    const LanguageOption(
        code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
    const LanguageOption(
        code: 'cs', name: 'Czech', nativeName: 'Čeština', flag: '🇨🇿'),
    const LanguageOption(
        code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    const LanguageOption(
        code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    const LanguageOption(
        code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
  ];

  @override
  void initState() {
    super.initState();
    initLanguageSelection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.pastelAqua
                  .withValues(alpha: AppThemeColors.of(context).pastelAlpha),
              AppColors.pastelMint
                  .withValues(alpha: AppThemeColors.of(context).pastelAlpha),
              AppThemeColors.of(context).gradientEnd,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _buildContent(),
                    ),
                    ...GlowingHeaderSeparator.build(
                      glowColor: AppColors.energy,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.contentPaddingH,
          vertical: spacing.contentPaddingV),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_back_ios,
                      color: AppThemeColors.of(context).textMain,
                      size: sizing.backIcon),
                  const SizedBox(width: AppConstants.space4),
                  Flexible(
                    child: Text(
                      l10n.categoryDetailBackToOverview,
                      style: typography.back.copyWith(
                        color: AppThemeColors.of(context).textMain,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: spacing.headerSpacing),
          NanosolveLogo(height: sizing.logoHeightLg),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.contentPaddingH,
          vertical: spacing.contentPaddingV),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(typography),
          SizedBox(height: spacing.cardSpacing * 2),
          ..._languages.map((lang) => Padding(
                padding: EdgeInsets.only(bottom: spacing.cardSpacing),
                child: _buildLanguageItem(
                  lang,
                  spacing,
                  sizing,
                  typography,
                ),
              )),
          SizedBox(height: spacing.cardSpacing),
          _buildInfoCard(spacing, sizing, typography),
          SizedBox(height: spacing.cardSpacing * 2),
        ],
      ),
    );
  }

  Widget _buildTitleSection(AppTypography typography) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.pastelAqua, AppColors.pastelMint],
          ).createShader(bounds),
          child: Text(
            AppLocalizations.of(context)!.languageTitle,
            style: typography.display.copyWith(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          AppLocalizations.of(context)!.languageSubtitle,
          style: typography.subtitle.copyWith(
            color: AppThemeColors.of(context).textMuted,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLanguageItem(
    LanguageOption language,
    AppSpacing spacing,
    AppSizing sizing,
    AppTypography typography,
  ) {
    final isSelected = selectedLanguage == language.code;

    return InkWell(
      onTap: () => selectLanguage(language.code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(spacing.cardPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pastelAqua.withValues(alpha: 0.15)
              : AppThemeColors.of(context)
                  .cardBackground
                  .withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: isSelected
                ? AppColors.pastelAqua.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.pastelAqua.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              language.flag,
              style: TextStyle(fontSize: sizing.iconMd + 6),
            ),
            SizedBox(width: spacing.cardSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: typography.title.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.pastelAqua
                          : AppThemeColors.of(context).textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language.nativeName,
                    style: typography.subtitle.copyWith(
                      color: isSelected
                          ? AppColors.pastelAqua.withValues(alpha: 0.7)
                          : AppThemeColors.of(context).textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: sizing.iconMd,
              height: sizing.iconMd,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.pastelAqua : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.pastelAqua : AppColors.textDark,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check,
                      size: sizing.iconMd * 0.65,
                      color: const Color(0xFF0A0A12))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    AppSpacing spacing,
    AppSizing sizing,
    AppTypography typography,
  ) {
    return Container(
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.pastelAqua.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppColors.pastelAqua.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: sizing.iconMd,
            color: AppColors.pastelAqua,
          ),
          SizedBox(width: spacing.cardSpacing),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.languageInfoMessage,
              style: typography.subtitle.copyWith(
                color: AppThemeColors.of(context).textMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}
