import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bootstrap.dart';
import '../models/project.dart';
import '../models/settings.dart';
import '../platform/native_gateway.dart';
import '../services/thumbnail_service.dart';
import '../storage/local_store.dart';

/// Chargement réel de l'application, affiché par ENT-01.
final bootstrapProvider = FutureProvider<BootstrapData>((ref) async {
  return bootstrapApplication();
});

final nativeGatewayProvider = Provider<NativeGateway>((ref) => NativeGateway());

final localPathsProvider = Provider<LocalPaths>((ref) {
  return ref.watch(bootstrapProvider).requireValue.paths;
});

final thumbnailServiceProvider = Provider<ThumbnailService>((ref) {
  return ThumbnailService(
    ref.watch(nativeGatewayProvider),
    ref.watch(localPathsProvider),
  );
});

/// Réglages locaux (SET-01) : thème, langue, animations, haptique, suppression.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final bootstrap = ref.watch(bootstrapProvider);
    return bootstrap.valueOrNull?.settings ?? const AppSettings();
  }

  Future<void> _apply(AppSettings next) async {
    state = next;
    final bootstrap = ref.read(bootstrapProvider).requireValue;
    await bootstrap.settingsRepository.save(next);
    // Les réglages servent aussi au premier lancement et à la reprise.
    bootstrap.prefs.setBool('graceedit.welcomeSeen', next.welcomeSeen);
  }

  Future<void> setTheme(AppThemeChoice choice) =>
      _apply(state.copyWith(theme: choice));

  Future<void> setLanguage(String? code) => _apply(
    code == null
        ? state.copyWith(clearLanguage: true)
        : state.copyWith(languageCode: code),
  );

  Future<void> setReduceMotion(bool value) =>
      _apply(state.copyWith(reduceMotion: value));

  Future<void> setHaptics(bool value) =>
      _apply(state.copyWith(haptics: value));

  Future<void> setDeleteBehavior(DeleteBehavior value) =>
      _apply(state.copyWith(deleteBehavior: value));

  Future<void> setWelcomeSeen() => _apply(state.copyWith(welcomeSeen: true));

  Future<void> setSort(SortMode sort) => _apply(state.copyWith(sort: sort));

  Future<void> setView(ViewMode view) => _apply(state.copyWith(view: view));
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

/// Liste des projets, triée et tenue à jour pour tous les écrans.
class ProjectsController extends AsyncNotifier<List<Project>> {
  ProjectRepository get _repository =>
      ref.read(bootstrapProvider).requireValue.projectRepository;

  @override
  Future<List<Project>> build() async {
    final bootstrap = await ref.watch(bootstrapProvider.future);
    await bootstrap.projectRepository.purgeExpiredTrash();
    return bootstrap.projectRepository.loadAll();
  }

  List<Project> get active =>
      (state.valueOrNull ?? const []).where((item) => !item.isTrashed).toList();

  List<Project> get trashed =>
      (state.valueOrNull ?? const []).where((item) => item.isTrashed).toList();

  Future<Project?> load(String id) async {
    for (final project in state.valueOrNull ?? const <Project>[]) {
      if (project.id == id) return project;
    }
    return _repository.load(id);
  }

  /// Enregistre puis met la liste à jour, sans recharger tout le disque.
  Future<void> save(Project project) async {
    await _repository.save(project);
    final current = [...(state.valueOrNull ?? const <Project>[])];
    final index = current.indexWhere((item) => item.id == project.id);
    if (index >= 0) {
      current[index] = project;
    } else {
      current.add(project);
    }
    current.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    state = AsyncData(current);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> rename(Project project, String title) =>
      save(project.copyWith(title: title, modifiedAt: DateTime.now()));

  Future<Project> duplicate(Project project, String title) async {
    final copy = cloneProject(project, id: _newId(), title: title);
    await save(copy);
    return copy;
  }

  Future<void> moveToTrash(Project project) async {
    await save(project.copyWith(trashedAt: DateTime.now()));
  }

  Future<void> moveManyToTrash(Iterable<Project> projects) async {
    for (final project in projects) {
      await moveToTrash(project);
    }
  }

  Future<void> restore(Project project) async {
    await save(
      project.copyWith(clearTrashedAt: true, modifiedAt: DateTime.now()),
    );
  }

  Future<void> deleteForever(Project project) async {
    await _repository.delete(project.id);
    final current = [...(state.valueOrNull ?? const <Project>[])]
      ..removeWhere((item) => item.id == project.id);
    state = AsyncData(current);
  }

  Future<void> emptyTrash() async {
    for (final project in trashed) {
      await _repository.delete(project.id);
    }
    state = AsyncData(active);
  }

  static String _newId() =>
      'p${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

final projectsControllerProvider =
    AsyncNotifierProvider<ProjectsController, List<Project>>(
      ProjectsController.new,
    );

/// Capacités réelles de l'appareil (EXP-01).
final capabilitiesProvider = FutureProvider<DeviceCapabilities>((ref) async {
  return ref.watch(nativeGatewayProvider).capabilities();
});

/// Espace libre, rafraîchi à chaque écran qui en a besoin.
final storageInfoProvider = FutureProvider<StorageInfo>((ref) async {
  return ref.watch(nativeGatewayProvider).storage();
});

/// Marqueur de projet en récupération au lancement (SYS-01).
/// Utilisé par l'écran de splash pour déterminer la route initiale.
final pendingRecoveryProvider = FutureProvider<String?>((ref) async {
  final bootstrap = await ref.watch(bootstrapProvider.future);
  return bootstrap?.recovery.pendingProjectId();
});

/// Identifiant du projet récupéré (nettoyé après affichage).
final recoveredProjectIdProvider = FutureProvider<String?>((ref) async {
  final pending = ref.watch(pendingRecoveryProvider);
  if (pending != null) {
    // Consomme le marqueur : on nettoie la récupération.
    await ref.read(bootstrapProvider).valueOrNull?.recovery.end();
  }
  return pending;
});