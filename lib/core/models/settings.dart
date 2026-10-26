enum AppThemeMode {
  system,
  light,
  dark;

  static AppThemeMode fromKey(String? key) => values.firstWhere(
    (v) => v.name == key,
    orElse: () => AppThemeMode.system,
  );
}

enum AppLanguage {
  fr,
  en;

  static AppLanguage fromKey(String? key) =>
      values.firstWhere((v) => v.name == key, orElse: () => AppLanguage.fr);
}

enum DeleteBehavior {
  ask,
  trash;

  static DeleteBehavior fromKey(String? key) =>
      values.firstWhere((v) => v.name == key, orElse: () => DeleteBehavior.ask);
}

enum SortOrder {
  recent,
  oldest,
  name;

  static SortOrder fromKey(String? key) =>
      values.firstWhere((v) => v.name == key, orElse: () => SortOrder.recent);
}

enum ProjectView {
  list,
  grid;

  static ProjectView fromKey(String? key) =>
      values.firstWhere((v) => v.name == key, orElse: () => ProjectView.list);
}

class Settings {
  const Settings({
    this.theme = AppThemeMode.system,
    this.language = AppLanguage.fr,
    this.reduceMotion = false,
    this.haptics = true,
    this.deleteBehavior = DeleteBehavior.ask,
    this.sort = SortOrder.recent,
    this.view = ProjectView.list,
    this.welcomeSeen = false,
    this.notificationsAsked = 0,
  });

  final AppThemeMode theme;
  final AppLanguage language;
  final bool reduceMotion;
  final bool haptics;
  final DeleteBehavior deleteBehavior;
  final SortOrder sort;
  final ProjectView view;
  final bool welcomeSeen;
  final int notificationsAsked;

  Settings copyWith({
    AppThemeMode? theme,
    AppLanguage? language,
    bool? reduceMotion,
    bool? haptics,
    DeleteBehavior? deleteBehavior,
    SortOrder? sort,
    ProjectView? view,
    bool? welcomeSeen,
    int? notificationsAsked,
  }) => Settings(
    theme: theme ?? this.theme,
    language: language ?? this.language,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    haptics: haptics ?? this.haptics,
    deleteBehavior: deleteBehavior ?? this.deleteBehavior,
    sort: sort ?? this.sort,
    view: view ?? this.view,
    welcomeSeen: welcomeSeen ?? this.welcomeSeen,
    notificationsAsked: notificationsAsked ?? this.notificationsAsked,
  );

  Map<String, Object?> toJson() => {
    'theme': theme.name,
    'language': language.name,
    'reduceMotion': reduceMotion,
    'haptics': haptics,
    'deleteBehavior': deleteBehavior.name,
    'sort': sort.name,
    'view': view.name,
    'welcomeSeen': welcomeSeen,
    'notificationsAsked': notificationsAsked,
  };

  factory Settings.fromJson(Map<String, Object?> json) => Settings(
    theme: AppThemeMode.fromKey(json['theme'] as String?),
    language: AppLanguage.fromKey(json['language'] as String?),
    reduceMotion: json['reduceMotion'] == true,
    haptics: json['haptics'] != false,
    deleteBehavior: DeleteBehavior.fromKey(json['deleteBehavior'] as String?),
    sort: SortOrder.fromKey(json['sort'] as String?),
    view: ProjectView.fromKey(json['view'] as String?),
    welcomeSeen: json['welcomeSeen'] == true,
    notificationsAsked: (json['notificationsAsked'] as num?)?.toInt() ?? 0,
  );
}
