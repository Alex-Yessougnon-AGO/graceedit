library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/state/providers.dart';
import '../nav/grace_nav.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final theme = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      bottomNavigationBar: const GraceNav(index: 3),
      body: ListView(
        children: [
          ListTile(
            title: Text(strings.themeMode),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined)),
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_suggest_outlined)),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined)),
              ],
              selected: {theme},
              onSelectionChanged: (s) =>
                  ref.read(themeModeProvider.notifier).state = s.first,
            ),
          ),
          ListTile(
            title: Text(strings.language),
            trailing: SegmentedButton<AppLocale>(
              segments: const [
                ButtonSegment(value: AppLocale.fr, label: Text('FR')),
                ButtonSegment(value: AppLocale.en, label: Text('EN')),
              ],
              selected: {locale},
              onSelectionChanged: (s) =>
                  ref.read(localeProvider.notifier).state = s.first,
            ),
          ),
          const AboutListTile(
            applicationName: 'GraceEdit',
            applicationVersion: '0.1.0 (fondation)',
            applicationLegalese: '© 2026 GraceEdit',
          ),
        ],
      ),
    );
  }
}
