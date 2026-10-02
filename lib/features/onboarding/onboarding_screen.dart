/// Onboarding 3 pages + choix des préférences (thème, langue, mode).
/// One question at a time, one primary action — beginner rule.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/state/providers.dart';
import '../../theme/tokens.dart';
import 'splash_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final g = context.grace;
    final pages = [_pageOne(g), _pageTwo(g), _pagePrefs(g)];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _page,
                onPageChanged: (i) => setState(() => _index = i),
                children: pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    width: _index == i ? 24 : 8, height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _index == i ? g.primary : g.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(GraceSpacing.l),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_index < 2
                      ? MaterialLocalizations.of(context).continueButtonLabel
                      : 'Commencer'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() async {
    if (_index < 2) {
      _page.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      await markOnboardingDone();
      if (mounted) context.go('/permissions');
    }
  }

  Widget _pageOne(GraceColors g) => _Page(
        icon: Icons.videocam_outlined,
        title: 'Créez sans savoir monter',
        body:
            'Importez une vidéo, coupez, ajoutez du texte,\npuis exportez. GraceEdit guide chaque étape.',
        colors: g,
      );

  Widget _pageTwo(GraceColors g) => _Page(
        icon: Icons.dashboard_customize_outlined,
        title: 'Du simple au Studio',
        body:
            'Commencez en mode simple. Le mode Studio\nrévèle la timeline multi-pistes quand vous êtes prêt.',
        colors: g,
      );

  Widget _pagePrefs(GraceColors g) {
    final theme = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return Padding(
      padding: const EdgeInsets.all(GraceSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tune_outlined, size: 56, color: g.primary),
          const SizedBox(height: GraceSpacing.l),
          Text('Vos préférences',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700, color: g.textPrimary)),
          const SizedBox(height: 4),
          Text('Modifiables à tout moment dans Paramètres.',
              style: TextStyle(color: g.textSecondary)),
          const SizedBox(height: GraceSpacing.l),
          const Text('Thème', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Clair')),
              ButtonSegment(value: ThemeMode.system, label: Text('Auto')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Sombre')),
            ],
            selected: {theme},
            onSelectionChanged: (s) =>
                ref.read(themeModeProvider.notifier).state = s.first,
          ),
          const SizedBox(height: GraceSpacing.m),
          const Text('Langue', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<AppLocale>(
            segments: const [
              ButtonSegment(value: AppLocale.fr, label: Text('Français')),
              ButtonSegment(value: AppLocale.en, label: Text('English')),
            ],
            selected: {locale},
            onSelectionChanged: (s) =>
                ref.read(localeProvider.notifier).state = s.first,
          ),
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page(
      {required this.icon, required this.title, required this.body, required this.colors});
  final IconData icon;
  final String title;
  final String body;
  final GraceColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GraceSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: colors.primary, semanticLabel: title),
          const SizedBox(height: GraceSpacing.l),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700, color: colors.textPrimary)),
          const SizedBox(height: GraceSpacing.s),
          Text(body,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: colors.textSecondary)),
        ],
      ),
    );
  }
}
