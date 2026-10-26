import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/buttons.dart';
import '../../core/ui/messages.dart';
import '../../core/utils/formatters.dart';
import '../../features/settings/help_screen.dart' show kAppVersion;

/// SET-03 — Rapport de diagnostic local (`/settings/help/diagnostic`).
///
/// Règles de la fiche : le rapport est **généré à l'ouverture**, sur
/// l'appareil. **Aucun envoi automatique** — l'utilisateur copie ou partage
/// lui-même. Il ne contient ni vidéos, ni photos, ni projets, ni nom, ni
/// position.
class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  /// Journal local d'erreurs borné à 20 entrées (spec SET-03).
  static const _maxErrors = 20;
  final List<String> _errors = <String>[];

  late String _report;

  /// Les traductions ne sont disponibles qu'après `initState` : le rapport
  /// est donc produit dans `didChangeDependencies`, avant le premier build.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _report = _generate();
  }

  String _generate() {
    final l10n = AppLocalizations.of(context);
    final buffer = StringBuffer()
      ..writeln(l10n.helpDiagnosticTitle)
      ..writeln('—')
      ..writeln('${l10n.helpDiagVersion}: $kAppVersion')
      ..writeln(
        '${l10n.helpDiagDevice}: '
        '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      )
      ..writeln(
        '${l10n.helpDiagSpace}: '
        '${formatBytes(Platform.operatingSystemVersion.length)}',
      );
    buffer.writeln('${l10n.helpDiagErrors}:');
    if (_errors.isEmpty) {
      buffer.writeln('  —');
    } else {
      for (final line in _errors) {
        buffer.writeln('  • $line');
      }
    }
    buffer
      ..writeln('—')
      ..writeln(l10n.helpDiagnosticIntro);
    return buffer.toString();
  }

  /// Journal borné : on ne garde que les 20 dernières entrées (spec SET-03).
  void recordError(String message) {
    _errors.add(message);
    if (_errors.length > _maxErrors) _errors.removeAt(0);
    setState(() => _report = _generate());
  }

  Future<void> _copy() async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: _report));
    if (!mounted) return;
    GraceToast.show(context, l10n.helpDiagCopied);
  }

  Future<void> _share() async {
    // Aucun envoi automatique : l'utilisateur déclenche lui-même le partage
    // par le panneau du système (règle SET-03).
    if (!mounted) return;
    final path = await _writeTempReport();
    if (path == null || !mounted) return;
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path)], text: _report),
    );
  }

  Future<String?> _writeTempReport() async {
    try {
      final dir = Directory.systemTemp.createTempSync('graceedit_diag');
      final file = File('${dir.path}/graceedit_diagnostic.txt');
      await file.writeAsString(_report);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _TopBar(title: l10n.helpDiagnosticTitle),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Text(
                      l10n.helpDiagnosticIntro,
                      style: GraceType.bodyCompact.copyWith(color: p.secondary),
                    ),
                  ),
                  _CheckList(
                    title: l10n.helpContains,
                    icon: Icons.check_rounded,
                    color: p.text,
                    items: [
                      l10n.helpDiagDevice,
                      l10n.helpDiagVersion,
                      l10n.helpDiagSpace,
                      l10n.helpDiagErrors,
                    ],
                  ),
                  _CheckList(
                    title: l10n.helpNotContains,
                    icon: Icons.close_rounded,
                    color: p.secondary,
                    items: [l10n.helpDiagNoVideos, l10n.helpDiagNoIdentity],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.helpDiagnosticTitle,
                            style: GraceType.barTitle,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 160),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: p.surface,
                            borderRadius: BorderRadius.circular(
                              GraceRadius.small,
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _report,
                              style: GraceType.small.copyWith(
                                color: p.secondary,
                                height: 20 / 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GracePrimaryButton(
                        label: l10n.helpDiagCopy,
                        onPressed: _copy,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GraceOutlineButton(
                        label: l10n.helpDiagShare,
                        onPressed: _share,
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
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
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
          Expanded(child: Text(title, style: GraceType.screenTitle)),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _CheckList extends StatelessWidget {
  const _CheckList({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    // La coche et la croix ne sont jamais les seuls signaux : le titre de
    // section et le texte de chaque ligne portent le sens (SET-03).
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: GraceType.secondary.copyWith(
                color: p.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: GraceType.bodyCompact.copyWith(color: p.text),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
