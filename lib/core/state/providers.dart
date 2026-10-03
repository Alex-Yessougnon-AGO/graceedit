/// Riverpod state: projects list, current project + command stack, prefs.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../commands/commands.dart';
import '../l10n/strings.dart';
import '../models/grace_project.dart';
import '../storage/project_repository.dart';

class OwnedAsset {
  const OwnedAsset({required this.projectId, required this.projectName, required this.asset});
  final String projectId;
  final String projectName;
  final MediaAsset asset;
}

/// Every imported asset across all projects (global Bibliothèque).
final allAssetsProvider = FutureProvider<List<OwnedAsset>>((ref) async {
  final projects = await ref.watch(projectsProvider.future);
  final out = <OwnedAsset>[];
  for (final p in projects) {
    for (final a in p.assets) {
      out.add(OwnedAsset(projectId: p.id, projectName: p.name, asset: a));
    }
  }
  return out;
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) => ProjectRepository());

final projectsProvider = AsyncNotifierProvider<ProjectsNotifier, List<GraceProject>>(ProjectsNotifier.new);

class ProjectsNotifier extends AsyncNotifier<List<GraceProject>> {
  @override
  Future<List<GraceProject>> build() => ref.watch(projectRepositoryProvider).listAll();

  Future<GraceProject> create({required String name, required ProjectKind kind}) async {
    final p = GraceProject(name: name, kind: kind);
    await ref.read(projectRepositoryProvider).save(p);
    final current = await future;
    state = AsyncData([p, ...current]);
    return p;
  }

  Future<void> remove(String id) async {
    await ref.read(projectRepositoryProvider).delete(id);
    final current = await future;
    state = AsyncData(current.where((p) => p.id != id).toList());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await ref.read(projectRepositoryProvider).listAll());
  }
}

/// Holds the open project + its undo stack for the editor.
class EditorSession {
  EditorSession(this.project) : commands = CommandStack();
  final GraceProject project;
  final CommandStack commands;
}

final editorSessionProvider = StateProvider<EditorSession?>((ref) => null);

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final localeProvider = StateProvider<AppLocale>((ref) => AppLocale.fr);
final stringsProvider = Provider<Strings>((ref) => Strings(ref.watch(localeProvider)));
