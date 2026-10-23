library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/l10n/strings.dart';
import '../../core/state/providers.dart';
import '../../theme/tokens.dart';
import '../nav/grace_nav.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final theme = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final g = context.grace;
    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      bottomNavigationBar: const GraceNav(index: 3),
      body: ListView(
        children: [
          ListTile(
            title: Text(strings.themeMode),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_outlined),
                    tooltip: 'Clair'),
                ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.settings_suggest_outlined),
                    tooltip: 'Auto'),
                ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_outlined),
                    tooltip: 'Sombre'),
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
          const Divider(),
          const ListTile(
            leading: Icon(Icons.phone_android_outlined),
            title: Text('Tout reste sur votre téléphone'),
            subtitle: Text('Aucun compte, aucun envoi sur Internet. '
                'Vos vidéos sont enregistrées dans l’application.'),
          ),
          const _StorageTile(),
          const Divider(),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'GraceEdit',
            applicationVersion: '1.0.0',
            applicationLegalese: '© 2026 GraceEdit',
            child: Text('À propos de GraceEdit'),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('GraceEdit — monter une vidéo simplement',
                style: TextStyle(color: g.textSecondary, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

/// Real numbers, read from the three folders the app actually uses — never a
/// decorative placeholder.
class _StorageTile extends StatefulWidget {
  const _StorageTile();
  @override
  State<_StorageTile> createState() => _StorageTileState();
}

class _StorageTileState extends State<_StorageTile> {
  String _label = 'Calcul…';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var total = 0;
    var exports = 0;
    try {
      final docs = await getApplicationDocumentsDirectory();
      for (final name in ['graceedit_media', 'graceedit_exports']) {
        final dir = Directory('${docs.path}/$name');
        if (!await dir.exists()) continue;
        await for (final f in dir.list()) {
          if (f is File) {
            total += await f.length();
            if (name == 'graceedit_exports' && f.path.endsWith('.mp4')) {
              exports++;
            }
          }
        }
      }
    } catch (_) {
      // Never block settings on a storage read.
    }
    if (!mounted) return;
    final mb = total / (1024 * 1024);
    setState(() {
      _label = '${mb < 1 ? mb.toStringAsFixed(2) : mb.toStringAsFixed(1).replaceAll('.', ',')} Mo · '
          '$exports vidéo${exports > 1 ? 's' : ''} exportée${exports > 1 ? 's' : ''}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.sd_storage_outlined),
      title: const Text('Espace utilisé'),
      subtitle: Text(_label),
    );
  }
}
