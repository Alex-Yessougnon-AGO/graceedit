import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/models/project.dart';
import '../../core/state/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/buttons.dart';
import '../../core/ui/messages.dart';
import '../../core/ui/sheets.dart';
import '../../core/ui/thumb.dart';
import '../../core/utils/formatters.dart';

class RelinkScreen extends ConsumerStatefulWidget {
  const RelinkScreen({super.key, required this.projectId});
  final String projectId;

  @override
  ConsumerState<RelinkScreen> createState() => _RelinkScreenState();
}

class _RelinkScreenState extends ConsumerState<RelinkScreen> {
  bool _busy = false;

  Project? get _project =>
      ref.read(storeProvider).projectById(widget.projectId);

  Future<void> _reconnect(MediaRef media) async {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(mediaServiceProvider);
    setState(() => _busy = true);
    final result = media.kind == MediaKind.audio
        ? await service.pickAudio()
        : media.kind == MediaKind.image
        ? await service.pickImage()
        : await service.pickVideos();
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.media.isEmpty) return;
    final picked = result.media.first;
    final project = _project;
    if (project == null) return;
    final different =
        media.durationMs > 0 &&
        picked.durationMs > 0 &&
        (picked.durationMs - media.durationMs).abs() / media.durationMs > 0.05;
    if (different) {
      final use = await showGraceDialog<bool>(
        context: context,
        builder: (dialogContext) => GraceDialog(
          title: l10n.missingDifferentTitle,
          body: l10n.missingDifferentBody(
            formatDuration(picked.durationMs),
            formatDuration(media.durationMs),
          ),
          actions: [
            GraceDialogAction(
              label: l10n.missingChooseAnother,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            GraceDialogAction(
              label: l10n.missingUseAnyway,
              style: GraceChoice.text,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        ),
      );
      if (use != true) {
        if (mounted && use == false) _reconnect(media);
        return;
      }
    }
    final updated = media.copyWith(
      uri: picked.uri,
      name: picked.name,
      durationMs: picked.durationMs > 0 ? picked.durationMs : media.durationMs,
      sizeBytes: picked.sizeBytes,
      width: picked.width,
      height: picked.height,
      missing: false,
    );
    final next = project.copyWith(
      media: [
        for (final m in project.media)
          if (m.id == media.id) updated else m,
      ],
      clips: [
        for (final c in project.clips)
          if (c.mediaId == media.id)
            c.copyWith(
              trimEndMs: c.trimEndMs.clamp(
                c.trimStartMs + 100,
                updated.durationMs > 0 ? updated.durationMs : c.trimEndMs,
              ),
            )
          else
            c,
      ],
    );
    await ref.read(storeProvider).saveProject(next);
    if (!mounted) return;
    setState(() {});
    GraceToast.show(context, l10n.missingReconnected);
  }

  Future<void> _remove(MediaRef media) async {
    final l10n = AppLocalizations.of(context);
    final project = _project;
    if (project == null) return;
    await ref
        .read(storeProvider)
        .saveProject(
          project.copyWith(
            media: project.media.where((m) => m.id != media.id).toList(),
            clips: project.clips.where((c) => c.mediaId != media.id).toList(),
            audios: project.audios.where((a) => a.mediaId != media.id).toList(),
          ),
        );
    if (!mounted) return;
    setState(() {});
    GraceToast.show(
      context,
      l10n.toastMediaRemoved,
      actionLabel: l10n.actionUndo,
      onAction: () async {
        await ref.read(storeProvider).saveProject(project);
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _removeAll() async {
    final l10n = AppLocalizations.of(context);
    final project = _project;
    if (project == null) return;
    final missingIds = project.missingMedia.map((m) => m.id).toSet();
    if (missingIds.isEmpty) return;
    await ref
        .read(storeProvider)
        .saveProject(
          project.copyWith(
            media: project.media
                .where((m) => !missingIds.contains(m.id))
                .toList(),
            clips: project.clips
                .where((c) => !missingIds.contains(c.mediaId))
                .toList(),
            audios: project.audios
                .where((a) => !missingIds.contains(a.mediaId))
                .toList(),
          ),
        );
    if (!mounted) return;
    GraceToast.show(
      context,
      l10n.toastMediaRemoved,
      actionLabel: l10n.actionUndo,
      onAction: () async {
        await ref.read(storeProvider).saveProject(project);
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    final store = ref.watch(storeProvider);
    final project = store.projectById(widget.projectId);
    if (project == null) {
      return Scaffold(body: Center(child: Text(l10n.errorGenericTitle)));
    }
    final missing = project.missingMedia;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 72,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  GraceIconAction(
                    icon: Icons.arrow_back,
                    semanticLabel: l10n.semanticsBack,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.missingTitle, style: GraceType.screenTitle),
                        Text(
                          l10n.missingProjectLabel(project.title),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GraceType.secondary.copyWith(
                            color: p.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                children: [
                  Text(
                    missing.isEmpty
                        ? l10n.missingAllGood
                        : '${l10n.missingSeveral(missing.length)}. '
                              '${l10n.missingExplain}',
                    style: GraceType.body,
                  ),
                  const SizedBox(height: 16),
                  for (final media in project.missingMedia)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MissingCard(
                        project: project,
                        media: media,
                        busy: _busy,
                        onReconnect: () => _reconnect(media),
                        onRemove: () => _remove(media),
                      ),
                    ),
                  for (final media in project.media.where(
                    (m) => !m.missing && !m.fileMissing,
                  ))
                    if (project.clips.any((c) => c.mediaId == media.id))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ConnectedCard(
                          project: project,
                          media: media,
                          onChange: () => _reconnect(media),
                        ),
                      ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              color: p.background,
              child: Column(
                children: [
                  if (missing.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        l10n.missingRemaining(missing.length),
                        style: GraceType.caption.copyWith(color: p.secondary),
                      ),
                    ),
                  GracePrimaryButton(
                    label: l10n.missingOpen,
                    onPressed: missing.isEmpty
                        ? () => context.pushReplacement('/editor/${project.id}')
                        : null,
                  ),
                  if (missing.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: GraceTextAction(
                        label: l10n.missingOpenWithout,
                        onPressed: () {
                          if (missing.length == project.media.length) {
                            _removeAll();
                          } else {
                            context.pushReplacement('/editor/${project.id}');
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingCard extends StatelessWidget {
  const _MissingCard({
    required this.project,
    required this.media,
    required this.busy,
    required this.onReconnect,
    required this.onRemove,
  });

  final Project project;
  final MediaRef media;
  final bool busy;
  final VoidCallback onReconnect;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    final count = project.clips.where((c) => c.mediaId == media.id).length;
    return Container(
      constraints: const BoxConstraints(minHeight: 148),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(GraceRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 40,
                decoration: BoxDecoration(
                  color: p.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 22,
                  color: p.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      media.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GraceType.bodyMedium,
                    ),
                    Text(
                      '${formatDuration(media.durationMs)} · ${formatBytes(media.sizeBytes)}',
                      style: GraceType.secondary.copyWith(color: p.secondary),
                    ),
                    Text(
                      l10n.missingUsedIn(count),
                      style: GraceType.caption.copyWith(color: p.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GraceOutlineButton(
                label: l10n.missingReconnect,
                expanded: false,
                height: 44,
                onPressed: busy ? null : onReconnect,
              ),
              const Spacer(),
              TextButton(
                onPressed: onRemove,
                child: Text(
                  l10n.missingRemove,
                  style: GraceType.secondaryMedium.copyWith(color: p.secondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConnectedCard extends StatelessWidget {
  const _ConnectedCard({
    required this.project,
    required this.media,
    required this.onChange,
  });

  final Project project;
  final MediaRef media;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    final count = project.clips.where((c) => c.mediaId == media.id).length;
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(GraceRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProjectCover(
                project: project.copyWith(media: [media]),
                width: 72,
                height: 40,
                showDuration: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      media.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GraceType.bodyMedium,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          l10n.missingReconnected,
                          style: GraceType.secondaryMedium,
                        ),
                      ],
                    ),
                    Text(
                      l10n.missingUsedIn(count),
                      style: GraceType.caption.copyWith(color: p.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onChange,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              l10n.missingChangeFile,
              style: GraceType.secondaryMedium.copyWith(color: p.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
