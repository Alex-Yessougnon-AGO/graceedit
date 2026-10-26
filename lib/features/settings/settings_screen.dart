import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/models/settings.dart';
import '../../core/state/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/nav_bar.dart';
import '../../core/ui/sheets.dart';
import '../../core/utils/formatters.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(storeProvider);
    final settings = store.settings;
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Semantics(
                header: true,
                child: Text(l10n.settingsTitle, style: GraceType.screenTitle),
              ),
            ),
            _Section(l10n.settingsAppearance),
            _SettingsRow(
              label: l10n.settingsTheme,
              value: switch (settings.theme) {
                AppThemeMode.system => l10n.settingsThemeSystem,
                AppThemeMode.light => l10n.settingsThemeLight,
                AppThemeMode.dark => l10n.settingsThemeDark,
              },
              onTap: () async {
                final value = await showGraceChoiceSheet<AppThemeMode>(
                  context: context,
                  title: l10n.settingsThemeSheetTitle,
                  current: settings.theme,
                  options: [
                    GraceChoiceOption(
                      value: AppThemeMode.system,
                      label: l10n.settingsThemeSystem,
                    ),
                    GraceChoiceOption(
                      value: AppThemeMode.light,
                      label: l10n.settingsThemeLight,
                    ),
                    GraceChoiceOption(
                      value: AppThemeMode.dark,
                      label: l10n.settingsThemeDark,
                    ),
                  ],
                );
                if (value != null) {
                  await store.setSettings(settings.copyWith(theme: value));
                }
              },
            ),
            _SettingsRow(
              label: l10n.settingsLanguage,
              value: settings.language == AppLanguage.fr
                  ? l10n.settingsLanguageFrench
                  : l10n.settingsLanguageEnglish,
              onTap: () async {
                final value = await showGraceChoiceSheet<AppLanguage>(
                  context: context,
                  title: l10n.settingsLanguageSheetTitle,
                  current: settings.language,
                  options: [
                    GraceChoiceOption(
                      value: AppLanguage.fr,
                      label: l10n.settingsLanguageFrench,
                    ),
                    GraceChoiceOption(
                      value: AppLanguage.en,
                      label: l10n.settingsLanguageEnglish,
                    ),
                  ],
                );
                if (value != null) {
                  await store.setSettings(settings.copyWith(language: value));
                }
              },
            ),
            _Section(l10n.settingsAccessibility),
            _SwitchRow(
              label: l10n.settingsMotion,
              subtitle: l10n.settingsMotionHint,
              value: settings.reduceMotion,
              onChanged: (v) =>
                  store.setSettings(settings.copyWith(reduceMotion: v)),
            ),
            _SwitchRow(
              label: l10n.settingsHaptics,
              value: settings.haptics,
              onChanged: (v) =>
                  store.setSettings(settings.copyWith(haptics: v)),
            ),
            _Section(l10n.navProjects),
            _SettingsRow(
              label: l10n.settingsDeletion,
              value: settings.deleteBehavior == DeleteBehavior.ask
                  ? l10n.settingsValueAsk
                  : l10n.settingsValueTrash,
              onTap: () async {
                final value = await showGraceChoiceSheet<DeleteBehavior>(
                  context: context,
                  title: l10n.settingsDeletionSheetTitle,
                  current: settings.deleteBehavior,
                  options: [
                    GraceChoiceOption(
                      value: DeleteBehavior.ask,
                      label: l10n.settingsDeletionAsk,
                    ),
                    GraceChoiceOption(
                      value: DeleteBehavior.trash,
                      label: l10n.settingsDeletionTrash,
                    ),
                  ],
                );
                if (value != null) {
                  await store.setSettings(
                    settings.copyWith(deleteBehavior: value),
                  );
                }
              },
            ),
            _SettingsRow(
              label: l10n.settingsTrash,
              value: '${store.trashProjects.length}',
              onTap: () => context.push('/projects/trash'),
            ),
            _Section(l10n.settingsStorageHelp),
            _SettingsRow(
              label: l10n.settingsStorageCache,
              trailing: FutureBuilder(
                future: store.storageStats(),
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  if (data == null) {
                    return Text(
                      l10n.storageComputing,
                      style: GraceType.body.copyWith(color: p.secondary),
                    );
                  }
                  return Text(
                    formatBytes(data.usedBytes),
                    style: GraceType.body.copyWith(color: p.secondary),
                  );
                },
              ),
              onTap: () => context.push('/settings/storage'),
            ),
            _SettingsRow(
              label: l10n.helpTitle,
              onTap: () => context.push('/settings/help'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: GraceNavBar(
        current: GraceTab.settings,
        onSelect: (tab) {
          switch (tab) {
            case GraceTab.home:
              context.go('/home');
            case GraceTab.projects:
              context.go('/projects');
            case GraceTab.settings:
              break;
          }
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Semantics(
        header: true,
        child: Text(
          label,
          style: GraceType.secondary.copyWith(
            color: context.grace.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Semantics(
      button: onTap != null,
      label: value == null ? label : '$label, $value',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.surface, width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GraceType.body.copyWith(fontSize: 18, height: 24 / 18),
                ),
              ),
              if (trailing != null)
                trailing!
              else if (value != null)
                Flexible(
                  child: Text(
                    value!,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GraceType.body.copyWith(
                      fontSize: 18,
                      color: p.secondary,
                    ),
                  ),
                ),
              if (onTap != null) ...[
                const SizedBox(width: 6),
                Icon(Icons.chevron_right, size: 22, color: p.secondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.surface, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GraceType.body.copyWith(fontSize: 18, height: 24 / 18),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GraceType.secondary.copyWith(color: p.secondary),
                  ),
              ],
            ),
          ),
          GraceSwitch(value: value, semanticLabel: label, onChanged: onChanged),
        ],
      ),
    );
  }
}
