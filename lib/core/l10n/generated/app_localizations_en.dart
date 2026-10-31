// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GraceEdit';

  @override
  String get brandTagline => 'Edit your videos, simply.';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDone => 'Done';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionDuplicate => 'Duplicate';

  @override
  String get actionExport => 'Export';

  @override
  String get actionShare => 'Share';

  @override
  String get actionBack => 'Back';

  @override
  String get actionOpen => 'Open';

  @override
  String get actionSelect => 'Select';

  @override
  String get actionSelectAll => 'Select all';

  @override
  String get actionMoveUp => 'Move up';

  @override
  String get actionMoveDown => 'Move down';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionRestore => 'Restore';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionRedo => 'Redo';

  @override
  String get actionSave => 'Save';

  @override
  String get actionMore => 'More';

  @override
  String get actionLess => 'Less';

  @override
  String get actionPlay => 'Play';

  @override
  String get actionPause => 'Pause';

  @override
  String get saveStateSaved => 'Saved';

  @override
  String get saveStateSaving => 'Saving…';

  @override
  String get saveStateFailed => 'Not saved';

  @override
  String get projectSaved => 'Project saved';

  @override
  String get toastClipDeleted => 'Clip deleted';

  @override
  String get toastClipSplit => 'Clip split';

  @override
  String get toastTextDeleted => 'Text deleted';

  @override
  String get toastAudioDeleted => 'Music removed';

  @override
  String get toastProjectTrashed => 'Project moved to trash';

  @override
  String get toastProjectsTrashed => 'Projects moved to trash';

  @override
  String get toastProjectRestored => 'Project restored';

  @override
  String get toastMediaRemoved => 'Media removed from project';

  @override
  String get toastExportCancelled => 'Export cancelled';

  @override
  String get toastCoverUpdated => 'Cover updated';

  @override
  String get splashLoadingSemantics => 'GraceEdit, loading';

  @override
  String get splashPreparing => 'Getting ready…';

  @override
  String get splashSlowHint => 'This is taking longer than usual.';

  @override
  String get splashErrorTitle => 'The app could not start.';

  @override
  String get splashErrorBody =>
      'Your projects are safe. Close other apps, then try again.';

  @override
  String get splashRetry => 'Try again';

  @override
  String get welcomeTitle => 'Edit your videos, simply.';

  @override
  String get welcomeBody => 'Import a video, trim it, add text, then export.';

  @override
  String get welcomeGuaranteeNoAccount => 'No account needed';

  @override
  String get welcomeGuaranteeOffline => 'Works without a connection';

  @override
  String get welcomeGuaranteeLocal => 'Your files stay on your phone';

  @override
  String get welcomeStart => 'Make a video';

  @override
  String get welcomeExplore => 'Look around first';

  @override
  String get homeResume => 'Resume';

  @override
  String get homeRecent => 'Recent';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeNewProject => 'New project';

  @override
  String get homeEmptyTitle => 'Create your first project';

  @override
  String get homeEmptyBody => 'Choose a video, trim it, add text, then export.';

  @override
  String get homeMissingMedia => 'Missing media';

  @override
  String get homeExportRunning => 'Export in progress';

  @override
  String get homeExportRunningBody => 'Your video is being prepared.';

  @override
  String homeStorageLow(String free) {
    return 'Low storage: $free free.';
  }

  @override
  String get homeDraftRecovered => 'Draft recovered';

  @override
  String homeProjectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projects',
      one: '1 project',
      zero: 'No projects',
    );
    return '$_temp0';
  }

  @override
  String modifiedAt(String when) {
    return 'Edited $when';
  }

  @override
  String get importTitle => 'New project';

  @override
  String get importNameLabel => 'Project name';

  @override
  String importDefaultName(String date) {
    return 'Project from $date';
  }

  @override
  String importMediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count media items',
      one: '1 media item',
      zero: 'No media',
    );
    return '$_temp0';
  }

  @override
  String get importAddMedia => 'Add media';

  @override
  String get importStart => 'Start editing';

  @override
  String importStartWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Start with $count media items',
      one: 'Start with 1 media item',
    );
    return '$_temp0';
  }

  @override
  String importPreparing(int percent) {
    return 'Preparing $percent%';
  }

  @override
  String get importUnsupported => 'Unsupported format';

  @override
  String get importUnreadable => 'Unreadable file';

  @override
  String get importRemoveFromProject => 'Remove from project';

  @override
  String get importAddHint => 'Your original files are never modified.';

  @override
  String get editorUntitled => 'Untitled';

  @override
  String get editorAdd => 'Add';

  @override
  String get editorAudio => 'Audio';

  @override
  String get editorText => 'Text';

  @override
  String get editorAdjust => 'Adjust';

  @override
  String get editorFormat => 'Format';

  @override
  String get editorCover => 'Cover';

  @override
  String get editorSplit => 'Split';

  @override
  String get editorVolume => 'Volume';

  @override
  String get editorCrop => 'Frame';

  @override
  String get editorDelete => 'Delete';

  @override
  String get editorDuplicate => 'Duplicate';

  @override
  String get editorEmptyTitle => 'Your timeline is empty.';

  @override
  String get editorEmptyBody => 'Add a video to get started.';

  @override
  String get editorAddMedia => 'Add media';

  @override
  String get editorMissingMedia => 'Missing media';

  @override
  String get editorReconnect => 'Reconnect';

  @override
  String get editorTextTrack => 'Text';

  @override
  String get editorAudioTrack => 'Audio';

  @override
  String get editorVideoTrack => 'Video';

  @override
  String get editorTimeline => 'Timeline';

  @override
  String get editorPreview => 'Preview';

  @override
  String get editorSaveFailed => 'Saving failed.';

  @override
  String get editorSaveFailedBody =>
      'Your work is kept on this device. Check free space, then try again.';

  @override
  String get editorRetrySave => 'Try again';

  @override
  String get editorZoomIn => 'Zoom in';

  @override
  String get editorZoomOut => 'Zoom out';

  @override
  String get editorClipActions => 'Clip actions';

  @override
  String get trimTitle => 'Trim';

  @override
  String get trimStart => 'Start';

  @override
  String get trimEnd => 'End';

  @override
  String trimRemoved(String duration) {
    return '−$duration';
  }

  @override
  String trimDurationLabel(String duration) {
    return 'Duration $duration';
  }

  @override
  String get trimMinimum => 'Minimum duration: 0.1 s.';

  @override
  String get textTitle => 'Text';

  @override
  String get textFieldLabel => 'Your text';

  @override
  String get textPlaceholder => 'Type here';

  @override
  String get textPresetTitle => 'Title';

  @override
  String get textPresetSubtitle => 'Subtitle';

  @override
  String get textPresetCaption => 'Caption';

  @override
  String get textEdit => 'Edit';

  @override
  String get textStyle => 'Style';

  @override
  String get textColor => 'Colour';

  @override
  String get textTabStyle => 'Style';

  @override
  String get textTabFont => 'Font';

  @override
  String get textTabColor => 'Colour';

  @override
  String get textTabBackground => 'Background';

  @override
  String get textSize => 'Size';

  @override
  String get textOpacity => 'Opacity';

  @override
  String get textPosition => 'Position';

  @override
  String get textRotation => 'Rotation';

  @override
  String get textBackgroundOn => 'Background behind text';

  @override
  String get textColorWhite => 'White';

  @override
  String get textColorBlack => 'Black';

  @override
  String get textColorAccent => 'Orange';

  @override
  String get textColorIvory => 'Ivory';

  @override
  String get textColorSlate => 'Slate';

  @override
  String get textColorGreen => 'Green';

  @override
  String get textMoveHint => 'Drag to move, pinch to resize.';

  @override
  String get textRotationHint => 'Rotates in 15° steps.';

  @override
  String get audioTitle => 'Audio';

  @override
  String get audioVideoSound => 'Video sound';

  @override
  String get audioMusic => 'Music';

  @override
  String get audioMute => 'Mute';

  @override
  String get audioUnmute => 'Unmute';

  @override
  String get audioAddMusic => 'Add music';

  @override
  String get audioMusicHint =>
      'Music starts at the playhead and stops at the end of the project.';

  @override
  String get audioVolumeLabel => 'Volume';

  @override
  String get audioFade => 'Fade';

  @override
  String get audioFadeIn => 'Fade in';

  @override
  String get audioFadeOut => 'Fade out';

  @override
  String get audioFadeTooLong => 'The fades are longer than the sound.';

  @override
  String audioVolumePercent(int percent) {
    return '$percent%';
  }

  @override
  String audioFadeSeconds(String seconds) {
    return '$seconds s';
  }

  @override
  String get adjustTitle => 'Adjust';

  @override
  String get adjustBrightness => 'Brightness';

  @override
  String get adjustContrast => 'Contrast';

  @override
  String get adjustSaturation => 'Saturation';

  @override
  String get adjustScope => 'Applies to';

  @override
  String get adjustScopeClip => 'This clip';

  @override
  String get adjustScopeAll => 'Whole project';

  @override
  String get adjustCompare => 'Compare';

  @override
  String get adjustCompareHint => 'Hold to see the original.';

  @override
  String get adjustReset => 'Reset';

  @override
  String get formatTitle => 'Format';

  @override
  String get formatVertical => 'Vertical 9:16';

  @override
  String get formatSquare => 'Square 1:1';

  @override
  String get formatHorizontal => 'Landscape 16:9';

  @override
  String get formatPortrait => 'Portrait 4:5';

  @override
  String get formatFitMode => 'Framing';

  @override
  String get formatFill => 'Fill';

  @override
  String get formatFit => 'Fit';

  @override
  String get formatFitHint => 'Fit: the whole image is kept, with black bars.';

  @override
  String get cropTitle => 'Frame';

  @override
  String get cropRotate => 'Rotate';

  @override
  String get cropMirror => 'Mirror';

  @override
  String get cropStraighten => 'Straighten';

  @override
  String get cropReset => 'Reset';

  @override
  String get cropGrid => 'Rule of thirds';

  @override
  String get coverTitle => 'Cover';

  @override
  String get coverFromVideo => 'Video frame';

  @override
  String get coverFromGallery => 'Gallery';

  @override
  String get coverAuto => 'Automatic';

  @override
  String get coverAutoBody => 'The first frame of the video is used.';

  @override
  String get coverUsage => 'In your projects';

  @override
  String get coverPickImage => 'Choose an image';

  @override
  String get coverCropHint => 'Drag to frame, pinch to zoom.';

  @override
  String get coverReset => 'Back to the video frame';

  @override
  String get exportTitle => 'Export';

  @override
  String get exportSummary => 'Summary';

  @override
  String get exportDuration => 'Duration';

  @override
  String get exportFormatLabel => 'Format';

  @override
  String get exportQuality => 'Quality';

  @override
  String get exportQualityHigh => 'High · 1080p';

  @override
  String get exportQualityStandard => 'Standard · 720p';

  @override
  String get exportFramesPerSecond => '30 fps';

  @override
  String get exportDestination => 'Destination';

  @override
  String get exportDestinationGallery => 'Phone gallery';

  @override
  String get exportSpaceFree => 'Free space';

  @override
  String get exportSpaceNeeded => 'Space needed';

  @override
  String get exportNotEnoughSpaceTitle => 'Not enough space';

  @override
  String exportNotEnoughSpaceBody(String needed, String free) {
    return 'About $needed is needed. $free is left. Free up space to continue.';
  }

  @override
  String get exportDisabledEmpty => 'Add at least one clip to export.';

  @override
  String get exportDisabledMissing => 'Reconnect the missing media to export.';

  @override
  String get exportBatteryLow => 'Low battery: the export may be interrupted.';

  @override
  String get exportNotificationsTitle => 'Get notified when the export ends?';

  @override
  String get exportNotificationsBody =>
      'GraceEdit can show progress and let you know when the video is ready. The export works without notifications too.';

  @override
  String get exportNotificationsAllow => 'Allow notifications';

  @override
  String get exportNotificationsLater => 'Not now';

  @override
  String get exportPreparing => 'Preparing…';

  @override
  String get exportRendering => 'Creating the video';

  @override
  String get exportVerifying => 'Checking…';

  @override
  String exportElapsed(String duration) {
    return 'Elapsed: $duration';
  }

  @override
  String get exportBackground => 'Keep working in the background';

  @override
  String get exportCancel => 'Cancel export';

  @override
  String get exportCancelTitle => 'Cancel the export?';

  @override
  String get exportCancelBody =>
      'The current video will be deleted. Your project stays intact.';

  @override
  String get exportCancelKeep => 'Keep exporting';

  @override
  String get exportCancelConfirm => 'Cancel export';

  @override
  String get exportSuccessTitle => 'Video saved';

  @override
  String get exportSuccessBody => 'Your video is in the phone gallery.';

  @override
  String get exportSuccessName => 'Name';

  @override
  String get exportSuccessDimensions => 'Dimensions';

  @override
  String get exportSuccessDuration => 'Duration';

  @override
  String get exportSuccessSize => 'Size';

  @override
  String get exportViewInGallery => 'View in gallery';

  @override
  String get exportContinueEditing => 'Keep editing';

  @override
  String get exportFailedTitle => 'The export did not finish';

  @override
  String get exportFailedSafe => 'Your project is intact.';

  @override
  String get exportFailedRender => 'The video could not be created.';

  @override
  String get exportFailedStorage =>
      'Free space ran out while creating the video.';

  @override
  String get exportFailedGallery =>
      'The video was created but could not be added to the gallery.';

  @override
  String get exportFailedInterrupted => 'The export was interrupted.';

  @override
  String get exportFailedCancelled => 'The export was cancelled.';

  @override
  String get exportTryStandard => 'Export in Standard';

  @override
  String get exportDetails => 'Technical details';

  @override
  String get exportFreeSpace => 'Free up space';

  @override
  String get exportRetryGallery => 'Retry adding';

  @override
  String get exportSaveAs => 'Save as…';

  @override
  String get exportRestart => 'Restart the export';

  @override
  String get exportVerifyingFile => 'Checking the file…';

  @override
  String get exportRegistering => 'Adding to the gallery…';

  @override
  String get projectsTitle => 'Projects';

  @override
  String get projectsSearch => 'Search projects';

  @override
  String get projectsSearchClear => 'Clear search';

  @override
  String get projectsSort => 'Sort';

  @override
  String get projectsSortRecent => 'Recent';

  @override
  String get projectsSortOldest => 'Oldest';

  @override
  String get projectsSortName => 'Name A–Z';

  @override
  String get projectsViewGrid => 'Grid';

  @override
  String get projectsViewList => 'List';

  @override
  String get projectsTrash => 'Trash';

  @override
  String projectsSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
      zero: '0 selected',
    );
    return '$_temp0';
  }

  @override
  String get projectsEmptyTitle => 'No projects';

  @override
  String get projectsEmptyBody => 'Your edits will appear here.';

  @override
  String get projectsNoResultsTitle => 'No results';

  @override
  String get projectsNoResultsBody => 'Try another title.';

  @override
  String projectsDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count projects?',
      one: 'Delete this project?',
    );
    return '$_temp0';
  }

  @override
  String projectsDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'They stay 30 days in the trash, then they are deleted.',
      one: 'It stays 30 days in the trash, then it is deleted.',
    );
    return '$_temp0';
  }

  @override
  String get projectsToTrash => 'Move to trash';

  @override
  String get projectsDeleteForever => 'Delete permanently';

  @override
  String get projectsDeleteForeverTitle => 'Delete permanently?';

  @override
  String get projectsDeleteForeverSingularBody =>
      'This project cannot be recovered.';

  @override
  String get projectsDeleteForeverPluralBody =>
      'These projects cannot be recovered.';

  @override
  String get projectsDeleteForeverAction => 'Delete permanently';

  @override
  String get projectsDeletedForever => 'Deleted permanently';

  @override
  String get projectsExportingLocked =>
      'A project that is exporting cannot be deleted.';

  @override
  String get projectsRenameTitle => 'Rename';

  @override
  String get projectsRenameEmpty => 'The name cannot be empty.';

  @override
  String get projectsRenameTooLong => '60 characters maximum.';

  @override
  String projectsDuplicateSuffix(String name) {
    return '$name (copy)';
  }

  @override
  String projectsMenu(String name) {
    return 'Actions for $name';
  }

  @override
  String projectsOpen(String name) {
    return 'Open $name';
  }

  @override
  String get trashTitle => 'Trash';

  @override
  String get trashEmpty => 'The trash is empty.';

  @override
  String get trashBody => 'Deleted projects stay here for 30 days.';

  @override
  String trashDaysLeft(int days) {
    return '$days days left';
  }

  @override
  String get trashLastDay => 'Deleted tomorrow';

  @override
  String get trashPurge => 'Empty the trash';

  @override
  String get trashPurgeTitle => 'Empty the trash?';

  @override
  String get trashPurgeBody =>
      'All projects in the trash will be permanently deleted.';

  @override
  String get trashPurged => 'Trash emptied';

  @override
  String get missingTitle => 'Missing media';

  @override
  String get missingBody =>
      'GraceEdit can no longer find this file. It may have been moved or deleted.';

  @override
  String get missingReconnect => 'Reconnect';

  @override
  String get missingRemove => 'Remove from project';

  @override
  String get missingOpen => 'Open the project';

  @override
  String get missingOpenWithout => 'Open without these media';

  @override
  String get missingDifferentTitle => 'This file is different';

  @override
  String missingDifferentBody(Object newDuration, Object oldDuration) {
    return 'The duration or type does not match the original media.';
  }

  @override
  String get missingChooseAnother => 'Choose another file';

  @override
  String get missingAllGood => 'All media are reconnected.';

  @override
  String get missingFileLabel => 'File';

  @override
  String missingSeveral(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count missing media items',
      one: '1 missing media item',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Phone language';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsMotion => 'Reduce motion';

  @override
  String get settingsHaptics => 'Haptic feedback';

  @override
  String get settingsDeletion => 'Deletion';

  @override
  String get settingsDeletionAsk => 'Ask every time';

  @override
  String get settingsDeletionTrash => 'Always move to trash';

  @override
  String get settingsTrash => 'Trash';

  @override
  String get settingsStorage => 'Storage';

  @override
  String get settingsHelp => 'Help and about';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get storageTitle => 'Storage';

  @override
  String get storageUsed => 'Used';

  @override
  String get storageProjects => 'Projects';

  @override
  String get storageCovers => 'Covers';

  @override
  String get storageExports => 'Unsaved exports';

  @override
  String get storageThumbnails => 'Thumbnails';

  @override
  String get storageFree => 'Free space';

  @override
  String get storageClearCache => 'Clear cache';

  @override
  String get storageClearCacheBody =>
      'Thumbnails and unsaved exports will be deleted. Your projects and media are not touched.';

  @override
  String storageCleared(String size) {
    return 'Cache cleared · $size freed';
  }

  @override
  String get storageComputing => 'Calculating…';

  @override
  String get helpTitle => 'Help and about';

  @override
  String get helpReplay => 'See the introduction again';

  @override
  String get helpFaq => 'Frequently asked questions';

  @override
  String get helpDiagnostic => 'Diagnostic report';

  @override
  String get helpDiagnosticBody =>
      'Generated on your phone. It is never sent automatically.';

  @override
  String get helpDiagnosticCreate => 'Create the report';

  @override
  String get helpDiagnosticCopy => 'Copy';

  @override
  String get helpDiagnosticShare => 'Share';

  @override
  String get helpDiagnosticCopied => 'Report copied';

  @override
  String get helpLicenses => 'Licences';

  @override
  String get helpTerms => 'Terms of use';

  @override
  String get helpPrivacy => 'Privacy';

  @override
  String get helpVersion => 'Version';

  @override
  String get helpFaqQ1 => 'Where are my videos?';

  @override
  String get helpFaqA1 =>
      'On your phone, where you saved them. GraceEdit does not copy or modify them.';

  @override
  String get helpFaqQ2 => 'Why no account?';

  @override
  String get helpFaqA2 =>
      'GraceEdit works offline. No setting or project is sent anywhere.';

  @override
  String get helpFaqQ3 => 'What happens when I delete a project?';

  @override
  String get helpFaqA3 =>
      'It goes to the trash for 30 days. After that, it is deleted permanently.';

  @override
  String get helpFaqQ4 => 'Can I find a media file I moved?';

  @override
  String get helpFaqA4 =>
      'Yes: open the project, tap “Reconnect” and pick the file in its new location.';

  @override
  String get helpFaqQ5 => 'Why is exporting slower on some phones?';

  @override
  String get helpFaqA5 =>
      'Rendering uses the device encoder. Choose Standard quality to go faster.';

  @override
  String get helpFaqQ6 => 'Are my videos uploaded?';

  @override
  String get helpFaqA6 =>
      'No. Nothing is uploaded, neither while editing nor while exporting.';

  @override
  String get termsBody =>
      'GraceEdit is provided as is, for personal use. You remain responsible for the videos you edit and share. No data is collected.';

  @override
  String get privacyBody =>
      'GraceEdit creates no account, does not access the network and sends no data. Your projects, settings and videos stay on your device.';

  @override
  String get recoveryTitle => 'Pick up where you left off?';

  @override
  String get recoveryBody =>
      'GraceEdit closed unexpectedly. Your work has been recovered.';

  @override
  String get recoveryResume => 'Resume the project';

  @override
  String get recoveryDiscard => 'Ignore';

  @override
  String get storageLowTitle => 'Low storage';

  @override
  String storageLowBody(String free) {
    return '$free left. The export may fail.';
  }

  @override
  String get storageFullTitle => 'Not enough space on your phone';

  @override
  String get storageFullBody =>
      'GraceEdit can no longer save or import. Free up space to continue.';

  @override
  String get storageManage => 'Manage storage';

  @override
  String get unsupportedTitle => 'Unsupported format';

  @override
  String get unsupportedBody => 'This file cannot be read on this device.';

  @override
  String get unsupportedChoose => 'Choose another file';

  @override
  String get permissionTitle => 'Allow media access';

  @override
  String get permissionBody =>
      'The system picker is not available on this device. GraceEdit needs your permission to open your videos.';

  @override
  String get permissionAllow => 'Allow';

  @override
  String get permissionDeniedTitle => 'Access denied';

  @override
  String get permissionDeniedBody =>
      'Without permission, GraceEdit cannot open your videos. You can grant it in the phone settings.';

  @override
  String get permissionOpenSettings => 'Open settings';

  @override
  String get pickerUnavailable => 'The file picker is not available.';

  @override
  String get pickerUnavailableBody =>
      'Close apps that may be using it, then try again.';

  @override
  String get errorGenericTitle => 'Something went wrong';

  @override
  String get errorGenericBody =>
      'Your projects are safe. Try again; if it keeps happening, restart the app.';

  @override
  String get semanticsBack => 'Back';

  @override
  String get semanticsClose => 'Close';

  @override
  String get semanticsMore => 'More options';

  @override
  String get semanticsSelected => 'Selected';

  @override
  String get semanticsUnselected => 'Not selected';

  @override
  String get semanticsPlayhead => 'Playhead';

  @override
  String timelineClipLabel(int index, String duration) {
    return 'Clip $index, duration $duration';
  }

  @override
  String timelineTextLabel(String text) {
    return 'Text: $text';
  }

  @override
  String timelineAudioLabel(String name) {
    return 'Music: $name';
  }

  @override
  String get trimHandleStartLabel => 'Start handle, drag to trim';

  @override
  String get trimHandleEndLabel => 'End handle, drag to trim';

  @override
  String semanticsPosition(String time) {
    return 'Position $time';
  }

  @override
  String get detailSeparator => ' · ';

  @override
  String get navHome => 'Home';

  @override
  String get navProjects => 'Projects';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionContinue => 'Continue';

  @override
  String get homeSaved =>
      'Your projects are saved automatically on this phone.';

  @override
  String get homeStorageManage => 'Manage';

  @override
  String get modifiedJustNow => 'Just now';

  @override
  String modifiedHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String modifiedMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String get unitHoursShort => 'h';

  @override
  String get unitMinutesShort => 'min';

  @override
  String get unitSecondsShort => 's';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get unitMinuteOne => 'minute';

  @override
  String get unitMinuteOther => 'minutes';

  @override
  String get unitSecondOne => 'second';

  @override
  String get unitSecondOther => 'seconds';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String projectLineLabel(Object duration, Object title, Object when) {
    return '$title, $duration, $when';
  }

  @override
  String importDurationTotal(Object duration) {
    return 'Total duration $duration';
  }

  @override
  String importIgnoredCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ignored',
      one: '1 ignored',
    );
    return '$_temp0';
  }

  @override
  String get importIgnoredNotice => 'The unsupported media will be ignored.';

  @override
  String get importNoneUsable =>
      'None of these media can be used. Add more to continue.';

  @override
  String get importOneVideo => '1 video';

  @override
  String importVideos(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos',
      one: '1 video',
      zero: '0 videos',
    );
    return '$_temp0';
  }

  @override
  String get welcomeGuarantees => 'Garanties';

  @override
  String get homeEmptyCta => 'Start a video';

  @override
  String get homeRecentCount => 'Récents';

  @override
  String get importPicked => 'Selected media';

  @override
  String get importDateLabel => '18 oct., 14:32';

  @override
  String get editorTimecodeNow => 'Position actuelle';

  @override
  String get editorTools => 'Outils';

  @override
  String get editorClipTools => 'Outils du clip';

  @override
  String get editorSplitHint => 'Place the playhead inside the clip';

  @override
  String get editorSelectClipFirst => 'Select a clip on the timeline first.';

  @override
  String get editorPreciseTrim => 'Trim precisely';

  @override
  String get editorDuplicateClip => 'Duplicate clip';

  @override
  String get editorAddToTimeline => 'Add to timeline';

  @override
  String get editorRemoveClip => 'Remove this clip';

  @override
  String get editorSavedAt => 'Auto-save';

  @override
  String get editorTextSelected => 'Text selected';

  @override
  String get editorAudioSelected => 'Music selected';

  @override
  String get editorAutoCover => 'Automatic cover';

  @override
  String get editorCoverChosen => 'Chosen cover';

  @override
  String get editorLocked => 'Read-only during export';

  @override
  String get trimSheetTitle => 'Trim precisely';

  @override
  String get trimStartLabel => 'Début';

  @override
  String get trimEndLabel => 'Fin';

  @override
  String get trimDone => 'Terminé';

  @override
  String get textAddTitle => 'Add text';

  @override
  String get textEditTitle => 'Edit text';

  @override
  String get textInputLabel => 'Text';

  @override
  String get textFinish => 'Done';

  @override
  String get textEmptyError => 'Enter some text';

  @override
  String get textColorTitle => 'Color';

  @override
  String get textStyleTitle => 'Style';

  @override
  String get textFontTitle => 'Font';

  @override
  String get textBackgroundTitle => 'Background';

  @override
  String get textPresetPosition => 'Position';

  @override
  String get textPresetAlignLeft => 'Left';

  @override
  String get textPresetAlignCenter => 'Center';

  @override
  String get textPresetAlignRight => 'Right';

  @override
  String get textBackgroundNone => 'None';

  @override
  String get textBackgroundLight => 'Light';

  @override
  String get textBackgroundSolid => 'Solid';

  @override
  String get textColorCream => 'Ivory';

  @override
  String get textColorInk => 'Ink';

  @override
  String get textColorOrange => 'Vermilion';

  @override
  String get textColorHoney => 'Honey';

  @override
  String get textColorForest => 'Forest';

  @override
  String get textColorOcean => 'Ocean';

  @override
  String get audioMix => 'Mix';

  @override
  String get audioMuted => 'Muted';

  @override
  String get audioCustom => 'Custom';

  @override
  String get audioVolumeTitle => 'Volume and fades';

  @override
  String get audioWaveformHint => 'Drag to move, use the handles to trim.';

  @override
  String get audioPreparing => 'Preparing audio…';

  @override
  String get audioUnreadable => 'Unreadable audio';

  @override
  String get audioFadePreview => 'Fade preview';

  @override
  String adjustApplied(Object count) {
    return 'Applied to $count clips';
  }

  @override
  String get adjustResetDone => 'Settings reset';

  @override
  String get formatFillHint =>
      'Fill: the image is cropped to cover the whole frame, no bars.';

  @override
  String get cropFree => 'Free';

  @override
  String get cropGridLabel => 'Rule of thirds';

  @override
  String get coverImageInProjects => 'In your projects';

  @override
  String get coverSlideHint => 'Drag the frame to choose the image.';

  @override
  String get coverModifiedNow => 'Modified just now';

  @override
  String get coverGalleryImage => 'Gallery image';

  @override
  String get coverChooseAnother => 'Choose another image';

  @override
  String get coverUseVideoImage => 'Use a video frame';

  @override
  String get coverFromVideoLabel => 'Video frame';

  @override
  String coverPreviewSemantics(String time) {
    return 'Cover preview at $time';
  }

  @override
  String coverFrameSemantics(String time) {
    return 'Frame at $time';
  }

  @override
  String get coverForward => 'Forward one second';

  @override
  String get coverBackward => 'Back one second';

  @override
  String get coverNextImage => 'Next frame';

  @override
  String get coverPrevImage => 'Previous frame';

  @override
  String get coverExtractFailed => 'Can\'t read this image';

  @override
  String get coverCropHintShort => 'Drag to crop';

  @override
  String get coverResetAutomatic => 'Back to automatic choice';

  @override
  String get coverPickFailed => 'Can\'t open the image picker.';

  @override
  String get coverCopyFailed => 'Can\'t copy this image.';

  @override
  String exportEstimatedSize(Object size) {
    return 'Estimated size: about $size';
  }

  @override
  String exportStep(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get exportProgressLabel => 'Export progress';

  @override
  String get exportInProgress => 'Export in progress';

  @override
  String get exportGallerySaved => 'In your phone gallery';

  @override
  String get exportShare => 'Share';

  @override
  String get exportKeepEditing => 'Keep editing';

  @override
  String get exportRetry => 'Retry';

  @override
  String get exportTryStandardShort => 'Try Standard · 720p';

  @override
  String get exportSafeFileDeleted => 'The incomplete file has been deleted';

  @override
  String get exportNotLost => 'Your video is not lost';

  @override
  String get exportErrorDetails => 'Technical details';

  @override
  String get exportKeepInApp => 'conservé dans GraceEdit';

  @override
  String get exportCancelMessage =>
      'Export annulé. Votre projet n’est pas modifié.';

  @override
  String exportSpaceNeededBody(Object free, Object needed) {
    return 'About $needed are needed. $free remain.';
  }

  @override
  String get exportUnableRender =>
      'Something went wrong while creating the video. Nothing was saved to your gallery.';

  @override
  String get exportUnableGallery =>
      'The video was created but could not be added to the gallery.';

  @override
  String get exportInterruptedBody =>
      'The app was closed before it finished. Your project is intact.';

  @override
  String get exportBattery => 'Batterie très faible';

  @override
  String get projectsSortTitle => 'Sort by';

  @override
  String get projectsViewToggleGrid => 'Switch to grid view';

  @override
  String get projectsViewToggleList => 'Switch to list view';

  @override
  String projectsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projects',
      one: '1 project',
      zero: 'No projects',
    );
    return '$_temp0';
  }

  @override
  String get projectsSelectAll => 'Select all';

  @override
  String get projectsDeselectAll => 'Deselect all';

  @override
  String get projectsDuplicate => 'Duplicate';

  @override
  String get projectsDelete => 'Delete';

  @override
  String get projectsExporting => 'Exporting';

  @override
  String get projectsDuplicateDone => 'Project duplicated';

  @override
  String projectsDuplicateMany(Object count) {
    return '$count projects duplicated';
  }

  @override
  String projectsDeleted(Object count) {
    return '$count projects deleted';
  }

  @override
  String get projectsDeleteSafeNote =>
      'Your original videos and exported videos are never deleted.';

  @override
  String get projectsTrashEmpty => 'Trash is empty.';

  @override
  String get projectsTrashEmptyBody =>
      'Deleted projects appear here for 30 days.';

  @override
  String trashDeletedAgo(Object days) {
    return 'Deleted $days days ago';
  }

  @override
  String trashPurgeIn(Object days) {
    return 'Deleted in $days days';
  }

  @override
  String get trashPurgeTomorrow => 'Deleted tomorrow';

  @override
  String get trashRestore => 'Restaurer';

  @override
  String get trashDeleteForever => 'Delete permanently';

  @override
  String get trashPurgeAction => 'Vider';

  @override
  String get trashRestored => 'Project restored';

  @override
  String missingProjectLabel(Object title) {
    return 'Project: $title';
  }

  @override
  String missingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count media are missing',
      one: '1 media is missing',
    );
    return '$_temp0';
  }

  @override
  String get missingExplain =>
      'It may have been moved, renamed or deleted. Choose the file to use instead.';

  @override
  String missingUsedIn(Object count) {
    return 'Used in $count clips';
  }

  @override
  String get missingReconnected => 'Reconnected';

  @override
  String get missingChangeFile => 'Change file';

  @override
  String missingRemaining(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count media left to reconnect.',
      one: '1 media left to reconnect.',
    );
    return '$_temp0';
  }

  @override
  String get missingUseAnyway => 'Use anyway';

  @override
  String get missingFileUnreadable => 'Ce fichier ne peut pas être lu';

  @override
  String get settingsValueAsk => 'Ask';

  @override
  String get settingsValueTrash => 'Corbeille';

  @override
  String get settingsThemeSheetTitle => 'Theme';

  @override
  String get settingsLanguageSheetTitle => 'Langue';

  @override
  String get settingsDeletionSheetTitle => 'Suppression';

  @override
  String get storageGraceEditUses => 'GraceEdit uses';

  @override
  String get storageCacheThumbs => 'Cache and thumbnails';

  @override
  String get storageUnregistered => 'Unregistered exports';

  @override
  String get storageTrash => 'Corbeille';

  @override
  String get storageFreePhone => 'Free space on phone';

  @override
  String get storageClear => 'Clear';

  @override
  String get storageNothingToClear => 'Rien à vider';

  @override
  String get storageCacheBody => 'Recreated when needed';

  @override
  String get storageLive => 'Espace libre';

  @override
  String get helpAbout => 'À propos';

  @override
  String get helpReplayCta => 'Revoir la présentation';

  @override
  String get helpDiagnosticTitle => 'Rapport de diagnostic';

  @override
  String get helpDiagnosticIntro =>
      'This report helps understand a problem. It is created on your phone and never sent automatically.';

  @override
  String get helpContains => 'What it contains';

  @override
  String get helpNotContains => 'What it does not contain';

  @override
  String get helpDiagDevice => 'Modèle de l’appareil et version d’Android';

  @override
  String get helpDiagVersion => 'Version de GraceEdit';

  @override
  String get helpDiagSpace => 'Espace libre et mémoire';

  @override
  String get helpDiagErrors => 'Derniers événements d’erreur';

  @override
  String get helpDiagNoVideos => 'Vos vidéos, vos photos, vos projets';

  @override
  String get helpDiagNoIdentity => 'Votre nom, votre position';

  @override
  String get helpDiagCopy => 'Copy report';

  @override
  String get helpDiagShare => 'Share';

  @override
  String get helpDiagCopied => 'Report copied';

  @override
  String get helpLicensesBody =>
      'Inter font (SIL OFL licence) · Flutter (BSD licence) · Media3 (Apache 2.0 licence)';

  @override
  String get helpTermsBody =>
      'GraceEdit is provided as is, for personal use. You remain responsible for the videos you edit and share. No data is collected.';

  @override
  String get helpPrivacyBody =>
      'GraceEdit creates no account, does not access the network and sends no data. Your projects, settings and videos stay on your device.';

  @override
  String recoverySavedAgo(Object when) {
    return 'Last save $when';
  }

  @override
  String get recoveryLater => 'Plus tard';

  @override
  String get recoverySafe =>
      'GraceEdit closed unexpectedly. Your work has been recovered.';

  @override
  String get saveFailedSheetTitle => 'Your changes are not saved';

  @override
  String get saveFailedSheetBody =>
      'The phone could not save the project: it is running out of space. Do not close the app before fixing this.';

  @override
  String get saveRetry => 'Retry';

  @override
  String get saveFreeSpace => 'Free up space';

  @override
  String get storageFullSafe => 'Your projects are safe.';

  @override
  String get storageFullLater => 'Later';

  @override
  String get storageFullTrash => 'View trash';

  @override
  String get unsupportedOptionTitle => 'Option unavailable';

  @override
  String get unsupportedOptionBody =>
      'Your phone cannot export in 1080p. Choose Standard · 720p.';

  @override
  String get unsupportedChooseStandard => 'Choose Standard · 720p';

  @override
  String get unsupportedClose => 'Fermer';

  @override
  String get notificationWhy =>
      'GraceEdit can show progress and let you know when the video is ready. Export works without notifications too.';

  @override
  String get notificationAllow => 'Allow notifications';

  @override
  String get notificationLater => 'Not now';

  @override
  String get permissionContinue => 'Continue';

  @override
  String get permissionChooseFiles => 'Choose files one by one';

  @override
  String get permissionSafe1 => 'Vous choisissez ce que GraceEdit peut voir.';

  @override
  String get permissionSafe2 => 'Rien n’est envoyé en ligne.';

  @override
  String get permissionDeniedPermission =>
      'Sans cet accès, GraceEdit ne peut pas afficher vos vidéos. Autorisez-le dans les réglages ou choisissez les fichiers un par un.';

  @override
  String get commonView => 'View';

  @override
  String get commonLater => 'Later';

  @override
  String get commonManage => 'Manage';

  @override
  String get commonThisClip => 'This clip';

  @override
  String get commonWholeProject => 'Whole project';

  @override
  String get commonOriginal => 'Original';

  @override
  String get commonCompare => 'Compare';

  @override
  String get commonReset => 'Reset';

  @override
  String commonStep(Object current, Object total) {
    return 'Étape $current sur $total';
  }

  @override
  String commonSeconds(Object seconds) {
    return '$seconds s';
  }

  @override
  String commonMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String commonDays(Object days) {
    return '$days j';
  }

  @override
  String commonPercent(Object percent) {
    return '$percent %';
  }

  @override
  String commonGigabytes(Object value) {
    return '$value Go';
  }

  @override
  String commonMegabytes(Object value) {
    return '$value Mo';
  }

  @override
  String commonSizeAndDuration(Object duration, Object size) {
    return '$size · $duration';
  }

  @override
  String get commonDone => 'Done';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonOpen => 'Open';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonPrevious => 'Précédent';

  @override
  String get commonPlay => 'Play';

  @override
  String get commonPause => 'Pause';

  @override
  String get commonMore => 'More';

  @override
  String get commonLess => 'Less';

  @override
  String get commonSaved => 'Saved';

  @override
  String get commonSaving => 'Saving…';

  @override
  String get commonNotSaved => 'Not saved';

  @override
  String get commonAuto => 'Automatic';

  @override
  String get settingsAccessibility => 'Accessibility';

  @override
  String get settingsMotionHint => 'Follows the device setting';

  @override
  String get settingsStorageHelp => 'Storage and help';

  @override
  String get settingsStorageCache => 'Storage and cache';
}
