import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'buttons.dart';

class GraceHandle extends StatelessWidget {
  const GraceHandle({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      decoration: BoxDecoration(
        color: context.grace.outline,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

/// Feuille modale commune. Les feuilles de réglages utilisent la couleur de
/// barre de navigation ; les panneaux d'outils de l'éditeur le fond d'écran.
Future<T?> showGraceSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool editorPanel = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: editorPanel ? context.grace.background : context.grace.nav,
    // Panneaux de l'éditeur : barrière transparente pour que l'aperçu
    // reste pleinement visible pendant les réglages (temps réel), au lieu
    // d'être assombri par le voile modal.
    barrierColor: editorPanel ? Colors.transparent : GraceColors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(GraceRadius.sheet),
      ),
    ),
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GraceHandle(),
            Flexible(child: builder(sheetContext)),
          ],
        ),
      ),
    ),
  );
}

enum GraceChoice { primary, outline, destructive, text }

class GraceDialogAction {
  const GraceDialogAction({
    required this.label,
    required this.onPressed,
    this.style = GraceChoice.primary,
    this.icon,
  });
  final String label;
  final VoidCallback onPressed;
  final GraceChoice style;
  final IconData? icon;
}

class GraceDialog extends StatelessWidget {
  const GraceDialog({
    super.key,
    required this.title,
    required this.body,
    required this.actions,
    this.icon,
    this.width = GraceDims.sheetWidth,
  });

  final String title;
  final String body;
  final List<GraceDialogAction> actions;
  final IconData? icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Material(
      color: p.background,
      borderRadius: BorderRadius.circular(GraceRadius.sheet),
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 28, color: p.error),
              const SizedBox(height: 16),
            ],
            Semantics(
              header: true,
              child: Text(title, style: GraceType.sheetTitle),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: GraceType.bodyCompact.copyWith(color: p.secondary),
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _action(context, actions[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _action(BuildContext context, GraceDialogAction action) {
    final p = context.grace;
    switch (action.style) {
      case GraceChoice.primary:
        return GracePrimaryButton(
          label: action.label,
          icon: action.icon,
          height: GraceDims.dialogButton,
          onPressed: action.onPressed,
        );
      case GraceChoice.outline:
        return GraceOutlineButton(
          label: action.label,
          icon: action.icon,
          onPressed: action.onPressed,
        );
      case GraceChoice.destructive:
        return GraceOutlineButton(
          label: action.label,
          icon: action.icon,
          destructive: true,
          onPressed: action.onPressed,
        );
      case GraceChoice.text:
        return SizedBox(
          width: double.infinity,
          child: GraceTextAction(
            label: action.label,
            color: action.label == action.label ? p.text : null,
            onPressed: action.onPressed,
          ),
        );
    }
  }
}

Future<T?> showGraceDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: GraceColors.scrim,
    transitionDuration: GraceMotion.fade,
    pageBuilder: (dialogContext, _, _) => SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: builder(dialogContext),
        ),
      ),
    ),
    transitionBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

class GraceChoiceOption<T> {
  const GraceChoiceOption({
    required this.value,
    required this.label,
    this.description,
  });
  final T value;
  final String label;
  final String? description;
}

/// Feuille de choix unique, avec bouton radio et fermeture immédiate.
Future<T?> showGraceChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required List<GraceChoiceOption<T>> options,
  required T current,
}) {
  return showGraceSheet<T>(
    context: context,
    builder: (sheetContext) =>
        _ChoiceList<T>(title: title, options: options, current: current),
  );
}

class _ChoiceList<T> extends StatelessWidget {
  const _ChoiceList({
    required this.title,
    required this.options,
    required this.current,
  });

  final String title;
  final List<GraceChoiceOption<T>> options;
  final T current;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: GraceType.sheetTitle),
          ),
          const SizedBox(height: 12),
          for (final option in options)
            Semantics(
              selected: option.value == current,
              button: true,
              label: option.label,
              excludeSemantics: true,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(option.value),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Row(
                    children: [
                      RadioDot(selected: option.value == current),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(option.label, style: GraceType.body),
                            if (option.description != null)
                              Text(
                                option.description!,
                                style: GraceType.secondary.copyWith(
                                  color: p.secondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RadioDot extends StatelessWidget {
  const RadioDot({super.key, required this.selected, this.size = 22});

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: p.text, width: 2),
      ),
      child: selected
          ? Center(
              child: Container(
                width: size * 0.48,
                height: size * 0.48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.text,
                ),
              ),
            )
          : null,
    );
  }
}

class GraceSwitch extends StatelessWidget {
  const GraceSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      toggled: value,
      child: ExcludeSemantics(
        child: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
