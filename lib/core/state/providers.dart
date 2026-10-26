import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import '../models/settings.dart';
import '../platform/native_gateway.dart';
import '../services/export_service.dart';
import '../services/media_service.dart';
import '../store/app_store.dart';

final storeProvider = ChangeNotifierProvider<AppStore>((ref) => AppStore());

/// Initialisation réelle : lecture du stockage local, purge de la corbeille.
final bootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(storeProvider).init();
});

final settingsProvider = Provider<Settings>(
  (ref) => ref.watch(storeProvider).settings,
);

final nativeGatewayProvider = Provider<NativeGateway>((ref) => NativeGateway());

/// Capacités de l'appareil, détectées une seule fois et mises en cache.
final deviceInfoProvider = FutureProvider<DeviceInfo>((ref) async {
  return ref.watch(nativeGatewayProvider).deviceInfo();
});

final mediaServiceProvider = Provider<MediaService>(
  (ref) =>
      MediaService(ref.watch(nativeGatewayProvider), ref.watch(storeProvider)),
);

final thumbnailServiceProvider = Provider<ThumbnailService>(
  (ref) => ThumbnailService(
    ref.watch(nativeGatewayProvider),
    ref.watch(storeProvider),
  ),
);

final exportServiceProvider = Provider<ExportService>(
  (ref) => ExportService(
    ref.watch(nativeGatewayProvider),
    () => ref.watch(storeProvider).exportsDir(),
  ),
);

/// Médias choisis en attente de confirmation (IMP-02).
final pendingImportProvider = StateProvider<List<MediaRef>>((ref) => const []);

/// Résultat d'un export en cours, partagé entre les écrans.
final activeExportProvider = StateProvider<ActiveExport?>((ref) => null);

class ActiveExport {
  const ActiveExport({
    required this.projectId,
    required this.quality,
    required this.startedAt,
    this.jobId,
  });
  final String projectId;
  final ExportQuality quality;
  final DateTime startedAt;

  /// Identifiant du travail de rendu côté natif, `null` tant que le rendu
  /// n'a pas démarré (réglages validés dans `EXP-01`).
  final String? jobId;

  ActiveExport copyWith({String? jobId}) => ActiveExport(
    projectId: projectId,
    quality: quality,
    startedAt: startedAt,
    jobId: jobId ?? this.jobId,
  );
}
