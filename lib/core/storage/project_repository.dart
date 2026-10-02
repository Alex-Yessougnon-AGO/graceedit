/// Local persistence: atomic writes, autosave, crash recovery marker.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/grace_project.dart';

class ProjectRepository {
  ProjectRepository({Directory? overrideDir}) : _overrideDir = overrideDir;
  final Directory? _overrideDir;

  Future<Directory> _dir() async {
    if (_overrideDir != null) return _overrideDir!;
    final app = await getApplicationDocumentsDirectory();
    final d = Directory('${app.path}/graceedit_projects');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  File _file(Directory d, String id) => File('${d.path}/$id.json');
  File _tmpFile(Directory d, String id) => File('${d.path}/$id.json.tmp');

  /// Atomic write: tmp + rename.
  Future<void> save(GraceProject project) async {
    final d = await _dir();
    final tmp = _tmpFile(d, project.id);
    await tmp.writeAsString(jsonEncode(project.toJson()), flush: true);
    await tmp.rename(_file(d, project.id).path);
    // Clear crash marker on successful save.
    final marker = File('${d.path}/${project.id}.recovery');
    if (await marker.exists()) await marker.delete();
  }

  Future<GraceProject?> load(String id) async {
    final d = await _dir();
    final f = _file(d, id);
    if (!await f.exists()) return null;
    try {
      final j = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      return GraceProject.fromJson(j);
    } catch (_) {
      return null;
    }
  }

  Future<List<GraceProject>> listAll() async {
    final d = await _dir();
    final out = <GraceProject>[];
    await for (final e in d.list()) {
      if (e is File && e.path.endsWith('.json') && !e.path.endsWith('.tmp')) {
        try {
          final j = jsonDecode(await e.readAsString()) as Map<String, dynamic>;
          if (j.containsKey('schemaVersion')) {
            out.add(GraceProject.fromJson(j));
          }
        } catch (_) {/* skip corrupted file */}
      }
    }
    out.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return out;
  }

  Future<void> delete(String id) async {
    final d = await _dir();
    final f = _file(d, id);
    if (await f.exists()) await f.delete();
  }

  /// Mark a project as having unsaved work (called at edit time, before autosave).
  Future<void> markDirty(String id) async {
    final d = await _dir();
    await File('${d.path}/$id.recovery').writeAsString(
      DateTime.now().toIso8601String(),
      flush: true,
    );
  }

  Future<bool> hasRecoveryMarker(String id) async {
    final d = await _dir();
    return File('${d.path}/$id.recovery').exists();
  }
}
