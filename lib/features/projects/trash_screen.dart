import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/models/project.dart';
import '../../core/state/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/buttons.dart';
import '../../core/ui/controls.dart';
import '../../core/ui/messages.dart';
import '../../core/ui/sheets.dart';
import '../../core/ui/thumb.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  final Set<String> _selected = {};
  bool _selecting = false;

  Future<void> _restore(List<String> ids) async {
    final l10n = AppLocalizations.of(context);
    await ref.read(storeProvider).restore(ids);
    if (!mounted) return;
    setState(() {
      _selected.clear();
      _selecting = false;
    });
    GraceToast.show(context, l10n.trashRestored);
  }

  Future<void> _delete(List<String> ids) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showGraceDialog<bool>(
      context: context,
      builder: (dialogContext) => GraceDialog(
        title: l10n.projectsDeleteForeverTitle,
        body: ids.length == 1
            ? l10n.projectsDeleteForeverSingularBody
            : l10n.projectsDeleteForeverPluralBody,
        actions: [
          GraceDialogAction(
            label: l10n.actionCancel,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          GraceDialogAction(
            label: l10n.projectsDeleteForeverAction,
            style: GraceChoice.destructive,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(storeProvider).deletePermanently(ids);
    if (!mounted) return;
    setState(() {
      _selected.clear();
      _selecting = false;
    });
    GraceToast.show(context, l10n.projectsDeletedForever);
  }

  Future<void> _purge() async {
    final l10n = AppLocalizations.of(context);
    final store = ref.read(storeProvider);
    final ids = store.trashProjects.map((e) => e.id).toList();
    final ok = await showGraceDialog<bool>(
      context: context,
      builder: (dialogContext) => GraceDialog(
        title: l10n.trashPurgeTitle,
        body: l10n.trashPurgeBody,
        actions: [
          GraceDialogAction(
            label: l10n.actionCancel,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          GraceDialogAction(
            label: l10n.trashPurgeAction,
            style: GraceChoice.destructive,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await store.deletePermanently(ids);
    if (!mounted) return;
    GraceToast.show(context, l10n.trashPurged);
  }

  Future<void> _actions(Project project) async {
    final l10n = AppLocalizations.of(context);
    await showGraceSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restore),
              title: Text(l10n.actionRestore),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _restore([project.id]);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever, color: context.grace.error),
              title: Text(
                l10n.projectsDeleteForever,
                style: TextStyle(color: context.grace.error),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _delete([project.id]);
              },
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
    final projects = store.trashProjects;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 64,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  if (_selecting)
                    GraceIconAction(
                      icon: Icons.close,
                      semanticLabel: l10n.actionClose,
                      onPressed: () => setState(() {
                        _selecting = false;
                        _selected.clear();
                      }),
                    )
                  else
                    GraceIconAction(
                      icon: Icons.arrow_back,
                      semanticLabel: l10n.semanticsBack,
                      onPressed: () => context.pop(),
                    ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _selecting
                          ? l10n.projectsSelectedCount(_selected.length)
                          : l10n.trashTitle,
                      style: GraceType.screenTitle,
                    ),
                  ),
                  if (!_selecting)
                    TextButton(
                      onPressed: projects.isEmpty ? null : _purge,
                      child: Text(
                        l10n.trashPurgeAction,
                        style: GraceType.bodyMedium,
                      ),
                    ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 20, color: p.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.projectsTrashEmptyBody,
                      style: GraceType.secondary.copyWith(color: p.secondary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: projects.isEmpty
                  // Défilement : le texte doit tenir avec une police à 200 %.
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 40,
                            color: p.secondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.projectsTrashEmpty,
                            textAlign: TextAlign.center,
                            style: GraceType.subtitle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.projectsTrashEmptyBody,
                            textAlign: TextAlign.center,
                            style: GraceType.secondary.copyWith(
                              color: p.secondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 12, 24),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        final days = project.trashedAt == null
                            ? 30
                            : (30 -
                                      DateTime.now()
                                          .difference(project.trashedAt!)
                                          .inDays)
                                  .clamp(0, 30);
                        final urgent = days <= 1;
                        final selected = _selected.contains(project.id);
                        return Semantics(
                          button: true,
                          selected: selected,
                          child: InkWell(
                            onTap: _selecting
                                ? () => setState(() {
                                    if (selected) {
                                      _selected.remove(project.id);
                                    } else {
                                      _selected.add(project.id);
                                    }
                                  })
                                : () => _actions(project),
                            onLongPress: () => setState(() {
                              _selecting = true;
                              _selected.add(project.id);
                            }),
                            child: Container(
                              // Hauteur minimale plutôt que fixe : le texte
                              // doit pouvoir grandir jusqu’à 200 %.
                              constraints: const BoxConstraints(minHeight: 96),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              color: selected ? p.active : Colors.transparent,
                              child: Row(
                                children: [
                                  if (_selecting)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: CheckDisc(selected: selected),
                                    ),
                                  Opacity(
                                    opacity: 0.85,
                                    child: ProjectCover(
                                      project: project,
                                      width: 96,
                                      height: 54,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          project.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GraceType.bodyMedium,
                                        ),
                                        Text(
                                          l10n.trashPurgeIn(
                                            (30 -
                                                    DateTime.now()
                                                        .difference(
                                                          project.trashedAt ??
                                                              DateTime.now(),
                                                        )
                                                        .inDays)
                                                .clamp(0, 30),
                                          ),
                                          style: GraceType.secondary.copyWith(
                                            color: urgent
                                                ? p.error
                                                : p.secondary,
                                          ),
                                        ),
                                        if (urgent)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                size: 14,
                                                color: p.error,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                l10n.trashPurgeTomorrow,
                                                style: GraceType.secondary
                                                    .copyWith(color: p.error),
                                              ),
                                            ],
                                          )
                                        else
                                          Text(
                                            l10n.trashDeletedAgo(
                                              DateTime.now()
                                                  .difference(
                                                    project.trashedAt ??
                                                        DateTime.now(),
                                                  )
                                                  .inDays,
                                            ),
                                            style: GraceType.caption.copyWith(
                                              color: p.secondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (!_selecting)
                                    GraceIconAction(
                                      icon: Icons.more_vert,
                                      semanticLabel: l10n.projectsMenu(
                                        project.title,
                                      ),
                                      onPressed: () => _actions(project),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _selecting && _selected.isNotEmpty
          ? Material(
              color: p.nav,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: GraceDims.navBar,
                  child: Row(
                    children: [
                      _TrashAction(
                        icon: Icons.restore,
                        label: l10n.actionRestore,
                        onTap: () => _restore(_selected.toList()),
                      ),
                      _TrashAction(
                        icon: Icons.delete_forever,
                        label: l10n.projectsDeleteForever,
                        onTap: () => _delete(_selected.toList()),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _TrashAction extends StatelessWidget {
  const _TrashAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 4),
              Text(label, style: GraceType.small),
            ],
          ),
        ),
      ),
    );
  }
}
