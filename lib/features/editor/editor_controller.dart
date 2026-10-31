import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/project.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/tokens.dart';

const _uuid = Uuid();

/// États de sauvegarde (SYS-02) : `recovered` suit un échec réparé et
/// permet d'annoncer « Projet enregistré » une seule fois.
enum SaveState { saved, saving, failed, recovered }

enum SelectionType { none, clip, text, audio }

enum EditorPanel {
  none,
  audioMix,
  audioVolume,
  adjust,
  format,
  textStyle,
  trim,
}

class EditorController extends ChangeNotifier {
  EditorController({
    required this.store,
    required this._project,
    this.onProjectSaved,
  }) {
    _fitToProject();
    _session();
  }

  final AppStore store;
  final void Function(Project project)? onProjectSaved;

  Project _project;
  Project get project => _project;

  int _positionMs = 0;
  int get positionMs => _positionMs;

  double zoom = 1;
  bool isPlaying = false;
  SaveState saveState = SaveState.saved;
  bool readOnly = false;
  bool compareOriginal = false;
  SelectionType selection = SelectionType.none;
  String? selectedId;
  EditorPanel panel = EditorPanel.none;
  int textStyleTab = 2;

  final List<Project> _undo = [];
  final List<Project> _redo = [];
  Project? _gestureBase;
  Timer? _saveTimer;
  Timer? _playTimer;
  Stopwatch? _playClock;
  int _playBaseMs = 0;

  /// Vrai quand l'aperçu vidéo pilote la tête de lecture : l'horloge murale
  /// ne doit plus avancer seule, sinon elle dépasse la vidéo dès que le
  /// décodeur cale et finit par arrêter la lecture à sa place.
  bool _previewDriven = false;
  DateTime? _lastPreviewSyncAt;
  Timer? _retryTimer;
  int _retries = 0;

  /// Nouvelle tentative automatique toutes les 10 secondes, 6 fois au plus,
  /// puis à chaque modification (SYS-02).
  static const int maxAutoRetries = 6;
  static const Duration retryEvery = Duration(seconds: 10);
  bool _disposed = false;

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  int get durationMs => _project.durationMs;
  bool get isEmpty => _project.clips.isEmpty;

  Clip? get selectedClip {
    if (selection != SelectionType.clip) return null;
    for (final c in _project.clips) {
      if (c.id == selectedId) return c;
    }
    return null;
  }

  TextItem? get selectedText {
    if (selection != SelectionType.text) return null;
    for (final t in _project.texts) {
      if (t.id == selectedId) return t;
    }
    return null;
  }

  AudioItem? get selectedAudio {
    if (selection != SelectionType.audio) return null;
    for (final a in _project.audios) {
      if (a.id == selectedId) return a;
    }
    return null;
  }

  int clipStartMs(Clip clip) {
    var start = 0;
    for (final c in _project.clips) {
      if (c.id == clip.id) return start;
      start += c.durationMs;
    }
    return start;
  }

  Clip? clipAt(int position) {
    var start = 0;
    for (final c in _project.clips) {
      final end = start + c.durationMs;
      if (position >= start && position < end) return c;
      start = end;
    }
    return _project.clips.isEmpty ? null : _project.clips.last;
  }

  MediaRef? mediaFor(Clip? clip) {
    if (clip == null) return null;
    return _project.mediaById(clip.mediaId);
  }

  double localPositionInClip(Clip clip) {
    final local = _positionMs - clipStartMs(clip) + clip.trimStartMs;
    return local
        .clamp(clip.trimStartMs.toDouble(), clip.trimEndMs.toDouble())
        .toDouble();
  }

  static const double _maxZoom = 24;

  /// Ajuste le zoom d'ouverture pour que la timeline reste lisible même avec
  /// une vidéo courte. L'échelle de départ de la fiche (1,2 dp/s) reste le
  /// plancher : on ne dézoome pas en dessous.
  void _fitToProject() {
    final seconds = durationMs / 1000;
    if (seconds <= 0) return;
    // Largeur utile d'un téléphone de référence (360 dp), avec une marge.
    const usable = 306.0;
    final needed = usable / (seconds * GraceDims.timelinePxPerSec);
    zoom = needed.clamp(1.0, _maxZoom);
  }

  /// Agrandit la timeline pour qu'un élément ajouté fasse au moins [minDp]
  /// à l'écran (FLUX_V1 : « la timeline s'agrandit à l'ajout »).
  void ensureElementWidth(int durationMs, {double minDp = 64}) {
    if (durationMs <= 0) return;
    final needed = minDp / (durationMs / 1000 * GraceDims.timelinePxPerSec);
    if (needed > zoom) setZoom(needed);
  }

  void setZoom(double value) {
    zoom = value.clamp(0.8, _maxZoom);
    notifyListeners();
  }

  /// Facteur de zoom au début du pincement : `details.scale` est cumulatif,
  /// le multiplier à chaque image faisait exploser le zoom (EDT-01).
  double? _zoomBase;

  void beginPinch() => _zoomBase ??= zoom;

  void updatePinch(double scale) => setZoom((_zoomBase ?? zoom) * scale);

  void endPinch() => _zoomBase = null;

  void setCompareOriginal(bool value) {
    if (compareOriginal == value) return;
    compareOriginal = value;
    notifyListeners();
  }

  Future<void> _session() async {
    readOnly = store.projects.any(
      (p) => p.id == _project.id && p.lastExport != null,
    );
    try {
      await store.setSession(projectId: _project.id, clean: false);
    } catch (_) {
      // Future non attendue (constructeur) : un échec d'écriture de session
      // ne doit jamais remonter en erreur non gérée. La prochaine
      // sauvegarde du projet réécrira l'état complet.
      return;
    }
    // L'écran peut être fermé pendant l'écriture : ne pas notifier un
    // contrôleur libéré (cela lèverait une exception au retour).
    if (!_disposed) notifyListeners();
  }

  void setReadOnly(bool value) {
    readOnly = value;
    notifyListeners();
  }

  void togglePanel(EditorPanel value) {
    panel = panel == value ? EditorPanel.none : value;
    notifyListeners();
  }

  void closePanel() {
    panel = EditorPanel.none;
    notifyListeners();
  }

  void seek(int ms, {bool stop = true}) {
    _positionMs = ms.clamp(0, durationMs);
    _previewDriven = false;
    _lastPreviewSyncAt = null;
    if (stop && isPlaying) {
      isPlaying = false;
      _playTimer?.cancel();
      _playClock?.stop();
      _playClock = null;
    }
    notifyListeners();
  }

  void scrubBy(int deltaMs) => seek(_positionMs + deltaMs);

  void togglePlay() {
    if (isEmpty) return;
    if (isPlaying) {
      pause();
      return;
    }
    if (_positionMs >= durationMs) _positionMs = 0;
    isPlaying = true;
    _startPlayClock();
    notifyListeners();
  }

  /// Horloge de secours : elle avance au temps réel et sert tant que l'aperçu
  /// ne fournit pas de position (projet sans vidéo, image fixe, clip sans
  /// lecteur). Dès qu'une vidéo joue, [syncToPreview] la recale sur l'image.
  void _startPlayClock() {
    _playTimer?.cancel();
    _playClock = Stopwatch()..start();
    _playBaseMs = _positionMs;
    _previewDriven = false;
    _lastPreviewSyncAt = null;
    _playTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final clock = _playClock;
      if (clock == null) return;
      if (_previewDriven) {
        // La vidéo pilote : tant qu'elle annonce sa position, l'horloge
        // attend. Si les annonces cessent (clip image, lecteur fermé), on
        // repart du dernier point connu après 700 ms.
        final last = _lastPreviewSyncAt;
        if (last != null &&
            DateTime.now().difference(last) <
                const Duration(milliseconds: 700)) {
          return;
        }
        _previewDriven = false;
        _playBaseMs = _positionMs;
        _playClock?.stop();
        _playClock = Stopwatch()..start();
        return;
      }
      _positionMs = _playBaseMs + clock.elapsedMilliseconds;
      if (_positionMs >= durationMs) {
        _endPlayback();
        return;
      }
      notifyListeners();
    });
  }

  void _endPlayback() {
    _positionMs = 0;
    isPlaying = false;
    _playTimer?.cancel();
    _playClock?.stop();
    _playClock = null;
    _previewDriven = false;
    _lastPreviewSyncAt = null;
    notifyListeners();
  }

  /// Pendant la lecture, la vidéo est la référence de temps : l'aperçu annonce
  /// sa position réelle (toutes les 100 ms) et l'horloge s'aligne dessus.
  ///
  /// Sans cela, un appareil qui décode un peu plus lentement que le temps réel
  /// faisait dériver l'horloge, l'aperçu recalais la vidéo toutes les secondes,
  /// et chaque recalage relançait un chargement : saccades, loader clignotant
  /// et lecture qui « recommence » (constaté sur émulateur). Aucun recalage
  /// inverse n'existe plus : c'est la tête qui suit l'image, jamais l'inverse.
  void syncToPreview(int globalMs) {
    if (!isPlaying) return;
    final clamped = globalMs.clamp(0, durationMs);
    _lastPreviewSyncAt = DateTime.now();
    if (clamped >= durationMs) {
      _endPlayback();
      return;
    }
    _previewDriven = true;
    // En dessous de 90 ms, l'écart est celui du battement : inutile de
    // redémarrer le chronomètre et de reconstruire l'écran.
    if ((clamped - _positionMs).abs() < 90) return;
    _positionMs = clamped;
    _playBaseMs = clamped;
    _playClock?.stop();
    _playClock = Stopwatch()..start();
    notifyListeners();
  }

  void pause() {
    isPlaying = false;
    _playTimer?.cancel();
    _playClock?.stop();
    _playClock = null;
    _previewDriven = false;
    _lastPreviewSyncAt = null;
    notifyListeners();
  }

  void selectClip(String id) {
    if (isPlaying) pause();
    selection = SelectionType.clip;
    selectedId = id;
    notifyListeners();
  }

  /// Sélectionne le clip sous la tête de lecture.
  ///
  /// Les outils généraux (Ajuster, Format) s'appliquent à un clip : sans
  /// sélection, ils ne faisaient rien. On prend donc le clip visible à la
  /// position courante, comme le ferait un appui sur la timeline.
  Clip? selectClipAtPlayhead() {
    final clip = clipAt(_positionMs);
    if (clip == null) return null;
    selectClip(clip.id);
    return clip;
  }

  void selectText(String id) {
    selection = SelectionType.text;
    selectedId = id;
    notifyListeners();
  }

  void selectAudio(String id) {
    selection = SelectionType.audio;
    selectedId = id;
    notifyListeners();
  }

  void clearSelection() {
    selection = SelectionType.none;
    selectedId = null;
    notifyListeners();
  }

  void beginGesture() {
    _gestureBase ??= _project;
  }

  void endGesture() {
    if (_gestureBase == null) return;
    final before = _gestureBase!;
    _gestureBase = null;
    _undo.add(before);
    if (_undo.length > 30) _undo.removeAt(0);
    _redo.clear();
    _markModified();
  }

  /// Abandonne les modifications faites depuis [beginGesture] (fermeture
  /// d'un panneau par la croix). Aucune entrée d'annulation n'est ajoutée.
  void cancelGesture() {
    final before = _gestureBase;
    if (before == null) return;
    _gestureBase = null;
    _project = before;
    _positionMs = _positionMs.clamp(0, durationMs);
    _markModified();
  }

  void _apply(Project next, {bool undoable = true}) {
    if (undoable && _gestureBase == null) {
      _undo.add(_project);
      if (_undo.length > 30) _undo.removeAt(0);
      _redo.clear();
    }
    _project = next.copyWith(modifiedAt: DateTime.now());
    _positionMs = _positionMs.clamp(0, durationMs);
    _markModified();
  }

  void _markModified() {
    saveState = SaveState.saving;
    notifyListeners();
    _saveTimer?.cancel();
    _retryTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 450), _save);
  }

  Future<void> _save() async {
    final wasFailed = saveState == SaveState.failed;
    try {
      await store.saveProject(_project);
      _project = store.projectById(_project.id) ?? _project;
      saveState = wasFailed ? SaveState.recovered : SaveState.saved;
      _retries = 0;
      _retryTimer?.cancel();
      onProjectSaved?.call(_project);
    } catch (_) {
      saveState = SaveState.failed;
      _scheduleRetry();
    }
    if (!_disposed) notifyListeners();
  }

  void _scheduleRetry() {
    if (_disposed || _retries >= maxAutoRetries) return;
    _retryTimer?.cancel();
    _retryTimer = Timer(retryEvery, () {
      if (_disposed || saveState != SaveState.failed) return;
      _retries++;
      unawaited(retrySave());
    });
  }

  /// L'écran appelle ceci après avoir annoncé « Projet enregistré » pour
  /// revenir à l'état nominal.
  void consumeRecovered() {
    if (saveState != SaveState.recovered) return;
    saveState = SaveState.saved;
    notifyListeners();
  }

  Future<void> retrySave() async {
    if (_disposed) return;
    saveState = SaveState.saving;
    notifyListeners();
    await _save();
  }

  Future<void> flush() async {
    _saveTimer?.cancel();
    _retryTimer?.cancel();
    await _save();
  }

  /// Ferme proprement la session : sauvegarde, puis marque la sortie comme
  /// volontaire pour que l'accueil ne propose pas de « récupération ».
  Future<void> close() async {
    _saveTimer?.cancel();
    _retryTimer?.cancel();
    await _save();
    await store.setSession(projectId: null, clean: true);
  }

  void undo() {
    if (_undo.isEmpty) return;
    _redo.add(_project);
    _project = _undo.removeLast();
    selection = SelectionType.none;
    selectedId = null;
    _markModified();
  }

  void redo() {
    if (_redo.isEmpty) return;
    _undo.add(_project);
    _project = _redo.removeLast();
    selection = SelectionType.none;
    selectedId = null;
    _markModified();
  }

  bool splitSelectedClip() {
    final clip = selectedClip;
    if (clip == null) return false;
    final start = clipStartMs(clip);
    final offset = _positionMs - start;
    if (offset < 100 || offset > clip.durationMs - 100) return false;
    final cut = clip.trimStartMs + offset;
    final left = clip.copyWith(trimEndMs: cut);
    final right = clip.copyWith(id: _uuid.v4(), trimStartMs: cut);
    final index = _project.clips.indexWhere((c) => c.id == clip.id);
    final clips = [..._project.clips];
    clips[index] = left;
    clips.insert(index + 1, right);
    _apply(_project.copyWith(clips: clips));
    selection = SelectionType.clip;
    selectedId = left.id;
    notifyListeners();
    return true;
  }

  void trimClip(String clipId, {int? start, int? end}) {
    final clips = [..._project.clips];
    final index = clips.indexWhere((c) => c.id == clipId);
    if (index < 0) return;
    final clip = clips[index];
    final media = _project.mediaById(clip.mediaId);
    // Métadonnées absentes (durée inconnue) : on retombe sur la fin actuelle
    // pour ne jamais produire une borne inversée.
    final maxEnd = (media?.durationMs ?? 0) > 0
        ? media!.durationMs
        : clip.trimEndMs;
    var newStart = start ?? clip.trimStartMs;
    var newEnd = end ?? clip.trimEndMs;
    newEnd = newEnd.clamp(100, maxEnd);
    newStart = newStart.clamp(0, newEnd - 100);
    clips[index] = clip.copyWith(trimStartMs: newStart, trimEndMs: newEnd);
    _apply(_project.copyWith(clips: clips));
  }

  void removeClip(String id) {
    final clips = _project.clips.where((c) => c.id != id).toList();
    _apply(_project.copyWith(clips: clips));
    clearSelection();
  }

  void duplicateClip(String id) {
    final index = _project.clips.indexWhere((c) => c.id == id);
    if (index < 0) return;
    final copy = _project.clips[index].copyWith(id: _uuid.v4());
    final clips = [..._project.clips]..insert(index + 1, copy);
    _apply(_project.copyWith(clips: clips));
    selection = SelectionType.clip;
    selectedId = copy.id;
    notifyListeners();
  }

  void setClipVolume(String id, double value) {
    final clips = [
      for (final c in _project.clips)
        if (c.id == id) c.copyWith(volume: value.clamp(0, 100)) else c,
    ];
    _apply(_project.copyWith(clips: clips));
  }

  /// Marque un média comme introuvable quand la lecture native échoue
  /// (fichier illisible, accès révoqué, codec non pris en charge). La lecture
  /// s'arrête et l'aperçu bascule vers l'état « média manquant » (EDT-01,
  /// PRJ-05) au lieu de geler sur une image statique.
  void markMediaMissing(String mediaId) {
    final media = _project.mediaById(mediaId);
    if (media == null || media.missing) return;
    if (isPlaying) pause();
    final next = [
      for (final m in _project.media)
        if (m.id == mediaId) m.copyWith(missing: true) else m,
    ];
    _apply(_project.copyWith(media: next), undoable: false);
  }

  void setVideoVolume(double value) {
    _apply(_project.copyWith(videoVolume: value.clamp(0, 100)));
  }

  void setAllAdjustments(Adjustments adjustments) {
    final clips = [
      for (final c in _project.clips) c.copyWith(adjustments: adjustments),
    ];
    _apply(_project.copyWith(clips: clips));
  }

  void setClipAdjustments(String id, Adjustments adjustments) {
    final clips = [
      for (final c in _project.clips)
        if (c.id == id) c.copyWith(adjustments: adjustments) else c,
    ];
    _apply(_project.copyWith(clips: clips));
  }

  void setFormat(ProjectFormat format) =>
      _apply(_project.copyWith(format: format));

  void setFitMode(FitMode mode) => _apply(_project.copyWith(fitMode: mode));

  void setClipTransform(
    String id, {
    int? rotation,
    bool? mirrored,
    double? straighten,
  }) {
    final clips = [
      for (final c in _project.clips)
        if (c.id == id)
          c.copyWith(
            rotation: rotation,
            mirrored: mirrored,
            straighten: straighten,
          )
        else
          c,
    ];
    _apply(_project.copyWith(clips: clips));
  }

  void setCover({
    required CoverSource source,
    int? timeMs,
    String? path,
    double? zoom,
    double? offsetX,
    double? offsetY,
  }) => _apply(
    _project.copyWith(
      coverSource: source,
      coverTimeMs: timeMs ?? _project.coverTimeMs,
      coverPath: path ?? _project.coverPath,
      coverZoom: zoom ?? _project.coverZoom,
      coverOffsetX: offsetX ?? _project.coverOffsetX,
      coverOffsetY: offsetY ?? _project.coverOffsetY,
    ),
  );

  TextItem addText({String text = '', TextPreset preset = TextPreset.caption}) {
    final start = _positionMs.clamp(0, durationMs);
    final item = TextItem(
      id: _uuid.v4(),
      text: text,
      startMs: start,
      durationMs: 3000,
      preset: preset,
    );
    _apply(_project.copyWith(texts: [..._project.texts, item]));
    ensureElementWidth(item.durationMs);
    selection = SelectionType.text;
    selectedId = item.id;
    notifyListeners();
    return item;
  }

  void updateText(TextItem item) {
    final texts = [
      for (final t in _project.texts)
        if (t.id == item.id) item else t,
    ];
    _apply(_project.copyWith(texts: texts));
    selection = SelectionType.text;
    selectedId = item.id;
    notifyListeners();
  }

  void removeText(String id) {
    _apply(
      _project.copyWith(
        texts: _project.texts.where((t) => t.id != id).toList(),
      ),
    );
    clearSelection();
  }

  /// EDT-03, barre « Plus » : dupliquer le texte sélectionné.
  void duplicateText(String id) {
    final index = _project.texts.indexWhere((t) => t.id == id);
    if (index < 0) return;
    final copy = _project.texts[index].copyWith(id: _uuid.v4());
    final texts = [..._project.texts]..insert(index + 1, copy);
    _apply(_project.copyWith(texts: texts));
    selection = SelectionType.text;
    selectedId = copy.id;
    notifyListeners();
  }

  void addAudio(MediaRef media) {
    final start = _positionMs.clamp(0, durationMs);
    final item = AudioItem(
      id: _uuid.v4(),
      mediaId: media.id,
      startMs: start,
      trimStartMs: 0,
      trimEndMs: media.durationMs > 0 ? media.durationMs : 3000,
    );
    _apply(
      _project.copyWith(
        media: [..._project.media, media],
        audios: [..._project.audios, item],
      ),
    );
    ensureElementWidth(item.durationMs);
    selection = SelectionType.audio;
    selectedId = item.id;
    notifyListeners();
  }

  void updateAudio(AudioItem item) {
    // Les fondus ne peuvent jamais dépasser la durée de l'élément (EDT-04).
    final duration = item.durationMs;
    final fadeIn = item.fadeInMs.clamp(0, duration);
    final fadeOut = item.fadeOutMs.clamp(0, duration - fadeIn);
    final safe = item.copyWith(fadeInMs: fadeIn, fadeOutMs: fadeOut);
    final audios = [
      for (final a in _project.audios)
        if (a.id == safe.id) safe else a,
    ];
    _apply(_project.copyWith(audios: audios));
    notifyListeners();
  }

  /// Déplace un élément audio sur la timeline (jamais avant zéro).
  void moveAudio(String id, int deltaMs) {
    final audios = [
      for (final a in _project.audios)
        if (a.id == id)
          a.copyWith(startMs: (a.startMs + deltaMs).clamp(0, durationMs))
        else
          a,
    ];
    _apply(_project.copyWith(audios: audios));
    selection = SelectionType.audio;
    selectedId = id;
  }

  /// Déplace un bord d'un élément audio.
  ///
  /// Le bord gauche avance dans le média en gardant le contenu aligné ; le bord
  /// droit s'arrête à la fin du fichier. 100 ms minimum, comme les clips.
  void resizeAudio(String id, {int leftDeltaMs = 0, int rightDeltaMs = 0}) {
    final index = _project.audios.indexWhere((a) => a.id == id);
    if (index < 0) return;
    final audio = _project.audios[index];
    final media = _project.mediaById(audio.mediaId);
    final mediaEnd = (media?.durationMs ?? 0) > 0
        ? media!.durationMs
        : audio.trimEndMs;
    var startMs = audio.startMs;
    var trimStart = audio.trimStartMs;
    var trimEnd = audio.trimEndMs;
    if (leftDeltaMs != 0) {
      final minDelta = -(trimStart < startMs ? trimStart : startMs);
      final maxDelta = (trimEnd - trimStart) - 100;
      if (maxDelta >= minDelta) {
        final delta = leftDeltaMs.clamp(minDelta, maxDelta);
        startMs += delta;
        trimStart += delta;
      }
    }
    if (rightDeltaMs != 0) {
      trimEnd = (trimEnd + rightDeltaMs).clamp(trimStart + 100, mediaEnd);
    }
    final audios = [..._project.audios];
    audios[index] = audio.copyWith(
      startMs: startMs,
      trimStartMs: trimStart,
      trimEndMs: trimEnd,
    );
    _apply(_project.copyWith(audios: audios));
    selection = SelectionType.audio;
    selectedId = id;
  }

  /// EDT-04, barre de l'audio : coupe l'élément à la tête de lecture.
  bool splitSelectedAudio() {
    final audio = selectedAudio;
    if (audio == null) return false;
    final offset = _positionMs - audio.startMs;
    if (offset < 100 || offset > audio.durationMs - 100) return false;
    final cut = audio.trimStartMs + offset;
    final left = audio.copyWith(trimEndMs: cut);
    final right = audio.copyWith(
      id: _uuid.v4(),
      startMs: audio.startMs + offset,
      trimStartMs: cut,
    );
    final index = _project.audios.indexWhere((a) => a.id == audio.id);
    final audios = [..._project.audios];
    audios[index] = left;
    audios.insert(index + 1, right);
    _apply(_project.copyWith(audios: audios));
    selection = SelectionType.audio;
    selectedId = left.id;
    notifyListeners();
    return true;
  }

  /// EDT-04, « Plus » : duplique l'élément audio juste après lui.
  void duplicateAudio(String id) {
    final index = _project.audios.indexWhere((a) => a.id == id);
    if (index < 0) return;
    final source = _project.audios[index];
    final copy = source.copyWith(id: _uuid.v4(), startMs: source.endMs);
    final audios = [..._project.audios]..insert(index + 1, copy);
    _apply(_project.copyWith(audios: audios));
    selection = SelectionType.audio;
    selectedId = copy.id;
    notifyListeners();
  }

  void removeAudio(String id) {
    _apply(
      _project.copyWith(
        audios: _project.audios.where((a) => a.id != id).toList(),
      ),
    );
    clearSelection();
  }

  void replaceProject(Project project) {
    _apply(project);
    clearSelection();
  }

  @override
  void dispose() {
    _disposed = true;
    _saveTimer?.cancel();
    _retryTimer?.cancel();
    _playTimer?.cancel();
    _playClock?.stop();
    super.dispose();
  }
}
