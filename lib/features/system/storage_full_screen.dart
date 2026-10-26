import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/buttons.dart';
import '../../core/ui/messages.dart';

/// SYS-03 — Stockage plein (`/system/storage-full`).
///
/// N'est affiché **qu'au moment où une action échoue**, jamais au lancement.
/// Le bandeau de stockage faible (niveau 1) vit dans l'accueil et la liste
/// des projets.
class StorageFullScreen extends StatelessWidget {
  const StorageFullScreen({super.key});

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
                  const SizedBox(height: 32),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: p.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sd_storage_outlined,
                      size: 28,
                      color: p.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.storageFullTitle,
                      style: GraceType.screenTitle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.check_rounded, size: 20, color: p.text),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.storageFullSafe,
                          style: GraceType.bodyCompact.copyWith(color: p.text),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.storageFullBody,
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
                      label: l10n.storageManage,
                      onPressed: () => context.push('/settings/storage'),
                    ),
                    const SizedBox(height: 8),
                    GraceOutlineButton(
                      label: l10n.storageFullTrash,
                      onPressed: () => context.push('/projects/trash'),
                    ),
                    const SizedBox(height: 4),
                    GraceTextAction(
                      label: l10n.storageFullLater,
                      onPressed: () {
                        context.pop();
                        GraceToast.show(context, l10n.storageFullBody);
                      },
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
