import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/buttons.dart';

/// IMP-03 — Autorisation d'accès aux médias (conditionnel).
///
/// Affiché **seulement** si le sélecteur du système n'est pas utilisable
/// (anciennes versions d'Android). Sur les appareils modernes cet écran
/// n'apparaît jamais.
class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key, this.denied = false});

  /// `true` sur `/import/permission/denied`.
  final bool denied;

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
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: p.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      denied
                          ? Icons.warning_amber_rounded
                          : Icons.image_outlined,
                      size: 36,
                      color: denied ? p.error : p.text,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(
                      denied
                          ? l10n.permissionDeniedTitle
                          : l10n.permissionTitle,
                      textAlign: TextAlign.center,
                      style: GraceType.screenTitle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!denied) ...[
                    _Line(
                      text: l10n.permissionSafe1,
                      icon: Icons.check_rounded,
                    ),
                    const SizedBox(height: 8),
                    _Line(
                      text: l10n.permissionSafe2,
                      icon: Icons.check_rounded,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    denied
                        ? l10n.permissionDeniedPermission
                        : l10n.permissionBody,
                    textAlign: TextAlign.center,
                    style: GraceType.bodyCompact.copyWith(color: p.secondary),
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
                      label: denied
                          ? l10n.permissionOpenSettings
                          : l10n.permissionContinue,
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(height: 8),
                    GraceOutlineButton(
                      label: denied
                          ? l10n.permissionChooseFiles
                          : l10n.permissionChooseFiles,
                      onPressed: () => context.pop(),
                    ),
                    if (denied) ...[
                      const SizedBox(height: 4),
                      GraceTextAction(
                        label: l10n.actionBack,
                        onPressed: () => context.pop(),
                      ),
                    ],
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

class _Line extends StatelessWidget {
  const _Line({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Row(
      children: [
        Icon(icon, size: 20, color: p.text),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GraceType.bodyCompact.copyWith(color: p.text),
          ),
        ),
      ],
    );
  }
}
