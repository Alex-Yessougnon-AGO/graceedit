import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/buttons.dart';
import '../../core/ui/messages.dart';
import '../../core/ui/sheets.dart';

const String kAppVersion = '1.0.0 (2)';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            _TopBar(title: l10n.helpTitle),
            _Section(l10n.helpTitle),
            _HelpRow(
              label: l10n.helpReplay,
              onTap: () => context.push('/welcome'),
            ),
            _HelpRow(label: l10n.helpFaq, onTap: () => _showFaq(context, l10n)),
            _HelpRow(
              label: l10n.helpDiagnostic,
              subtitle: l10n.helpDiagnosticBody,
              onTap: () => context.push('/settings/help/diagnostic'),
            ),
            _Section(l10n.helpAbout),
            _HelpRow(
              label: l10n.helpVersion,
              value: kAppVersion,
              onTap: () async {
                await Clipboard.setData(const ClipboardData(text: kAppVersion));
                if (context.mounted) {
                  GraceToast.show(context, l10n.helpDiagnosticCopied);
                }
              },
            ),
            _HelpRow(
              label: l10n.helpLicenses,
              onTap: () =>
                  _showText(context, l10n.helpLicenses, l10n.helpLicensesBody),
            ),
            _HelpRow(
              label: l10n.helpTerms,
              onTap: () =>
                  _showText(context, l10n.helpTerms, l10n.helpTermsBody),
            ),
            _HelpRow(
              label: l10n.helpPrivacy,
              onTap: () =>
                  _showText(context, l10n.helpPrivacy, l10n.helpPrivacyBody),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFaq(BuildContext context, AppLocalizations l10n) {
    final items = [
      (l10n.helpFaqQ1, l10n.helpFaqA1),
      (l10n.helpFaqQ2, l10n.helpFaqA2),
      (l10n.helpFaqQ3, l10n.helpFaqA3),
      (l10n.helpFaqQ4, l10n.helpFaqA4),
      (l10n.helpFaqQ5, l10n.helpFaqA5),
      (l10n.helpFaqQ6, l10n.helpFaqA6),
    ];
    return showGraceSheet<void>(
      context: context,
      builder: (sheetContext) => Flexible(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.helpFaq, style: GraceType.sheetTitle),
              const SizedBox(height: 8),
              for (final item in items)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 12),
                  title: Text(item.$1, style: GraceType.bodyMedium),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.$2,
                        style: GraceType.bodyCompact.copyWith(
                          color: context.grace.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showText(BuildContext context, String title, String body) {
    return showGraceSheet<void>(
      context: context,
      builder: (sheetContext) => Flexible(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: GraceType.sheetTitle),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                style: GraceType.body.copyWith(color: context.grace.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          const SizedBox(width: 4),
          GraceIconAction(
            icon: Icons.arrow_back,
            semanticLabel: l10n.semanticsBack,
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: GraceType.screenTitle)),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Semantics(
        header: true,
        child: Text(
          label,
          style: GraceType.secondary.copyWith(
            color: context.grace.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.label, this.value, this.subtitle, this.onTap});
  final String label;
  final String? value;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Semantics(
      button: onTap != null,
      label: value == null ? label : '$label, $value',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.surface)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: GraceType.body.copyWith(
                        fontSize: 18,
                        height: 24 / 18,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: GraceType.secondary.copyWith(color: p.secondary),
                      ),
                  ],
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: GraceType.body.copyWith(
                    fontSize: 18,
                    color: p.secondary,
                  ),
                ),
              if (onTap != null) ...[
                const SizedBox(width: 6),
                Icon(Icons.chevron_right, size: 22, color: p.secondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
