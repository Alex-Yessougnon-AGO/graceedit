import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/models/project.dart';
import '../../core/models/settings.dart';
import '../../core/state/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/back_scope.dart';
import '../../core/ui/buttons.dart';
import '../../core/ui/controls.dart';
import '../../core/ui/messages.dart';
import '../../core/ui/nav_bar.dart';
import '../../core/ui/sheets.dart';
import '../../core/ui/thumb.dart';
import '../../core/utils/formatters.dart';
import '../import/import_flow.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final TextEditingController _search = TextEditingController();
  final Set<String> _selected = {};
  bool _searching = false;
  bool _selecting = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Project> _visible(List<Project> projects) {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return projects;
    return projects
        .where((p) => _normalize(p.title).contains(_normalize(query)))
        .toList();
  }

  String _normalize(String value) {
    const accents = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'ô': 'o',
      'ö': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
    };
    var out = value.toLowerCase();
    accents.forEach((key, replacement) {
      out = out.replaceAll(key, replacement);
    });
    return out;
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
      // Désélectionner le dernier élément quitte le mode sélection : sinon
      // l'écran reste bloqué avec un compteur à 0 et des actions éteintes.
      _selecting = _selected.isNotEmpty;
    });
  }

  void _exitSelection() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
  }

  Future<void> _open(Project project) async {
    if (project.hasMissingMedia) {
      await context.push('/projects/${project.id}/relink');
    } else {
      await context.push('/editor/${project.id}');
    }
  }

  Future<void> _newProject() async {
    await startImport(context, ref);
  }

  Future<void> _sort() async {
    final l10n = AppLocalizations.of(context);
    final store = ref.read(storeProvider);
    final value = await showGraceChoiceSheet<SortOrder>(
      context: context,
      title: l10n.projectsSortTitle,
      current: store.settings.sort,
      options: [
        GraceChoiceOption(
          value: SortOrder.recent,
          label: l10n.projectsSortRecent,
        ),
        GraceChoiceOption(
          value: SortOrder.oldest,
          label: l10n.projectsSortOldest,
        ),
        GraceChoiceOption(value: SortOrder.name, label: l10n.projectsSortName),
      ],
    );
    if (value == null) return;
    await store.setSettings(store.settings.copyWith(sort: value));
  }

  /// Ferme la recherche puis la sélection avant de quitter l'écran.
  bool _onBack() {
    if (_searching) {
      setState(() {
        _searching = false;
        _search.clear();
      });
      return true;
    }
    if (_selecting) {
      _exitSelection();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    final all = store.activeProjects;
    // Réconcilie la sélection avec les données : un projet mis à la
    // corbeille, restauré ou supprimé ailleurs ne doit pas rester coché.
    _selected.retainWhere((id) => all.any((project) => project.id == id));
    final projects = _visible(all);
    final grid = store.settings.view == ProjectView.grid;

    return GraceBackScope(
      onBack: _onBack,
      child: Scaffold(
        backgroundColor: p.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (_searching)
                _SearchBar(
                  controller: _search,
                  onClose: () {
                    setState(() {
                      _searching = false;
                      _search.clear();
                    });
                  },
                  onChanged: (_) => setState(() {}),
                )
              else if (_selecting)
                _SelectionBar(
                  count: _selected.length,
                  allSelected:
                      projects.isNotEmpty &&
                      projects.every((e) => _selected.contains(e.id)),
                  onClose: _exitSelection,
                  onSelectAll: () {
                    setState(() {
                      final allVisible =
                          projects.isNotEmpty &&
                          projects.every((e) => _selected.contains(e.id));
                      if (allVisible) {
                        _selecting = false;
                        _selected.clear();
                      } else {
                        _selecting = true;
                        _selected
                          ..clear()
                          ..addAll(projects.map((e) => e.id));
                      }
                    });
                  },
                )
              else
                _ProjectsBar(
                  grid: grid,
                  onSearch: () => setState(() => _searching = true),
                  onToggleView: () {
                    store.setSettings(
                      store.settings.copyWith(
                        view: grid ? ProjectView.list : ProjectView.grid,
                      ),
                    );
                  },
                  onMenu: _showMenu,
                ),
              if (!_searching && !_selecting)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: _sort,
                        borderRadius: BorderRadius.circular(20),
                        child: Semantics(
                          button: true,
                          label: l10n.projectsSort,
                          child: Container(
                            // Zone tactile de 48 dp minimum (règle 6).
                            constraints: const BoxConstraints(
                              minHeight: GraceDims.touch,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: p.surface,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    switch (store.settings.sort) {
                                      SortOrder.recent =>
                                        l10n.projectsSortRecent,
                                      SortOrder.oldest =>
                                        l10n.projectsSortOldest,
                                      SortOrder.name => l10n.projectsSortName,
                                    },
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GraceType.secondaryMedium,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.keyboard_arrow_down, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.projectsCount(projects.length),
                          textAlign: TextAlign.end,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GraceType.secondary.copyWith(
                            color: p.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: projects.isEmpty
                    ? _EmptyProjects(
                        searching: _searching && _search.text.trim().isNotEmpty,
                        onStart: _newProject,
                      )
                    : grid
                    ? _ProjectsGrid(
                        projects: projects,
                        selected: _selected,
                        selecting: _selecting,
                        onOpen: _open,
                        onLongPress: (project) {
                          if (_selecting) {
                            _toggleSelection(project.id);
                          } else {
                            setState(() {
                              _selecting = true;
                              _selected.add(project.id);
                            });
                          }
                        },
                        onMenu: _showActions,
                        onSelect: _toggleSelection,
                      )
                    : _ProjectsList(
                        projects: projects,
                        selected: _selected,
                        selecting: _selecting,
                        onOpen: _open,
                        onLongPress: (project) {
                          if (_selecting) {
                            _toggleSelection(project.id);
                          } else {
                            setState(() {
                              _selecting = true;
                              _selected.add(project.id);
                            });
                          }
                        },
                        onMenu: _showActions,
                        onSelect: _toggleSelection,
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _selecting
            ? _SelectionActions(
                enabled: _selected.isNotEmpty,
                onDuplicate: _duplicateSelected,
                onDelete: _deleteSelected,
              )
            : GraceNavBar(
                current: GraceTab.projects,
                onSelect: (tab) {
                  switch (tab) {
                    case GraceTab.home:
                      context.go('/home');
                    case GraceTab.projects:
                      break;
                    case GraceTab.settings:
                      context.go('/settings');
                  }
                },
              ),
        floatingActionButton: _selecting || _searching
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GraceExtendedFab(
                  label: l10n.homeNewProject,
                  onPressed: _newProject,
                ),
              ),
      ),
    );
  }

  Future<void> _showMenu() async {
    final l10n = AppLocalizations.of(context);
    final trash = ref.read(storeProvider).trashProjects.length;
    await showGraceSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.checklist),
              title: Text(l10n.actionSelect),
              onTap: () {
                Navigator.of(sheetContext).pop();
                setState(() => _selecting = true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text('${l10n.projectsTrash} ($trash)'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/projects/trash');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showActions(Project project) async {
    final l10n = AppLocalizations.of(context);
    await showGraceSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProjectCover(project: project, width: 96, height: 54),
                const SizedBox(width: 12),
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
                      Text(
                        formatModified(project.modifiedAt, l10n),
                        style: GraceType.secondary.copyWith(
                          color: context.grace.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ActionRow(
              icon: Icons.edit_outlined,
              label: l10n.actionRename,
              onTap: () {
                Navigator.of(sheetContext).pop();
                _rename(project);
              },
            ),
            _ActionRow(
              icon: Icons.content_copy,
              label: l10n.actionDuplicate,
              onTap: () async {
                await ref.read(storeProvider).duplicate([
                  project.id,
                ], titleOf: (p) => l10n.projectsDuplicateSuffix(p.title));
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                if (mounted) {
                  GraceToast.show(context, l10n.projectsDuplicateDone);
                }
              },
            ),
            _ActionRow(
              icon: Icons.ios_share,
              label: l10n.actionExport,
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/export/${project.id}');
              },
            ),
            _ActionRow(
              icon: Icons.checklist,
              label: l10n.actionSelect,
              onTap: () {
                Navigator.of(sheetContext).pop();
                setState(() {
                  _selecting = true;
                  _selected.add(project.id);
                });
              },
            ),
            _ActionRow(
              icon: Icons.delete_outline,
              label: l10n.projectsDelete,
              destructive: true,
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

  Future<void> _rename(Project project) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: project.title);
    final ok = await showGraceDialog<bool>(
      context: context,
      builder: (dialogContext) => Material(
        color: context.grace.background,
        borderRadius: BorderRadius.circular(GraceRadius.sheet),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.projectsRenameTitle, style: GraceType.sheetTitle),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 60,
                style: GraceType.body,
                decoration: InputDecoration(
                  labelText: l10n.importNameLabel,
                  counterText: '',
                ),
                onSubmitted: (_) => Navigator.of(dialogContext).pop(true),
              ),
              const SizedBox(height: 16),
              GracePrimaryButton(
                label: l10n.actionSave,
                height: GraceDims.dialogButton,
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;
                  Navigator.of(dialogContext).pop(true);
                },
              ),
              SizedBox(
                width: double.infinity,
                child: GraceTextAction(
                  label: l10n.actionCancel,
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true) {
      await ref.read(storeProvider).rename(project.id, controller.text.trim());
    }
    controller.dispose();
  }

  void _deleteSelected() {
    final l10n = AppLocalizations.of(context);
    final ids = _selected.toList();
    if (ids.isEmpty) return;
    _delete(ids);
    if (ids.isNotEmpty) {
      GraceToast.show(context, l10n.projectsDeleted(ids.length));
    }
  }

  Future<void> _delete(List<String> ids) async {
    final l10n = AppLocalizations.of(context);
    final store = ref.read(storeProvider);
    if (store.settings.deleteBehavior == DeleteBehavior.trash) {
      await store.trash(ids);
      if (!mounted) return;
      _exitSelection();
      GraceToast.show(
        context,
        ids.length == 1 ? l10n.toastProjectTrashed : l10n.toastProjectsTrashed,
        actionLabel: l10n.actionUndo,
        onAction: () => store.restore(ids),
      );
      return;
    }
    final choice = await showGraceDialog<String>(
      context: context,
      builder: (dialogContext) => GraceDialog(
        title: l10n.projectsDeleteTitle(ids.length),
        body:
            '${l10n.projectsDeleteBody(ids.length)}\n\n${l10n.projectsDeleteSafeNote}',
        actions: [
          GraceDialogAction(
            label: l10n.projectsToTrash,
            onPressed: () => Navigator.of(dialogContext).pop('trash'),
          ),
          GraceDialogAction(
            label: l10n.projectsDeleteForever,
            style: GraceChoice.destructive,
            onPressed: () => Navigator.of(dialogContext).pop('forever'),
          ),
          GraceDialogAction(
            label: l10n.actionCancel,
            style: GraceChoice.text,
            onPressed: () => Navigator.of(dialogContext).pop(null),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (choice == 'trash') {
      await store.trash(ids);
      if (!mounted) return;
      _exitSelection();
      GraceToast.show(
        context,
        ids.length == 1 ? l10n.toastProjectTrashed : l10n.toastProjectsTrashed,
        actionLabel: l10n.actionUndo,
        onAction: () => store.restore(ids),
      );
    } else if (choice == 'forever') {
      final confirm = await showGraceDialog<bool>(
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
      if (confirm == true) {
        await store.deletePermanently(ids);
        if (!mounted) return;
        _exitSelection();
        GraceToast.show(context, l10n.projectsDeletedForever);
      }
    }
  }

  Future<void> _duplicateSelected() async {
    final l10n = AppLocalizations.of(context);
    final ids = _selected.toList();
    final copies = await ref
        .read(storeProvider)
        .duplicate(ids, titleOf: (p) => l10n.projectsDuplicateSuffix(p.title));
    if (!mounted) return;
    _exitSelection();
    GraceToast.show(
      context,
      copies.length == 1
          ? l10n.projectsDuplicateDone
          : l10n.projectsDuplicateMany(copies.length),
    );
  }
}

class _ProjectsBar extends StatelessWidget {
  const _ProjectsBar({
    required this.grid,
    required this.onSearch,
    required this.onToggleView,
    required this.onMenu,
  });

  final bool grid;
  final VoidCallback onSearch;
  final VoidCallback onToggleView;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ConstrainedBox(
      // Hauteur libre : le titre doit pouvoir grandir à 200 %.
      constraints: const BoxConstraints(minHeight: 64),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(l10n.projectsTitle, style: GraceType.screenTitle),
            ),
          ),
          GraceIconAction(
            icon: Icons.search,
            semanticLabel: l10n.projectsSearch,
            onPressed: onSearch,
          ),
          GraceIconAction(
            icon: grid ? Icons.view_agenda_outlined : Icons.grid_view,
            semanticLabel: grid
                ? l10n.projectsViewToggleList
                : l10n.projectsViewToggleGrid,
            onPressed: onToggleView,
          ),
          GraceIconAction(
            icon: Icons.more_vert,
            semanticLabel: l10n.semanticsMore,
            onPressed: onMenu,
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onClose,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onClose;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          GraceIconAction(
            icon: Icons.arrow_back,
            semanticLabel: l10n.semanticsBack,
            onPressed: onClose,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: onChanged,
              style: GraceType.body,
              decoration: InputDecoration(
                hintText: l10n.projectsSearch,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: l10n.projectsSearchClear,
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.count,
    required this.allSelected,
    required this.onClose,
    required this.onSelectAll,
  });

  final int count;
  final bool allSelected;
  final VoidCallback onClose;
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          const SizedBox(width: 4),
          GraceIconAction(
            icon: Icons.close,
            semanticLabel: l10n.actionClose,
            onPressed: onClose,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.projectsSelectedCount(count),
              style: GraceType.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: onSelectAll,
            child: Text(
              allSelected ? l10n.projectsDeselectAll : l10n.projectsSelectAll,
              style: GraceType.secondaryMedium,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _SelectionActions extends StatelessWidget {
  const _SelectionActions({
    required this.enabled,
    required this.onDuplicate,
    required this.onDelete,
  });

  final bool enabled;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: context.grace.nav,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: GraceDims.navBar,
          child: Row(
            children: [
              _SelectionAction(
                icon: Icons.content_copy,
                label: l10n.projectsDuplicate,
                onTap: enabled ? onDuplicate : null,
              ),
              _SelectionAction(
                icon: Icons.delete_outline,
                label: l10n.projectsDelete,
                onTap: enabled ? onDelete : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionAction extends StatelessWidget {
  const _SelectionAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Expanded(
      child: Semantics(
        button: true,
        enabled: onTap != null,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: onTap == null ? p.outline : p.text),
              const SizedBox(height: 4),
              Text(
                label,
                style: GraceType.small.copyWith(
                  color: onTap == null ? p.outline : p.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectsList extends StatelessWidget {
  const _ProjectsList({
    required this.projects,
    required this.selected,
    required this.selecting,
    required this.onOpen,
    required this.onLongPress,
    required this.onMenu,
    required this.onSelect,
  });

  final List<Project> projects;
  final Set<String> selected;
  final bool selecting;
  final ValueChanged<Project> onOpen;
  final ValueChanged<Project> onLongPress;
  final ValueChanged<Project> onMenu;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 12, 104),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final isSelected = selected.contains(project.id);
        final l10n = AppLocalizations.of(context);
        return Semantics(
          button: true,
          selected: isSelected,
          label: l10n.projectLineLabel(
            project.title,
            formatDurationSpoken(project.durationMs, l10n),
            formatModified(project.modifiedAt, l10n),
          ),
          child: InkWell(
            onTap: selecting
                ? () => onSelect(project.id)
                : () => onOpen(project),
            onLongPress: () => onLongPress(project),
            child: Container(
              // Hauteur minimale : la ligne doit tenir à 200 %.
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? p.active : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (selecting)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 8),
                      child: CheckDisc(selected: isSelected),
                    ),
                  ProjectCover(project: project, width: 96, height: 54),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GraceType.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        if (project.hasMissingMedia)
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: p.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.homeMissingMedia,
                                style: GraceType.secondary.copyWith(
                                  color: p.error,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            formatModified(project.modifiedAt, l10n),
                            style: GraceType.secondary.copyWith(
                              color: p.secondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!selecting)
                    GraceIconAction(
                      icon: Icons.more_vert,
                      semanticLabel: l10n.projectsMenu(project.title),
                      onPressed: () => onMenu(project),
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProjectsGrid extends StatelessWidget {
  const _ProjectsGrid({
    required this.projects,
    required this.selected,
    required this.selecting,
    required this.onOpen,
    required this.onLongPress,
    required this.onMenu,
    required this.onSelect,
  });

  final List<Project> projects;
  final Set<String> selected;
  final bool selecting;
  final ValueChanged<Project> onOpen;
  final ValueChanged<Project> onLongPress;
  final ValueChanged<Project> onMenu;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 840
        ? 4
        : width >= 600
        ? 3
        : MediaQuery.textScalerOf(context).scale(1) > 1.5
        ? 1
        : 2;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 104),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
        childAspectRatio: 152 / 122,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final isSelected = selected.contains(project.id);
        return Semantics(
          button: true,
          selected: isSelected,
          label: l10n.projectLineLabel(
            project.title,
            formatDurationSpoken(project.durationMs, l10n),
            formatModified(project.modifiedAt, l10n),
          ),
          child: GestureDetector(
            onTap: selecting
                ? () => onSelect(project.id)
                : () => onOpen(project),
            onLongPress: () => onLongPress(project),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: isSelected ? p.active : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              GraceRadius.small,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: ProjectCover(
                              project: project,
                              width: 152,
                              height: 86,
                              radius: 10,
                            ),
                          ),
                        ),
                      ),
                      if (selecting)
                        Positioned(
                          left: 6,
                          top: 6,
                          child: CheckDisc(selected: isSelected),
                        )
                      else
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: GraceDims.touch,
                            height: GraceDims.touch,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: GraceColors.ink.withValues(alpha: 0.55),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.more_vert,
                                size: 20,
                                color: GraceColors.ivory,
                              ),
                              tooltip: l10n.projectsMenu(project.title),
                              onPressed: () => onMenu(project),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GraceType.secondaryMedium,
                ),
                if (project.hasMissingMedia)
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 13,
                        color: p.error,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          l10n.homeMissingMedia,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GraceType.caption.copyWith(color: p.error),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    formatModified(project.modifiedAt, l10n),
                    maxLines: 1,
                    style: GraceType.caption.copyWith(color: p.secondary),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects({required this.searching, required this.onStart});
  final bool searching;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searching ? Icons.search_off : Icons.movie_outlined,
              size: 40,
              color: p.secondary,
            ),
            const SizedBox(height: 12),
            Text(
              searching ? l10n.projectsNoResultsTitle : l10n.projectsEmptyTitle,
              style: GraceType.subtitle,
            ),
            const SizedBox(height: 4),
            Text(
              searching ? l10n.projectsNoResultsBody : l10n.projectsEmptyBody,
              textAlign: TextAlign.center,
              style: GraceType.secondary.copyWith(color: p.secondary),
            ),
            if (!searching) ...[
              const SizedBox(height: 20),
              GracePrimaryButton(
                label: l10n.homeEmptyCta,
                expanded: false,
                onPressed: onStart,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? context.grace.error : context.grace.text;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 16),
            Text(label, style: GraceType.body.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
