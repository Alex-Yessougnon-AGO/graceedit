/// Splash: restores session, decides first route (onboarding vs home).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    context.go(done ? '/' : '/onboarding');
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
