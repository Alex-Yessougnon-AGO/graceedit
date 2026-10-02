/// Undoable, serializable commands operating on [GraceProject].
/// Every mutation of a project must go through a command so that
/// undo/redo, autosave and tests stay deterministic.
library;

import '../models/grace_project.dart';

abstract class ProjectCommand {
  String get name;
  void apply(GraceProject project);
  void revert(GraceProject project);
  Map<String, dynamic> toJson();
}

class AddClipCommand implements ProjectCommand {
  AddClipCommand(this.clip);
  final VideoClip clip;
  @override String get name => 'AddClip';
  @override void apply(GraceProject p) { p.clips.add(clip); p.touch(); }
  @override void revert(GraceProject p) { p.clips.removeWhere((c) => c.id == clip.id); p.touch(); }
  @override Map<String, dynamic> toJson() => {'type': name, 'clip': clip.toJson()};
}

class RemoveClipCommand implements ProjectCommand {
  RemoveClipCommand(this.clipId);
  final String clipId;
  VideoClip? _removed;
  int? _index;
  @override String get name => 'RemoveClip';
  @override void apply(GraceProject p) {
    _index = p.clips.indexWhere((c) => c.id == clipId);
    if (_index! >= 0) _removed = p.clips.removeAt(_index!);
    p.touch();
  }
  @override void revert(GraceProject p) {
    if (_removed != null) {
      if (_index != null && _index! <= p.clips.length) {
        p.clips.insert(_index!, _removed!);
      } else {
        p.clips.add(_removed!);
      }
      p.touch();
    }
  }
  @override Map<String, dynamic> toJson() => {'type': name, 'clipId': clipId};
}

class TrimClipCommand implements ProjectCommand {
  TrimClipCommand(this.clipId, {required this.newStartMs, required this.newEndMs});
  final String clipId;
  final int newStartMs;
  final int newEndMs;
  int? _oldStart;
  int? _oldEnd;
  @override String get name => 'TrimClip';
  @override void apply(GraceProject p) {
    final i = p.clips.indexWhere((c) => c.id == clipId);
    if (i < 0) return;
    _oldStart = p.clips[i].startMs;
    _oldEnd = p.clips[i].endMs;
    final c = p.clips[i];
    assert(newStartMs >= 0 && newEndMs > newStartMs, 'Invalid trim range');
    p.clips[i] = c.copyWith(startMs: newStartMs, endMs: newEndMs);
    p.touch();
  }
  @override void revert(GraceProject p) {
    final i = p.clips.indexWhere((c) => c.id == clipId);
    if (i < 0 || _oldStart == null) return;
    p.clips[i] = p.clips[i].copyWith(startMs: _oldStart, endMs: _oldEnd);
    p.touch();
  }
  @override Map<String, dynamic> toJson() =>
      {'type': name, 'clipId': clipId, 'newStartMs': newStartMs, 'newEndMs': newEndMs};
}

class SplitClipCommand implements ProjectCommand {
  SplitClipCommand(this.clipId, this.splitAtMs);
  final String clipId;
  final int splitAtMs;
  VideoClip? _second;
  @override String get name => 'SplitClip';
  @override void apply(GraceProject p) {
    final i = p.clips.indexWhere((c) => c.id == clipId);
    if (i < 0) return;
    final c = p.clips[i];
    assert(splitAtMs > c.startMs && splitAtMs < c.endMs, 'Split point outside clip');
    p.clips[i] = c.copyWith(startMs: c.startMs, endMs: splitAtMs);
    _second = VideoClip(
      id: GraceProject.newId(), assetId: c.assetId,
      startMs: splitAtMs, endMs: c.endMs,
      speed: c.speed, volume: c.volume, rotation: c.rotation,
    );
    p.clips.insert(i + 1, _second!);
    p.touch();
  }
  @override void revert(GraceProject p) {
    if (_second == null) return;
    p.clips.removeWhere((c) => c.id == _second!.id);
    final i = p.clips.indexWhere((c) => c.id == clipId);
    if (i >= 0) {
      final c = p.clips[i];
      p.clips[i] = c.copyWith(endMs: _second!.endMs);
    }
    p.touch();
  }
  @override Map<String, dynamic> toJson() =>
      {'type': name, 'clipId': clipId, 'splitAtMs': splitAtMs};
}

class MoveClipCommand implements ProjectCommand {  MoveClipCommand(this.clipId, this.newIndex);
  final String clipId;
  final int newIndex;
  int? _oldIndex;
  @override String get name => 'MoveClip';
  @override void apply(GraceProject p) {
    final i = p.clips.indexWhere((c) => c.id == clipId);
    if (i < 0) return;
    _oldIndex = i;
    final c = p.clips.removeAt(i);
    final target = newIndex.clamp(0, p.clips.length);
    p.clips.insert(target, c);
    p.touch();
  }
  @override void revert(GraceProject p) {
    if (_oldIndex == null) return;
    final i = p.clips.indexWhere((c) => c.id == clipId);
    if (i < 0) return;
    final c = p.clips.removeAt(i);
    p.clips.insert(_oldIndex!.clamp(0, p.clips.length), c);
    p.touch();
  }
  @override Map<String, dynamic> toJson() =>
      {'type': name, 'clipId': clipId, 'newIndex': newIndex};
}

/// Generic undoable property update (speed, volume, rotation, filters).
/// Null fields are left untouched.
class UpdateClipPropsCommand implements ProjectCommand {
  UpdateClipPropsCommand(this.clipId, {
    this.speed, this.volume, this.rotation,
    this.brightness, this.contrast, this.saturation,
  });
  final String clipId;
  final double? speed;
  final double? volume;
  final int? rotation;
  final double? brightness;
  final double? contrast;
  final double? saturation;
  VideoClip? _before;

  @override
  String get name => 'UpdateClipProps';

  @override
  void apply(GraceProject p) {
    final i = p.clips.indexWhere((c) => c.id == clipId);
    if (i < 0) return;
    _before ??= p.clips[i];
    p.clips[i] = p.clips[i].copyWith(
      speed: speed, volume: volume, rotation: rotation,
      brightness: brightness, contrast: contrast, saturation: saturation,
    );
    p.touch();
  }

  @override
  void revert(GraceProject p) {
    if (_before == null) return;
    final i = p.clips.indexWhere((c) => c.id == clipId);
    if (i < 0) return;
    p.clips[i] = _before!;
    p.touch();
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': name, 'clipId': clipId,
        'speed': speed, 'volume': volume, 'rotation': rotation,
        'brightness': brightness, 'contrast': contrast, 'saturation': saturation,
      };
}

/// Simple in-memory command stack with undo/redo.
class CommandStack {
  final List<ProjectCommand> _done = [];
  final List<ProjectCommand> _undone = [];

  bool get canUndo => _done.isNotEmpty;
  bool get canRedo => _undone.isNotEmpty;
  int get length => _done.length;

  void execute(GraceProject p, ProjectCommand cmd) {
    cmd.apply(p);
    _done.add(cmd);
    _undone.clear();
  }

  bool undo(GraceProject p) {
    if (_done.isEmpty) return false;
    final cmd = _done.removeLast();
    cmd.revert(p);
    _undone.add(cmd);
    return true;
  }

  bool redo(GraceProject p) {
    if (_undone.isEmpty) return false;
    final cmd = _undone.removeLast();
    cmd.apply(p);
    _done.add(cmd);
    return true;
  }

  void clear() { _done.clear(); _undone.clear(); }
}
