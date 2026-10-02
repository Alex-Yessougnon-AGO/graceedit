/// Minimal localizable strings (FR/EN). No hardcoded UI text in widgets.
library;

enum AppLocale { fr, en }

class Strings {
  const Strings(this.locale);
  final AppLocale locale;
  bool get isFr => locale == AppLocale.fr;

  String get appName => 'GraceEdit';
  String get homeTitle => isFr ? 'Bonjour 👋' : 'Hello 👋';
  String get homeSubtitle => isFr
      ? 'Que voulez-vous créer aujourd’hui ?'
      : 'What do you want to create today?';
  String get newVideo => isFr ? 'Nouvelle vidéo' : 'New video';
  String get newPoster => isFr ? 'Nouvelle affiche' : 'New poster';
  String get recentProjects => isFr ? 'Projets récents' : 'Recent projects';
  String get emptyProjects => isFr
      ? 'Aucun projet pour l’instant.\nCréez votre première vidéo ou affiche.'
      : 'No projects yet.\nCreate your first video or poster.';
  String get create => isFr ? 'Créer' : 'Create';
  String get openEditor => isFr ? 'Ouvrir l’éditeur' : 'Open editor';
  String get settings => isFr ? 'Paramètres' : 'Settings';
  String get themeMode => isFr ? 'Thème' : 'Theme';
  String get language => isFr ? 'Langue' : 'Language';
  String get system => isFr ? 'Système' : 'System';
  String get export => isFr ? 'Exporter' : 'Export';
  String get save => isFr ? 'Enregistrer' : 'Save';
  String get retry => isFr ? 'Réessayer' : 'Retry';
  String get errorGeneric => isFr ? 'Quelque chose s’est mal passé.' : 'Something went wrong.';
  String get projectNameHint => isFr ? 'Nom du projet' : 'Project name';
  String get timeline => isFr ? 'Timeline' : 'Timeline';
  String get preview => isFr ? 'Aperçu' : 'Preview';
  String get trim => isFr ? 'Couper' : 'Trim';
  String get split => isFr ? 'Diviser' : 'Split';
  String get delete => isFr ? 'Supprimer' : 'Delete';
  String get addText => isFr ? 'Texte' : 'Text';
  String get undo => isFr ? 'Annuler' : 'Undo';
  String get redo => isFr ? 'Rétablir' : 'Redo';
}
