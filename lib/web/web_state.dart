enum WebSection { explore, sources, ideas, leaderboard, settings }

enum WebDomain { human, planet }

extension WebDomainX on WebDomain {
  bool get isHuman => this == WebDomain.human;
}
