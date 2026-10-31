import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Empêche le geste « retour » de fermer l'application.
///
/// Plusieurs écrans sont atteints par `go()`, qui remplace toute la pile : ils
/// se retrouvent seuls et le retour système quitte l'application au lieu de
/// revenir en arrière. Ce garde-fou dépile quand une page est disponible et
/// retombe sinon sur [fallback] (l'accueil par défaut).
///
/// Les feuilles et boîtes de dialogue s'empilent au-dessus : elles reçoivent le
/// retour avant ce garde-fou et se ferment normalement.
class GraceBackScope extends StatelessWidget {
  const GraceBackScope({
    super.key,
    required this.child,
    this.fallback = '/home',
    this.onBack,
  });

  final Widget child;
  final String fallback;

  /// Intercepte le retour avant la navigation. Retourner `true` quand le
  /// retour a été consommé (fermer une recherche ou une sélection) pour ne
  /// pas quitter l'écran.
  final bool Function()? onBack;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (onBack != null && onBack!()) return;
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
        } else {
          router.go(fallback);
        }
      },
      child: child,
    );
  }
}
