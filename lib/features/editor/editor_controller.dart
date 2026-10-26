import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/project.dart';
import '../../core/store/app_store.dart';

const _uuid = Uuid();

enum SaveState { saved, saving, failed }

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
  Timer? _clock;
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

  void setZoom(double value) {
    zoom = value.clamp(0.8, 8.0);
    notifyListeners();
  }

  void setCompareOriginal(bool value) {
    if (compareOriginal == value) return;
    compareOriginal = value;
    notifyListeners();
  }

  Future<void> _session() async {
    readOnly = store.projects.any(
      (p) => p.id == _project.id && p.lastExport != null,
    );
    await store.setSession(projectId: _project.id, clean: false);
    notifyListeners();
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
    if (stop && isPlaying) {
      isPlaying = false;
      _playTimer?.cancel();
      _clock?.cancel();
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
    _playTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _positionMs += 100;
      if (_positionMs >= durationMs) {
        _positionMs = 0;
        isPlaying = false;
        _playTimer?.cancel();
        _clock?.cancel();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    isPlaying = false;
    _playTimer?.cancel();
    _clock?.cancel();
    notifyListeners();
  }

  void selectClip(String id) {
    if (isPlaying) pause();
    selection = SelectionType.clip;
    selectedId = id;
    notifyListeners();
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
    _saveTimer = Timer(const Duration(milliseconds: 450), _save);
  }

  Future<void> _save() async {
    try {
      await store.saveProject(_project);
      _project = store.projectById(_project.id) ?? _project;
      saveState = SaveState.saved;
      onProjectSaved?.call(_project);
    } catch (_) {
      saveState = SaveState.failed;
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> retrySave() async {
    saveState = SaveState.saving;
    notifyListeners();
    await _save();
  }

  Future<void> flush() async {
    _saveTimer?.cancel();
    await _save();
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
    final maxEnd = media?.durationMs ?? clip.trimEndMs;
    var newStart = start ?? clip.trimStartMs;
    var newEnd = end ?? clip.trimEndMs;
    newStart = newStart.clamp(0, newEnd - 100);
    newEnd = newEnd.clamp(newStart + 100, maxEnd);
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

  void setCover({required CoverSource source, int? timeMs, String? path}) =>
      _apply(
        _project.copyWith(
          coverSource: source,
          coverTimeMs: timeMs ?? _project.coverTimeMs,
          coverPath: path ?? _project.coverPath,
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
    selection = SelectionType.audio;
    selectedId = item.id;
    notifyListeners();
  }

  void updateAudio(AudioItem item) {
    final audios = [
      for (final a in _project.audios)
        if (a.id == item.id) item else a,
    ];
    _apply(_project.copyWith(audios: audios));
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
    _playTimer?.cancel();
    _clock?.cancel();
    super.dispose();
  }
}
