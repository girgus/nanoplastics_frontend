import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/solver.dart';
import '../../services/service_locator.dart';

class LeaderboardSection extends StatefulWidget {
  final AppLocalizations l10n;
  final VoidCallback onPostIdea;

  const LeaderboardSection({
    super.key,
    required this.l10n,
    required this.onPostIdea,
  });

  @override
  State<LeaderboardSection> createState() => _LeaderboardSectionState();
}

class _LeaderboardSectionState extends State<LeaderboardSection> {
  late final Future<List<Solver>> _solversFuture;

  @override
  void initState() {
    super.initState();
    _solversFuture = ServiceLocator().apiService.getTopSolvers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Solver>>(
      future: _solversFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.pastelMint),
          );
        }

        final solvers = snapshot.data ?? const <Solver>[];
        if (solvers.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.l10n.leaderboardEmpty,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: widget.onPostIdea,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: Text(widget.l10n.leaderboardPostIdeaCta),
                ),
              ],
            ),
          );
        }

        final podium = solvers.take(3).toList(growable: false);
        final table = solvers.skip(3).toList(growable: false);
        final hasEmail = ServiceLocator().settingsManager.email.isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.l10n.leaderboardContributorsTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.l10n.leaderboardContributorsSubtitle,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
              ),
              const SizedBox(height: 18),
              _Podium(podium: podium),
              const SizedBox(height: 18),
              _RankingsTable(l10n: widget.l10n, rows: table),
              if (!hasEmail) ...[
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add_alt_1),
                  label: Text(widget.l10n.leaderboardRegisterCta),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Podium extends StatelessWidget {
  final List<Solver> podium;

  const _Podium({required this.podium});

  @override
  Widget build(BuildContext context) {
    const medals = ['🥇', '🥈', '🥉'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: podium.asMap().entries.map((entry) {
          final i = entry.key;
          final solver = entry.value;
          return Container(
            width: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                Text(medals[i], style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(
                  '#${solver.rank}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                ),
                const SizedBox(height: 4),
                Text(
                  solver.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${solver.rating.toStringAsFixed(1)} ★',
                  style: const TextStyle(color: AppColors.pastelAqua),
                ),
              ],
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _RankingsTable extends StatelessWidget {
  final AppLocalizations l10n;
  final List<Solver> rows;

  const _RankingsTable({required this.l10n, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _head(l10n.leaderboardRankHeader, 50),
                _head(l10n.leaderboardNameHeader, 180),
                _head(l10n.leaderboardSpecialtyHeader, 150),
                _head(l10n.leaderboardIdeasHeader, 90),
                _head(l10n.leaderboardScoreHeader, 70),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          ...rows.map((s) => _row(s)).toList(growable: false),
        ],
      ),
    );
  }

  Widget _head(String text, double width) => SizedBox(
        width: width,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _row(Solver s) {
    return MouseRegion(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
                width: 50,
                child: Text('${s.rank}',
                    style: const TextStyle(color: Colors.white))),
            SizedBox(
                width: 180,
                child:
                    Text(s.name, style: const TextStyle(color: Colors.white))),
            SizedBox(
              width: 150,
              child: Text(
                s.specialty,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
                width: 90,
                child: Text('${s.solutionsCount}',
                    style: const TextStyle(color: Colors.white))),
            SizedBox(
                width: 70,
                child: Text(s.rating.toStringAsFixed(1),
                    style: const TextStyle(color: AppColors.pastelAqua))),
          ],
        ),
      ),
    );
  }
}
