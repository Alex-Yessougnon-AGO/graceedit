import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/buttons.dart';
import '../../core/ui/messages.dart';
import '../../core/ui/sheets.dart';
import '../../core/utils/formatters.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/store/app_store.dart';

class StorageScreen extends ConsumerStatefulWidget {
  const StorageScreen({super.key});

  @override
  ConsumerState<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends ConsumerState<StorageScreen> {
  StorageStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await ref.read(storeProvider).storageStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _loading = false;
      });
    }
  }

  Future<void> _clear() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showGraceDialog<bool>(
      context: context,
      builder: (dialogContext) => GraceDialog(
        title: l10n.storageClearCache,
        body: l10n.storageClearCacheBody,
        actions: [
          GraceDialogAction(
            label: l10n.storageClear,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
          GraceDialogAction(
            label: l10n.actionCancel,
            style: GraceChoice.text,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final freed = await ref.read(storeProvider).clearCache();
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    GraceToast.show(context, l10n.storageCleared(formatBytes(freed)));
  }

  Future<void> _manageExports() async {
    final l10n = AppLocalizations.of(context);
    final dir = await ref.read(storeProvider).exportsDir();
    final files = <File>[];
    if (await dir.exists()) {
      await for (final entity in dir.list()) {
        if (entity is File) files.add(entity);
      }
    }
    if (!mounted) return;
    await showGraceSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.storageUnregistered, style: GraceType.sheetTitle),
            const SizedBox(height: 12),
            if (files.isEmpty)
              Text(
                l10n.storageNothingToClear,
                style: GraceType.body.copyWith(color: context.grace.secondary),
              ),
            for (final file in files)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  file.uri.pathSegments.last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GraceType.bodyCompact,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.actionDelete,
                  onPressed: () async {
                    await file.delete();
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                    await _load();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    final store = ref.watch(storeProvider);
    final stats = _stats;
    final device = ref.watch(deviceInfoProvider);
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            SizedBox(
              height: 64,
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
                    child: Text(
                      l10n.settingsStorageCache,
                      style: GraceType.screenTitle,
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.storageGraceEditUses,
                    style: GraceType.secondary.copyWith(color: p.secondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _loading
                        ? l10n.storageComputing
                        : formatBytes(stats?.usedBytes ?? 0),
                    style: const TextStyle(
                      fontFamily: GraceType.family,
                      fontSize: 32,
                      height: 40 / 32,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _UsageBar(stats: stats),
                  const SizedBox(height: 16),
                  _LegendRow(
                    color: p.text,
                    label: l10n.storageCacheThumbs,
                    size: stats?.cacheBytes ?? 0,
                  ),
                  _LegendRow(
                    color: p.text.withValues(alpha: 0.55),
                    label: l10n.storageProjects,
                    size: stats?.projectBytes ?? 0,
                  ),
                  _LegendRow(
                    color: p.text.withValues(alpha: 0.3),
                    label: l10n.storageUnregistered,
                    size: stats?.exportBytes ?? 0,
                  ),
                  _LegendRow(
                    color: p.text.withValues(alpha: 0.15),
                    label: l10n.storageTrash,
                    size: stats?.trashBytes ?? 0,
                  ),
                  const SizedBox(height: 24),
                  _ActionRow(
                    title: l10n.storageCacheThumbs,
                    subtitle: l10n.storageCacheBody,
                    action: GraceOutlineButton(
                      label: stats != null && stats.cacheBytes == 0
                          ? l10n.storageNothingToClear
                          : l10n.storageClear,
                      expanded: false,
                      height: 44,
                      onPressed: stats != null && stats.cacheBytes == 0
                          ? null
                          : _clear,
                    ),
                  ),
                  _ActionRow(
                    title: l10n.storageUnregistered,
                    subtitle:
                        '${formatBytes(stats?.exportBytes ?? 0)}${l10n.detailSeparator}${l10n.storageCacheBody}',
                    action: TextButton(
                      onPressed: _manageExports,
                      child: Text(
                        l10n.commonManage,
                        style: GraceType.bodyMedium,
                      ),
                    ),
                  ),
                  _ActionRow(
                    title: l10n.storageTrash,
                    subtitle: l10n.projectsCount(store.trashProjects.length),
                    action: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.chevron_right, color: p.secondary)],
                    ),
                    onTap: () => context.push('/projects/trash'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.storageFreePhone,
                          style: GraceType.body.copyWith(color: p.secondary),
                        ),
                      ),
                      Flexible(
                        child: device.when(
                          data: (d) => Text(
                            d.totalBytes == 0 ? '—' : formatBytes(d.freeBytes),
                            textAlign: TextAlign.end,
                            style: GraceType.bodyMedium,
                          ),
                          loading: () => Text(
                            l10n.storageComputing,
                            textAlign: TextAlign.end,
                            style: GraceType.caption.copyWith(
                              color: p.secondary,
                            ),
                          ),
                          error: (_, _) =>
                              Text('—', style: GraceType.bodyMedium),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  device.when(
                    data: (d) =>
                        _FreeBar(free: d.freeBytes, total: d.totalBytes),
                    loading: () => const SizedBox(height: 8),
                    error: (_, _) => const SizedBox(height: 8),
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

class _UsageBar extends StatelessWidget {
  const _UsageBar({required this.stats});
  final StorageStats? stats;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    final values = [
      stats?.cacheBytes ?? 0,
      stats?.projectBytes ?? 0,
      stats?.exportBytes ?? 0,
      stats?.trashBytes ?? 0,
    ];
    final total = values.fold<int>(0, (a, b) => a + b);
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 14,
        child: total == 0
            ? ColoredBox(color: p.active)
            : Row(
                children: [
                  for (var i = 0; i < values.length; i++)
                    if (values[i] > 0)
                      Expanded(
                        flex: values[i],
                        child: ColoredBox(
                          color: p.text.withValues(
                            alpha: [1.0, 0.55, 0.3, 0.15][i],
                          ),
                        ),
                      ),
                ],
              ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.size,
  });
  final Color color;
  final String label;
  final int size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: GraceType.body)),
          Text(formatBytes(size), style: GraceType.bodyMedium),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.action,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.surface)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GraceType.body.copyWith(
                      fontSize: 18,
                      height: 24 / 18,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GraceType.secondary.copyWith(color: p.secondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // `Flexible` : à 200 %, l’action se rétrécit au lieu de pousser
            // le texte hors de l’écran.
            Flexible(child: action),
          ],
        ),
      ),
    );
  }
}

class _FreeBar extends StatelessWidget {
  const _FreeBar({required this.free, required this.total});
  final int free;
  final int total;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    final factor = total == 0 ? 0.0 : (free / total).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 8,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: p.active),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: factor,
              child: ColoredBox(color: p.text),
            ),
          ],
        ),
      ),
    );
  }
}
