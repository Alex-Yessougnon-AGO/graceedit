import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Barre de message temporaire : 48 dp, couleurs inversées, une à la fois.
abstract final class GraceToast {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    bool isError = false,
    Duration duration = GraceMotion.toast,
    double bottomOffset = 16,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    _timer?.cancel();
    _entry?.remove();
    _entry = null;

    final p = context.grace;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        left: 16,
        right: 16,
        bottom: MediaQuery.viewPaddingOf(overlayContext).bottom + bottomOffset,
        child: Semantics(
          liveRegion: true,
          container: true,
          child: Material(
            color: p.text,
            borderRadius: BorderRadius.circular(GraceRadius.thumb),
            child: Container(
              constraints: const BoxConstraints(minHeight: GraceDims.toast),
              padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
              child: Row(
                children: [
                  if (isError) ...[
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: p.background,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      message,
                      style: GraceType.secondary.copyWith(color: p.background),
                    ),
                  ),
                  if (actionLabel != null)
                    TextButton(
                      onPressed: () {
                        _remove();
                        onAction?.call();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: p.background,
                        minimumSize: const Size(48, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Text(
                        actionLabel,
                        style: GraceType.secondary.copyWith(
                          color: p.background,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(duration, _remove);
  }

  static void _remove() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }

  static void hide() => _remove();
}
