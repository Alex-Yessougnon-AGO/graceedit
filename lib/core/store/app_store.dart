import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/project.dart';
import '../models/settings.dart';

class StorageStats {
  const StorageStats({
    required this.cacheBytes,
    required this.projectBytes,
    required this.exportBytes,
    required this.trashBytes,
    required this.freeBytes,
    required this.totalBytes,
  });

  final int cacheBytes;
  final int projectBytes;
  final int exportBytes;
  final int trashBytes;
  final int freeBytes;
  final int totalBytes;

  int get usedBytes => cacheBytes + projectBytes + exportBytes + trashBytes;
}

/// Stockage local unique de l'application. Aucun accès réseau, aucun compte.
/// Les projets ne contiennent que des références aux médias d'origine.
class AppStore extends ChangeNotifier {
  /// `root` n'est renseigné que par les tests : en production le dossier
  /// vient de `getApplicationSupportDirectory`.
  AppStore({this._root});

  Directory? _root;
  bool _ready = false;
  bool get isReady => _ready;

  Settings settings = const Settings();
  List<Project> projects = const [];
  int trashCount = 0;

  String? openProjectId;
  bool cleanExit = true;
  String? lastError;

  Future<Directory> _base() async {
    final existing = _root;
    if (existing != null) return existing;
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}/graceedit');
    _root = dir;
    return dir;
  }

  Future<File> _stateFile() async => File('${(await _base()).path}/state.json');

  Future<Directory> cacheDir() async {
    final dir = Directory('${(await _base()).path}/cache');
    await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> coversDir() async {
    final dir = Directory('${(await _base()).path}/covers');
    await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> exportsDir() async {
    final dir = Directory('${(await _base()).path}/exports');
    await dir.create(recursive: true);
    return dir;
  }

  Future<void> init() async {
    final base = await _base();
    await base.create(recursive: true);
    final file = File('${base.path}/state.json');
    if (await file.exists()) {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) {
        final settingsJson = decoded['settings'];
        if (settingsJson is Map) {
          settings = Settings.fromJson(settingsJson.cast<String, Object?>());
        }
        final projectsJson = decoded['projects'];
        if (projectsJson is List) {
          projects = projectsJson
              .whereType<Map>()
              .map((e) => Project.fromJson(e.cast<String, Object?>()))
              .toList();
        }
        openProjectId = decoded['openProjectId'] as String?;
        cleanExit = decoded['cleanExit'] != false;
      }
    }
    await purgeExpiredTrash();
    _ready = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final file = await _stateFile();
    final tmp = File('${file.path}.tmp');
    final payload = jsonEncode({
      'settings': settings.toJson(),
      'projects': projects.map((p) => p.toJson()).toList(),
      'openProjectId': openProjectId,
      'cleanExit': cleanExit,
    });
    await tmp.writeAsString(payload, flush: true);
    await tmp.rename(file.path);
  }

  List<Project> get activeProjects {
    final list = projects.where((p) => !p.isTrashed).toList();
    switch (settings.sort) {
      case SortOrder.recent:
        list.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
      case SortOrder.oldest:
        list.sort((a, b) => a.modifiedAt.compareTo(b.modifiedAt));
      case SortOrder.name:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    }
    return list;
  }

  List<Project> get trashProjects {
    final list = projects.where((p) => p.isTrashed).toList();
    list.sort((a, b) => a.trashedAt!.compareTo(b.trashedAt!));
    return list;
  }

  Project? projectById(String? id) {
    if (id == null) return null;
    for (final p in projects) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> setSettings(Settings value) async {
    settings = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setWelcomeSeen() async {
    if (settings.welcomeSeen) return;
    settings = settings.copyWith(welcomeSeen: true);
    notifyListeners();
    await _persist();
  }

  Future<void> _replace(Project project) async {
    final index = projects.indexWhere((p) => p.id == project.id);
    final next = [...projects];
    if (index >= 0) {
      next[index] = project;
    } else {
      next.add(project);
    }
    projects = next;
    notifyListeners();
    await _persist();
  }

  Future<void> addProject(Project project) => _replace(project);

  Future<void> saveProject(Project project) =>
      _replace(project.copyWith(modifiedAt: DateTime.now()));

  Future<void> setSession({String? projectId, required bool clean}) async {
    openProjectId = projectId;
    cleanExit = clean;
    await _persist();
  }

  Future<void> trash(List<String> ids) async {
    final now = DateTime.now();
    projects = [
      for (final p in projects)
        if (ids.contains(p.id)) p.copyWith(trashedAt: now) else p,
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> restore(List<String> ids) async {
    projects = [
      for (final p in projects)
        if (ids.contains(p.id)) p.copyWith(clearTrash: true) else p,
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> deletePermanently(List<String> ids) async {
    projects = projects.where((p) => !ids.contains(p.id)).toList();
    notifyListeners();
    await _persist();
  }

  /// Duplique des projets. Le titre de la copie vient de l'appelant : le
  /// libellé « (copie) » est traduit, donc jamais figé ici.
  Future<List<Project>> duplicate(
    List<String> ids, {
    required String Function(Project source) titleOf,
  }) async {
    final copies = <Project>[];
    final now = DateTime.now();
    for (final id in ids) {
      final source = projectById(id);
      if (source == null) continue;
      final copy = Project.fromJson({
        ...source.toJson(),
        'id':
            '${source.id}-copy-${now.microsecondsSinceEpoch}-${copies.length}',
        'title': titleOf(source),
        'createdAt': now.toIso8601String(),
        'modifiedAt': now.toIso8601String(),
        'trashedAt': null,
      });
      copies.add(copy);
    }
    projects = [...copies, ...projects];
    notifyListeners();
    await _persist();
    return copies;
  }

  Future<void> rename(String id, String title) async {
    final project = projectById(id);
    if (project == null) return;
    await saveProject(project.copyWith(title: title));
  }

  Future<void> purgeExpiredTrash() async {
    final now = DateTime.now();
    final expired = <String>[];
    for (final p in projects) {
      final at = p.trashedAt;
      if (at != null && now.difference(at).inDays >= 30) {
        expired.add(p.id);
      }
    }
    if (expired.isNotEmpty) {
      projects = projects.where((p) => !expired.contains(p.id)).toList();
      notifyListeners();
      await _persist();
    }
  }

  Future<int> clearCache() async {
    final dir = await cacheDir();
    var freed = 0;
    if (await dir.exists()) {
      await for (final entity in dir.list()) {
        if (entity is File) freed += await entity.length();
        await entity.delete(recursive: true);
      }
    }
    await dir.create(recursive: true);
    notifyListeners();
    return freed;
  }

  Future<StorageStats> storageStats() async {
    Future<int> sizeOf(Directory dir) async {
      if (!await dir.exists()) return 0;
      var total = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) total += await entity.length();
      }
      return total;
    }

    final trashSize = projects
        .where((p) => p.isTrashed)
        .fold<int>(
          0,
          (sum, p) => sum + p.media.fold(0, (s, m) => s + m.sizeBytes),
        );
    final projectSize = projects
        .where((p) => !p.isTrashed)
        .fold<int>(
          0,
          (sum, p) => sum + p.media.fold(0, (s, m) => s + m.sizeBytes),
        );
    return StorageStats(
      cacheBytes: await sizeOf(await cacheDir()),
      projectBytes: projectSize,
      exportBytes: await sizeOf(await exportsDir()),
      trashBytes: trashSize,
      freeBytes: 0,
      totalBytes: 0,
    );
  }

  Future<void> markCleanExit({required bool clean}) async {
    cleanExit = clean;
    await _persist();
  }
}
