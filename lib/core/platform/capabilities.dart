/// Device capability detection — never assume a device can do 4K/HEVC/HDR.
library;

class DeviceCapabilities {
  const DeviceCapabilities({
    this.supports4K = false,
    this.supportsHDR = false,
    this.supportsHEVC = false,
    this.supportsHardwareEncoding = true,
    this.supportsBackgroundExport = false,
    this.supportsCamera = true,
    this.supportsLocalAI = false,
    this.supportsOfflineGeneration = false,
    this.maxExportWidth = 1920,
    this.maxExportHeight = 1080,
    this.maxFps = 30,
  });

  final bool supports4K;
  final bool supportsHDR;
  final bool supportsHEVC;
  final bool supportsHardwareEncoding;
  final bool supportsBackgroundExport;
  final bool supportsCamera;
  final bool supportsLocalAI;
  final bool supportsOfflineGeneration;
  final int maxExportWidth;
  final int maxExportHeight;
  final int maxFps;

  /// Conservative default usable on modest devices.
  static const fallback = DeviceCapabilities();

  Map<String, dynamic> toJson() => {
        'supports4K': supports4K, 'supportsHDR': supportsHDR,
        'supportsHEVC': supportsHEVC,
        'supportsHardwareEncoding': supportsHardwareEncoding,
        'supportsBackgroundExport': supportsBackgroundExport,
        'supportsCamera': supportsCamera, 'supportsLocalAI': supportsLocalAI,
        'supportsOfflineGeneration': supportsOfflineGeneration,
        'maxExportWidth': maxExportWidth, 'maxExportHeight': maxExportHeight,
        'maxFps': maxFps,
      };
}

enum ExportProfileId { p720, p1080, vertical1080x1920, square1080 }

class ExportProfile {
  const ExportProfile({
    required this.id, required this.label,
    required this.width, required this.height, required this.fps,
  });
  final ExportProfileId id;
  final String label;
  final int width;
  final int height;
  final int fps;

  static const all = [
    ExportProfile(id: ExportProfileId.p720, label: 'HD 720p', width: 1280, height: 720, fps: 30),
    ExportProfile(id: ExportProfileId.p1080, label: 'Full HD 1080p', width: 1920, height: 1080, fps: 30),
    ExportProfile(id: ExportProfileId.vertical1080x1920, label: 'Vertical 1080×1920', width: 1080, height: 1920, fps: 30),
    ExportProfile(id: ExportProfileId.square1080, label: 'Carré 1080×1080', width: 1080, height: 1080, fps: 30),
  ];

  /// Filter profiles by what the device can really produce.
  static List<ExportProfile> supportedBy(DeviceCapabilities caps) => all
      .where((p) => p.width <= caps.maxExportWidth && p.height <= caps.maxExportHeight && p.fps <= caps.maxFps)
      .toList();
}
