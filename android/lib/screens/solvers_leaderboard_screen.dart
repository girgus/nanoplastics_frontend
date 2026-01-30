import 'package:flutter/material.dart';
import 'dart:ui';
import '../l10n/app_localizations.dart';
import '../config/app_colors.dart';
import '../widgets/nanosolve_logo.dart';
import '../services/settings_manager.dart';
import '../services/solver_service.dart';
import '../models/solver.dart';
import 'user_settings/profile_registration_dialog.dart';

class SolversLeaderboardScreen extends StatefulWidget {
  const SolversLeaderboardScreen({super.key});

  @override
  State<SolversLeaderboardScreen> createState() =>
      _SolversLeaderboardScreenState();
}

class _SolversLeaderboardScreenState extends State<SolversLeaderboardScreen> {
  late bool _userIsRegistered;
  late bool _userHasEmailAndBio;
  final _settingsManager = SettingsManager();

  @override
  void initState() {
    super.initState();
    _checkUserRegistration();
  }

  void _checkUserRegistration() {
    _userIsRegistered = _settingsManager.isProfileRegistered;
    final displayName = _settingsManager.displayName.trim();
    final email = _settingsManager.email.trim();
    _userHasEmailAndBio = displayName.isNotEmpty && email.isNotEmpty;
  }

  void _showRegistrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ProfileRegistrationDialog(
        onProfileShared: () {
          setState(() {
            _checkUserRegistration();
          });
          Navigator.of(context).pop();
        },
      ),
    );
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
              AppColors.pastelMint.withValues(alpha: 0.08),
              AppColors.pastelLavender.withValues(alpha: 0.05),
              const Color(0xFF0A0A12),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildLeaderboard(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: AppColors.pastelMint,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        l10n.resultsBackButton,
                        style: TextStyle(
                          color: AppColors.pastelMint,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.emoji_events,
                  size: 24,
                  color: AppColors.pastelMint,
                ),
              ],
            ),
            const SizedBox(height: 15),
            const NanosolveLogo(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Check if user has access to leaderboard
    if (!_userIsRegistered || !_userHasEmailAndBio) {
      return _buildRestrictedAccessView(context, l10n);
    }

    return FutureBuilder<List<Solver>>(
      future: SolverService.getTopSolvers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.pastelMint,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading solvers: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final solvers = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleSection(context),
              const SizedBox(height: 25),
              ...solvers.map((solver) => _buildSolverCard(solver)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestrictedAccessView(
      BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(context),
          const SizedBox(height: 60),
          // Locked icon
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.pastelMint.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.lock,
                size: 50,
                color: AppColors.pastelMint,
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Main message
          Center(
            child: Text(
              'Leaderboard Access Restricted',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          // Description
          Center(
            child: Text(
              'Register with your email and name to view the top 10 leaderboard and be recognized for your solutions.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          // CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showRegistrationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pastelMint,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.app_registration,
                color: Colors.black,
              ),
              label: const Text(
                'Register Now',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.pastelMint, AppColors.pastelAqua],
          ).createShader(bounds),
          child: Text(
            l10n.leaderboardTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.leaderboardSubtitle,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSolverCard(Solver solver) {
    final int rank = solver.rank;
    final bool isTopThree = rank <= 3;

    Color getRankColor() {
      if (rank == 1) return const Color(0xFFFFD700); // Gold
      if (rank == 2) return const Color(0xFFC0C0C0); // Silver
      if (rank == 3) return const Color(0xFFCD7F32); // Bronze
      return AppColors.pastelMint;
    }

    // Generate avatar emoji based on specialty
    String getAvatar() {
      const avatars = [
        '🧪',
        '🔬',
        '🧬',
        '⚗️',
        '🔭',
        '🧫',
        '🌊',
        '⚛️',
        '🔍',
        '🌱'
      ];
      return avatars[rank - 1];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTopThree
              ? getRankColor().withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: isTopThree ? 2 : 1,
        ),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: getRankColor().withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: getRankColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: getRankColor().withValues(alpha: 0.5),
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: getRankColor(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Avatar
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.pastelLavender.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                getAvatar(),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Name and contributions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        solver.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 14,
                      color: AppColors.pastelAqua,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${solver.solutionsCount} realized solutions',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  solver.specialty,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.pastelMint.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // Trophy for top 3
          if (isTopThree)
            Icon(
              Icons.emoji_events,
              size: 28,
              color: getRankColor(),
            ),
        ],
      ),
    );
  }
}
