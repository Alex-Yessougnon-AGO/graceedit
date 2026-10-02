# 12 — Open Source, Licensing and Commercialization

This is an engineering checklist, not legal advice.

## Recommended components

| Component | Role | License/status | Recommendation |
|---|---|---|---|
| AndroidX Media3 | Android media | Apache-2.0 project/code licensing | Main engine |
| CameraX | camera | Apache-2.0 | Use |
| LibreCuts | Android reference/possible code | MIT | Audit and study |
| OpenCut | cross-platform reference | MIT | Study |
| FFmpeg | advanced media | LGPL by default; optional GPL parts | Conditional |
| whisper.cpp | local transcription | MIT | Future |
| ONNX Runtime | local ML runtime | MIT | Future |
| Lottie Android | animation | Apache-2.0 | Optional |
| MediaPipe | ML/vision | Apache-2.0 project | Future |

Sources:
- https://github.com/androidx/media
- https://github.com/androidx-releases/CameraX
- https://github.com/tharunbirla/LibreCuts
- https://github.com/OpenCut-app/OpenCut
- https://ffmpeg.org/doxygen/trunk/md_LICENSE.html
- https://github.com/ggml-org/whisper.cpp
- https://github.com/microsoft/onnxruntime
- https://github.com/airbnb/lottie-android
- https://github.com/google-ai-edge/mediapipe

## LibreCuts
Current repository states MIT. Use it as an implementation reference or consider a fork only after auditing dependencies, bundled assets and architecture.

## OpenCut
MIT and useful as a cross-platform/editor architecture reference. The current repository is being rewritten, so it should not automatically become the Android MVP foundation.

## FFmpeg
FFmpeg states most files are LGPL v2.1+ while optional components are GPL v2+. Enabling GPL components changes the licensing situation.

Source:
https://ffmpeg.org/doxygen/trunk/md_LICENSE.html

Freeze exact version and build flags before release.

## Assets
Track every:
- font;
- music file;
- image;
- icon;
- template;
- animation;
- model;
- dataset.

Record source, license, attribution, modification and redistribution terms.

## AI models
Check model weights separately from runtime licenses.

## Codecs
Open-source licensing and patent rights are separate questions. Review the exact codecs and target jurisdictions before commercial launch.

## Notices
Repository must contain:
```text
legal/
  THIRD_PARTY_LICENSES.md
  THIRD_PARTY_NOTICES.md
  ASSET_LICENSES.md
  MODEL_LICENSES.md
  FONT_LICENSES.md
  CODEC_NOTES.md
```

## Trademark
Before launch, check GraceEdit across app stores, domains, social handles and relevant trademark databases.
