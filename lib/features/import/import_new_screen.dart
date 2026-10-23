import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:graceedit/core/state/app_providers.dart';
import 'package:graceedit/core/l10n/generated/app_localizations.dart';
import 'package:graceedit/core/platform/native_gateway.dart';

/// Écran IMP-02 — Nouveau projet (préparation des médias).
/// Après la sélection dans le sélecteur du système, permettre à
/// l'utilisateur de vérifier, ordonner et nettoyer ses médias avant
/// d'ouvrir l'éditeur.
class ImportNewScreen extends ConsumerStatefulWidget {
  const ImportNewScreen({super.key});

  @override
  ConsumerState<ImportNewScreen> createState() => _ImportNewScreenState();
}

class _ImportNewScreenState extends ConsumerState<ImportNewScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<PickedMedia> _medias = [];
  final List<PickedMedia> _unsupported = [];
  bool _isPreparing = false;
  int _preparingPercent = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _nameController.text = 'Projet du ${now.day} ${_monthName(now.month)}';
  }

  String _monthName(int month) {
    const months = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
    ];
    return months[month - 1];
  }

  int get _usableCount => _medias.where((m) => m.supported).length;
  int get _totalDurationMs => _medias.fold<int>(0, (sum, m) => sum + m.durationMs);
  bool get _hasUnsupported => _unsupported.isNotEmpty;
  bool get _hasUsable => _usableCount > 0;

  String _formatDuration(int ms) {
    final seconds = ms ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatSize(int bytes) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} Mo';
  }

  void _removeMedia(PickedMedia media) {
    setState(() {
      _medias.remove(media);
      _unsupported.remove(media);
    });
  }

  Future<void> _addMedia() async {
    final navigator = Navigator.of(context);
    final gateway = ref.read(nativeGatewayProvider);
    try {
      final picked = await gateway.pickMultiple();
      setState(() {
        for (final m in picked) {
          if (m.supported) {
            _medias.add(m);
          } else {
            _unsupported.add(m);
          }
        }
      });
    } catch (e) {
      // Ignorer les erreurs de sélection
    }
  }

  void _startEditing() {
    if (!_hasUsable) return;
    // TODO: Créer le projet et naviguer vers l'éditeur
    // Pour l'instant, naviguer vers /editor/:projectId
    context.go('/editor/new');
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final Color background = isLight ? Color(0xFFEDE7DB) : Color(0xFF1D1F25);
    final Color textPrimary = isLight ? Color(0xFF14151A) : Color(0xFFF6F2EA);
    final Color textSecondary = isLight ? Color(0xFF5E5C58) : Color(0xFFB9B5AD);
    final Color surface = isLight ? Color(0xFFE4DED2) : Color(0xFF2A2C33);
    final Color accent = Color(0xFFE2542B);
    final Color errorColor = isLight ? Color(0xFFB3261E) : Color(0xFF2B8C45);
    final Color placeholderColor = isLight ? Color(0xFF9A968D) : Color(0xFF6B6D75);
    final Color borderColor = isLight ? Color(0xFF9A968D) : Color(0xFF6B6D75);
    final Color progressTrack = isLight ? Color(0xFFD9D2C3) : Color(0xFF3A3C45);

    final l10n = AppLocalizations.of(context)!;

    final totalUsable = _medias.where((m) => m.supported).length;
    final totalDuration = _totalDurationMs;
    final summary = _hasUnsupported
        ? '${_medias.length + _unsupported.length} sélectionnés · ${_unsupported.length} ignoré${_unsupported.length > 1 ? 's' : ''}'
        : '${_medias.length} vidéo${_medias.length > 1 ? 's' : ''} · durée totale ${_formatDuration(totalDuration)}';

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Nouveau projet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Nom du projet ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du projet',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                ),
                style: TextStyle(color: textPrimary),
              ),
            ),

            // --- Résumé ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                summary,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
            ),

            // --- Liste des médias ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _medias.length + _unsupported.length + 1,
                itemBuilder: (context, index) {
                  if (index == _medias.length + _unsupported.length) {
                    // Bouton "Ajouter des médias"
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: OutlinedButton.icon(
                        onPressed: _addMedia,
                        icon: const Icon(Icons.add, size: 24),
                        label: const Text('Ajouter des médias'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    );
                  }

                  final media = index < _medias.length
                      ? _medias[index]
                      : _unsupported[index - _medias.length];

                  return _MediaRow(
                    media: media,
                    isLight: isLight,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    surface: surface,
                    errorColor: errorColor,
                    placeholderColor: placeholderColor,
                    progressTrack: progressTrack,
                    onRemove: () => _removeMedia(media),
                  );
                },
              ),
            ),

            // --- Légende ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                _hasUnsupported
                    ? 'Le média non pris en charge sera ignoré.'
                    : (_hasUsable
                        ? 'Vos fichiers d\'origine ne sont jamais modifiés.'
                        : 'Aucun de ces médias ne peut être utilisé. Ajoutez-en d\'autres pour continuer.'),
                style: TextStyle(
                  fontSize: 14,
                  color: _hasUnsupported ? textSecondary : textSecondary,
                ),
              ),
            ),

            // --- Bouton principal ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _hasUsable ? _startEditing : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: isLight ? Color(0xFF14151A) : Color(0xFFF6F2EA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text(
                  _hasUnsupported
                      ? 'Commencer avec $_usableCount média${_usableCount > 1 ? 's' : ''}'
                      : 'Commencer le montage',
                  style: TextStyle(
                    color: isLight ? Color(0xFF5E5C58) : Color(0xFFF6F2EA),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ligne de média dans la liste (72 dp de hauteur).
class _MediaRow extends StatelessWidget {
  final PickedMedia media;
  final bool isLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color errorColor;
  final Color placeholderColor;
  final Color progressTrack;
  final VoidCallback onRemove;

  const _MediaRow({
    required this.media,
    required this.isLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.errorColor,
    required this.placeholderColor,
    required this.progressTrack,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isSupported = media.supported;

    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // --- Poignée de glisser ---
          SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              Icons.drag_handle,
              color: isLight ? Color(0xFF9A968D) : Color(0xFF6B6D75),
            ),
          ),

          // --- Miniature 96 × 54 dp ---
          Container(
            width: 96,
            height: 54,
            color: surface,
            child: isSupported
                ? Stack(
                    children: [
                      // Placeholder pour la miniature
                      Center(
                        child: Text(
                          'Miniature',
                          style: TextStyle(
                            fontSize: 10,
                            color: textSecondary,
                          ),
                        ),
                      ),
                      // Badge de durée
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatDuration(media.durationMs),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Icon(
                    Icons.warning_amber_rounded,
                    color: errorColor,
                    size: 24,
                  ),
          ),

          const SizedBox(width: 12),

          // --- Titre + durée + poids ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  media.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isSupported
                      ? '${_formatDuration(media.durationMs)} · ${_formatSize(media.sizeBytes)}'
                      : 'Format non pris en charge',
                  style: TextStyle(
                    fontSize: 14,
                    color: isSupported ? textSecondary : errorColor,
                  ),
                ),
              ],
            ),
          ),

          // --- Bouton retirer ---
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: const Icon(Icons.close, size: 24),
              onPressed: onRemove,
              tooltip: 'Retirer du projet',
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int ms) {
    final seconds = ms ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatSize(int bytes) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} Mo';
  }
}