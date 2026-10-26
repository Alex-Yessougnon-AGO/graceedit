import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

enum GraceTab { home, projects, settings }

class GraceNavBar extends StatelessWidget {
  const GraceNavBar({super.key, required this.current, required this.onSelect});

  final GraceTab current;
  final ValueChanged<GraceTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    final l10n = AppLocalizations.of(context);
    return Material(
      color: p.nav,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: GraceDims.navBar,
          child: Row(
            children: [
              _NavItem(
                label: l10n.navHome,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                selected: current == GraceTab.home,
                onTap: () => onSelect(GraceTab.home),
              ),
              _NavItem(
                label: l10n.navProjects,
                icon: Icons.grid_view_rounded,
                selectedIcon: Icons.grid_view_rounded,
                selected: current == GraceTab.projects,
                onTap: () => onSelect(GraceTab.projects),
                filled: true,
              ),
              _NavItem(
                label: l10n.navSettings,
                icon: Icons.tune,
                selectedIcon: Icons.tune,
                selected: current == GraceTab.settings,
                onTap: () => onSelect(GraceTab.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? p.active : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  size: GraceDims.icon,
                  color: selected ? p.text : p.secondary,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GraceType.small.copyWith(
                    color: selected ? p.text : p.secondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
