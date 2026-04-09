import 'package:flutter/material.dart';

class WebTheme {
  // ── Surfaces (solid dark slate) ───────────────────────────────────────────
  static const Color bg = Color(0xFF0F172A);
  static const Color surfacePanel = Color(0xFF1E293B);
  static const Color surfaceCard = Color(0xFF1E293B);
  static const Color surfaceHover = Color(0xFF263548);
  static const Color surfaceTopbar = Color(0xFF1E293B);
  static const Color surfaceSidebar = Color(0xFF1E293B);

  // Context-taking overloads kept for backward compat (ignore ctx)
  static Color surfacePanelCtx(BuildContext ctx) => surfacePanel;
  static Color surfaceCardCtx(BuildContext ctx) => surfaceCard;
  static Color surfaceHoverCtx(BuildContext ctx) => surfaceHover;
  static Color surfaceTopbarCtx(BuildContext ctx) => surfaceTopbar;
  static Color surfaceAiPanel(BuildContext ctx) => const Color(0xFF0F172A);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color borderSubtle = Color(0xFF334155);
  static const Color borderMid = Color(0xFF475569);
  static const Color borderDivider = Color(0xFF1E293B);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF475569);

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF38BDF8);
  static const Color accentTeal = Color(0xFF2DD4BF);
  static const Color accentDim = Color(0x1F38BDF8); // accent @ 12%
  static const Color accentGlow = Color(0x3838BDF8); // accent @ 22%

  // ── Risk level colors ─────────────────────────────────────────────────────
  static const Color riskCritical = Color(0xFFF87171);
  static const Color riskHigh = Color(0xFFFBBF24);
  static const Color riskModerate = Color(0xFF38BDF8);

  // ── Layout ────────────────────────────────────────────────────────────────
  static const double sidebarCollapsed = 68;
  static const double sidebarExpanded = 240;
  static const double topbarHeight = 44;
  static const double chatPanelHeightDefault = 360;
  static const double chatPanelHeightMin = 200;
  static const double pagePadding = 28;
  static const double cardGap = 14;
  static const double sectionGap = 24;
  static const double cardRadius = 10;
  static const double itemRadius = 6;
  static const double formMaxWidth = 560;

  // ── Animation ─────────────────────────────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Curve sidebarCurve = Curves.easeOut;
  static const Curve chatCurve = Curves.easeOutCubic;
  static const Curve switchCurve = Curves.easeInOut;
}
