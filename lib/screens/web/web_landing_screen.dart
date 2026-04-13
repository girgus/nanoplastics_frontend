import 'dart:html' as html;

import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../web/web_app_shell.dart';
import '../../widgets/nanosolve_logo.dart';

// ── Category descriptor (landing-page only) ───────────────────────────────────

class _Cat {
  final String key;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final bool isHuman;

  const _Cat(
      this.key, this.title, this.desc, this.icon, this.color, this.isHuman);
}

const _human = [
  _Cat(
      'human_central',
      'Central Systems',
      'Blood–brain barrier penetration, neurological damage, and accumulation data.',
      Icons.psychology_outlined,
      AppColors.neonCyan,
      true),
  _Cat(
      'human_detox',
      'Filtration & Detox',
      'Liver and kidney overload, bioaccumulation in detox organs.',
      Icons.water_drop_outlined,
      AppColors.neonLime,
      true),
  _Cat(
      'human_vitality',
      'Vitality & Tissues',
      'Cardiovascular inflammation, mitochondrial disruption, muscle tissue damage.',
      Icons.favorite_outline,
      AppColors.neonCrimson,
      true),
  _Cat(
      'human_reproduction',
      'Origin & Protection',
      'Reproductive system effects, placental crossings, fertility impact.',
      Icons.people_outline,
      AppColors.neonViolet,
      true),
  _Cat(
      'human_entry',
      'Entry Gates',
      'Inhalation and ingestion pathways — how nanoplastics enter the body.',
      Icons.air,
      AppColors.neonOrange,
      true),
  _Cat(
      'human_ways_of_destruction',
      'Ways of Destruction',
      'Oxidative stress, epigenetic disruption, and cellular damage mechanisms.',
      Icons.science_outlined,
      AppColors.neonCrimson,
      true),
];

const _planet = [
  _Cat(
      'planet_ocean',
      'World Ocean',
      'Marine microplastic accumulation, deep-sea distribution, food chain impact.',
      Icons.waves,
      AppColors.neonOcean,
      false),
  _Cat(
      'planet_atmosphere',
      'Atmosphere',
      'Airborne nanoplastics, cloud formation disruption, global water cycle interference.',
      Icons.cloud_outlined,
      AppColors.neonAtmos,
      false),
  _Cat(
      'planet_bio',
      'Flora, Fauna & Soil',
      'Soil biota disruption, plant uptake, and wildlife exposure pathways.',
      Icons.eco,
      AppColors.neonBio,
      false),
  _Cat(
      'planet_magnetic',
      'Magnetic Field & Core',
      'Ferrofluid-like behavior and potential geological interference.',
      Icons.explore,
      AppColors.neonMagma,
      false),
  _Cat(
      'planet_entry',
      'Crisis Entry Gates',
      'How nanoplastics enter planetary systems — industrial, urban, and agricultural sources.',
      Icons.input,
      AppColors.neonSource,
      false),
  _Cat(
      'planet_physical',
      'Physical Properties',
      'Nanoplastic material science — charge, size distribution, surface interactions.',
      Icons.hub,
      AppColors.neonPhysics,
      false),
];

// ── Shared colors (mirroring HTML CSS variables) ─────────────────────────────

const _bgDeep = Color(0xFF031622);
const _bgOcean = Color(0xFF0A3A4A);
const _surfaceStrong = Color(0xCC071D2E);
const _line = Color(0x427FEBD7); // rgba(127,235,215,.26)
const _textMain = Color(0xFFECFBF7);
const _textSoft = Color(0xFFB9DCD4);
const _accent = Color(0xFF6DF5D8);
const _accentStrong = Color(0xFF2DD4BF);

const _googlePlayUrl =
    'https://play.google.com/store/apps/details?id=org.nanosolve.hive';
const _githubLatestReleaseUrl =
    'https://github.com/glmcz/nanoplastics_frontend/releases/latest/';
const _githubRepoUrl = 'https://github.com/glmcz/nanoplastics_frontend';
const _privacyPolicyUrl =
    'https://glmcz.github.io/nanoplastics_frontend/privacy/';

void _openExternalUrl(String url) {
  html.window.open(url, '_blank');
}

// ── Screen ────────────────────────────────────────────────────────────────────

class WebLandingScreen extends StatefulWidget {
  const WebLandingScreen({super.key});

  @override
  State<WebLandingScreen> createState() => _WebLandingScreenState();
}

class _WebLandingScreenState extends State<WebLandingScreen> {
  final GlobalKey _whySectionKey = GlobalKey();
  final GlobalKey _howSectionKey = GlobalKey();
  final GlobalKey _downloadSectionKey = GlobalKey();

  Future<void> _scrollToSection(GlobalKey key) async {
    final sectionContext = key.currentContext;
    if (sectionContext == null) return;

    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  void _openWorkspace(BuildContext context, {String? categoryKey}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NanoSolveWebApp(initialCategoryKey: categoryKey),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.68, -0.76),
            radius: 1.2,
            colors: [
              Color(0x336DF5D8),
              Colors.transparent,
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            _LandingTopBar(
              onLaunchWorkspace: () => _openWorkspace(context),
              onOpenWhy: () => _scrollToSection(_whySectionKey),
              onOpenHow: () => _scrollToSection(_howSectionKey),
              onOpenDownload: () => _scrollToSection(_downloadSectionKey),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _HeroSection(
                        onLaunchWorkspace: () => _openWorkspace(context)),
                    KeyedSubtree(
                      key: _whySectionKey,
                      child: _WhySection(),
                    ),
                    KeyedSubtree(
                      key: _howSectionKey,
                      child: _CategoriesSection(
                        onOpenCategory: (key) =>
                            _openWorkspace(context, categoryKey: key),
                      ),
                    ),
                    KeyedSubtree(
                      key: _downloadSectionKey,
                      child: _Footer(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _LandingTopBar extends StatelessWidget {
  final VoidCallback onLaunchWorkspace;
  final VoidCallback onOpenWhy;
  final VoidCallback onOpenHow;
  final VoidCallback onOpenDownload;
  const _LandingTopBar({
    required this.onLaunchWorkspace,
    required this.onOpenWhy,
    required this.onOpenHow,
    required this.onOpenDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xDB031622),
        border: const Border(bottom: BorderSide(color: _line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: _constrain(
        child: Row(
          children: [
            const NanosolveLogo(height: 26),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('NanoSolve Hive',
                    style: TextStyle(
                        color: _textMain,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text('Nanoplastics Action App',
                    style: TextStyle(
                        color: _textSoft,
                        fontSize: 10,
                        letterSpacing: 0.9,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const Spacer(),
            _topLink('Why it works', onTap: onOpenWhy),
            const SizedBox(width: 4),
            _topLink('How it works', onTap: onOpenHow),
            const SizedBox(width: 4),
            _topLink('Download', onTap: onOpenDownload),
            const SizedBox(width: 8),
            _PillButton(
              label: 'Launch Workspace',
              onTap: onLaunchWorkspace,
              primary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _topLink(String label, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label,
            style: const TextStyle(
                color: _textMain, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final VoidCallback onLaunchWorkspace;
  const _HeroSection({required this.onLaunchWorkspace});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      child: _constrain(
        child: _heroMain(context),
      ),
    );
  }

  Widget _heroMain(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('iOS · Android · GitHub Access',
                  style: TextStyle(
                      color: _accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
            ),
            const SizedBox(height: 16),
            const Text('Understand nanoplastics.\nAct with evidence.',
                style: TextStyle(
                    color: _textMain,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -0.5)),
            const SizedBox(height: 12),
            const Text(
                'NanoSolve Hive turns dense scientific research into a guided experience so you can learn fast, share ideas, and contribute to real environmental problem-solving.',
                style: TextStyle(color: _textSoft, fontSize: 15, height: 1.6)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _PillButton(
                    label: 'Launch Workspace',
                    onTap: onLaunchWorkspace,
                    primary: true),
                _PillButton(
                    label: 'Get on Google Play',
                    onTap: () {
                      _openExternalUrl(_googlePlayUrl);
                    },
                    primary: false),
                _PillButton(
                    label: 'GitHub Build',
                    onTap: () {
                      _openExternalUrl(_githubLatestReleaseUrl);
                    },
                    primary: false),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
                'If Google Play is restricted in your country, use the GitHub build. iOS release tracked through GitHub Releases.',
                style: TextStyle(color: _textSoft, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ── Why Section ───────────────────────────────────────────────────────────────

class _WhySection extends StatelessWidget {
  const _WhySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: _constrain(
        child: _Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Why new users stick with NanoSolve Hive',
                    style: TextStyle(
                        color: _textMain,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3)),
                const SizedBox(height: 6),
                const Text(
                    'The app is built to reduce first-use friction: clear categories, fast navigation, and practical actions instead of overwhelming theory.',
                    style: TextStyle(
                        color: _textSoft, fontSize: 13.5, height: 1.55)),
                const SizedBox(height: 16),
                _AdaptiveGrid(
                  minChildWidth: 260,
                  children: const [
                    _FeatureCard(
                      title: 'Structured science, not random articles',
                      desc:
                          'Health and planet impacts are organized into focused categories so users can understand complex topics without getting lost.',
                    ),
                    _FeatureCard(
                      title: 'Actionable from day one',
                      desc:
                          'Every category includes a brainstorm area where users can submit ideas and help shape community solutions.',
                    ),
                    _FeatureCard(
                      title: 'Trust-focused data handling',
                      desc:
                          'Privacy policy remains always one tap away, so users know exactly what is collected and why. User ideas are under CC BY 4.0 — free for research & public benefit.',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── How Section ───────────────────────────────────────────────────────────────

// ── Categories Section (the main new addition) ────────────────────────────────

class _CategoriesSection extends StatelessWidget {
  final ValueChanged<String> onOpenCategory;
  const _CategoriesSection({required this.onOpenCategory});

  @override
  Widget build(BuildContext context) {
    return _SectionWrap(
      title: 'Explore all 12 research categories',
      subtitle:
          'Jump directly into the interactive workspace. Each category loads the full evidence, source links, and brainstorm area.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _domainLabel('Human Health Impact', isHuman: true),
          const SizedBox(height: 10),
          _AdaptiveGrid(
            minChildWidth: 200,
            children: _human
                .map((c) =>
                    _CategoryCard(cat: c, onTap: () => onOpenCategory(c.key)))
                .toList(),
          ),
          const SizedBox(height: 24),
          _domainLabel('Planetary Impact', isHuman: false),
          const SizedBox(height: 10),
          _AdaptiveGrid(
            minChildWidth: 200,
            children: _planet
                .map((c) =>
                    _CategoryCard(cat: c, onTap: () => onOpenCategory(c.key)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _domainLabel(String label, {required bool isHuman}) {
    final color = isHuman ? const Color(0xFF7DD3FC) : const Color(0xFF86EFAC);
    final bg = isHuman ? const Color(0x1F38BDF8) : const Color(0x1F4ADE80);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
          child: Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: _line, height: 1)),
      ],
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final _Cat cat;
  final VoidCallback onTap;
  const _CategoryCard({required this.cat, required this.onTap});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.cat;
    final domainColor =
        c.isHuman ? const Color(0xFF7DD3FC) : const Color(0xFF86EFAC);

    return Semantics(
      button: true,
      label: c.title,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: _hovered
              ? Matrix4.translationValues(0, -3, 0)
              : Matrix4.identity(),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: _hovered
                    ? _bgOcean.withValues(alpha: 0.9)
                    : _surfaceStrong.withValues(alpha: 0.7),
                border: Border.all(
                  color: _hovered
                      ? c.color.withValues(alpha: 0.45)
                      : _line.withValues(alpha: 0.6),
                ),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: c.color.withValues(alpha: 0.12),
                          blurRadius: 16,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(c.icon, size: 18, color: c.color),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.isHuman
                          ? const Color(0x1F38BDF8)
                          : const Color(0x1F4ADE80),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(c.isHuman ? 'Human' : 'Planet',
                        style: TextStyle(
                            color: domainColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6)),
                  ),
                  const SizedBox(height: 8),
                  Text(c.title,
                      style: const TextStyle(
                          color: _textMain,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.25)),
                  const SizedBox(height: 5),
                  Text(c.desc,
                      style: const TextStyle(
                          color: _textSoft, fontSize: 11.5, height: 1.45),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Open workspace',
                          style: TextStyle(
                              color: c.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 3),
                      Icon(Icons.arrow_forward, size: 11, color: c.color),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _line)),
      ),
      child: _constrain(
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 10,
          children: [
            const Text('© 2024–2026 Martin Durak. All rights reserved.',
                style: TextStyle(color: _textSoft, fontSize: 12)),
            Wrap(
              spacing: 16,
              children: [
                _footerLink(
                  'GitHub Repository',
                  onTap: () {
                    _openExternalUrl(_githubRepoUrl);
                  },
                ),
                _footerLink(
                  'Release History',
                  onTap: () {
                    _openExternalUrl(_githubLatestReleaseUrl);
                  },
                ),
                _footerLink(
                  'Privacy Policy',
                  onTap: () {
                    _openExternalUrl(_privacyPolicyUrl);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerLink(String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Text(label,
          style: const TextStyle(
              color: _accent, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Reusable section wrapper ──────────────────────────────────────────────────

class _SectionWrap extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _SectionWrap(
      {required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: _constrain(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: _textMain,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3)),
            const SizedBox(height: 6),
            Text(subtitle,
                style: const TextStyle(
                    color: _textSoft, fontSize: 13.5, height: 1.55)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Feature card ──────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final String title;
  final String desc;
  const _FeatureCard({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: _textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(desc,
                style: const TextStyle(
                    color: _textSoft, fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// ── Shared micro-widgets ──────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: _surfaceStrong,
        border: Border.all(
          color: _line.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: child,
    );
  }
}

class _PillButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;
  const _PillButton(
      {required this.label, required this.onTap, required this.primary});

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform:
            _hovered ? Matrix4.translationValues(0, -2, 0) : Matrix4.identity(),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: widget.primary
                  ? const LinearGradient(
                      colors: [_accent, _accentStrong],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.primary ? null : _bgOcean,
              border: widget.primary ? null : Border.all(color: _line),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.primary ? const Color(0xFF003228) : _textMain,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Responsive grid using Wrap so items reflow naturally.
class _AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minChildWidth;

  const _AdaptiveGrid({required this.children, required this.minChildWidth});

  @override
  Widget build(BuildContext context) {
    final available = MediaQuery.sizeOf(context).width - 40;
    final cols = (available / minChildWidth).floor().clamp(1, children.length);
    final itemWidth = (available - (cols - 1) * 12) / cols;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          children.map((c) => SizedBox(width: itemWidth, child: c)).toList(),
    );
  }
}

/// Centers content with max-width matching the HTML's --layout-max: 1140px.
Widget _constrain({required Widget child}) {
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1140),
      child: child,
    ),
  );
}
