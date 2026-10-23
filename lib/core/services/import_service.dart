/// Real media import: system gallery picker + camera capture.
/// Picked files are copied into permanent app storage — the picker only
/// hands out cache files that Android may delete at any time.
library;

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/grace_project.dart';

enum ImportSource { gallery, camera }

class ImportResult {
  const ImportResult({required this.asset, required this.probeMs});
  final MediaAsset asset;
  /// Known duration when available (video), null otherwise.
  final int? probeMs;
}

class ImportService {
  ImportService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;

  Future<ImportResult?> pickVideo({required ImportSource source}) async {
    final XFile? file = source == ImportSource.gallery
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickVideo(
            source: ImageSource.camera,
            maxDuration: const Duration(minutes: 10));
    if (file == null) return null; // user cancelled — not an error
    final id = GraceProject.newId();
    final path = await _persist(file.path, id, '.mp4');
    return ImportResult(
      asset: MediaAsset(
        id: id,
        kind: MediaKind.video,
        path: path,
        source: source == ImportSource.gallery ? 'import' : 'camera',
      ),
      probeMs: null,
    );
  }

  Future<ImportResult?> pickImage({required ImportSource source}) async {
    final XFile? file = source == ImportSource.gallery
        ? await _picker.pickImage(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return null;
    final id = GraceProject.newId();
    final path = await _persist(file.path, id, '.jpg');
    return ImportResult(
      asset: MediaAsset(
        id: id,
        kind: MediaKind.image,
        path: path,
        source: source == ImportSource.gallery ? 'import' : 'camera',
      ),
      probeMs: null,
    );
  }

  /// A picked file the device cannot read is reported, never silently added.
  static Future<bool> isReadable(String path) async {
    try {
      final f = File(path);
      if (!await f.exists()) return false;
      return await f.length() > 0;
    } catch (_) {
      return false;
    }
  }

  /// Copies the picked file out of the picker cache into app documents so the
  /// project keeps working after a reboot or a cache cleanup.
  Future<String> _persist(String sourcePath, String id, String fallbackExt) async {
    final src = File(sourcePath);
    if (!await src.exists()) {
      throw FileSystemException(
          'Le fichier choisi est introuvable. Réessayez l’import.', sourcePath);
    }
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/graceedit_media');
    if (!await dir.exists()) await dir.create(recursive: true);
    final dot = sourcePath.lastIndexOf('.');
    final slash = sourcePath.lastIndexOf('/');
    final ext = (dot > slash && dot >= 0)
        ? sourcePath.substring(dot).toLowerCase()
        : fallbackExt;
    final dest = File('${dir.path}/$id$ext');
    await src.copy(dest.path);
    return dest.path;
  }
}
