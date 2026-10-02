/// Real media import: system gallery picker + camera capture.
/// Returns [MediaAsset]s pointing at real device files — never fake entries.
library;

import 'package:image_picker/image_picker.dart';

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
        : await _picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(minutes: 10));
    if (file == null) return null; // user cancelled — not an error
    return ImportResult(
      asset: MediaAsset(
        id: GraceProject.newId(),
        kind: MediaKind.video,
        path: file.path,
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
    return ImportResult(
      asset: MediaAsset(
        id: GraceProject.newId(),
        kind: MediaKind.image,
        path: file.path,
        source: source == ImportSource.gallery ? 'import' : 'camera',
      ),
      probeMs: null,
    );
  }

  /// A picked file the device cannot read is reported, never silently added.
  static Future<bool> isReadable(String path) async {
    try {
      final f = XFile(path);
      final len = await f.length();
      return len > 0;
    } catch (_) {
      return false;
    }
  }
}
