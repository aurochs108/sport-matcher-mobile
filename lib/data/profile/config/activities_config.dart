enum ActivitiesConfig {
  bike,
  climbing,
  football,
  hockey,
  pingPong,
  running,
  tennis,
  voleyball;

  String get displayName {
    switch (this) {
      case ActivitiesConfig.bike:
        return 'Bike';
      case ActivitiesConfig.climbing:
        return 'Climbing';
      case ActivitiesConfig.football:
        return 'Football';
      case ActivitiesConfig.hockey:
        return 'Hockey';
      case ActivitiesConfig.pingPong:
        return 'Ping Pong';
      case ActivitiesConfig.running:
        return 'Running';
      case ActivitiesConfig.tennis:
        return 'Tennis';
      case ActivitiesConfig.voleyball:
        return 'Volleyball';
    }
  }
}
