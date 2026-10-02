/// Reusable thumbnail widget with loading / error / cached states.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/thumbnails.dart';
import '../../theme/tokens.dart';

final thumbnailServiceProvider =
    Provider<ThumbnailService>((ref) => ThumbnailService());

class GraceThumb extends ConsumerWidget {
  const GraceThumb({
    super.key,
    required this.assetId,
    required this.sourcePath,
    required this.kind,
    this.frameMs,
    this.width = 110,
    this.height = 72,
    this.borderRadius = 8,
  });
  final String assetId;
  final String sourcePath;
  final String kind; // 'video' | 'image'
  final int? frameMs;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = context.grace;
    if (kind == 'image') {
      final f = File(sourcePath);
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          f, width: width, height: height, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(g),
        ),
      );
    }
    final svc = ref.watch(thumbnailServiceProvider);
    return FutureBuilder<File?>(
      future: svc.thumbnailFor(ThumbnailRequest(
        assetId: assetId, sourcePath: sourcePath, sourceVersion: 1,
        maxWidth: 320, frameMs: frameMs,
      )),
      builder: (c, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: width, height: height,
            child: Center(
              child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: g.textSecondary)),
            ),
          );
        }
        final file = snap.data;
        if (file == null) return _fallback(g);
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.file(file,
              width: width, height: height, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(g)),
        );
      },
    );
  }

  Widget _fallback(GraceColors g) => Container(
        width: width, height: height,
        decoration: BoxDecoration(
          color: g.elevated,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(Icons.movie_outlined, color: g.textSecondary),
      );
}
