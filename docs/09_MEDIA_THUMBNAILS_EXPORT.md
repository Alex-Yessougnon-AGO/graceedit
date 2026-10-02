# 09 — Media Engine, Thumbnails and Export

## Android engine
Use Media3 playback/Transformer/Composition, CameraX capture and MediaCodec/GPU capabilities.

Official references:
- https://developer.android.com/media/media3/transformer
- https://developer.android.com/media/media3/transformer/composition
- https://developer.android.com/media/implement/editing-app

## Thumbnail types
1. Library media thumbnail.
2. Project cover.
3. Timeline strip.
4. Precise preview frame.
5. Template thumbnail.
6. Export-result thumbnail.

## Representative frame
Do not blindly use frame zero.

Initial heuristic:
- sample several timestamps;
- reject black/blank frames where possible;
- prefer a stable representative frame;
- future: face/content-aware selection.

Android provides ThumbnailUtils/MediaMetadataRetriever, and Media3 FrameExtractor explicitly supports thumbnail generation and editor preview use cases.

References:
- https://developer.android.com/social-and-messaging/guides/media-thumbnails
- https://developer.android.com/reference/android/media/ThumbnailUtils
- https://developer.android.com/reference/android/media/MediaMetadataRetriever
- https://developer.android.com/media/media3/inspector/extract-frames

## Thumbnail cache
Key:
`assetId + sourceVersion + size + cropMode + frameTimestamp`

Generate off the UI thread. Cache low-resolution versions. Invalidate when source/project state changes.

## Timeline thumbnails
- zoomed out: sparse frames;
- medium zoom: more frames;
- high zoom: precise frames;
- prioritize visible range;
- never create thousands of simultaneous bitmaps.

## Preview
Preview prioritizes responsiveness rather than final export quality. Use proxy/preview strategies later for long/4K projects.

## Export pipeline
```text
Project
 -> Validate
 -> Resolve assets
 -> Build render plan
 -> Select profile
 -> Capability check
 -> Render
 -> Verify
 -> Register output
```

## MVP profiles
| Profile | Output | FPS | Use |
|---|---|---|---|
| Small | 1280x720 | 24/30 | quick share |
| Standard | 1920x1080 | 30 | default |
| Social Vertical | 1080x1920 | 30 | short-form |
| Square | 1080x1080 | 30 | square |
| Landscape | 1920x1080 | 30 | standard video |

## Future profiles
| Profile | Output | FPS | Notes |
|---|---|---|---|
| Full HD Smooth | 1080p | 60 | device dependent |
| QHD | 1440p | 30/60 | device dependent |
| 4K Standard | 3840x2160 | 30 | hardware dependent |
| 4K Smooth | 3840x2160 | 60 | demanding |
| 4K HDR | 3840x2160 | 30/60 | device/color-pipeline dependent |

Media3 currently documents H.264/H.265 output support and HDR editing on Android 13/API 33+ on devices with the required encoding support.

References:
- https://developer.android.com/reference/androidx/media3/transformer/Transformer.Builder
- https://developer.android.com/media/media3/transformer/supported-formats

## Export UI
Beginner:
> Recommended for WhatsApp

Advanced:
> 1080p / 30fps / quality

Future Studio:
> 4K / 60fps / HEVC / HDR

## Capability-aware export
Expose:
supportsVideoMimeType, supportsResolution, supportsFrameRate, supportsHdr, supportsHardwareEncoding, estimatedOutputSize.

If 4K60 is unavailable, recommend 4K30 or 1080p60 rather than failing.

## Resilience
Support cancellation, progress, low-storage detection, partial-file cleanup, retry and diagnostics.

## Future proxy workflow
For long/high-resolution projects:
originals → low-res proxy for editing → originals for final export.
