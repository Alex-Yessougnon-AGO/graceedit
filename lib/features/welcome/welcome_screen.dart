import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/app_providers.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/grace_ui.dart';

/// Écran ENT-02 Bienvenue (premier lancement).
/// Écran unique qui présente l'application, ses trois garanties,
/// puis deux actions : « Monter une vidéo » et « Explorer d'abord ».
/// N'apparaît qu'une seule fois (indicateur local).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final Color background = isLight ? Color(0xFFEDE7DB) : Color(0xFF1D1F25);
    final Color glyphColor = isLight ? Color(0xFF14151A) : Color(0xFF6F6C64);
    final Color textPrimary = isLight ? Color(0xFF14151A) : Color(0xFFF6F2EA);
    final Color textSecondary = isLight ? Color(0xFF5E5C58) : Color(0xFFB9B5AD);
    final Color surfaceLight = Color(0xFFE4DED2);
    final Color surfaceDark = Color(0xFF2A2C33);
    final Color accent = Color(0xFFE2542B);

    final l10n = AppLocalizations.of(context)!;

    // Marquer comme vu d'ici (au moins l'affichage a commencé).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bootstrapProvider).valueOrNull?.copyWith(welcomeSeen: true);
    });

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
              maxWidth: 480,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- En-tête : symbole + logotype alignés à gauche ---
                _Header(accentColor: accentColor, glyphColor: glyphColor),

                const SizedBox(height: 56 - 24), // 56dp du haut - marge 24dp

                // --- Titre ---
                Text(
                  l10n.welcomeTitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    height: 40 / 34,
                    color: textPrimary,
                  ),
                  textAlign: TextAlignment.start,
                ),

                const SizedBox(height: 16),

                // --- Texte descriptif ---
                Text(
                  l10n.welcomeSubtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    height: 24 / 16,
                    color: textSecondary,
                  ),
                  textAlign: TextAlignment.start,
                ),

                const SizedBox(height: 32),

                // --- Bande décorative (4 blocs arrondis) ---
                _DecorativeBands(accentColor: accentColor),

                const SizedBox(height: 32),

                // --- Garanties ---
                _Guarantees(accentColor: accentColor, isLight: isLight),

                const SizedBox(height: 48),

                // --- Actions ---
                _Actions(ref: ref, isLight: isLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// En-tête : symbole + logotype alignés à gauche.
/// Symbole 36 dp, marge 24 dp, à 56 dp du haut.
class _Header extends StatelessWidget {
  final Color accentColor;
  final Color glyphColor;

  const _Header({
    required this.accentColor,
    required this.glyphColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GraceMark(
          size: 36,
          // La couleur est gérée par le widget GraceMark via context.grace
        ),
        const SizedBox(width: 12),
        const Text(
          'GraceEdit',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 34,
            fontWeight: FontWeight.w600,
            height: 40 / 34,
          ),
        ),
      ],
    );
  }
}

/// Bande décorative : 4 blocs arrondis dont un en accent.
class _DecorativeBands extends StatelessWidget {
  final Color accentColor;

  const _DecorativeBands({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final Color surface = isLight ? Color(0xFFE4DED2) : Color(0xFF2A2C33);

    return Row(
      children: [
        _Band(color: surface, accent: false, accentColor: accentColor),
        _Band(color: surface, accent: true, accentColor: accentColor),
        _Band(color: surface, accent: false, accentColor: accentColor),
        _Band(color: surface, accent: true, accentColor: accentColor),
      ],
    );
  }
}

/// Bloc arrondi décoratif.
class _Band extends StatelessWidget {
  final Color color;
  final bool accent;
  final Color accentColor;

  const _Band({required this.color, required this.accent, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final actualAccent = accent ? accentColor : Colors.transparent;
    return Container(
      width: 64,
      height: 56,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: actualAccent == Colors.transparent ? color : null,
        border: actualAccent != Colors.transparent
            ? Border.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
                bottomLeft: const Radius.circular(10),
                bottomRight: const Radius.circular(10),
              )
            : null,
      ),
    );
  }
}

/// Garanties : trois lignes avec puces.
class _Guarantees extends StatelessWidget {
  final Color accentColor;
  final bool isLight;

  const _Guarantees({required this.accentColor, required this.isLight});

  @override
  Widget build(BuildContext context) {
    final Color textColor = isLight ? Color(0xFF14151A) : Color(0xFFF6F2EA);
    final Color dotColor = isLight ? Color(0xFF14151A) : Color(0xFFF6F2EA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GuaranteeLine(
          icon: Icons.person_off,
          text: 'Aucun compte nécessaire',
          color: textColor,
        ),
        _GuaranteeLine(
          icon: Icons.offline_bolt,
          text: 'Fonctionne sans connexion',
          color: textColor,
        ),
        _GuaranteeLine(
          icon: Icons.lock_outline,
          text: 'Vos fichiers restent sur votre téléphone',
          color: textColor,
        ),
      ],
    );
  }
}

/// Une ligne de garantie avec icône et texte.
class _GuaranteeLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _GuaranteeLine({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}

/// Actions : « Monter une vidéo » (plein) et « Explorer d'abord » (texte).
class _Actions extends ConsumerWidget {
  final WidgetRef ref;
  final bool isLight;

  const _Actions({required this.ref, required this.isLight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color textPrimary = isLight ? Color(0xFF14151A) : Color(0xFFF6F2EA);
    final Color textSecondary = isLight ? Color(0xFF5E5C58) : Color(0xFFB9B5AD);
    final Color btnBgLight = Color(0xFF14151A);
    final Color btnBgDark = Color(0xFFF6F2EA);

    final Color btnBg = isLight ? btnBgLight : btnBgDark;
    final Color btnText = isLight ? textSecondary : textPrimary;
    final Color secBtnColor = isLight ? textSecondary : textPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton principal : « Monter une vidéo »
        ElevatedButton(
          onPressed: () {
            context.go('/import/new');
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: btnBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: Text(
            'Monter une vidéo',
            style: TextStyle(
              color: btnText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Bouton secondaire : « Explorer d'abord »
        OutlinedButton(
          onPressed: () {
            context.go('/home');
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            foregroundColor: textSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: Text(
            'Explorer d\'abord',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}