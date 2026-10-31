import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/models/project.dart';
import '../../core/state/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/buttons.dart';
import '../../core/ui/messages.dart';
import '../../core/ui/screen.dart';
import '../../core/ui/thumb.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/typography.dart';
import 'import_flow.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final TextEditingController _title = TextEditingController();
  bool _titleInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_titleInitialized) return;
    _titleInitialized = true;
    final l10n = AppLocalizations.of(context);
    _title.text = defaultProjectTitle(DateTime.now(), l10n);
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  List<MediaRef> get _media => ref.read(pendingImportProvider);

  List<MediaRef> get _usable =>
      _media.where((m) => !m.unsupported && m.kind == MediaKind.video).toList();

  void _setMedia(List<MediaRef> media) {
    ref.read(pendingImportProvider.notifier).state = media;
  }

  Future<void> _addMedia() async {
    final l10n = AppLocalizations.of(context);
    final result = await ref.read(mediaServiceProvider).pickVideos();
    if (!mounted) return;
    if (result.failure != null) {
      GraceToast.show(context, l10n.pickerUnavailable, isError: true);
      return;
    }
    if (result.media.isEmpty) return;
    _setMedia([..._media, ...result.media.map(mediaRefFromPicked)]);
  }

  void _remove(MediaRef media) {
    _setMedia(_media.where((m) => m.id != media.id).toList());
  }

  Future<void> _start() async {
    final usable = _usable;
    if (usable.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final project = projectFromMedia(_media, l10n);
    final title = _title.text.trim();
    final renamed = title.isEmpty ? project : project.copyWith(title: title);
    await ref.read(storeProvider).addProject(renamed);
    ref.read(pendingImportProvider.notifier).state = const [];
    if (mounted) context.pushReplacement('/editor/${renamed.id}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    final media = ref.watch(pendingImportProvider);
    final usable = media
        .where((m) => !m.unsupported && m.kind == MediaKind.video)
        .toList();
    final ignored = media.length - usable.length;
    final total = usable.fold<int>(0, (sum, m) => sum + m.durationMs);
    final canStart = usable.isNotEmpty;

    return GraceScreen(
      child: Column(
        children: [
          GraceTopBar(
            title: l10n.importTitle,
            onLeading: () {
              ref.read(pendingImportProvider.notifier).state = const [];
              Navigator.of(context).maybePop();
            },
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              buildDefaultDragHandles: false,
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _title,
                    textInputAction: TextInputAction.done,
                    maxLength: 60,
                    style: GraceType.body,
                    decoration: InputDecoration(
                      labelText: l10n.importNameLabel,
                      counterText: '',
                      suffixIcon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: p.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${l10n.importVideos(usable.length)}'
                          ' · ${l10n.importDurationTotal(formatDuration(total))}',
                          style: GraceType.bodyCompact.copyWith(
                            color: p.secondary,
                          ),
                        ),
                      ),
                      if (ignored > 0)
                        Text(
                          l10n.importIgnoredCount(ignored),
                          style: GraceType.caption.copyWith(color: p.error),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              footer: Column(
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GraceOutlineButton(
                      label: l10n.importAddMedia,
                      icon: Icons.add,
                      onPressed: _addMedia,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        ignored > 0 ? Icons.info_outline : Icons.check,
                        size: 18,
                        color: ignored > 0 ? p.secondary : p.text,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          media.isEmpty
                              ? l10n.importAddHint
                              : usable.isEmpty
                              ? l10n.importNoneUsable
                              : ignored > 0
                              ? l10n.importIgnoredNotice
                              : l10n.importAddHint,
                          style: GraceType.caption.copyWith(
                            color: ignored > 0 && usable.isEmpty
                                ? p.error
                                : p.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              itemCount: media.length,
              // `onReorderItem` reçoit un `newIndex` déjà ajusté au retrait de
              // l'élément déplacé : pas de correction à refaire ici.
              onReorderItem: (oldIndex, newIndex) {
                final next = [...media];
                final item = next.removeAt(oldIndex);
                next.insert(newIndex, item);
                _setMedia(next);
              },
              itemBuilder: (context, index) {
                final item = media[index];
                return _MediaRow(
                  key: ValueKey(item.id),
                  media: item,
                  index: index,
                  total: media.length,
                  onRemove: () => _remove(item),
                  onMove: (delta) {
                    final next = [...media];
                    final target = index + delta;
                    if (target < 0 || target >= next.length) return;
                    final moved = next.removeAt(index);
                    next.insert(target, moved);
                    _setMedia(next);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            color: p.background,
            child: GracePrimaryButton(
              // Sans média utilisable, le bouton désactivé garde son libellé
              // simple : « Commencer avec 1 média » serait faux (et le
              // pluriel français mettrait 0 au singulier).
              label: ignored > 0 && usable.isNotEmpty
                  ? l10n.importStartWithCount(usable.length)
                  : l10n.importStart,
              onPressed: canStart ? _start : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaRow extends StatelessWidget {
  const _MediaRow({
    super.key,
    required this.media,
    required this.index,
    required this.total,
    required this.onRemove,
    required this.onMove,
  });

  final MediaRef media;
  final int index;
  final int total;
  final VoidCallback onRemove;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    final title = media.capturedAt != null
        ? formatCaptureDate(media.capturedAt!, l10n)
        : media.name;
    final duration = formatDuration(media.durationMs);
    final size = formatBytes(media.sizeBytes);
    return Semantics(
      label: '$title, $duration, $size, ${index + 1} / $total',
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.actionMoveUp): () => onMove(-1),
        CustomSemanticsAction(label: l10n.actionMoveDown): () => onMove(1),
      },
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const SizedBox(
                width: 32,
                height: 48,
                child: Icon(Icons.drag_handle, size: 20),
              ),
            ),
            const SizedBox(width: 4),
            GraceThumb(
              media: media,
              width: 96,
              height: 54,
              missing: media.unsupported,
              durationMs: media.durationMs,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GraceType.secondaryMedium,
                  ),
                  if (media.unsupported)
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: p.error,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            l10n.importUnsupported,
                            style: GraceType.caption.copyWith(color: p.error),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      typo('$duration · $size'),
                      style: GraceType.caption.copyWith(color: p.secondary),
                    ),
                ],
              ),
            ),
            GraceIconAction(
              icon: Icons.close,
              semanticLabel: l10n.importRemoveFromProject,
              onPressed: onRemove,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
