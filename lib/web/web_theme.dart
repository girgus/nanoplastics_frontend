import 'package:flutter/material.dart';

class WebTheme {
  // Surfaces
  static Color surfaceCard(BuildContext ctx) =>
      Colors.white.withValues(alpha: 0.04);
  static Color surfaceHover(BuildContext ctx) =>
      Colors.white.withValues(alpha: 0.08);
  static Color surfacePanel(BuildContext ctx) =>
      Colors.black.withValues(alpha: 0.22);
  static Color surfaceTopbar(BuildContext ctx) =>
      Colors.black.withValues(alpha: 0.18);
  static Color surfaceAiPanel(BuildContext ctx) =>
      Colors.black.withValues(alpha: 0.55);

  // Borders
  static Color borderSubtle = Colors.white.withValues(alpha: 0.08);
  static Color borderMid = Colors.white.withValues(alpha: 0.14);
  static Color borderDivider = Colors.white.withValues(alpha: 0.06);

  // Text
  static Color textPrimary = Colors.white;
  static Color textSecondary = Colors.white.withValues(alpha: 0.65);
  static Color textMuted = Colors.white.withValues(alpha: 0.40);
  static Color textDisabled = Colors.white.withValues(alpha: 0.25);

  // Layout
  static const double sidebarCollapsed = 68;
  static const double sidebarExpanded = 240;
  static const double topbarHeight = 52;
  static const double chatPanelHeightDefault = 360;
  static const double chatPanelHeightMin = 200;
  static const double pagePadding = 32;
  static const double cardGap = 14;
  static const double sectionGap = 28;
  static const double cardRadius = 16;
  static const double itemRadius = 10;
  static const double formMaxWidth = 560;

  // Animation
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Curve sidebarCurve = Curves.easeOut;
  static const Curve chatCurve = Curves.easeOutCubic;
  static const Curve switchCurve = Curves.easeInOut;
}
