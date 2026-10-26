import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/state/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/brand.dart';
import '../../core/ui/buttons.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.grace;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const GraceBrand(markSize: 36, textSize: 15),
                        const SizedBox(height: 64),
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.welcomeTitle,
                            style: GraceType.display,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.welcomeBody,
                          style: GraceType.body.copyWith(color: p.secondary),
                        ),
                        const SizedBox(height: 40),
                        const _Bands(),
                        const SizedBox(height: 32),
                        _Guarantee(text: l10n.welcomeGuaranteeNoAccount),
                        _Guarantee(text: l10n.welcomeGuaranteeOffline),
                        _Guarantee(text: l10n.welcomeGuaranteeLocal),
                        const Spacer(),
                        const SizedBox(height: 32),
                        GracePrimaryButton(
                          label: l10n.welcomeStart,
                          onPressed: () async {
                            final store = ref.read(storeProvider);
                            await store.setWelcomeSeen();
                            if (context.mounted) context.go('/home');
                          },
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: GraceTextAction(
                            label: l10n.welcomeExplore,
                            onPressed: () async {
                              final store = ref.read(storeProvider);
                              await store.setWelcomeSeen();
                              if (context.mounted) context.go('/home');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bands extends StatelessWidget {
  const _Bands();

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return ExcludeSemantics(
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Expanded(flex: 50, child: _Block(color: p.surface)),
            const SizedBox(width: 8),
            Expanded(flex: 35, child: _Block(color: GraceColors.accent)),
            const SizedBox(width: 8),
            Expanded(flex: 30, child: _Block(color: p.surface)),
            const SizedBox(width: 8),
            Expanded(flex: 25, child: _Block(color: p.surface)),
          ],
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

class _Guarantee extends StatelessWidget {
  const _Guarantee({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: p.text, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: GraceType.bodyCompact)),
        ],
      ),
    );
  }
}
