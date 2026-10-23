/// Splash: restores session, decides first route (onboarding vs home).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/grace_project.dart';
import '../../core/state/providers.dart';

const String _kOnboardingDone = 'graceedit.onboardingDone.v1';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    bool done = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      done = prefs.getBool(_kOnboardingDone) ?? false;
    } catch (_) {
      done = false;
    }
    if (!mounted) return;
    if (!done) {
      context.go('/onboarding');
      return;
    }
    // Crash recovery: resume the most recently touched project that
    // still carries a recovery marker instead of silently dropping it.
    try {
      final repo = ref.read(projectRepositoryProvider);
      GraceProject? recovery;
      for (final p in await repo.listAll()) {
        if (await repo.hasRecoveryMarker(p.id)) {
          recovery = p;
          break;
        }
      }
      if (!mounted) return;
      if (recovery != null) {
        final resume = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (c) => AlertDialog(
            title: const Text('Reprendre le montage ?'),
            content: Text(
                '« ${recovery!.name} » n’a pas été fermé proprement. Voulez-vous reprendre où vous en étiez ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Ignorer'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Reprendre'),
              ),
            ],
          ),
        );
        if (!mounted) return;
        if (resume == true) {
          ref.read(editorSessionProvider.notifier).state =
              EditorSession(recovery);
          await ref.read(projectsProvider.notifier).refresh();
          if (!mounted) return;
          context.go('/editor/${recovery.id}');
          return;
        }
      }
    } catch (_) {
      // Fall through to home on any storage error.
    }
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_filter_outlined, size: 64),
            SizedBox(height: 12),
            Text('GraceEdit',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            SizedBox(height: 16),
            SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ),
    );
  }
}

Future<void> markOnboardingDone() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDone, true);
  } catch (_) {}
}
