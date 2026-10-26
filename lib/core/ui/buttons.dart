import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

class GracePrimaryButton extends StatelessWidget {
  const GracePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = GraceDims.primaryButton,
    this.expanded = true,
    this.semanticHint,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool expanded;
  final String? semanticHint;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    final enabled = onPressed != null;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GraceType.bodyMedium.copyWith(
              color: enabled ? p.onButton : p.secondary,
            ),
          ),
        ),
      ],
    );
    final button = Semantics(
      button: true,
      enabled: enabled,
      hint: semanticHint,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: enabled ? p.button : p.surface,
        borderRadius: BorderRadius.circular(height / 2),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(height / 2),
          child: Container(
            // Hauteur minimale, jamais fixe : le libellé doit pouvoir
            // occuper deux lignes avec une police à 200 %.
            constraints: BoxConstraints(minWidth: 120, minHeight: height),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class GraceOutlineButton extends StatelessWidget {
  const GraceOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = GraceDims.outlineButton,
    this.expanded = true,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool expanded;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    final enabled = onPressed != null;
    final color = destructive ? p.error : (enabled ? p.text : p.secondary);
    final button = Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: enabled ? color : p.outline, width: 1.5),
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          child: Container(
            constraints: BoxConstraints(minHeight: height),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GraceType.bodyMedium.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class GraceTextAction extends StatelessWidget {
  const GraceTextAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.textAlign = TextAlign.center,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(GraceRadius.small),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: GraceDims.touch),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: color ?? (enabled ? p.text : p.outline),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: textAlign,
                    style: GraceType.bodyMedium.copyWith(
                      color: color ?? (enabled ? p.text : p.secondary),
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

class GraceIconAction extends StatelessWidget {
  const GraceIconAction({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.size = GraceDims.icon,
    this.color,
    this.selected = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Semantics(
      button: true,
      label: semanticLabel,
      selected: selected,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: GraceDims.touch,
          height: GraceDims.touch,
          child: Icon(
            icon,
            size: size,
            color: color ?? (onPressed == null ? p.outline : p.text),
          ),
        ),
      ),
    );
  }
}

/// Bouton compact de barre supérieure (par exemple « Exporter »).
class GracePillAction extends StatelessWidget {
  const GracePillAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 40,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: GraceDims.touch),
          child: Container(
            constraints: BoxConstraints(minWidth: 88, minHeight: height),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: enabled ? p.button : p.surface,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: Text(
              label,
              style: GraceType.secondaryMedium.copyWith(
                color: enabled ? p.onButton : p.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GraceExtendedFab extends StatelessWidget {
  const GraceExtendedFab({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: p.button,
        borderRadius: BorderRadius.circular(GraceDims.primaryButton / 2),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(GraceDims.primaryButton / 2),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: GraceDims.primaryButton,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: p.onButton),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    style: GraceType.bodyMedium.copyWith(color: p.onButton),
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
