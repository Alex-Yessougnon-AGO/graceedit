import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/project.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../utils/formatters.dart';

class GraceThumb extends ConsumerWidget {
  const GraceThumb({
    super.key,
    this.media,
    this.imagePath,
    required this.width,
    required this.height,
    this.radius = GraceRadius.thumb,
    this.missing = false,
    this.durationMs,
    this.showDuration = true,
    this.timeMs = 0,
    this.fit = BoxFit.cover,
  });

  final MediaRef? media;
  final String? imagePath;
  final double width;
  final double height;
  final double radius;
  final bool missing;
  final int? durationMs;
  final bool showDuration;
  final int timeMs;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.grace;
    final path = imagePath;
    if (missing) {
      return _frame(
        context,
        ColoredBox(
          color: p.surface,
          child: Center(
            child: Icon(
              Icons.warning_amber_rounded,
              size: width < 80 ? 20 : 28,
              color: p.error,
            ),
          ),
        ),
      );
    }
    if (path != null) {
      return _frame(context, _file(path));
    }
    final m = media;
    if (m == null) {
      return _frame(context, _placeholder(context));
    }
    if (m.kind == MediaKind.image &&
        !m.uri.startsWith('content://') &&
        File(m.uri).existsSync()) {
      return _frame(context, _file(m.uri));
    }
    final service = ref.watch(thumbnailServiceProvider);
    return _frame(
      context,
      FutureBuilder<String?>(
        future: service.frame(m, timeMs, width: (width * 2).round()),
        builder: (context, snapshot) {
          final file = snapshot.data;
          if (file != null && File(file).existsSync()) {
            return _file(file);
          }
          return _placeholder(context);
        },
      ),
    );
  }

  Widget _frame(BuildContext context, Widget content) {
    final p = context.grace;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            content,
            if (missing) ...[
              Positioned(
                left: 4,
                right: 4,
                bottom: 4,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: p.background.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      AppLocalizations.of(context).homeMissingMedia,
                      style: GraceType.timecodeSmall.copyWith(
                        color: p.error,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ),
            ] else if (showDuration && durationMs != null)
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: GraceColors.ink.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    formatDuration(durationMs!),
                    style: GraceType.timecodeSmall.copyWith(
                      color: GraceColors.ivory,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _file(String path) => Image.file(
    File(path),
    fit: fit,
    gaplessPlayback: true,
    errorBuilder: (context, _, _) => _placeholder(context),
  );

  Widget _placeholder(BuildContext context) {
    final p = context.grace;
    return ColoredBox(
      color: p.surface,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          size: width < 80 ? 18 : 24,
          color: p.secondary,
        ),
      ),
    );
  }
}

/// Vignette de couverture : image de galerie ou première image de la vidéo.
class ProjectCover extends ConsumerWidget {
  const ProjectCover({
    super.key,
    required this.project,
    required this.width,
    required this.height,
    this.radius = GraceRadius.thumb,
    this.showDuration = true,
  });

  final Project project;
  final double width;
  final double height;
  final double radius;
  final bool showDuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missing = project.hasMissingMedia;
    final cover = project.coverFilePath;
    final media = project.firstVideo;
    return GraceThumb(
      width: width,
      height: height,
      radius: radius,
      missing: missing,
      media: cover == null ? media : null,
      imagePath: cover,
      durationMs: project.durationMs,
      showDuration: showDuration,
      timeMs: project.coverTimeMs,
    );
  }
}
