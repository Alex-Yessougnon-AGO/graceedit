import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/models/project.dart';
import '../../core/platform/native_gateway.dart';
import '../../core/state/providers.dart';
import '../../core/ui/messages.dart';
import '../../core/utils/formatters.dart';

const _uuid = Uuid();

MediaRef mediaRefFromPicked(PickedMedia picked) => MediaRef(
  id: _uuid.v4(),
  uri: picked.uri,
  name: picked.name,
  kind: picked.isAudio
      ? MediaKind.audio
      : picked.isImage
      ? MediaKind.image
      : MediaKind.video,
  durationMs: picked.durationMs,
  sizeBytes: picked.sizeBytes,
  width: picked.width,
  height: picked.height,
  capturedAt: picked.capturedAt,
  unsupported: !picked.supported || picked.mimeType.isEmpty,
);

ProjectFormat formatFromMedia(MediaRef media) {
  if (media.width <= 0 || media.height <= 0) {
    return ProjectFormat.horizontal;
  }
  final ratio = media.width / media.height;
  if (ratio > 1.2) return ProjectFormat.horizontal;
  if (ratio < 0.85) return ProjectFormat.vertical;
  if (ratio < 0.95) return ProjectFormat.portrait;
  return ProjectFormat.square;
}

/// Ouvre le sélecteur système. Si une seule vidéo utilisable est choisie,
/// l'éditeur s'ouvre directement (règle de saut de IMP-02).
Future<void> startImport(
  BuildContext context,
  WidgetRef ref, {
  bool navigate = true,
}) async {
  final l10n = AppLocalizations.of(context);
  final service = ref.read(mediaServiceProvider);
  final result = await service.pickVideos();
  if (!context.mounted) return;
  if (result.failure != null) {
    GraceToast.show(
      context,
      l10n.pickerUnavailable,
      actionLabel: l10n.actionRetry,
      onAction: () => startImport(context, ref, navigate: navigate),
      isError: true,
    );
    return;
  }
  if (result.media.isEmpty) return;
  final media = result.media.map(mediaRefFromPicked).toList();
  final usable = media
      .where((m) => !m.unsupported && m.kind == MediaKind.video)
      .toList();
  if (media.length == 1 && usable.length == 1) {
    final project = projectFromMedia(media, l10n);
    await ref.read(storeProvider).addProject(project);
    if (!context.mounted) return;
    context.push('/editor/${project.id}');
    return;
  }
  ref.read(pendingImportProvider.notifier).state = media;
  if (navigate && context.mounted) context.push('/import/new');
}

Project projectFromMedia(List<MediaRef> media, AppLocalizations l10n) {
  final usable = media
      .where((m) => !m.unsupported && m.kind == MediaKind.video)
      .toList();
  final now = DateTime.now();
  final format = usable.isEmpty
      ? ProjectFormat.horizontal
      : formatFromMedia(usable.first);
  return Project(
    id: _uuid.v4(),
    title: defaultProjectTitle(now, l10n),
    createdAt: now,
    modifiedAt: now,
    format: format,
    media: media,
    clips: [
      for (final m in usable)
        Clip(
          id: _uuid.v4(),
          mediaId: m.id,
          trimStartMs: 0,
          trimEndMs: m.durationMs > 0 ? m.durationMs : 3000,
        ),
    ],
  );
}
