/// Centralized runtime permission handling.
/// GraceEdit degrades gracefully: denied permission => clear explanation,
/// never a silent failure or a crash.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum GracePermission { mediaLibrary, camera, microphone }

class PermissionState {
  const PermissionState({
    required this.mediaLibrary, required this.camera, required this.microphone,
  });
  final bool mediaLibrary;
  final bool camera;
  final bool microphone;

  bool get canImport => mediaLibrary;
  bool get canCapture => camera;
  bool get canRecordAudio => microphone;
}

class PermissionService {
  /// Web and desktop need no runtime permission prompts (system picker).
  /// kIsWeb is checked FIRST: dart:io Platform throws on web.
  static bool get _needsRuntimePrompt =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// On Android 13+, the system photo picker needs no permission.
  /// This requests full library access for older flows / direct file access.
  Future<bool> requestMediaLibrary() async {
    if (!_needsRuntimePrompt) return true;
    final videos = await Permission.videos.request();
    final photos = await Permission.photos.request();
    return videos.isGranted || photos.isGranted;
  }

  Future<bool> requestCamera() async {
    if (!_needsRuntimePrompt) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<bool> requestMicrophone() async {
    if (!_needsRuntimePrompt) return true;
    return (await Permission.microphone.request()).isGranted;
  }

  Future<PermissionState> currentState() async {
    if (!_needsRuntimePrompt) {
      return const PermissionState(mediaLibrary: true, camera: true, microphone: true);
    }
    final videos = await Permission.videos.status;
    final photos = await Permission.photos.status;
    final camera = await Permission.camera.status;
    final mic = await Permission.microphone.status;
    return PermissionState(
      mediaLibrary: videos.isGranted || videos.isLimited || photos.isGranted || photos.isLimited,
      camera: camera.isGranted,
      microphone: mic.isGranted,
    );
  }

  Future<void> openSettings() => openAppSettings();
}
