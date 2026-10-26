import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/state/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/brand.dart';
import '../../core/ui/buttons.dart';

/// ENT-01 — Splash : masque l'initialisation réelle et ouvre sur la marque.
///
/// Aucun délai artificiel : l'écran reste affiché le temps du bootstrap.
/// Le symbole fait 120 dp et il est centré exactement dans la fenêtre.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const double _markSize = 120;
  static const double _markInk = 96;
  static const double _messageGap = 24;

  late final AnimationController _controller;
  Timer? _slowTimer;
  bool _slow = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: GraceMotion.splashSlide,
    );
    final settings = ref.read(settingsProvider);
    if (settings.reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
    _slowTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _slow = true);
    });
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    final store = ref.read(storeProvider);
    if (!store.settings.welcomeSeen) {
      context.go('/welcome');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    final l10n = AppLocalizations.of(context);
    final boot = ref.watch(bootstrapProvider);
    boot.whenData((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goNext());
    });

    return Scaffold(
      backgroundColor: p.background,
      body: boot.hasError
          ? _SplashError(onRetry: () => ref.invalidate(bootstrapProvider))
          : LayoutBuilder(
              builder: (context, constraints) {
                // Le symbole est centré sur la fenêtre entière, barres système
                // comprises : c'est le centre exact des maquettes.
                final messageTop =
                    constraints.maxHeight / 2 + _markInk / 2 + _messageGap;
                return Stack(
                  children: [
                    Center(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) => GraceMark(
                          size: _markSize,
                          semanticLabel: l10n.splashLoadingSemantics,
                          accentProgress: Curves.easeOutCubic.transform(
                            _controller.value,
                          ),
                        ),
                      ),
                    ),
                    if (_slow)
                      Positioned(
                        top: messageTop,
                        left: 0,
                        right: 0,
                        child: Text(
                          l10n.splashPreparing,
                          textAlign: TextAlign.center,
                          style: GraceType.secondary.copyWith(
                            color: p.secondary,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

class _SplashError extends StatelessWidget {
  const _SplashError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GraceSpacing.xl),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GraceMark(size: 72),
                const SizedBox(height: GraceSpacing.xl),
                Text(
                  l10n.splashErrorTitle,
                  textAlign: TextAlign.center,
                  style: GraceType.subtitle,
                ),
                const SizedBox(height: GraceSpacing.sm),
                Text(
                  l10n.splashErrorBody,
                  textAlign: TextAlign.center,
                  style: GraceType.secondary.copyWith(color: p.secondary),
                ),
                const SizedBox(height: GraceSpacing.xl),
                GracePrimaryButton(
                  label: l10n.splashRetry,
                  onPressed: onRetry,
                  expanded: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
