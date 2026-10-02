/// Permissions screen: explains WHY before requesting, handles denial
/// with a settings shortcut. Skippable — guest mode stays available.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/permissions.dart';
import '../../core/state/providers.dart';
import '../../theme/tokens.dart';

final permissionServiceProvider =
    Provider<PermissionService>((ref) => PermissionService());

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});
  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  PermissionState? _state;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final s = await ref.read(permissionServiceProvider).currentState();
    if (mounted) setState(() { _state = s; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final g = context.grace;
    final svc = ref.watch(permissionServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Autorisations')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(GraceSpacing.l),
              children: [
                Text(
                  'GraceEdit a besoin d’accéder à vos médias pour monter vos vidéos. Rien n’est envoyé en ligne.',
                  style: TextStyle(color: g.textSecondary, fontSize: 15),
                ),
                const SizedBox(height: GraceSpacing.l),
                _Row(
                  icon: Icons.photo_library_outlined,
                  title: 'Photos et vidéos',
                  granted: _state!.mediaLibrary,
                  onGrant: () async {
                    await svc.requestMediaLibrary();
                    _refresh();
                  },
                ),
                _Row(
                  icon: Icons.videocam_outlined,
                  title: 'Caméra',
                  granted: _state!.camera,
                  onGrant: () async {
                    await svc.requestCamera();
                    _refresh();
                  },
                ),
                _Row(
                  icon: Icons.mic_outlined,
                  title: 'Microphone',
                  granted: _state!.microphone,
                  onGrant: () async {
                    await svc.requestMicrophone();
                    _refresh();
                  },
                ),
                const SizedBox(height: GraceSpacing.s),
                TextButton(
                  onPressed: () => svc.openSettings(),
                  child: const Text('Ouvrir les réglages système'),
                ),
                const SizedBox(height: GraceSpacing.l),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.go('/'),
                    child: Text(_state!.canImport
                        ? 'Continuer'
                        : 'Continuer en mode invité'),
                  ),
                ),
                if (!_state!.canImport)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      strings.errorGeneric,
                      style: TextStyle(color: g.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(
      {required this.icon, required this.title, required this.granted, required this.onGrant});
  final IconData icon;
  final String title;
  final bool granted;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, semanticLabel: title),
        title: Text(title),
        trailing: granted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : OutlinedButton(onPressed: onGrant, child: const Text('Autoriser')),
      ),
    );
  }
}
