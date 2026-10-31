// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'GraceEdit';

  @override
  String get brandTagline => 'Montez vos vidéos, simplement.';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionRename => 'Renommer';

  @override
  String get actionDuplicate => 'Dupliquer';

  @override
  String get actionExport => 'Exporter';

  @override
  String get actionShare => 'Partager';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionOpen => 'Ouvrir';

  @override
  String get actionSelect => 'Sélectionner';

  @override
  String get actionSelectAll => 'Tout sélectionner';

  @override
  String get actionMoveUp => 'Monter';

  @override
  String get actionMoveDown => 'Descendre';

  @override
  String get actionRemove => 'Retirer';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionRestore => 'Restaurer';

  @override
  String get actionUndo => 'Annuler';

  @override
  String get actionRedo => 'Rétablir';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionMore => 'Plus';

  @override
  String get actionLess => 'Moins';

  @override
  String get actionPlay => 'Lire';

  @override
  String get actionPause => 'Pause';

  @override
  String get saveStateSaved => 'Enregistré';

  @override
  String get saveStateSaving => 'Enregistrement…';

  @override
  String get saveStateFailed => 'Non enregistré';

  @override
  String get projectSaved => 'Projet enregistré';

  @override
  String get toastClipDeleted => 'Clip supprimé';

  @override
  String get toastClipSplit => 'Clip scindé';

  @override
  String get toastTextDeleted => 'Texte supprimé';

  @override
  String get toastAudioDeleted => 'Musique supprimée';

  @override
  String get toastProjectTrashed => 'Projet déplacé dans la corbeille';

  @override
  String get toastProjectsTrashed => 'Projets déplacés dans la corbeille';

  @override
  String get toastProjectRestored => 'Projet restauré';

  @override
  String get toastMediaRemoved => 'Média retiré du projet';

  @override
  String get toastExportCancelled => 'Export annulé';

  @override
  String get toastCoverUpdated => 'Couverture mise à jour';

  @override
  String get splashLoadingSemantics => 'GraceEdit, chargement';

  @override
  String get splashPreparing => 'Préparation en cours…';

  @override
  String get splashSlowHint => 'Cela prend plus de temps que d\'habitude.';

  @override
  String get splashErrorTitle => 'L\'application n\'a pas pu démarrer.';

  @override
  String get splashErrorBody =>
      'Vos projets sont intacts. Fermez les autres applications, puis réessayez.';

  @override
  String get splashRetry => 'Réessayer';

  @override
  String get welcomeTitle => 'Montez vos vidéos, simplement.';

  @override
  String get welcomeBody =>
      'Importez une vidéo, coupez, ajoutez du texte, puis exportez.';

  @override
  String get welcomeGuaranteeNoAccount => 'Aucun compte nécessaire';

  @override
  String get welcomeGuaranteeOffline => 'Fonctionne sans connexion';

  @override
  String get welcomeGuaranteeLocal =>
      'Vos fichiers restent sur votre téléphone';

  @override
  String get welcomeStart => 'Monter une vidéo';

  @override
  String get welcomeExplore => 'Explorer d\'abord';

  @override
  String get homeResume => 'Reprendre';

  @override
  String get homeRecent => 'Récents';

  @override
  String get homeSeeAll => 'Tout voir';

  @override
  String get homeNewProject => 'Nouveau projet';

  @override
  String get homeEmptyTitle => 'Créez votre premier projet';

  @override
  String get homeEmptyBody =>
      'Choisissez une vidéo, coupez-la, ajoutez du texte, puis exportez.';

  @override
  String get homeMissingMedia => 'Média manquant';

  @override
  String get homeExportRunning => 'Export en cours';

  @override
  String get homeExportRunningBody => 'Votre vidéo est en préparation.';

  @override
  String homeStorageLow(String free) {
    return 'Stockage faible : $free libres.';
  }

  @override
  String get homeDraftRecovered => 'Brouillon récupéré';

  @override
  String homeProjectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projets',
      one: '1 projet',
      zero: 'Aucun projet',
    );
    return '$_temp0';
  }

  @override
  String modifiedAt(String when) {
    return 'Modifié $when';
  }

  @override
  String get importTitle => 'Nouveau projet';

  @override
  String get importNameLabel => 'Nom du projet';

  @override
  String importDefaultName(String date) {
    return 'Projet du $date';
  }

  @override
  String importMediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count médias',
      one: '1 média',
      zero: 'Aucun média',
    );
    return '$_temp0';
  }

  @override
  String get importAddMedia => 'Ajouter des médias';

  @override
  String get importStart => 'Commencer le montage';

  @override
  String importStartWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Commencer avec $count médias',
      one: 'Commencer avec 1 média',
    );
    return '$_temp0';
  }

  @override
  String importPreparing(int percent) {
    return 'Préparation $percent %';
  }

  @override
  String get importUnsupported => 'Format non pris en charge';

  @override
  String get importUnreadable => 'Fichier illisible';

  @override
  String get importRemoveFromProject => 'Retirer du projet';

  @override
  String get importAddHint =>
      'Vos fichiers d\'origine ne sont jamais modifiés.';

  @override
  String get editorUntitled => 'Sans titre';

  @override
  String get editorAdd => 'Ajouter';

  @override
  String get editorAudio => 'Audio';

  @override
  String get editorText => 'Texte';

  @override
  String get editorAdjust => 'Ajuster';

  @override
  String get editorFormat => 'Format';

  @override
  String get editorCover => 'Couverture';

  @override
  String get editorSplit => 'Scinder';

  @override
  String get editorVolume => 'Volume';

  @override
  String get editorCrop => 'Cadrer';

  @override
  String get editorDelete => 'Supprimer';

  @override
  String get editorDuplicate => 'Dupliquer';

  @override
  String get editorEmptyTitle => 'Votre timeline est vide.';

  @override
  String get editorEmptyBody => 'Ajoutez une vidéo pour commencer.';

  @override
  String get editorAddMedia => 'Ajouter un média';

  @override
  String get editorMissingMedia => 'Média manquant';

  @override
  String get editorReconnect => 'Reconnecter';

  @override
  String get editorTextTrack => 'Textes';

  @override
  String get editorAudioTrack => 'Audio';

  @override
  String get editorVideoTrack => 'Vidéo';

  @override
  String get editorTimeline => 'Timeline';

  @override
  String get editorPreview => 'Aperçu';

  @override
  String get editorSaveFailed => 'La sauvegarde a échoué.';

  @override
  String get editorSaveFailedBody =>
      'Votre travail est conservé sur cet appareil. Vérifiez l\'espace libre, puis réessayez.';

  @override
  String get editorRetrySave => 'Réessayer';

  @override
  String get editorZoomIn => 'Zoom avant';

  @override
  String get editorZoomOut => 'Zoom arrière';

  @override
  String get editorClipActions => 'Actions du clip';

  @override
  String get trimTitle => 'Rogner';

  @override
  String get trimStart => 'Début';

  @override
  String get trimEnd => 'Fin';

  @override
  String trimRemoved(String duration) {
    return '−$duration';
  }

  @override
  String trimDurationLabel(String duration) {
    return 'Durée $duration';
  }

  @override
  String get trimMinimum => 'Durée minimale : 0,1 s.';

  @override
  String get textTitle => 'Texte';

  @override
  String get textFieldLabel => 'Votre texte';

  @override
  String get textPlaceholder => 'Écrivez ici';

  @override
  String get textPresetTitle => 'Titre';

  @override
  String get textPresetSubtitle => 'Sous-titre';

  @override
  String get textPresetCaption => 'Légende';

  @override
  String get textEdit => 'Modifier';

  @override
  String get textStyle => 'Style';

  @override
  String get textColor => 'Couleur';

  @override
  String get textTabStyle => 'Style';

  @override
  String get textTabFont => 'Police';

  @override
  String get textTabColor => 'Couleur';

  @override
  String get textTabBackground => 'Fond';

  @override
  String get textSize => 'Taille';

  @override
  String get textOpacity => 'Opacité';

  @override
  String get textPosition => 'Position';

  @override
  String get textRotation => 'Rotation';

  @override
  String get textBackgroundOn => 'Fond derrière le texte';

  @override
  String get textColorWhite => 'Blanc';

  @override
  String get textColorBlack => 'Noir';

  @override
  String get textColorAccent => 'Orange';

  @override
  String get textColorIvory => 'Ivoire';

  @override
  String get textColorSlate => 'Ardoise';

  @override
  String get textColorGreen => 'Vert';

  @override
  String get textMoveHint =>
      'Faites glisser pour déplacer, pincez pour redimensionner.';

  @override
  String get textRotationHint => 'Rotation par pas de 15°.';

  @override
  String get audioTitle => 'Audio';

  @override
  String get audioVideoSound => 'Son de la vidéo';

  @override
  String get audioMusic => 'Musique';

  @override
  String get audioMute => 'Couper le son';

  @override
  String get audioUnmute => 'Rétablir le son';

  @override
  String get audioAddMusic => 'Ajouter de la musique';

  @override
  String get audioMusicHint =>
      'La musique démarre à la tête de lecture et s\'arrête à la fin du projet.';

  @override
  String get audioVolumeLabel => 'Volume';

  @override
  String get audioFade => 'Fondu';

  @override
  String get audioFadeIn => 'Fondu d\'entrée';

  @override
  String get audioFadeOut => 'Fondu de sortie';

  @override
  String get audioFadeTooLong => 'La somme des fondus dépasse la durée du son.';

  @override
  String audioVolumePercent(int percent) {
    return '$percent %';
  }

  @override
  String audioFadeSeconds(String seconds) {
    return '$seconds s';
  }

  @override
  String get adjustTitle => 'Ajuster';

  @override
  String get adjustBrightness => 'Luminosité';

  @override
  String get adjustContrast => 'Contraste';

  @override
  String get adjustSaturation => 'Saturation';

  @override
  String get adjustScope => 'Portée';

  @override
  String get adjustScopeClip => 'Ce clip';

  @override
  String get adjustScopeAll => 'Tout le projet';

  @override
  String get adjustCompare => 'Comparer';

  @override
  String get adjustCompareHint => 'Maintenez pour voir l\'original.';

  @override
  String get adjustReset => 'Réinitialiser';

  @override
  String get formatTitle => 'Format';

  @override
  String get formatVertical => 'Vertical 9:16';

  @override
  String get formatSquare => 'Carré 1:1';

  @override
  String get formatHorizontal => 'Horizontal 16:9';

  @override
  String get formatPortrait => 'Portrait 4:5';

  @override
  String get formatFitMode => 'Cadrage';

  @override
  String get formatFill => 'Remplir';

  @override
  String get formatFit => 'Ajuster';

  @override
  String get formatFitHint =>
      'Ajuster : l’image entière est gardée, avec des bandes noires.';

  @override
  String get cropTitle => 'Cadrer';

  @override
  String get cropRotate => 'Pivoter';

  @override
  String get cropMirror => 'Miroir';

  @override
  String get cropStraighten => 'Redresser';

  @override
  String get cropReset => 'Réinitialiser';

  @override
  String get cropGrid => 'Grille des tiers';

  @override
  String get coverTitle => 'Couverture';

  @override
  String get coverFromVideo => 'Image de la vidéo';

  @override
  String get coverFromGallery => 'Galerie';

  @override
  String get coverAuto => 'Automatique';

  @override
  String get coverAutoBody => 'La première image de la vidéo est utilisée.';

  @override
  String get coverUsage => 'Dans vos projets';

  @override
  String get coverPickImage => 'Choisir une image';

  @override
  String get coverCropHint => 'Glissez pour recadrer, pincez pour zoomer.';

  @override
  String get coverReset => 'Revenir à l\'image de la vidéo';

  @override
  String get exportTitle => 'Exporter';

  @override
  String get exportSummary => 'Récapitulatif';

  @override
  String get exportDuration => 'Durée';

  @override
  String get exportFormatLabel => 'Format';

  @override
  String get exportQuality => 'Qualité';

  @override
  String get exportQualityHigh => 'Haute · 1080p';

  @override
  String get exportQualityStandard => 'Standard · 720p';

  @override
  String get exportFramesPerSecond => '30 images/s';

  @override
  String get exportDestination => 'Destination';

  @override
  String get exportDestinationGallery => 'Galerie du téléphone';

  @override
  String get exportSpaceFree => 'Espace disponible';

  @override
  String get exportSpaceNeeded => 'Espace nécessaire';

  @override
  String get exportNotEnoughSpaceTitle => 'Espace insuffisant';

  @override
  String exportNotEnoughSpaceBody(String needed, String free) {
    return 'Il faut environ $needed. Il reste $free. Libérez de l\'espace pour continuer.';
  }

  @override
  String get exportDisabledEmpty => 'Ajoutez au moins un clip pour exporter.';

  @override
  String get exportDisabledMissing =>
      'Reconnectez le média manquant pour exporter.';

  @override
  String get exportBatteryLow =>
      'Batterie faible : l\'export peut s\'interrompre.';

  @override
  String get exportNotificationsTitle => 'Être prévenu à la fin de l\'export ?';

  @override
  String get exportNotificationsBody =>
      'GraceEdit peut afficher la progression et vous prévenir quand la vidéo est prête. L\'export fonctionne aussi sans notification.';

  @override
  String get exportNotificationsAllow => 'Autoriser les notifications';

  @override
  String get exportNotificationsLater => 'Pas maintenant';

  @override
  String get exportPreparing => 'Préparation…';

  @override
  String get exportRendering => 'Création de la vidéo';

  @override
  String get exportVerifying => 'Vérification…';

  @override
  String exportElapsed(String duration) {
    return 'Temps écoulé : $duration';
  }

  @override
  String get exportBackground => 'Continuer en arrière-plan';

  @override
  String get exportCancel => 'Annuler l\'export';

  @override
  String get exportCancelTitle => 'Annuler l\'export ?';

  @override
  String get exportCancelBody =>
      'La vidéo en cours sera supprimée. Votre projet reste intact.';

  @override
  String get exportCancelKeep => 'Continuer l\'export';

  @override
  String get exportCancelConfirm => 'Annuler l\'export';

  @override
  String get exportSuccessTitle => 'Vidéo enregistrée';

  @override
  String get exportSuccessBody =>
      'Votre vidéo est dans la galerie du téléphone.';

  @override
  String get exportSuccessName => 'Nom';

  @override
  String get exportSuccessDimensions => 'Dimensions';

  @override
  String get exportSuccessDuration => 'Durée';

  @override
  String get exportSuccessSize => 'Taille';

  @override
  String get exportViewInGallery => 'Voir dans la galerie';

  @override
  String get exportContinueEditing => 'Continuer à modifier';

  @override
  String get exportFailedTitle => 'L\'export n\'a pas abouti';

  @override
  String get exportFailedSafe => 'Votre projet est intact.';

  @override
  String get exportFailedRender => 'La vidéo n\'a pas pu être créée.';

  @override
  String get exportFailedStorage =>
      'L\'espace libre s\'est épuisé pendant la création.';

  @override
  String get exportFailedGallery =>
      'La vidéo a été créée mais n\'a pas pu être ajoutée à la galerie.';

  @override
  String get exportFailedInterrupted => 'L\'export a été interrompu.';

  @override
  String get exportFailedCancelled => 'L\'export a été annulé.';

  @override
  String get exportTryStandard => 'Exporter en Standard';

  @override
  String get exportDetails => 'Détails techniques';

  @override
  String get exportFreeSpace => 'Libérer de l’espace';

  @override
  String get exportRetryGallery => 'Réessayer l\'ajout';

  @override
  String get exportSaveAs => 'Enregistrer sous…';

  @override
  String get exportRestart => 'Recommencer l\'export';

  @override
  String get exportVerifyingFile => 'Vérification du fichier…';

  @override
  String get exportRegistering => 'Ajout à la galerie…';

  @override
  String get projectsTitle => 'Projets';

  @override
  String get projectsSearch => 'Rechercher un projet';

  @override
  String get projectsSearchClear => 'Effacer la recherche';

  @override
  String get projectsSort => 'Trier';

  @override
  String get projectsSortRecent => 'Récents';

  @override
  String get projectsSortOldest => 'Plus anciens';

  @override
  String get projectsSortName => 'Nom A–Z';

  @override
  String get projectsViewGrid => 'Grille';

  @override
  String get projectsViewList => 'Liste';

  @override
  String get projectsTrash => 'Corbeille';

  @override
  String projectsSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '1 sélectionné',
      zero: '0 sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get projectsEmptyTitle => 'Aucun projet';

  @override
  String get projectsEmptyBody => 'Vos montages apparaîtront ici.';

  @override
  String get projectsNoResultsTitle => 'Aucun résultat';

  @override
  String get projectsNoResultsBody => 'Essayez un autre titre.';

  @override
  String projectsDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer $count projets ?',
      one: 'Supprimer ce projet ?',
    );
    return '$_temp0';
  }

  @override
  String projectsDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ils resteront 30 jours dans la corbeille, puis seront supprimés.',
      one: 'Il restera 30 jours dans la corbeille, puis sera supprimé.',
    );
    return '$_temp0';
  }

  @override
  String get projectsToTrash => 'Mettre à la corbeille';

  @override
  String get projectsDeleteForever => 'Supprimer définitivement';

  @override
  String get projectsDeleteForeverTitle => 'Supprimer définitivement ?';

  @override
  String get projectsDeleteForeverSingularBody =>
      'Ce projet ne pourra pas être récupéré.';

  @override
  String get projectsDeleteForeverPluralBody =>
      'Ces projets ne pourront pas être récupérés.';

  @override
  String get projectsDeleteForeverAction => 'Supprimer définitivement';

  @override
  String get projectsDeletedForever => 'Supprimé définitivement';

  @override
  String get projectsExportingLocked =>
      'Un projet en cours d\'export ne peut pas être supprimé.';

  @override
  String get projectsRenameTitle => 'Renommer';

  @override
  String get projectsRenameEmpty => 'Le nom ne peut pas être vide.';

  @override
  String get projectsRenameTooLong => '60 caractères maximum.';

  @override
  String projectsDuplicateSuffix(String name) {
    return '$name (copie)';
  }

  @override
  String projectsMenu(String name) {
    return 'Actions du projet $name';
  }

  @override
  String projectsOpen(String name) {
    return 'Ouvrir $name';
  }

  @override
  String get trashTitle => 'Corbeille';

  @override
  String get trashEmpty => 'La corbeille est vide.';

  @override
  String get trashBody => 'Les projets supprimés restent 30 jours ici.';

  @override
  String trashDaysLeft(int days) {
    return 'Encore $days jours';
  }

  @override
  String get trashLastDay => 'Suppression demain';

  @override
  String get trashPurge => 'Vider la corbeille';

  @override
  String get trashPurgeTitle => 'Vider la corbeille ?';

  @override
  String get trashPurgeBody =>
      'Tous les projets de la corbeille seront supprimés pour toujours.';

  @override
  String get trashPurged => 'Corbeille vidée';

  @override
  String get missingTitle => 'Média manquant';

  @override
  String get missingBody =>
      'GraceEdit ne trouve plus ce fichier. Il a peut-être été déplacé ou supprimé.';

  @override
  String get missingReconnect => 'Reconnecter';

  @override
  String get missingRemove => 'Retirer du projet';

  @override
  String get missingOpen => 'Ouvrir le projet';

  @override
  String get missingOpenWithout => 'Ouvrir sans ces médias';

  @override
  String get missingDifferentTitle => 'Ce fichier est différent';

  @override
  String missingDifferentBody(Object newDuration, Object oldDuration) {
    return 'Le fichier choisi dure $newDuration, l’original durait $oldDuration. Les coupes et les textes de ce clip risquent d’être décalés.';
  }

  @override
  String get missingChooseAnother => 'Choisir un autre fichier';

  @override
  String get missingAllGood => 'Tous les médias sont reconnectés.';

  @override
  String get missingFileLabel => 'Fichier';

  @override
  String missingSeveral(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count médias manquants',
      one: '1 média manquant',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Langue du téléphone';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsMotion => 'Réduire les animations';

  @override
  String get settingsHaptics => 'Retour haptique';

  @override
  String get settingsDeletion => 'Suppression';

  @override
  String get settingsDeletionAsk => 'Demander à chaque fois';

  @override
  String get settingsDeletionTrash => 'Toujours mettre à la corbeille';

  @override
  String get settingsTrash => 'Corbeille';

  @override
  String get settingsStorage => 'Stockage';

  @override
  String get settingsHelp => 'Aide et à propos';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get storageTitle => 'Stockage';

  @override
  String get storageUsed => 'Utilisé';

  @override
  String get storageProjects => 'Projets';

  @override
  String get storageCovers => 'Couvertures';

  @override
  String get storageExports => 'Exports non enregistrés';

  @override
  String get storageThumbnails => 'Miniatures';

  @override
  String get storageFree => 'Espace libre';

  @override
  String get storageClearCache => 'Vider le cache';

  @override
  String get storageClearCacheBody =>
      'Les miniatures et les exports non enregistrés seront supprimés. Vos projets et vos médias ne sont pas touchés.';

  @override
  String storageCleared(String size) {
    return 'Cache vidé · $size libérés';
  }

  @override
  String get storageComputing => 'Calcul en cours…';

  @override
  String get helpTitle => 'Aide et à propos';

  @override
  String get helpReplay => 'Revoir la présentation';

  @override
  String get helpFaq => 'Questions fréquentes';

  @override
  String get helpDiagnostic => 'Rapport de diagnostic';

  @override
  String get helpDiagnosticBody =>
      'Généré sur votre téléphone. Il n\'est jamais envoyé automatiquement.';

  @override
  String get helpDiagnosticCreate => 'Créer le rapport';

  @override
  String get helpDiagnosticCopy => 'Copier';

  @override
  String get helpDiagnosticShare => 'Partager';

  @override
  String get helpDiagnosticCopied => 'Rapport copié';

  @override
  String get helpLicenses => 'Licences';

  @override
  String get helpTerms => 'Conditions d\'utilisation';

  @override
  String get helpPrivacy => 'Confidentialité';

  @override
  String get helpVersion => 'Version';

  @override
  String get helpFaqQ1 => 'Où sont mes vidéos ?';

  @override
  String get helpFaqA1 =>
      'Sur votre téléphone, à l\'endroit où vous les avez enregistrées. GraceEdit ne les copie pas et ne les modifie pas.';

  @override
  String get helpFaqQ2 => 'Pourquoi aucun compte ?';

  @override
  String get helpFaqA2 =>
      'GraceEdit fonctionne hors connexion. Aucun réglage ni projet n\'est envoyé quelque part.';

  @override
  String get helpFaqQ3 => 'Que se passe-t-il si je supprime un projet ?';

  @override
  String get helpFaqA3 =>
      'Il part dans la corbeille pendant 30 jours. Passé ce délai, il est supprimé définitivement.';

  @override
  String get helpFaqQ4 => 'Puis-je retrouver un média déplacé ?';

  @override
  String get helpFaqA4 =>
      'Oui : ouvrez le projet, puis « Reconnecter » et choisissez le fichier au nouvel emplacement.';

  @override
  String get helpFaqQ5 =>
      'Pourquoi l\'export est-il plus lent sur certains téléphones ?';

  @override
  String get helpFaqA5 =>
      'Le rendu utilise l\'encodeur de l\'appareil. Choisissez la qualité Standard pour aller plus vite.';

  @override
  String get helpFaqQ6 => 'Mes vidéos sont-elles envoyées en ligne ?';

  @override
  String get helpFaqA6 =>
      'Non. Aucun envoi n\'est effectué, ni pendant le montage ni pendant l\'export.';

  @override
  String get termsBody =>
      'GraceEdit est fourni tel quel, pour un usage personnel. Vous restez responsable des vidéos que vous montez et partagez. Aucune donnée n\'est collectée.';

  @override
  String get privacyBody =>
      'GraceEdit ne crée pas de compte, n\'accède pas au réseau et n\'envoie aucune donnée. Vos projets, réglages et vidéos restent sur votre appareil.';

  @override
  String get recoveryTitle => 'Reprendre où vous en étiez ?';

  @override
  String get recoveryBody =>
      'GraceEdit s\'est fermé de façon inattendue. Votre travail a été récupéré.';

  @override
  String get recoveryResume => 'Reprendre le projet';

  @override
  String get recoveryDiscard => 'Ignorer';

  @override
  String get storageLowTitle => 'Stockage faible';

  @override
  String storageLowBody(String free) {
    return 'Il reste $free. L\'export peut échouer.';
  }

  @override
  String get storageFullTitle => 'Plus assez d\'espace sur le téléphone';

  @override
  String get storageFullBody =>
      'GraceEdit ne peut plus enregistrer ni importer. Libérez de l\'espace pour continuer.';

  @override
  String get storageManage => 'Gérer';

  @override
  String get unsupportedTitle => 'Format non pris en charge';

  @override
  String get unsupportedBody =>
      'Ce fichier ne peut pas être lu sur cet appareil.';

  @override
  String get unsupportedChoose => 'Choisir un autre fichier';

  @override
  String get permissionTitle => 'Autoriser l\'accès aux médias';

  @override
  String get permissionBody =>
      'Le sélecteur du système n\'est pas disponible sur cet appareil. GraceEdit a besoin de votre autorisation pour ouvrir vos vidéos.';

  @override
  String get permissionAllow => 'Autoriser';

  @override
  String get permissionDeniedTitle => 'Accès refusé';

  @override
  String get permissionDeniedBody =>
      'Sans autorisation, GraceEdit ne peut pas ouvrir vos vidéos. Vous pouvez l\'accorder dans les réglages du téléphone.';

  @override
  String get permissionOpenSettings => 'Ouvrir les réglages';

  @override
  String get pickerUnavailable =>
      'Le sélecteur de fichiers n\'est pas disponible.';

  @override
  String get pickerUnavailableBody =>
      'Fermez les applications qui pourraient l\'occuper, puis réessayez.';

  @override
  String get errorGenericTitle => 'Une erreur est survenue';

  @override
  String get errorGenericBody =>
      'Vos projets sont intacts. Réessayez ; si le problème continue, redémarrez l\'application.';

  @override
  String get semanticsBack => 'Retour';

  @override
  String get semanticsClose => 'Fermer';

  @override
  String get semanticsMore => 'Plus d\'options';

  @override
  String get semanticsSelected => 'Sélectionné';

  @override
  String get semanticsUnselected => 'Non sélectionné';

  @override
  String get semanticsPlayhead => 'Tête de lecture';

  @override
  String timelineClipLabel(int index, String duration) {
    return 'Clip $index, durée $duration';
  }

  @override
  String timelineTextLabel(String text) {
    return 'Texte : $text';
  }

  @override
  String timelineAudioLabel(String name) {
    return 'Musique : $name';
  }

  @override
  String get trimHandleStartLabel =>
      'Poignée de début, faire glisser pour rogner';

  @override
  String get trimHandleEndLabel => 'Poignée de fin, faire glisser pour rogner';

  @override
  String semanticsPosition(String time) {
    return 'Position $time';
  }

  @override
  String get detailSeparator => ' · ';

  @override
  String get navHome => 'Accueil';

  @override
  String get navProjects => 'Projets';

  @override
  String get navSettings => 'Réglages';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get homeSaved =>
      'Vos projets sont enregistrés automatiquement sur ce téléphone.';

  @override
  String get homeStorageManage => 'Gérer';

  @override
  String get modifiedJustNow => 'À l’instant';

  @override
  String modifiedHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count h',
      one: 'il y a 1 h',
    );
    return '$_temp0';
  }

  @override
  String modifiedMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count min',
      one: 'il y a 1 min',
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
  String get dateYesterday => 'Hier';

  @override
  String get unitMinuteOne => 'minute';

  @override
  String get unitMinuteOther => 'minutes';

  @override
  String get unitSecondOne => 'seconde';

  @override
  String get unitSecondOther => 'secondes';

  @override
  String get monthJan => 'janv.';

  @override
  String get monthFeb => 'févr.';

  @override
  String get monthMar => 'mars';

  @override
  String get monthApr => 'avr.';

  @override
  String get monthMay => 'mai';

  @override
  String get monthJun => 'juin';

  @override
  String get monthJul => 'juil.';

  @override
  String get monthAug => 'août';

  @override
  String get monthSep => 'sept.';

  @override
  String get monthOct => 'oct.';

  @override
  String get monthNov => 'nov.';

  @override
  String get monthDec => 'déc.';

  @override
  String projectLineLabel(Object duration, Object title, Object when) {
    return '$title, $duration, $when';
  }

  @override
  String importDurationTotal(Object duration) {
    return 'Durée totale $duration';
  }

  @override
  String importIgnoredCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ignorés',
      one: '1 ignoré',
    );
    return '$_temp0';
  }

  @override
  String get importIgnoredNotice => 'Le média non pris en charge sera ignoré.';

  @override
  String get importNoneUsable =>
      'Aucun de ces médias ne peut être utilisé. Ajoutez-en d’autres pour continuer.';

  @override
  String get importOneVideo => '1 vidéo';

  @override
  String importVideos(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vidéos',
      one: '1 vidéo',
      zero: '0 vidéo',
    );
    return '$_temp0';
  }

  @override
  String get welcomeGuarantees => 'Garanties';

  @override
  String get homeEmptyCta => 'Monter une vidéo';

  @override
  String get homeRecentCount => 'Récents';

  @override
  String get importPicked => 'Médias choisis';

  @override
  String get importDateLabel => '18 oct., 14:32';

  @override
  String get editorTimecodeNow => 'Position actuelle';

  @override
  String get editorTools => 'Outils';

  @override
  String get editorClipTools => 'Outils du clip';

  @override
  String get editorSplitHint =>
      'Placez la tête de lecture à l’intérieur du clip';

  @override
  String get editorSelectClipFirst =>
      'Sélectionnez d’abord un clip de la timeline.';

  @override
  String get editorPreciseTrim => 'Rogner précisément';

  @override
  String get editorDuplicateClip => 'Dupliquer le clip';

  @override
  String get editorAddToTimeline => 'Ajouter à la timeline';

  @override
  String get editorRemoveClip => 'Retirer ce clip';

  @override
  String get editorSavedAt => 'Sauvegarde automatique';

  @override
  String get editorTextSelected => 'Texte sélectionné';

  @override
  String get editorAudioSelected => 'Musique sélectionnée';

  @override
  String get editorAutoCover => 'Couverture automatique';

  @override
  String get editorCoverChosen => 'Couverture choisie';

  @override
  String get editorLocked => 'Lecture seule pendant l’export';

  @override
  String get trimSheetTitle => 'Rogner précisément';

  @override
  String get trimStartLabel => 'Début';

  @override
  String get trimEndLabel => 'Fin';

  @override
  String get trimDone => 'Terminé';

  @override
  String get textAddTitle => 'Ajouter du texte';

  @override
  String get textEditTitle => 'Modifier le texte';

  @override
  String get textInputLabel => 'Texte';

  @override
  String get textFinish => 'Terminé';

  @override
  String get textEmptyError => 'Saisissez un texte';

  @override
  String get textColorTitle => 'Couleur';

  @override
  String get textStyleTitle => 'Style';

  @override
  String get textFontTitle => 'Police';

  @override
  String get textBackgroundTitle => 'Fond';

  @override
  String get textPresetPosition => 'Position';

  @override
  String get textPresetAlignLeft => 'Gauche';

  @override
  String get textPresetAlignCenter => 'Centré';

  @override
  String get textPresetAlignRight => 'Droite';

  @override
  String get textBackgroundNone => 'Aucun';

  @override
  String get textBackgroundLight => 'Léger';

  @override
  String get textBackgroundSolid => 'Plein';

  @override
  String get textColorCream => 'Ivoire';

  @override
  String get textColorInk => 'Encre';

  @override
  String get textColorOrange => 'Vermillon';

  @override
  String get textColorHoney => 'Miel';

  @override
  String get textColorForest => 'Forêt';

  @override
  String get textColorOcean => 'Océan';

  @override
  String get audioMix => 'Mixage';

  @override
  String get audioMuted => 'Coupé';

  @override
  String get audioCustom => 'Personnalisé';

  @override
  String get audioVolumeTitle => 'Volume et fondus';

  @override
  String get audioWaveformHint =>
      'Faites glisser pour déplacer, les poignées pour rogner.';

  @override
  String get audioPreparing => 'Préparation de l’audio…';

  @override
  String get audioUnreadable => 'Audio illisible';

  @override
  String get audioFadePreview => 'Aperçu des fondus';

  @override
  String adjustApplied(Object count) {
    return 'Appliqué à $count clips';
  }

  @override
  String get adjustResetDone => 'Réglages réinitialisés';

  @override
  String get formatFillHint =>
      'Remplir : l’image est recadrée pour couvrir tout le cadre, sans bandes.';

  @override
  String get cropFree => 'Libre';

  @override
  String get cropGridLabel => 'Grille des tiers';

  @override
  String get coverImageInProjects => 'Dans vos projets';

  @override
  String get coverSlideHint => 'Faites glisser le cadre pour choisir l’image.';

  @override
  String get coverModifiedNow => 'Modifié à l’instant';

  @override
  String get coverGalleryImage => 'Image de la galerie';

  @override
  String get coverChooseAnother => 'Choisir une autre image';

  @override
  String get coverUseVideoImage => 'Utiliser une image de la vidéo';

  @override
  String get coverFromVideoLabel => 'Image de la vidéo';

  @override
  String coverPreviewSemantics(String time) {
    return 'Aperçu de la couverture à $time';
  }

  @override
  String coverFrameSemantics(String time) {
    return 'Image à $time';
  }

  @override
  String get coverForward => 'Avancer d’une seconde';

  @override
  String get coverBackward => 'Reculer d’une seconde';

  @override
  String get coverNextImage => 'Image suivante';

  @override
  String get coverPrevImage => 'Image précédente';

  @override
  String get coverExtractFailed => 'Impossible de lire cette image';

  @override
  String get coverCropHintShort => 'Glissez pour recadrer';

  @override
  String get coverResetAutomatic => 'Revenir au choix automatique';

  @override
  String get coverPickFailed => 'Impossible d’ouvrir le sélecteur d’images.';

  @override
  String get coverCopyFailed => 'Impossible de copier cette image.';

  @override
  String exportEstimatedSize(Object size) {
    return 'Taille estimée : environ $size';
  }

  @override
  String exportStep(Object current, Object total) {
    return 'Étape $current sur $total';
  }

  @override
  String get exportProgressLabel => 'Progression de l\'export';

  @override
  String get exportInProgress => 'Export en cours';

  @override
  String get exportGallerySaved => 'Dans la galerie de votre téléphone';

  @override
  String get exportShare => 'Partager';

  @override
  String get exportKeepEditing => 'Continuer à modifier';

  @override
  String get exportRetry => 'Réessayer';

  @override
  String get exportTryStandardShort => 'Essayer en Standard · 720p';

  @override
  String get exportSafeFileDeleted => 'Le fichier incomplet a été supprimé';

  @override
  String get exportNotLost => 'Votre vidéo n’est pas perdue';

  @override
  String get exportErrorDetails => 'Détails techniques';

  @override
  String get exportKeepInApp => 'conservé dans GraceEdit';

  @override
  String get exportCancelMessage =>
      'Export annulé. Votre projet n’est pas modifié.';

  @override
  String exportSpaceNeededBody(Object free, Object needed) {
    return 'Il faut environ $needed. Il reste $free.';
  }

  @override
  String get exportUnableRender =>
      'Un problème est survenu pendant la création de la vidéo. Rien n’a été enregistré dans votre galerie.';

  @override
  String get exportUnableGallery =>
      'La vidéo a été créée, mais n’a pas pu être ajoutée à la galerie.';

  @override
  String get exportInterruptedBody =>
      'L’application a été fermée avant la fin. Votre projet est intact.';

  @override
  String get exportBattery => 'Batterie très faible';

  @override
  String get projectsSortTitle => 'Trier par';

  @override
  String get projectsViewToggleGrid => 'Passer en affichage en grille';

  @override
  String get projectsViewToggleList => 'Passer en affichage en liste';

  @override
  String projectsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projets',
      one: '1 projet',
      zero: 'Aucun projet',
    );
    return '$_temp0';
  }

  @override
  String get projectsSelectAll => 'Tout sélectionner';

  @override
  String get projectsDeselectAll => 'Tout désélectionner';

  @override
  String get projectsDuplicate => 'Dupliquer';

  @override
  String get projectsDelete => 'Supprimer';

  @override
  String get projectsExporting => 'Export en cours';

  @override
  String get projectsDuplicateDone => 'Projet dupliqué';

  @override
  String projectsDuplicateMany(Object count) {
    return '$count projets dupliqués';
  }

  @override
  String projectsDeleted(Object count) {
    return '$count projets supprimés';
  }

  @override
  String get projectsDeleteSafeNote =>
      'Vos vidéos d’origine et vos vidéos exportées ne sont jamais supprimées.';

  @override
  String get projectsTrashEmpty => 'La corbeille est vide.';

  @override
  String get projectsTrashEmptyBody =>
      'Les projets supprimés apparaissent ici pendant 30 jours.';

  @override
  String trashDeletedAgo(Object days) {
    return 'Supprimé il y a $days j';
  }

  @override
  String trashPurgeIn(Object days) {
    return 'Suppression dans $days j';
  }

  @override
  String get trashPurgeTomorrow => 'Suppression demain';

  @override
  String get trashRestore => 'Restaurer';

  @override
  String get trashDeleteForever => 'Supprimer définitivement';

  @override
  String get trashPurgeAction => 'Vider';

  @override
  String get trashRestored => 'Projet restauré';

  @override
  String missingProjectLabel(Object title) {
    return 'Projet : $title';
  }

  @override
  String missingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count médias sont introuvables',
      one: '1 média est introuvable',
    );
    return '$_temp0';
  }

  @override
  String get missingExplain =>
      'Il a peut-être été déplacé, renommé ou supprimé. Choisissez le fichier à utiliser à sa place.';

  @override
  String missingUsedIn(Object count) {
    return 'Utilisé dans $count clips';
  }

  @override
  String get missingReconnected => 'Reconnecté';

  @override
  String get missingChangeFile => 'Changer de fichier';

  @override
  String missingRemaining(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count médias restent à reconnecter.',
      one: '1 média reste à reconnecter.',
    );
    return '$_temp0';
  }

  @override
  String get missingUseAnyway => 'Utiliser quand même';

  @override
  String get missingFileUnreadable => 'Ce fichier ne peut pas être lu';

  @override
  String get settingsValueAsk => 'Demander';

  @override
  String get settingsValueTrash => 'Corbeille';

  @override
  String get settingsThemeSheetTitle => 'Thème';

  @override
  String get settingsLanguageSheetTitle => 'Langue';

  @override
  String get settingsDeletionSheetTitle => 'Suppression';

  @override
  String get storageGraceEditUses => 'GraceEdit utilise';

  @override
  String get storageCacheThumbs => 'Cache et miniatures';

  @override
  String get storageUnregistered => 'Exports non enregistrés';

  @override
  String get storageTrash => 'Corbeille';

  @override
  String get storageFreePhone => 'Espace libre sur le téléphone';

  @override
  String get storageClear => 'Vider';

  @override
  String get storageNothingToClear => 'Rien à vider';

  @override
  String get storageCacheBody => 'Recréés au besoin';

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
      'Ce rapport aide à comprendre un problème. Il est créé sur votre téléphone et n’est jamais envoyé automatiquement.';

  @override
  String get helpContains => 'Ce qu’il contient';

  @override
  String get helpNotContains => 'Ce qu’il ne contient pas';

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
  String get helpDiagCopy => 'Copier le rapport';

  @override
  String get helpDiagShare => 'Partager';

  @override
  String get helpDiagCopied => 'Rapport copié';

  @override
  String get helpLicensesBody =>
      'Police Inter (licence SIL OFL) · Flutter (licence BSD) · Media3 (licence Apache 2.0)';

  @override
  String get helpTermsBody =>
      'GraceEdit est fourni tel quel, pour un usage personnel. Vous restez responsable des vidéos que vous montez et partagez. Aucune donnée n’est collectée.';

  @override
  String get helpPrivacyBody =>
      'GraceEdit ne crée pas de compte, n’accède pas au réseau et n’envoie aucune donnée. Vos projets, réglages et vidéos restent sur votre appareil.';

  @override
  String recoverySavedAgo(Object when) {
    return 'Dernière sauvegarde $when';
  }

  @override
  String get recoveryLater => 'Plus tard';

  @override
  String get recoverySafe =>
      'GraceEdit s’est fermé de façon inattendue. Votre travail a été récupéré.';

  @override
  String get saveFailedSheetTitle =>
      'Vos modifications ne sont pas enregistrées';

  @override
  String get saveFailedSheetBody =>
      'Le téléphone n’a pas pu enregistrer le projet : il manque de l’espace. Ne fermez pas l’application avant d’avoir résolu le problème.';

  @override
  String get saveRetry => 'Réessayer';

  @override
  String get saveFreeSpace => 'Libérer de l’espace';

  @override
  String get storageFullSafe => 'Vos projets sont intacts.';

  @override
  String get storageFullLater => 'Plus tard';

  @override
  String get storageFullTrash => 'Voir la corbeille';

  @override
  String get unsupportedOptionTitle => 'Option non disponible';

  @override
  String get unsupportedOptionBody =>
      'Votre téléphone ne peut pas exporter en 1080p. Choisissez Standard · 720p.';

  @override
  String get unsupportedChooseStandard => 'Choisir Standard · 720p';

  @override
  String get unsupportedClose => 'Fermer';

  @override
  String get notificationWhy =>
      'GraceEdit peut afficher la progression et vous prévenir quand la vidéo est prête. L’export fonctionne aussi sans notification.';

  @override
  String get notificationAllow => 'Autoriser les notifications';

  @override
  String get notificationLater => 'Pas maintenant';

  @override
  String get permissionContinue => 'Continuer';

  @override
  String get permissionChooseFiles => 'Choisir des fichiers un par un';

  @override
  String get permissionSafe1 => 'Vous choisissez ce que GraceEdit peut voir.';

  @override
  String get permissionSafe2 => 'Rien n’est envoyé en ligne.';

  @override
  String get permissionDeniedPermission =>
      'Sans cet accès, GraceEdit ne peut pas afficher vos vidéos. Autorisez-le dans les réglages ou choisissez les fichiers un par un.';

  @override
  String get commonView => 'Voir';

  @override
  String get commonLater => 'Plus tard';

  @override
  String get commonManage => 'Gérer';

  @override
  String get commonThisClip => 'Ce clip';

  @override
  String get commonWholeProject => 'Tout le projet';

  @override
  String get commonOriginal => 'Original';

  @override
  String get commonCompare => 'Comparer';

  @override
  String get commonReset => 'Réinitialiser';

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
  String get commonDone => 'Terminé';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonOpen => 'Ouvrir';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonPrevious => 'Précédent';

  @override
  String get commonPlay => 'Lire';

  @override
  String get commonPause => 'Pause';

  @override
  String get commonMore => 'Plus';

  @override
  String get commonLess => 'Moins';

  @override
  String get commonSaved => 'Enregistré';

  @override
  String get commonSaving => 'Enregistrement…';

  @override
  String get commonNotSaved => 'Non enregistré';

  @override
  String get commonAuto => 'Automatique';

  @override
  String get settingsAccessibility => 'Accessibilité';

  @override
  String get settingsMotionHint => 'Suit le réglage de l\'appareil';

  @override
  String get settingsStorageHelp => 'Stockage et aide';

  @override
  String get settingsStorageCache => 'Stockage et cache';
}
