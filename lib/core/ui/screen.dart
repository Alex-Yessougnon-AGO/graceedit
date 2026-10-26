import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'brand.dart';
import 'buttons.dart';

enum BarLeading { back, close, none }

class GraceTopBar extends StatelessWidget {
  const GraceTopBar({
    super.key,
    this.title,
    this.subtitle,
    this.subtitleColor,
    this.subtitleIcon,
    this.leading = BarLeading.back,
    this.onLeading,
    this.trailing,
    this.brand = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final String? title;
  final String? subtitle;
  final Color? subtitleColor;
  final IconData? subtitleIcon;
  final BarLeading leading;
  final VoidCallback? onLeading;
  final Widget? trailing;
  final bool brand;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    final l10n = AppLocalizations.of(context);
    return Container(
      height: GraceDims.topBar,
      padding: padding,
      color: p.background,
      child: Row(
        children: [
          if (brand)
            const GraceBrand()
          else ...[
            if (leading != BarLeading.none)
              GraceIconAction(
                icon: leading == BarLeading.close
                    ? Icons.close
                    : Icons.arrow_back,
                semanticLabel: leading == BarLeading.close
                    ? l10n.semanticsClose
                    : l10n.semanticsBack,
                onPressed: onLeading ?? () => Navigator.of(context).maybePop(),
                size: 22,
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GraceType.barTitle,
                    ),
                  if (subtitle != null)
                    Row(
                      children: [
                        if (subtitleIcon != null) ...[
                          Icon(
                            subtitleIcon,
                            size: 13,
                            color: subtitleColor ?? p.secondary,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GraceType.small.copyWith(
                              color: subtitleColor ?? p.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
          if (brand) const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

class GraceScreen extends StatelessWidget {
  const GraceScreen({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.safeTop = true,
    this.safeBottom = false,
  });

  final Widget child;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool safeTop;
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? context.grace.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(top: safeTop, bottom: safeBottom, child: child),
    );
  }
}

class GraceSectionTitle extends StatelessWidget {
  const GraceSectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: GraceType.barTitle),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class GraceInfoLine extends StatelessWidget {
  const GraceInfoLine({super.key, required this.text, this.icon, this.color});
  final String text;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: color ?? p.secondary),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            text,
            style: GraceType.bodyCompact.copyWith(color: color ?? p.secondary),
          ),
        ),
      ],
    );
  }
}
