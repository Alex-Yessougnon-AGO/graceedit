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
import '../../core/ui/nav_bar.dart';
import '../../core/ui/screen.dart';
import '../../core/ui/sheets.dart';
import '../../core/ui/thumb.dart';
import '../../core/utils/formatters.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _recoveryChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_recoveryChecked) return;
    _recoveryChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRecover());
  }

  Future<void> _maybeRecover() async {
    final store = ref.read(storeProvider);
    final project = store.projectById(store.openProjectId);
    if (project == null || store.cleanExit || project.isTrashed) return;
    final l10n = AppLocalizations.of(context);
    await showGraceSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(l10n.recoveryTitle, style: GraceType.sheetTitle),
            ),
            const SizedBox(height: 16),
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
                      const SizedBox(height: 2),
                      Text(
                        l10n.recoverySavedAgo(
                          formatModified(project.modifiedAt, l10n),
                        ),
                        style: GraceType.secondary.copyWith(
                          color: context.grace.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check, size: 20, color: context.grace.text),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l10n.recoverySafe, style: GraceType.bodyCompact),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GracePrimaryButton(
              label: l10n.recoveryResume,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.push('/editor/${project.id}');
              },
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: GraceTextAction(
                label: l10n.recoveryLater,
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    final projects = store.activeProjects;
    final activeExport = ref.watch(activeExportProvider);
    final l10n = AppLocalizations.of(context);
    final p = context.grace;

    return Scaffold(
      backgroundColor: p.background,
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: GraceTopBar(
              brand: true,
              leading: BarLeading.none,
              padding: EdgeInsets.symmetric(horizontal: 24),
            ),
          ),
          if (activeExport != null)
            _ExportBanner(
              title: l10n.homeExportRunning,
              body: l10n.homeExportRunningBody,
              onTap: () =>
                  context.push('/export/${activeExport.projectId}/progress'),
            ),
          Expanded(
            child: projects.isEmpty
                ? _EmptyHome(onStart: () => context.push('/import/new'))
                : _FilledHome(projects: projects),
          ),
        ],
      ),
      bottomNavigationBar: GraceNavBar(
        current: GraceTab.home,
        onSelect: (tab) {
          switch (tab) {
            case GraceTab.home:
              break;
            case GraceTab.projects:
              context.go('/projects');
            case GraceTab.settings:
              context.go('/settings');
          }
        },
      ),
      floatingActionButton: projects.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GraceExtendedFab(
                label: l10n.homeNewProject,
                onPressed: () => context.push('/import/new'),
              ),
            ),
    );
  }
}

class _ExportBanner extends StatelessWidget {
  const _ExportBanner({
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: p.surface,
        padding: const EdgeInsets.fromLTRB(24, 10, 16, 10),
        child: Row(
          children: [
            Icon(Icons.movie_creation_outlined, size: 20, color: p.text),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GraceType.secondaryMedium),
                  Text(
                    body,
                    style: GraceType.caption.copyWith(color: p.secondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: p.secondary),
          ],
        ),
      ),
    );
  }
}

class _FilledHome extends StatelessWidget {
  const _FilledHome({required this.projects});

  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    final first = projects.first;
    final recent = projects.skip(1).take(5).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 96),
      children: [
        GraceSectionTitle(l10n.homeResume),
        const SizedBox(height: 12),
        _ResumeCard(project: first),
        if (recent.isNotEmpty) ...[
          const SizedBox(height: 24),
          GraceSectionTitle(
            l10n.homeRecent,
            trailing: GraceTextAction(
              label: l10n.homeSeeAll,
              onPressed: () => context.go('/projects'),
            ),
          ),
          const SizedBox(height: 4),
          for (final project in recent) _RecentRow(project: project),
        ],
        if (first.hasMissingMedia)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.projectsExportingLocked,
              style: GraceType.caption.copyWith(color: p.secondary),
            ),
          ),
      ],
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    return Semantics(
      button: true,
      label: l10n.projectLineLabel(
        project.title,
        formatDurationSpoken(project.durationMs, l10n),
        formatModified(project.modifiedAt, l10n),
      ),
      excludeSemantics: true,
      child: InkWell(
        onTap: () => context.push(
          project.hasMissingMedia
              ? '/projects/${project.id}/relink'
              : '/editor/${project.id}',
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) => ProjectCover(
                project: project,
                width: constraints.maxWidth,
                height: constraints.maxWidth * 9 / 16,
                radius: GraceRadius.card,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              project.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GraceType.subtitle,
            ),
            const SizedBox(height: 2),
            if (project.hasMissingMedia)
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 15, color: p.error),
                  const SizedBox(width: 4),
                  Text(
                    l10n.homeMissingMedia,
                    style: GraceType.secondary.copyWith(color: p.error),
                  ),
                ],
              )
            else
              Text(
                formatModified(project.modifiedAt, l10n),
                style: GraceType.secondary.copyWith(color: p.secondary),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    return Semantics(
      button: true,
      label: l10n.projectLineLabel(
        project.title,
        formatDurationSpoken(project.durationMs, l10n),
        formatModified(project.modifiedAt, l10n),
      ),
      excludeSemantics: true,
      child: InkWell(
        onTap: () => context.push(
          project.hasMissingMedia
              ? '/projects/${project.id}/relink'
              : '/editor/${project.id}',
        ),
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
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
                            style: GraceType.secondary.copyWith(color: p.error),
                          ),
                        ],
                      )
                    else
                      Text(
                        formatModified(project.modifiedAt, l10n),
                        style: GraceType.secondary.copyWith(color: p.secondary),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashedSlot(
                onTap: onStart,
                label: l10n.homeNewProject,
                height: constraints.maxWidth.clamp(0, 480) * 9 / 16,
                icon: Icons.add,
              ),
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Text(l10n.homeEmptyTitle, style: GraceType.screenTitle),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.homeEmptyBody,
                style: GraceType.body.copyWith(color: p.secondary),
              ),
              const SizedBox(height: 48),
              Text(
                l10n.homeSaved,
                style: GraceType.bodyCompact.copyWith(color: p.secondary),
              ),
              const SizedBox(height: 16),
              GracePrimaryButton(label: l10n.homeEmptyCta, onPressed: onStart),
            ],
          ),
        ),
      ),
    );
  }
}
