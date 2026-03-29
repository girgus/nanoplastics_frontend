enum WebSection { explore, sources, ideas, leaderboard }

enum WebDomain { human, planet }

extension WebDomainX on WebDomain {
  bool get isHuman => this == WebDomain.human;
}
