import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/models/project.dart';
import '../../core/platform/native_gateway.dart';
import '../../core/services/export_service.dart';
import '../../core/state/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/buttons.dart';
import '../../core/ui/controls.dart';
import '../../core/ui/messages.dart';
import '../../core/ui/sheets.dart';
import '../../core/ui/thumb.dart';
import '../../core/utils/formatters.dart';

/// Écrans d'export de la V1 — `EXP-01` à `EXP-04`.
///
/// Un seul **gabarit** pour l'échec, plusieurs **causes** (`EXP-04`). Chaque
/// état répond aux trois questions de la fiche, dans cet ordre : ce qui est
/// sûr, ce qui s'est passé, quoi faire.

/// Capacités de l'appareil, sans faire échouer l'écran si la détection rate.
Future<DeviceInfo?> _readDevice(WidgetRef ref) async {
  try {
    return await ref.read(deviceInfoProvider.future);
  } catch (_) {
    return null;
  }
}

// ---------------------------------------------------------------- commun

class _ExportTopBar extends StatelessWidget {
  const _ExportTopBar({
    required this.title,
    this.onLeading,
    this.close = false,
  });

  final String title;
  final VoidCallback? onLeading;
  final bool close;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: GraceDims.topBar,
      child: Row(
        children: [
          const SizedBox(width: 4),
          GraceIconAction(
            icon: close ? Icons.close : Icons.arrow_back,
            semanticLabel: close ? l10n.semanticsClose : l10n.semanticsBack,
            onPressed: onLeading ?? () => context.pop(),
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GraceType.barTitle,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

/// Récapitulatif : couverture, titre, format.
class _ExportSummary extends StatelessWidget {
  const _ExportSummary({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    return Row(
      children: [
        ProjectCover(
          project: project,
          width: 96,
          height: 54,
          radius: GraceRadius.thumb,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GraceType.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                [
                  switch (project.format) {
                    ProjectFormat.horizontal => l10n.formatHorizontal,
                    ProjectFormat.vertical => l10n.formatVertical,
                    ProjectFormat.square => l10n.formatSquare,
                    ProjectFormat.portrait => l10n.formatPortrait,
                  },
                  formatDuration(project.durationMs),
                ].join('  ·  '),
                style: GraceType.caption.copyWith(color: p.secondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    this.onTap,
    this.showChevron = false,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    final child = Container(
      constraints: const BoxConstraints(minHeight: GraceDims.touch),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.surface)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GraceType.secondary.copyWith(color: p.secondary),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(value, textAlign: TextAlign.end, style: GraceType.body),
          ),
          if (showChevron) ...[
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: p.secondary),
          ],
        ],
      ),
    );
    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: '$label, $value',
        excludeSemantics: true,
        child: child,
      ),
    );
  }
}

/// Encadré d'alerte : contour de 1,5 dp en couleur d'erreur, rayon 12 dp.
class _AlertBox extends StatelessWidget {
  const _AlertBox({required this.title, required this.body, this.actions});

  final String title;
  final String body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.error, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 20, color: p.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GraceType.bodyMedium.copyWith(color: p.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: GraceType.bodyCompact.copyWith(color: p.secondary)),
          if (actions != null) ...[
            const SizedBox(height: 12),
            for (final action in actions!) action,
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- EXP-01

/// EXP-01 — Réglages d'export (`/export/:projectId`).
///
/// Valide les réglages et vérifie les capacités de l'appareil. Le rendu est
/// dans `EXP-02`.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  ExportQuality _quality = ExportQuality.high;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // La vérification de l'espace se refait à chaque ouverture (spec).
    ref.invalidate(deviceInfoProvider);
  }

  Project? get _project =>
      ref.read(storeProvider).projectById(widget.projectId);

  void _start() {
    final project = _project;
    if (project == null) return;
    final asked = ref.read(settingsProvider).notificationsAsked;

    Future<void> launch() async {
      if (!mounted) return;
      ref.read(activeExportProvider.notifier).state = ActiveExport(
        projectId: project.id,
        quality: _quality,
        startedAt: DateTime.now(),
      );
      context.push('/export/${project.id}/progress');
    }

    // SYS-05 : une seule feuille avant la première demande système, jamais
    // bloquante — l'export démarre dans tous les cas.
    if (asked < 2) {
      showGraceSheet<void>(
        context: context,
        builder: (sheetContext) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  AppLocalizations.of(context).exportNotificationsTitle,
                  style: GraceType.sheetTitle,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).exportNotificationsBody,
                style: GraceType.bodyCompact.copyWith(
                  color: context.grace.secondary,
                ),
              ),
              const SizedBox(height: 24),
              GracePrimaryButton(
                label: AppLocalizations.of(context).exportNotificationsAllow,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  ref.read(nativeGatewayProvider).requestNotifications();
                },
              ),
              const SizedBox(height: 4),
              GraceTextAction(
                label: AppLocalizations.of(context).exportNotificationsLater,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  final s = ref.read(settingsProvider);
                  ref
                      .read(storeProvider)
                      .setSettings(
                        s.copyWith(
                          notificationsAsked: s.notificationsAsked + 1,
                        ),
                      );
                },
              ),
            ],
          ),
        ),
      ).then((_) => launch());
      return;
    }
    launch();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    final project = _project;

    if (project == null) {
      return Scaffold(
        backgroundColor: p.background,
        body: SafeArea(child: _ExportTopBar(title: l10n.exportTitle)),
      );
    }

    final service = ref.watch(exportServiceProvider);
    final device = ref.watch(deviceInfoProvider);
    final supports1080p = device.valueOrNull?.supports1080p ?? true;

    // Le choix par défaut est « Haute » si l'appareil le permet (spec) : on
    // recalcule un choix **effectif** plutôt que de modifier l'état au build.
    final quality = !supports1080p && _quality == ExportQuality.high
        ? ExportQuality.standard
        : _quality;

    final high = service.configuration(
      project,
      ExportQuality.high,
      supports1080p: supports1080p,
    );
    final standard = service.configuration(
      project,
      ExportQuality.standard,
      supports1080p: false,
    );
    final current = quality == ExportQuality.high ? high : standard;

    final free = device.valueOrNull?.freeBytes ?? 0;
    final needed = current.estimatedBytes;
    final enough = free == 0 || free >= needed;
    final noHigh = !supports1080p;

    final empty = project.isEmpty;
    final missing = project.hasMissingMedia;

    String? blockReason;
    if (empty) {
      blockReason = l10n.exportDisabledEmpty;
    } else if (missing) {
      blockReason = l10n.exportDisabledMissing;
    } else if (!enough) {
      blockReason = l10n.exportNotEnoughSpaceBody(
        formatBytes(needed),
        formatBytes(free),
      );
    }

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  _ExportTopBar(title: l10n.exportTitle),
                  const SizedBox(height: 8),
                  _ExportSummary(project: project),
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(l10n.exportQuality, style: GraceType.subtitle),
                  ),
                  const SizedBox(height: 12),
                  if (noHigh)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.exportTryStandardShort,
                        style: GraceType.bodyCompact.copyWith(
                          color: p.secondary,
                        ),
                      ),
                    )
                  else
                    _QualityOption(
                      label: l10n.exportQualityHigh,
                      width: high.width,
                      height: high.height,
                      bytes: high.estimatedBytes,
                      selected: quality == ExportQuality.high,
                      warning: !enough && quality == ExportQuality.high,
                      onTap: () =>
                          setState(() => _quality = ExportQuality.high),
                    ),
                  const SizedBox(height: 8),
                  _QualityOption(
                    label: l10n.exportQualityStandard,
                    width: standard.width,
                    height: standard.height,
                    bytes: standard.estimatedBytes,
                    selected: quality == ExportQuality.standard,
                    warning: !enough && quality == ExportQuality.standard,
                    onTap: () =>
                        setState(() => _quality = ExportQuality.standard),
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    header: true,
                    child: Text(l10n.exportSummary, style: GraceType.subtitle),
                  ),
                  const SizedBox(height: 4),
                  _SettingRow(
                    label: l10n.exportFormatLabel,
                    value: switch (project.format) {
                      ProjectFormat.horizontal => l10n.formatHorizontal,
                      ProjectFormat.vertical => l10n.formatVertical,
                      ProjectFormat.square => l10n.formatSquare,
                      ProjectFormat.portrait => l10n.formatPortrait,
                    },
                    showChevron: true,
                    // Le format se change dans l'éditeur (EDT-05) : changer de
                    // format modifie la composition.
                    onTap: () => context.push('/editor/${project.id}'),
                  ),
                  _SettingRow(
                    label: l10n.exportDestination,
                    value: l10n.exportDestinationGallery,
                  ),
                  const SizedBox(height: 16),
                  if (blockReason != null)
                    _AlertBox(
                      title: enough
                          ? l10n.exportDetails
                          : l10n.exportNotEnoughSpaceTitle,
                      body: blockReason,
                      actions: [
                        if (empty || missing)
                          GraceTextAction(
                            label: l10n.actionBack,
                            textAlign: TextAlign.start,
                            onPressed: () =>
                                context.push('/editor/${project.id}'),
                          )
                        else if (!enough)
                          GraceTextAction(
                            label: l10n.exportFreeSpace,
                            textAlign: TextAlign.start,
                            onPressed: () => context.push('/settings/storage'),
                          ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: p.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${l10n.exportSpaceFree}${l10n.detailSeparator}'
                            '${formatBytes(free)}',
                            style: GraceType.bodyCompact.copyWith(
                              color: p.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  children: [
                    GracePrimaryButton(
                      label: l10n.exportTitle,
                      onPressed: blockReason == null
                          ? () {
                              _quality = quality;
                              _start();
                            }
                          : null,
                      semanticHint: blockReason,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.exportEstimatedSize(
                        formatBytes(current.estimatedBytes),
                      ),
                      textAlign: TextAlign.center,
                      style: GraceType.caption.copyWith(color: p.secondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QualityOption extends StatelessWidget {
  const _QualityOption({
    required this.label,
    required this.width,
    required this.height,
    required this.bytes,
    required this.selected,
    required this.warning,
    required this.onTap,
  });

  final String label;
  final int width;
  final int height;
  final int bytes;
  final bool selected;
  final bool warning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    return Semantics(
      button: true,
      selected: selected,
      // Le groupe de choix porte son nom, sa sélection et sa taille (spec).
      label:
          '$label, ${formatBytes(bytes)}, '
          '${selected ? l10n.semanticsSelected : l10n.semanticsUnselected}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: GraceMotion.fade,
          // Hauteur minimale : le libellé doit tenir à 200 %.
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? p.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? p.text : p.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 22,
                color: warning ? p.error : (selected ? p.text : p.secondary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GraceType.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatPixels(width, height),
                      style: GraceType.caption.copyWith(color: p.secondary),
                    ),
                    Text(
                      l10n.exportFramesPerSecond,
                      style: GraceType.caption.copyWith(color: p.secondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  '≈ ${formatBytes(bytes)}',
                  textAlign: TextAlign.end,
                  style: GraceType.bodyMedium.copyWith(
                    color: warning ? p.error : p.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- EXP-02

/// EXP-02 — Progression de l'export (`/export/:projectId/progress`).
///
/// Une **vraie** progression, jamais une animation simulée : le pourcentage
/// ne recule jamais et n'affiche jamais 100 % avant la fin de la vérification.
class ExportProgressScreen extends ConsumerStatefulWidget {
  const ExportProgressScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ExportProgressScreen> createState() =>
      _ExportProgressScreenState();
}

class _ExportProgressScreenState extends ConsumerState<ExportProgressScreen> {
  Timer? _timer;
  String? _jobId;
  String? _outPath;
  ExportConfiguration? _config;
  double _progress = 0;
  int _step = 1;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _begin());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Ramène à `EXP-04` avec la cause exacte, sans jamais afficher un échec
  /// que l'on n'a pas constaté.
  void _fail(String code) {
    _finished = true;
    _timer?.cancel();
    ref.read(activeExportProvider.notifier).state = null;
    if (!mounted) return;
    context.pushReplacement('/export/${widget.projectId}/error?cause=$code');
  }

  Future<void> _begin() async {
    final active = ref.read(activeExportProvider);
    final project = ref.read(storeProvider).projectById(widget.projectId);
    if (project == null) return;

    if (active?.jobId == null) {
      // Validation des réglages faite dans EXP-01 : on lance le rendu.
      final service = ref.read(exportServiceProvider);
      final device = await _readDevice(ref);
      if (!mounted) return;
      final config = service.configuration(
        project,
        active?.quality ?? ExportQuality.high,
        supports1080p: device?.supports1080p ?? true,
      );
      _config = config;
      try {
        final handle = await service.start(project, config);
        if (!mounted) return;
        _jobId = handle.jobId;
        _outPath = handle.path;
        final current = ref.read(activeExportProvider);
        if (current != null) {
          ref.read(activeExportProvider.notifier).state = current.copyWith(
            jobId: handle.jobId,
          );
        }
      } on ExportException catch (e) {
        _fail(e.code);
        return;
      }
    } else {
      _jobId = active!.jobId;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _poll());
  }

  Future<void> _poll() async {
    if (_jobId == null || _finished) return;
    final service = ref.read(exportServiceProvider);
    final project = ref.read(storeProvider).projectById(widget.projectId);
    if (project == null) return;

    final state = await service.poll(_jobId!);
    if (!mounted) return;

    if (state.isCancelled) {
      _finished = true;
      _timer?.cancel();
      ref.read(activeExportProvider.notifier).state = null;
      context.pushReplacement('/export/${project.id}');
      GraceToast.show(
        context,
        AppLocalizations.of(context).exportCancelMessage,
      );
      return;
    }
    if (state.isError) {
      _fail(state.error ?? 'render');
      return;
    }
    if (state.isDone) {
      _finished = true;
      _timer?.cancel();
      setState(() {
        _step = 3;
        _progress = 1;
      });
      await _finish(project);
      return;
    }

    final next = state.progress.clamp(0.0, 1.0);
    // Le pourcentage ne recule jamais (spec).
    setState(() {
      _progress = next > _progress ? next : _progress;
      _step = _progress >= 0.999 ? 3 : (_progress > 0 ? 2 : 1);
    });
  }

  Future<void> _finish(Project project) async {
    final service = ref.read(exportServiceProvider);
    final path = _outPath;
    if (path == null) {
      _fail('output_missing');
      return;
    }
    final config =
        _config ??
        service.configuration(
          project,
          ref.read(activeExportProvider)?.quality ?? ExportQuality.high,
        );
    try {
      final record = await service.finish(project, path, config);
      await ref
          .read(storeProvider)
          .saveProject(project.copyWith(lastExport: record));
      // `EXP-03` ne s'affiche qu'après vérification **et** galerie (spec).
      if (!record.inGallery) {
        _fail('gallery');
        return;
      }
      ref.read(activeExportProvider.notifier).state = null;
      if (!mounted) return;
      context.pushReplacement('/export/${project.id}/result');
    } on ExportException catch (e) {
      _fail(e.code);
    }
  }

  Future<void> _confirmCancel() async {
    final l10n = AppLocalizations.of(context);
    final percent = (_progress * 100).round();
    final keep = await showGraceDialog<bool>(
      context: context,
      builder: (dialogContext) => GraceDialog(
        title: l10n.exportCancelTitle,
        body:
            '${l10n.exportCancelBody}\n\n'
            '${l10n.commonPercent(percent)}',
        actions: [
          GraceDialogAction(
            label: l10n.exportCancelKeep,
            // L'action par défaut est la plus sûre (spec).
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
          GraceDialogAction(
            label: l10n.exportCancelConfirm,
            style: GraceChoice.destructive,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (keep != false) return;

    final jobId = _jobId;
    _finished = true;
    _timer?.cancel();
    if (jobId != null) {
      await ref.read(exportServiceProvider).cancel(jobId);
    }
    ref.read(activeExportProvider.notifier).state = null;
    if (!mounted) return;
    // Le rendu annulé n'a rien écrit dans la galerie ; les fichiers
    // temporaires sont supprimés par le service natif.
    context.pushReplacement('/export/${widget.projectId}');
    GraceToast.show(context, l10n.exportCancelMessage);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    final project = ref.watch(
      storeProvider.select((s) => s.projectById(widget.projectId)),
    );
    final active = ref.watch(activeExportProvider);
    final startedAt = active?.startedAt ?? DateTime.now();
    final elapsed = DateTime.now().difference(startedAt);

    final stepLabel = switch (_step) {
      1 => l10n.exportPreparing,
      2 => l10n.exportRendering,
      _ => l10n.exportVerifying,
    };
    final indeterminate = _step != 2;

    if (project == null) {
      return Scaffold(
        backgroundColor: p.background,
        body: SafeArea(child: _ExportTopBar(title: l10n.exportInProgress)),
      );
    }

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Column(
          children: [
            _ExportTopBar(
              title: l10n.exportInProgress,
              onLeading: () => context.go('/home'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  _ExportSummary(project: project),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            stepLabel,
                            style: GraceType.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        indeterminate ? '—' : formatPercent(_progress * 100),
                        style: GraceType.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // L'avancement ne dépend jamais de la couleur seule.
                  GraceProgressBar(
                    value: indeterminate ? null : _progress,
                    indeterminate: indeterminate,
                    semanticLabel: l10n.exportProgressLabel,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.exportStep(_step, 3),
                    style: GraceType.bodyCompact.copyWith(color: p.secondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.exportElapsed(formatClock(elapsed, l10n)),
                    style: GraceType.bodyCompact.copyWith(color: p.secondary),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 18, color: p.secondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.homeExportRunningBody,
                          style: GraceType.caption.copyWith(color: p.secondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  children: [
                    GracePrimaryButton(
                      label: l10n.exportBackground,
                      onPressed: () => context.go('/home'),
                    ),
                    const SizedBox(height: 4),
                    GraceTextAction(
                      label: l10n.exportCancel,
                      onPressed: _confirmCancel,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- EXP-03

/// EXP-03 — Export réussi et partage (`/export/:projectId/result`).
///
/// Affiché **seulement après** vérification du fichier **et** enregistrement
/// dans la galerie : il n'annonce jamais une réussite qui n'est pas confirmée.
class ExportResultScreen extends ConsumerWidget {
  const ExportResultScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    final project = ref.watch(
      storeProvider.select((s) => s.projectById(projectId)),
    );
    final record = project?.lastExport;

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Column(
          children: [
            _ExportTopBar(
              title: l10n.exportSuccessTitle,
              close: true,
              // ✕ et Retour ramènent à l'accueil, jamais à la progression.
              onLeading: () => context.go('/home'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  if (project != null) ...[
                    _ExportSummary(project: project),
                    const SizedBox(height: 24),
                  ],
                  // Vignette avec disque de lecture de 56 dp.
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (project != null)
                        ProjectCover(
                          project: project,
                          width: 312,
                          height: 176,
                          radius: GraceRadius.card,
                        ),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 30,
                          color: GraceColors.ivory,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: p.text,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: p.background,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.exportSuccessTitle,
                              style: GraceType.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              l10n.exportGallerySaved,
                              style: GraceType.bodyCompact.copyWith(
                                color: p.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (record != null) ...[
                    _DetailRow(
                      label: l10n.exportSuccessName,
                      value: record.name,
                    ),
                    _DetailRow(
                      label: l10n.exportSuccessDimensions,
                      value: formatPixels(record.width, record.height),
                    ),
                    _DetailRow(
                      label: l10n.exportSuccessDuration,
                      value: formatDuration(record.durationMs),
                    ),
                    // Plus de « ≈ » : le fichier existe, la taille est exacte.
                    _DetailRow(
                      label: l10n.exportSuccessSize,
                      value: formatBytes(record.sizeBytes),
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  children: [
                    GracePrimaryButton(
                      label: l10n.exportShare,
                      onPressed: record == null
                          ? null
                          : () async {
                              await SharePlus.instance.share(
                                ShareParams(
                                  files: [XFile(record.path)],
                                  text: project?.title ?? '',
                                ),
                              );
                            },
                    ),
                    const SizedBox(height: 8),
                    GraceOutlineButton(
                      label: l10n.exportViewInGallery,
                      onPressed: record == null
                          ? null
                          : () => ref
                                .read(nativeGatewayProvider)
                                .openGallery(record.path),
                    ),
                    const SizedBox(height: 4),
                    GraceTextAction(
                      label: l10n.exportKeepEditing,
                      onPressed: () =>
                          context.pushReplacement('/editor/$projectId'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GraceType.secondary.copyWith(color: p.secondary),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GraceType.bodyCompact.copyWith(color: p.text),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- EXP-04

/// Causes d'échec — un seul gabarit, plusieurs causes (`EXP-04`).
enum ExportFailureCause { render, storage, gallery, interrupted, unsupported }

class ExportErrorScreen extends ConsumerStatefulWidget {
  const ExportErrorScreen({
    super.key,
    required this.projectId,
    this.cause = 'render',
  });

  final String projectId;
  final String cause;

  @override
  ConsumerState<ExportErrorScreen> createState() => _ExportErrorScreenState();
}

class _ExportErrorScreenState extends ConsumerState<ExportErrorScreen> {
  bool _detailsOpen = false;
  int _attempts = 0;

  ExportFailureCause get _cause => switch (widget.cause) {
    'storage' ||
    'output_missing' ||
    'not_enough_space' => ExportFailureCause.storage,
    'gallery' => ExportFailureCause.gallery,
    'interrupted' => ExportFailureCause.interrupted,
    'unsupported_platform' || 'unsupported' => ExportFailureCause.unsupported,
    _ => ExportFailureCause.render,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    final project = ref.watch(
      storeProvider.select((s) => s.projectById(widget.projectId)),
    );

    // Le titre porte la cause en quelques mots ; la couleur d'erreur n'est
    // utilisée QUE pour l'icône (spec).
    final (title, body) = switch (_cause) {
      ExportFailureCause.storage => (
        l10n.exportNotEnoughSpaceTitle,
        '${l10n.exportFailedStorage}\n\n${l10n.exportSafeFileDeleted}',
      ),
      ExportFailureCause.gallery => (
        l10n.exportFailedGallery,
        l10n.exportUnableGallery,
      ),
      ExportFailureCause.interrupted => (
        l10n.exportFailedInterrupted,
        l10n.exportInterruptedBody,
      ),
      ExportFailureCause.unsupported => (
        l10n.unsupportedTitle,
        l10n.unsupportedBody,
      ),
      ExportFailureCause.render => (
        l10n.exportFailedTitle,
        l10n.exportUnableRender,
      ),
    };

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Column(
          children: [
            _ExportTopBar(
              title: l10n.exportTitle,
              close: true,
              // ✕ et Retour ramènent à l'accueil, le projet est enregistré.
              onLeading: () => context.go('/home'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: p.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 28,
                      color: p.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    liveRegion: true,
                    child: Text(
                      title,
                      style: GraceType.screenTitle.copyWith(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Rassurance : toujours en premier.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_rounded, size: 20, color: p.text),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _cause == ExportFailureCause.gallery
                              ? l10n.exportNotLost
                              : l10n.exportFailedSafe,
                          style: GraceType.bodyMedium.copyWith(color: p.text),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    body,
                    style: GraceType.bodyCompact.copyWith(color: p.secondary),
                  ),
                  if (_cause == ExportFailureCause.gallery) ...[
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(minHeight: 64),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.movie_outlined, size: 22, color: p.text),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Text(
                              project?.lastExport?.name ??
                                  '${project?.title ?? ''}.mp4',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GraceType.bodyCompact,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 2,
                            child: Text(
                              l10n.exportKeepInApp,
                              textAlign: TextAlign.end,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GraceType.caption.copyWith(
                                color: p.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_cause == ExportFailureCause.render) ...[
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => setState(() => _detailsOpen = !_detailsOpen),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 56),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: p.surface),
                            bottom: BorderSide(color: p.surface),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.exportErrorDetails,
                                style: GraceType.bodyCompact,
                              ),
                            ),
                            Icon(
                              _detailsOpen
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 20,
                              color: p.secondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_detailsOpen)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n.exportDetails}${l10n.detailSeparator}'
                              '${widget.cause}',
                              style: GraceType.small.copyWith(
                                color: p.secondary,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 8),
                            GraceTextAction(
                              label: l10n.helpDiagCopy,
                              textAlign: TextAlign.start,
                              onPressed: () =>
                                  GraceToast.show(context, l10n.helpDiagCopied),
                            ),
                            GraceTextAction(
                              label: l10n.helpDiagnosticTitle,
                              textAlign: TextAlign.start,
                              onPressed: () =>
                                  context.push('/settings/help/diagnostic'),
                            ),
                          ],
                        ),
                      ),
                    if (_attempts >= 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          l10n.storageLowBody(
                            formatBytes(
                              ref
                                      .read(deviceInfoProvider)
                                      .valueOrNull
                                      ?.freeBytes ??
                                  0,
                            ),
                          ),
                          style: GraceType.bodyCompact.copyWith(
                            color: p.secondary,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  children: [
                    GracePrimaryButton(
                      label: switch (_cause) {
                        ExportFailureCause.storage => l10n.exportFreeSpace,
                        ExportFailureCause.gallery => l10n.exportRetryGallery,
                        ExportFailureCause.interrupted => l10n.exportRestart,
                        _ => l10n.exportRetry,
                      },
                      onPressed: switch (_cause) {
                        ExportFailureCause.storage => () => context.push(
                          '/settings/storage',
                        ),
                        ExportFailureCause.gallery => () => _retry(),
                        _ => () => _retry(),
                      },
                    ),
                    if (_cause == ExportFailureCause.render) ...[
                      const SizedBox(height: 8),
                      GraceOutlineButton(
                        label: l10n.exportTryStandardShort,
                        onPressed: () => _retry(),
                      ),
                    ],
                    const SizedBox(height: 4),
                    GraceTextAction(
                      label: l10n.exportKeepEditing,
                      onPressed: () => context.pushReplacement(
                        '/editor/${widget.projectId}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _retry() {
    setState(() => _attempts++);
    ref.read(activeExportProvider.notifier).state = null;
    context.pushReplacement('/export/${widget.projectId}/progress');
  }
}
