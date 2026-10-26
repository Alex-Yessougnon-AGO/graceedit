import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'GraceEdit'**
  String get appTitle;

  /// No description provided for @brandTagline.
  ///
  /// In fr, this message translates to:
  /// **'Montez vos vidéos, simplement.'**
  String get brandTagline;

  /// No description provided for @actionCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get actionCancel;

  /// No description provided for @actionClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get actionClose;

  /// No description provided for @actionDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get actionDone;

  /// No description provided for @actionRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get actionRetry;

  /// No description provided for @actionDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get actionDelete;

  /// No description provided for @actionRename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get actionRename;

  /// No description provided for @actionDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Dupliquer'**
  String get actionDuplicate;

  /// No description provided for @actionExport.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get actionExport;

  /// No description provided for @actionShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get actionShare;

  /// No description provided for @actionBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get actionBack;

  /// No description provided for @actionOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir'**
  String get actionOpen;

  /// No description provided for @actionSelect.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner'**
  String get actionSelect;

  /// No description provided for @actionSelectAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout sélectionner'**
  String get actionSelectAll;

  /// No description provided for @actionMoveUp.
  ///
  /// In fr, this message translates to:
  /// **'Monter'**
  String get actionMoveUp;

  /// No description provided for @actionMoveDown.
  ///
  /// In fr, this message translates to:
  /// **'Descendre'**
  String get actionMoveDown;

  /// No description provided for @actionRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get actionRemove;

  /// No description provided for @actionAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get actionAdd;

  /// No description provided for @actionRestore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get actionRestore;

  /// No description provided for @actionUndo.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get actionUndo;

  /// No description provided for @actionRedo.
  ///
  /// In fr, this message translates to:
  /// **'Rétablir'**
  String get actionRedo;

  /// No description provided for @actionSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get actionSave;

  /// No description provided for @actionMore.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get actionMore;

  /// No description provided for @actionLess.
  ///
  /// In fr, this message translates to:
  /// **'Moins'**
  String get actionLess;

  /// No description provided for @actionPlay.
  ///
  /// In fr, this message translates to:
  /// **'Lire'**
  String get actionPlay;

  /// No description provided for @actionPause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get actionPause;

  /// No description provided for @saveStateSaved.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré'**
  String get saveStateSaved;

  /// No description provided for @saveStateSaving.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement…'**
  String get saveStateSaving;

  /// No description provided for @saveStateFailed.
  ///
  /// In fr, this message translates to:
  /// **'Non enregistré'**
  String get saveStateFailed;

  /// No description provided for @toastClipDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Clip supprimé'**
  String get toastClipDeleted;

  /// No description provided for @toastClipSplit.
  ///
  /// In fr, this message translates to:
  /// **'Clip scindé'**
  String get toastClipSplit;

  /// No description provided for @toastTextDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Texte supprimé'**
  String get toastTextDeleted;

  /// No description provided for @toastAudioDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Musique supprimée'**
  String get toastAudioDeleted;

  /// No description provided for @toastProjectTrashed.
  ///
  /// In fr, this message translates to:
  /// **'Projet déplacé dans la corbeille'**
  String get toastProjectTrashed;

  /// No description provided for @toastProjectsTrashed.
  ///
  /// In fr, this message translates to:
  /// **'Projets déplacés dans la corbeille'**
  String get toastProjectsTrashed;

  /// No description provided for @toastProjectRestored.
  ///
  /// In fr, this message translates to:
  /// **'Projet restauré'**
  String get toastProjectRestored;

  /// No description provided for @toastMediaRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Média retiré du projet'**
  String get toastMediaRemoved;

  /// No description provided for @toastExportCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Export annulé'**
  String get toastExportCancelled;

  /// No description provided for @toastCoverUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Couverture mise à jour'**
  String get toastCoverUpdated;

  /// No description provided for @splashLoadingSemantics.
  ///
  /// In fr, this message translates to:
  /// **'GraceEdit, chargement'**
  String get splashLoadingSemantics;

  /// No description provided for @splashPreparing.
  ///
  /// In fr, this message translates to:
  /// **'Préparation en cours…'**
  String get splashPreparing;

  /// No description provided for @splashSlowHint.
  ///
  /// In fr, this message translates to:
  /// **'Cela prend plus de temps que d\'habitude.'**
  String get splashSlowHint;

  /// No description provided for @splashErrorTitle.
  ///
  /// In fr, this message translates to:
  /// **'L\'application n\'a pas pu démarrer.'**
  String get splashErrorTitle;

  /// No description provided for @splashErrorBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos projets sont intacts. Fermez les autres applications, puis réessayez.'**
  String get splashErrorBody;

  /// No description provided for @splashRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get splashRetry;

  /// No description provided for @welcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Montez vos vidéos, simplement.'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In fr, this message translates to:
  /// **'Importez une vidéo, coupez, ajoutez du texte, puis exportez.'**
  String get welcomeBody;

  /// No description provided for @welcomeGuaranteeNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte nécessaire'**
  String get welcomeGuaranteeNoAccount;

  /// No description provided for @welcomeGuaranteeOffline.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionne sans connexion'**
  String get welcomeGuaranteeOffline;

  /// No description provided for @welcomeGuaranteeLocal.
  ///
  /// In fr, this message translates to:
  /// **'Vos fichiers restent sur votre téléphone'**
  String get welcomeGuaranteeLocal;

  /// No description provided for @welcomeStart.
  ///
  /// In fr, this message translates to:
  /// **'Monter une vidéo'**
  String get welcomeStart;

  /// No description provided for @welcomeExplore.
  ///
  /// In fr, this message translates to:
  /// **'Explorer d\'abord'**
  String get welcomeExplore;

  /// No description provided for @homeResume.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get homeResume;

  /// No description provided for @homeRecent.
  ///
  /// In fr, this message translates to:
  /// **'Récents'**
  String get homeRecent;

  /// No description provided for @homeSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get homeSeeAll;

  /// No description provided for @homeNewProject.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau projet'**
  String get homeNewProject;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre premier projet'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une vidéo, coupez-la, ajoutez du texte, puis exportez.'**
  String get homeEmptyBody;

  /// No description provided for @homeMissingMedia.
  ///
  /// In fr, this message translates to:
  /// **'Média manquant'**
  String get homeMissingMedia;

  /// No description provided for @homeExportRunning.
  ///
  /// In fr, this message translates to:
  /// **'Export en cours'**
  String get homeExportRunning;

  /// No description provided for @homeExportRunningBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre vidéo est en préparation.'**
  String get homeExportRunningBody;

  /// No description provided for @homeStorageLow.
  ///
  /// In fr, this message translates to:
  /// **'Stockage faible : {free} libres.'**
  String homeStorageLow(String free);

  /// No description provided for @homeDraftRecovered.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon récupéré'**
  String get homeDraftRecovered;

  /// No description provided for @homeProjectCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun projet} =1{1 projet} other{{count} projets}}'**
  String homeProjectCount(int count);

  /// No description provided for @modifiedAt.
  ///
  /// In fr, this message translates to:
  /// **'Modifié {when}'**
  String modifiedAt(String when);

  /// No description provided for @importTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau projet'**
  String get importTitle;

  /// No description provided for @importNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du projet'**
  String get importNameLabel;

  /// No description provided for @importDefaultName.
  ///
  /// In fr, this message translates to:
  /// **'Projet du {date}'**
  String importDefaultName(String date);

  /// No description provided for @importMediaCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun média} =1{1 média} other{{count} médias}}'**
  String importMediaCount(int count);

  /// No description provided for @importAddMedia.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des médias'**
  String get importAddMedia;

  /// No description provided for @importStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer le montage'**
  String get importStart;

  /// No description provided for @importStartWithCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Commencer avec 1 média} other{Commencer avec {count} médias}}'**
  String importStartWithCount(int count);

  /// No description provided for @importPreparing.
  ///
  /// In fr, this message translates to:
  /// **'Préparation {percent} %'**
  String importPreparing(int percent);

  /// No description provided for @importUnsupported.
  ///
  /// In fr, this message translates to:
  /// **'Format non pris en charge'**
  String get importUnsupported;

  /// No description provided for @importUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'Fichier illisible'**
  String get importUnreadable;

  /// No description provided for @importRemoveFromProject.
  ///
  /// In fr, this message translates to:
  /// **'Retirer du projet'**
  String get importRemoveFromProject;

  /// No description provided for @importAddHint.
  ///
  /// In fr, this message translates to:
  /// **'Vos fichiers d\'origine ne sont jamais modifiés.'**
  String get importAddHint;

  /// No description provided for @editorUntitled.
  ///
  /// In fr, this message translates to:
  /// **'Sans titre'**
  String get editorUntitled;

  /// No description provided for @editorAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get editorAdd;

  /// No description provided for @editorAudio.
  ///
  /// In fr, this message translates to:
  /// **'Audio'**
  String get editorAudio;

  /// No description provided for @editorText.
  ///
  /// In fr, this message translates to:
  /// **'Texte'**
  String get editorText;

  /// No description provided for @editorAdjust.
  ///
  /// In fr, this message translates to:
  /// **'Ajuster'**
  String get editorAdjust;

  /// No description provided for @editorFormat.
  ///
  /// In fr, this message translates to:
  /// **'Format'**
  String get editorFormat;

  /// No description provided for @editorCover.
  ///
  /// In fr, this message translates to:
  /// **'Couverture'**
  String get editorCover;

  /// No description provided for @editorSplit.
  ///
  /// In fr, this message translates to:
  /// **'Scinder'**
  String get editorSplit;

  /// No description provided for @editorVolume.
  ///
  /// In fr, this message translates to:
  /// **'Volume'**
  String get editorVolume;

  /// No description provided for @editorCrop.
  ///
  /// In fr, this message translates to:
  /// **'Cadrer'**
  String get editorCrop;

  /// No description provided for @editorDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get editorDelete;

  /// No description provided for @editorDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Dupliquer'**
  String get editorDuplicate;

  /// No description provided for @editorEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre timeline est vide.'**
  String get editorEmptyTitle;

  /// No description provided for @editorEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez une vidéo pour commencer.'**
  String get editorEmptyBody;

  /// No description provided for @editorAddMedia.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un média'**
  String get editorAddMedia;

  /// No description provided for @editorMissingMedia.
  ///
  /// In fr, this message translates to:
  /// **'Média manquant'**
  String get editorMissingMedia;

  /// No description provided for @editorReconnect.
  ///
  /// In fr, this message translates to:
  /// **'Reconnecter'**
  String get editorReconnect;

  /// No description provided for @editorTextTrack.
  ///
  /// In fr, this message translates to:
  /// **'Textes'**
  String get editorTextTrack;

  /// No description provided for @editorAudioTrack.
  ///
  /// In fr, this message translates to:
  /// **'Audio'**
  String get editorAudioTrack;

  /// No description provided for @editorVideoTrack.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get editorVideoTrack;

  /// No description provided for @editorTimeline.
  ///
  /// In fr, this message translates to:
  /// **'Timeline'**
  String get editorTimeline;

  /// No description provided for @editorPreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get editorPreview;

  /// No description provided for @editorSaveFailed.
  ///
  /// In fr, this message translates to:
  /// **'La sauvegarde a échoué.'**
  String get editorSaveFailed;

  /// No description provided for @editorSaveFailedBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre travail est conservé sur cet appareil. Vérifiez l\'espace libre, puis réessayez.'**
  String get editorSaveFailedBody;

  /// No description provided for @editorRetrySave.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get editorRetrySave;

  /// No description provided for @editorZoomIn.
  ///
  /// In fr, this message translates to:
  /// **'Zoom avant'**
  String get editorZoomIn;

  /// No description provided for @editorZoomOut.
  ///
  /// In fr, this message translates to:
  /// **'Zoom arrière'**
  String get editorZoomOut;

  /// No description provided for @editorClipActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions du clip'**
  String get editorClipActions;

  /// No description provided for @trimTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rogner'**
  String get trimTitle;

  /// No description provided for @trimStart.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get trimStart;

  /// No description provided for @trimEnd.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get trimEnd;

  /// No description provided for @trimRemoved.
  ///
  /// In fr, this message translates to:
  /// **'−{duration}'**
  String trimRemoved(String duration);

  /// No description provided for @trimDurationLabel.
  ///
  /// In fr, this message translates to:
  /// **'Durée {duration}'**
  String trimDurationLabel(String duration);

  /// No description provided for @trimMinimum.
  ///
  /// In fr, this message translates to:
  /// **'Durée minimale : 0,1 s.'**
  String get trimMinimum;

  /// No description provided for @textTitle.
  ///
  /// In fr, this message translates to:
  /// **'Texte'**
  String get textTitle;

  /// No description provided for @textFieldLabel.
  ///
  /// In fr, this message translates to:
  /// **'Votre texte'**
  String get textFieldLabel;

  /// No description provided for @textPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Écrivez ici'**
  String get textPlaceholder;

  /// No description provided for @textPresetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get textPresetTitle;

  /// No description provided for @textPresetSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sous-titre'**
  String get textPresetSubtitle;

  /// No description provided for @textPresetCaption.
  ///
  /// In fr, this message translates to:
  /// **'Légende'**
  String get textPresetCaption;

  /// No description provided for @textEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get textEdit;

  /// No description provided for @textStyle.
  ///
  /// In fr, this message translates to:
  /// **'Style'**
  String get textStyle;

  /// No description provided for @textColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get textColor;

  /// No description provided for @textTabStyle.
  ///
  /// In fr, this message translates to:
  /// **'Style'**
  String get textTabStyle;

  /// No description provided for @textTabFont.
  ///
  /// In fr, this message translates to:
  /// **'Police'**
  String get textTabFont;

  /// No description provided for @textTabColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get textTabColor;

  /// No description provided for @textTabBackground.
  ///
  /// In fr, this message translates to:
  /// **'Fond'**
  String get textTabBackground;

  /// No description provided for @textSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille'**
  String get textSize;

  /// No description provided for @textOpacity.
  ///
  /// In fr, this message translates to:
  /// **'Opacité'**
  String get textOpacity;

  /// No description provided for @textPosition.
  ///
  /// In fr, this message translates to:
  /// **'Position'**
  String get textPosition;

  /// No description provided for @textRotation.
  ///
  /// In fr, this message translates to:
  /// **'Rotation'**
  String get textRotation;

  /// No description provided for @textBackgroundOn.
  ///
  /// In fr, this message translates to:
  /// **'Fond derrière le texte'**
  String get textBackgroundOn;

  /// No description provided for @textColorWhite.
  ///
  /// In fr, this message translates to:
  /// **'Blanc'**
  String get textColorWhite;

  /// No description provided for @textColorBlack.
  ///
  /// In fr, this message translates to:
  /// **'Noir'**
  String get textColorBlack;

  /// No description provided for @textColorAccent.
  ///
  /// In fr, this message translates to:
  /// **'Orange'**
  String get textColorAccent;

  /// No description provided for @textColorIvory.
  ///
  /// In fr, this message translates to:
  /// **'Ivoire'**
  String get textColorIvory;

  /// No description provided for @textColorSlate.
  ///
  /// In fr, this message translates to:
  /// **'Ardoise'**
  String get textColorSlate;

  /// No description provided for @textColorGreen.
  ///
  /// In fr, this message translates to:
  /// **'Vert'**
  String get textColorGreen;

  /// No description provided for @textMoveHint.
  ///
  /// In fr, this message translates to:
  /// **'Faites glisser pour déplacer, pincez pour redimensionner.'**
  String get textMoveHint;

  /// No description provided for @textRotationHint.
  ///
  /// In fr, this message translates to:
  /// **'Rotation par pas de 15°.'**
  String get textRotationHint;

  /// No description provided for @audioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Audio'**
  String get audioTitle;

  /// No description provided for @audioVideoSound.
  ///
  /// In fr, this message translates to:
  /// **'Son de la vidéo'**
  String get audioVideoSound;

  /// No description provided for @audioMusic.
  ///
  /// In fr, this message translates to:
  /// **'Musique'**
  String get audioMusic;

  /// No description provided for @audioMute.
  ///
  /// In fr, this message translates to:
  /// **'Couper le son'**
  String get audioMute;

  /// No description provided for @audioUnmute.
  ///
  /// In fr, this message translates to:
  /// **'Rétablir le son'**
  String get audioUnmute;

  /// No description provided for @audioAddMusic.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter de la musique'**
  String get audioAddMusic;

  /// No description provided for @audioMusicHint.
  ///
  /// In fr, this message translates to:
  /// **'La musique démarre à la tête de lecture et s\'arrête à la fin du projet.'**
  String get audioMusicHint;

  /// No description provided for @audioVolumeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Volume'**
  String get audioVolumeLabel;

  /// No description provided for @audioFade.
  ///
  /// In fr, this message translates to:
  /// **'Fondu'**
  String get audioFade;

  /// No description provided for @audioFadeIn.
  ///
  /// In fr, this message translates to:
  /// **'Fondu d\'entrée'**
  String get audioFadeIn;

  /// No description provided for @audioFadeOut.
  ///
  /// In fr, this message translates to:
  /// **'Fondu de sortie'**
  String get audioFadeOut;

  /// No description provided for @audioFadeTooLong.
  ///
  /// In fr, this message translates to:
  /// **'La somme des fondus dépasse la durée du son.'**
  String get audioFadeTooLong;

  /// No description provided for @audioVolumePercent.
  ///
  /// In fr, this message translates to:
  /// **'{percent} %'**
  String audioVolumePercent(int percent);

  /// No description provided for @audioFadeSeconds.
  ///
  /// In fr, this message translates to:
  /// **'{seconds} s'**
  String audioFadeSeconds(String seconds);

  /// No description provided for @adjustTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajuster'**
  String get adjustTitle;

  /// No description provided for @adjustBrightness.
  ///
  /// In fr, this message translates to:
  /// **'Luminosité'**
  String get adjustBrightness;

  /// No description provided for @adjustContrast.
  ///
  /// In fr, this message translates to:
  /// **'Contraste'**
  String get adjustContrast;

  /// No description provided for @adjustSaturation.
  ///
  /// In fr, this message translates to:
  /// **'Saturation'**
  String get adjustSaturation;

  /// No description provided for @adjustScope.
  ///
  /// In fr, this message translates to:
  /// **'Portée'**
  String get adjustScope;

  /// No description provided for @adjustScopeClip.
  ///
  /// In fr, this message translates to:
  /// **'Ce clip'**
  String get adjustScopeClip;

  /// No description provided for @adjustScopeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout le projet'**
  String get adjustScopeAll;

  /// No description provided for @adjustCompare.
  ///
  /// In fr, this message translates to:
  /// **'Comparer'**
  String get adjustCompare;

  /// No description provided for @adjustCompareHint.
  ///
  /// In fr, this message translates to:
  /// **'Maintenez pour voir l\'original.'**
  String get adjustCompareHint;

  /// No description provided for @adjustReset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get adjustReset;

  /// No description provided for @formatTitle.
  ///
  /// In fr, this message translates to:
  /// **'Format'**
  String get formatTitle;

  /// No description provided for @formatVertical.
  ///
  /// In fr, this message translates to:
  /// **'Vertical 9:16'**
  String get formatVertical;

  /// No description provided for @formatSquare.
  ///
  /// In fr, this message translates to:
  /// **'Carré 1:1'**
  String get formatSquare;

  /// No description provided for @formatHorizontal.
  ///
  /// In fr, this message translates to:
  /// **'Horizontal 16:9'**
  String get formatHorizontal;

  /// No description provided for @formatPortrait.
  ///
  /// In fr, this message translates to:
  /// **'Portrait 4:5'**
  String get formatPortrait;

  /// No description provided for @formatFitMode.
  ///
  /// In fr, this message translates to:
  /// **'Cadrage'**
  String get formatFitMode;

  /// No description provided for @formatFill.
  ///
  /// In fr, this message translates to:
  /// **'Remplir'**
  String get formatFill;

  /// No description provided for @formatFit.
  ///
  /// In fr, this message translates to:
  /// **'Ajuster'**
  String get formatFit;

  /// No description provided for @formatFitHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajuster : l’image entière est gardée, avec des bandes noires.'**
  String get formatFitHint;

  /// No description provided for @cropTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cadrer'**
  String get cropTitle;

  /// No description provided for @cropRotate.
  ///
  /// In fr, this message translates to:
  /// **'Pivoter'**
  String get cropRotate;

  /// No description provided for @cropMirror.
  ///
  /// In fr, this message translates to:
  /// **'Miroir'**
  String get cropMirror;

  /// No description provided for @cropStraighten.
  ///
  /// In fr, this message translates to:
  /// **'Redresser'**
  String get cropStraighten;

  /// No description provided for @cropReset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get cropReset;

  /// No description provided for @cropGrid.
  ///
  /// In fr, this message translates to:
  /// **'Grille des tiers'**
  String get cropGrid;

  /// No description provided for @coverTitle.
  ///
  /// In fr, this message translates to:
  /// **'Couverture'**
  String get coverTitle;

  /// No description provided for @coverFromVideo.
  ///
  /// In fr, this message translates to:
  /// **'Image de la vidéo'**
  String get coverFromVideo;

  /// No description provided for @coverFromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get coverFromGallery;

  /// No description provided for @coverAuto.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get coverAuto;

  /// No description provided for @coverAutoBody.
  ///
  /// In fr, this message translates to:
  /// **'La première image de la vidéo est utilisée.'**
  String get coverAutoBody;

  /// No description provided for @coverUsage.
  ///
  /// In fr, this message translates to:
  /// **'Dans vos projets'**
  String get coverUsage;

  /// No description provided for @coverPickImage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une image'**
  String get coverPickImage;

  /// No description provided for @coverCropHint.
  ///
  /// In fr, this message translates to:
  /// **'Glissez pour recadrer, pincez pour zoomer.'**
  String get coverCropHint;

  /// No description provided for @coverReset.
  ///
  /// In fr, this message translates to:
  /// **'Revenir à l\'image de la vidéo'**
  String get coverReset;

  /// No description provided for @exportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get exportTitle;

  /// No description provided for @exportSummary.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif'**
  String get exportSummary;

  /// No description provided for @exportDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get exportDuration;

  /// No description provided for @exportFormatLabel.
  ///
  /// In fr, this message translates to:
  /// **'Format'**
  String get exportFormatLabel;

  /// No description provided for @exportQuality.
  ///
  /// In fr, this message translates to:
  /// **'Qualité'**
  String get exportQuality;

  /// No description provided for @exportQualityHigh.
  ///
  /// In fr, this message translates to:
  /// **'Haute · 1080p'**
  String get exportQualityHigh;

  /// No description provided for @exportQualityStandard.
  ///
  /// In fr, this message translates to:
  /// **'Standard · 720p'**
  String get exportQualityStandard;

  /// No description provided for @exportFramesPerSecond.
  ///
  /// In fr, this message translates to:
  /// **'30 images/s'**
  String get exportFramesPerSecond;

  /// No description provided for @exportDestination.
  ///
  /// In fr, this message translates to:
  /// **'Destination'**
  String get exportDestination;

  /// No description provided for @exportDestinationGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie du téléphone'**
  String get exportDestinationGallery;

  /// No description provided for @exportSpaceFree.
  ///
  /// In fr, this message translates to:
  /// **'Espace disponible'**
  String get exportSpaceFree;

  /// No description provided for @exportSpaceNeeded.
  ///
  /// In fr, this message translates to:
  /// **'Espace nécessaire'**
  String get exportSpaceNeeded;

  /// No description provided for @exportNotEnoughSpaceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Espace insuffisant'**
  String get exportNotEnoughSpaceTitle;

  /// No description provided for @exportNotEnoughSpaceBody.
  ///
  /// In fr, this message translates to:
  /// **'Il faut environ {needed}. Il reste {free}. Libérez de l\'espace pour continuer.'**
  String exportNotEnoughSpaceBody(String needed, String free);

  /// No description provided for @exportDisabledEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez au moins un clip pour exporter.'**
  String get exportDisabledEmpty;

  /// No description provided for @exportDisabledMissing.
  ///
  /// In fr, this message translates to:
  /// **'Reconnectez le média manquant pour exporter.'**
  String get exportDisabledMissing;

  /// No description provided for @exportBatteryLow.
  ///
  /// In fr, this message translates to:
  /// **'Batterie faible : l\'export peut s\'interrompre.'**
  String get exportBatteryLow;

  /// No description provided for @exportNotificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Être prévenu à la fin de l\'export ?'**
  String get exportNotificationsTitle;

  /// No description provided for @exportNotificationsBody.
  ///
  /// In fr, this message translates to:
  /// **'GraceEdit peut afficher la progression et vous prévenir quand la vidéo est prête. L\'export fonctionne aussi sans notification.'**
  String get exportNotificationsBody;

  /// No description provided for @exportNotificationsAllow.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser les notifications'**
  String get exportNotificationsAllow;

  /// No description provided for @exportNotificationsLater.
  ///
  /// In fr, this message translates to:
  /// **'Pas maintenant'**
  String get exportNotificationsLater;

  /// No description provided for @exportPreparing.
  ///
  /// In fr, this message translates to:
  /// **'Préparation…'**
  String get exportPreparing;

  /// No description provided for @exportRendering.
  ///
  /// In fr, this message translates to:
  /// **'Création de la vidéo'**
  String get exportRendering;

  /// No description provided for @exportVerifying.
  ///
  /// In fr, this message translates to:
  /// **'Vérification…'**
  String get exportVerifying;

  /// No description provided for @exportElapsed.
  ///
  /// In fr, this message translates to:
  /// **'Temps écoulé : {duration}'**
  String exportElapsed(String duration);

  /// No description provided for @exportBackground.
  ///
  /// In fr, this message translates to:
  /// **'Continuer en arrière-plan'**
  String get exportBackground;

  /// No description provided for @exportCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler l\'export'**
  String get exportCancel;

  /// No description provided for @exportCancelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler l\'export ?'**
  String get exportCancelTitle;

  /// No description provided for @exportCancelBody.
  ///
  /// In fr, this message translates to:
  /// **'La vidéo en cours sera supprimée. Votre projet reste intact.'**
  String get exportCancelBody;

  /// No description provided for @exportCancelKeep.
  ///
  /// In fr, this message translates to:
  /// **'Continuer l\'export'**
  String get exportCancelKeep;

  /// No description provided for @exportCancelConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Annuler l\'export'**
  String get exportCancelConfirm;

  /// No description provided for @exportSuccessTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo enregistrée'**
  String get exportSuccessTitle;

  /// No description provided for @exportSuccessBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre vidéo est dans la galerie du téléphone.'**
  String get exportSuccessBody;

  /// No description provided for @exportSuccessName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get exportSuccessName;

  /// No description provided for @exportSuccessDimensions.
  ///
  /// In fr, this message translates to:
  /// **'Dimensions'**
  String get exportSuccessDimensions;

  /// No description provided for @exportSuccessDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get exportSuccessDuration;

  /// No description provided for @exportSuccessSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille'**
  String get exportSuccessSize;

  /// No description provided for @exportViewInGallery.
  ///
  /// In fr, this message translates to:
  /// **'Voir dans la galerie'**
  String get exportViewInGallery;

  /// No description provided for @exportContinueEditing.
  ///
  /// In fr, this message translates to:
  /// **'Continuer à modifier'**
  String get exportContinueEditing;

  /// No description provided for @exportFailedTitle.
  ///
  /// In fr, this message translates to:
  /// **'L\'export n\'a pas abouti'**
  String get exportFailedTitle;

  /// No description provided for @exportFailedSafe.
  ///
  /// In fr, this message translates to:
  /// **'Votre projet est intact.'**
  String get exportFailedSafe;

  /// No description provided for @exportFailedRender.
  ///
  /// In fr, this message translates to:
  /// **'La vidéo n\'a pas pu être créée.'**
  String get exportFailedRender;

  /// No description provided for @exportFailedStorage.
  ///
  /// In fr, this message translates to:
  /// **'L\'espace libre s\'est épuisé pendant la création.'**
  String get exportFailedStorage;

  /// No description provided for @exportFailedGallery.
  ///
  /// In fr, this message translates to:
  /// **'La vidéo a été créée mais n\'a pas pu être ajoutée à la galerie.'**
  String get exportFailedGallery;

  /// No description provided for @exportFailedInterrupted.
  ///
  /// In fr, this message translates to:
  /// **'L\'export a été interrompu.'**
  String get exportFailedInterrupted;

  /// No description provided for @exportFailedCancelled.
  ///
  /// In fr, this message translates to:
  /// **'L\'export a été annulé.'**
  String get exportFailedCancelled;

  /// No description provided for @exportTryStandard.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en Standard'**
  String get exportTryStandard;

  /// No description provided for @exportDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails techniques'**
  String get exportDetails;

  /// No description provided for @exportFreeSpace.
  ///
  /// In fr, this message translates to:
  /// **'Libérer de l’espace'**
  String get exportFreeSpace;

  /// No description provided for @exportRetryGallery.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer l\'ajout'**
  String get exportRetryGallery;

  /// No description provided for @exportSaveAs.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer sous…'**
  String get exportSaveAs;

  /// No description provided for @exportRestart.
  ///
  /// In fr, this message translates to:
  /// **'Recommencer l\'export'**
  String get exportRestart;

  /// No description provided for @exportVerifyingFile.
  ///
  /// In fr, this message translates to:
  /// **'Vérification du fichier…'**
  String get exportVerifyingFile;

  /// No description provided for @exportRegistering.
  ///
  /// In fr, this message translates to:
  /// **'Ajout à la galerie…'**
  String get exportRegistering;

  /// No description provided for @projectsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Projets'**
  String get projectsTitle;

  /// No description provided for @projectsSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un projet'**
  String get projectsSearch;

  /// No description provided for @projectsSearchClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la recherche'**
  String get projectsSearchClear;

  /// No description provided for @projectsSort.
  ///
  /// In fr, this message translates to:
  /// **'Trier'**
  String get projectsSort;

  /// No description provided for @projectsSortRecent.
  ///
  /// In fr, this message translates to:
  /// **'Récents'**
  String get projectsSortRecent;

  /// No description provided for @projectsSortOldest.
  ///
  /// In fr, this message translates to:
  /// **'Plus anciens'**
  String get projectsSortOldest;

  /// No description provided for @projectsSortName.
  ///
  /// In fr, this message translates to:
  /// **'Nom A–Z'**
  String get projectsSortName;

  /// No description provided for @projectsViewGrid.
  ///
  /// In fr, this message translates to:
  /// **'Grille'**
  String get projectsViewGrid;

  /// No description provided for @projectsViewList.
  ///
  /// In fr, this message translates to:
  /// **'Liste'**
  String get projectsViewList;

  /// No description provided for @projectsTrash.
  ///
  /// In fr, this message translates to:
  /// **'Corbeille'**
  String get projectsTrash;

  /// No description provided for @projectsSelectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 sélectionné} other{{count} sélectionnés}}'**
  String projectsSelectedCount(int count);

  /// No description provided for @projectsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun projet'**
  String get projectsEmptyTitle;

  /// No description provided for @projectsEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos montages apparaîtront ici.'**
  String get projectsEmptyBody;

  /// No description provided for @projectsNoResultsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get projectsNoResultsTitle;

  /// No description provided for @projectsNoResultsBody.
  ///
  /// In fr, this message translates to:
  /// **'Essayez un autre titre.'**
  String get projectsNoResultsBody;

  /// No description provided for @projectsDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Supprimer ce projet ?} other{Supprimer {count} projets ?}}'**
  String projectsDeleteTitle(int count);

  /// No description provided for @projectsDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'Ils resteront 30 jours dans la corbeille, puis seront supprimés.'**
  String get projectsDeleteBody;

  /// No description provided for @projectsToTrash.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à la corbeille'**
  String get projectsToTrash;

  /// No description provided for @projectsDeleteForever.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement'**
  String get projectsDeleteForever;

  /// No description provided for @projectsDeleteForeverTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement ?'**
  String get projectsDeleteForeverTitle;

  /// No description provided for @projectsDeleteForeverSingularBody.
  ///
  /// In fr, this message translates to:
  /// **'Ce projet ne pourra pas être récupéré.'**
  String get projectsDeleteForeverSingularBody;

  /// No description provided for @projectsDeleteForeverPluralBody.
  ///
  /// In fr, this message translates to:
  /// **'Ces projets ne pourront pas être récupérés.'**
  String get projectsDeleteForeverPluralBody;

  /// No description provided for @projectsDeleteForeverAction.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement'**
  String get projectsDeleteForeverAction;

  /// No description provided for @projectsDeletedForever.
  ///
  /// In fr, this message translates to:
  /// **'Supprimé définitivement'**
  String get projectsDeletedForever;

  /// No description provided for @projectsExportingLocked.
  ///
  /// In fr, this message translates to:
  /// **'Un projet en cours d\'export ne peut pas être supprimé.'**
  String get projectsExportingLocked;

  /// No description provided for @projectsRenameTitle.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get projectsRenameTitle;

  /// No description provided for @projectsRenameEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Le nom ne peut pas être vide.'**
  String get projectsRenameEmpty;

  /// No description provided for @projectsRenameTooLong.
  ///
  /// In fr, this message translates to:
  /// **'60 caractères maximum.'**
  String get projectsRenameTooLong;

  /// No description provided for @projectsDuplicateSuffix.
  ///
  /// In fr, this message translates to:
  /// **'{name} (copie)'**
  String projectsDuplicateSuffix(String name);

  /// No description provided for @projectsMenu.
  ///
  /// In fr, this message translates to:
  /// **'Actions du projet {name}'**
  String projectsMenu(String name);

  /// No description provided for @projectsOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir {name}'**
  String projectsOpen(String name);

  /// No description provided for @trashTitle.
  ///
  /// In fr, this message translates to:
  /// **'Corbeille'**
  String get trashTitle;

  /// No description provided for @trashEmpty.
  ///
  /// In fr, this message translates to:
  /// **'La corbeille est vide.'**
  String get trashEmpty;

  /// No description provided for @trashBody.
  ///
  /// In fr, this message translates to:
  /// **'Les projets supprimés restent 30 jours ici.'**
  String get trashBody;

  /// No description provided for @trashDaysLeft.
  ///
  /// In fr, this message translates to:
  /// **'Encore {days} jours'**
  String trashDaysLeft(int days);

  /// No description provided for @trashLastDay.
  ///
  /// In fr, this message translates to:
  /// **'Suppression demain'**
  String get trashLastDay;

  /// No description provided for @trashPurge.
  ///
  /// In fr, this message translates to:
  /// **'Vider la corbeille'**
  String get trashPurge;

  /// No description provided for @trashPurgeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vider la corbeille ?'**
  String get trashPurgeTitle;

  /// No description provided for @trashPurgeBody.
  ///
  /// In fr, this message translates to:
  /// **'Tous les projets de la corbeille seront supprimés pour toujours.'**
  String get trashPurgeBody;

  /// No description provided for @trashPurged.
  ///
  /// In fr, this message translates to:
  /// **'Corbeille vidée'**
  String get trashPurged;

  /// No description provided for @missingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Média manquant'**
  String get missingTitle;

  /// No description provided for @missingBody.
  ///
  /// In fr, this message translates to:
  /// **'GraceEdit ne trouve plus ce fichier. Il a peut-être été déplacé ou supprimé.'**
  String get missingBody;

  /// No description provided for @missingReconnect.
  ///
  /// In fr, this message translates to:
  /// **'Reconnecter'**
  String get missingReconnect;

  /// No description provided for @missingRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer du projet'**
  String get missingRemove;

  /// No description provided for @missingOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le projet'**
  String get missingOpen;

  /// No description provided for @missingOpenWithout.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir sans ces médias'**
  String get missingOpenWithout;

  /// No description provided for @missingDifferentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier est différent'**
  String get missingDifferentTitle;

  /// No description provided for @missingDifferentBody.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier choisi dure {newDuration}, l’original durait {oldDuration}. Les coupes et les textes de ce clip risquent d’être décalés.'**
  String missingDifferentBody(Object newDuration, Object oldDuration);

  /// No description provided for @missingChooseAnother.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un autre fichier'**
  String get missingChooseAnother;

  /// No description provided for @missingAllGood.
  ///
  /// In fr, this message translates to:
  /// **'Tous les médias sont reconnectés.'**
  String get missingAllGood;

  /// No description provided for @missingFileLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fichier'**
  String get missingFileLabel;

  /// No description provided for @missingSeveral.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 média manquant} other{{count} médias manquants}}'**
  String missingSeveral(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Langue du téléphone'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get settingsLanguageFrench;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsMotion.
  ///
  /// In fr, this message translates to:
  /// **'Réduire les animations'**
  String get settingsMotion;

  /// No description provided for @settingsHaptics.
  ///
  /// In fr, this message translates to:
  /// **'Retour haptique'**
  String get settingsHaptics;

  /// No description provided for @settingsDeletion.
  ///
  /// In fr, this message translates to:
  /// **'Suppression'**
  String get settingsDeletion;

  /// No description provided for @settingsDeletionAsk.
  ///
  /// In fr, this message translates to:
  /// **'Demander à chaque fois'**
  String get settingsDeletionAsk;

  /// No description provided for @settingsDeletionTrash.
  ///
  /// In fr, this message translates to:
  /// **'Toujours mettre à la corbeille'**
  String get settingsDeletionTrash;

  /// No description provided for @settingsTrash.
  ///
  /// In fr, this message translates to:
  /// **'Corbeille'**
  String get settingsTrash;

  /// No description provided for @settingsStorage.
  ///
  /// In fr, this message translates to:
  /// **'Stockage'**
  String get settingsStorage;

  /// No description provided for @settingsHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide et à propos'**
  String get settingsHelp;

  /// No description provided for @settingsVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @storageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stockage'**
  String get storageTitle;

  /// No description provided for @storageUsed.
  ///
  /// In fr, this message translates to:
  /// **'Utilisé'**
  String get storageUsed;

  /// No description provided for @storageProjects.
  ///
  /// In fr, this message translates to:
  /// **'Projets'**
  String get storageProjects;

  /// No description provided for @storageCovers.
  ///
  /// In fr, this message translates to:
  /// **'Couvertures'**
  String get storageCovers;

  /// No description provided for @storageExports.
  ///
  /// In fr, this message translates to:
  /// **'Exports non enregistrés'**
  String get storageExports;

  /// No description provided for @storageThumbnails.
  ///
  /// In fr, this message translates to:
  /// **'Miniatures'**
  String get storageThumbnails;

  /// No description provided for @storageFree.
  ///
  /// In fr, this message translates to:
  /// **'Espace libre'**
  String get storageFree;

  /// No description provided for @storageClearCache.
  ///
  /// In fr, this message translates to:
  /// **'Vider le cache'**
  String get storageClearCache;

  /// No description provided for @storageClearCacheBody.
  ///
  /// In fr, this message translates to:
  /// **'Les miniatures et les exports non enregistrés seront supprimés. Vos projets et vos médias ne sont pas touchés.'**
  String get storageClearCacheBody;

  /// No description provided for @storageCleared.
  ///
  /// In fr, this message translates to:
  /// **'Cache vidé · {size} libérés'**
  String storageCleared(String size);

  /// No description provided for @storageComputing.
  ///
  /// In fr, this message translates to:
  /// **'Calcul en cours…'**
  String get storageComputing;

  /// No description provided for @helpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aide et à propos'**
  String get helpTitle;

  /// No description provided for @helpReplay.
  ///
  /// In fr, this message translates to:
  /// **'Revoir la présentation'**
  String get helpReplay;

  /// No description provided for @helpFaq.
  ///
  /// In fr, this message translates to:
  /// **'Questions fréquentes'**
  String get helpFaq;

  /// No description provided for @helpDiagnostic.
  ///
  /// In fr, this message translates to:
  /// **'Rapport de diagnostic'**
  String get helpDiagnostic;

  /// No description provided for @helpDiagnosticBody.
  ///
  /// In fr, this message translates to:
  /// **'Généré sur votre téléphone. Il n\'est jamais envoyé automatiquement.'**
  String get helpDiagnosticBody;

  /// No description provided for @helpDiagnosticCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer le rapport'**
  String get helpDiagnosticCreate;

  /// No description provided for @helpDiagnosticCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get helpDiagnosticCopy;

  /// No description provided for @helpDiagnosticShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get helpDiagnosticShare;

  /// No description provided for @helpDiagnosticCopied.
  ///
  /// In fr, this message translates to:
  /// **'Rapport copié'**
  String get helpDiagnosticCopied;

  /// No description provided for @helpLicenses.
  ///
  /// In fr, this message translates to:
  /// **'Licences'**
  String get helpLicenses;

  /// No description provided for @helpTerms.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get helpTerms;

  /// No description provided for @helpPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get helpPrivacy;

  /// No description provided for @helpVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get helpVersion;

  /// No description provided for @helpFaqQ1.
  ///
  /// In fr, this message translates to:
  /// **'Où sont mes vidéos ?'**
  String get helpFaqQ1;

  /// No description provided for @helpFaqA1.
  ///
  /// In fr, this message translates to:
  /// **'Sur votre téléphone, à l\'endroit où vous les avez enregistrées. GraceEdit ne les copie pas et ne les modifie pas.'**
  String get helpFaqA1;

  /// No description provided for @helpFaqQ2.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi aucun compte ?'**
  String get helpFaqQ2;

  /// No description provided for @helpFaqA2.
  ///
  /// In fr, this message translates to:
  /// **'GraceEdit fonctionne hors connexion. Aucun réglage ni projet n\'est envoyé quelque part.'**
  String get helpFaqA2;

  /// No description provided for @helpFaqQ3.
  ///
  /// In fr, this message translates to:
  /// **'Que se passe-t-il si je supprime un projet ?'**
  String get helpFaqQ3;

  /// No description provided for @helpFaqA3.
  ///
  /// In fr, this message translates to:
  /// **'Il part dans la corbeille pendant 30 jours. Passé ce délai, il est supprimé définitivement.'**
  String get helpFaqA3;

  /// No description provided for @helpFaqQ4.
  ///
  /// In fr, this message translates to:
  /// **'Puis-je retrouver un média déplacé ?'**
  String get helpFaqQ4;

  /// No description provided for @helpFaqA4.
  ///
  /// In fr, this message translates to:
  /// **'Oui : ouvrez le projet, puis « Reconnecter » et choisissez le fichier au nouvel emplacement.'**
  String get helpFaqA4;

  /// No description provided for @helpFaqQ5.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi l\'export est-il plus lent sur certains téléphones ?'**
  String get helpFaqQ5;

  /// No description provided for @helpFaqA5.
  ///
  /// In fr, this message translates to:
  /// **'Le rendu utilise l\'encodeur de l\'appareil. Choisissez la qualité Standard pour aller plus vite.'**
  String get helpFaqA5;

  /// No description provided for @helpFaqQ6.
  ///
  /// In fr, this message translates to:
  /// **'Mes vidéos sont-elles envoyées en ligne ?'**
  String get helpFaqQ6;

  /// No description provided for @helpFaqA6.
  ///
  /// In fr, this message translates to:
  /// **'Non. Aucun envoi n\'est effectué, ni pendant le montage ni pendant l\'export.'**
  String get helpFaqA6;

  /// No description provided for @termsBody.
  ///
  /// In fr, this message translates to:
  /// **'GraceEdit est fourni tel quel, pour un usage personnel. Vous restez responsable des vidéos que vous montez et partagez. Aucune donnée n\'est collectée.'**
  String get termsBody;

  /// No description provided for @privacyBody.
  ///
  /// In fr, this message translates to:
  /// **'GraceEdit ne crée pas de compte, n\'accède pas au réseau et n\'envoie aucune donnée. Vos projets, réglages et vidéos restent sur votre appareil.'**
  String get privacyBody;

  /// No description provided for @recoveryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre où vous en étiez ?'**
  String get recoveryTitle;

  /// No description provided for @recoveryBody.
  ///
  /// In fr, this message translates to:
  /// **'GraceEdit s\'est fermé de façon inattendue. Votre travail a été récupéré.'**
  String get recoveryBody;

  /// No description provided for @recoveryResume.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre le projet'**
  String get recoveryResume;

  /// No description provided for @recoveryDiscard.
  ///
  /// In fr, this message translates to:
  /// **'Ignorer'**
  String get recoveryDiscard;

  /// No description provided for @storageLowTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stockage faible'**
  String get storageLowTitle;

  /// No description provided for @storageLowBody.
  ///
  /// In fr, this message translates to:
  /// **'Il reste {free}. L\'export peut échouer.'**
  String storageLowBody(String free);

  /// No description provided for @storageFullTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plus assez d\'espace sur le téléphone'**
  String get storageFullTitle;

  /// No description provided for @storageFullBody.
  ///
  /// In fr, this message translates to:
  /// **'GraceEdit ne peut plus enregistrer ni importer. Libérez de l\'espace pour continuer.'**
  String get storageFullBody;

  /// No description provided for @storageManage.
  ///
  /// In fr, this message translates to:
  /// **'Gérer'**
  String get storageManage;

  /// No description provided for @unsupportedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Format non pris en charge'**
  String get unsupportedTitle;

  /// No description provided for @unsupportedBody.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier ne peut pas être lu sur cet appareil.'**
  String get unsupportedBody;

  /// No description provided for @unsupportedChoose.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un autre fichier'**
  String get unsupportedChoose;

  /// No description provided for @permissionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser l\'accès aux médias'**
  String get permissionTitle;

  /// No description provided for @permissionBody.
  ///
  /// In fr, this message translates to:
  /// **'Le sélecteur du système n\'est pas disponible sur cet appareil. GraceEdit a besoin de votre autorisation pour ouvrir vos vidéos.'**
  String get permissionBody;

  /// No description provided for @permissionAllow.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser'**
  String get permissionAllow;

  /// No description provided for @permissionDeniedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accès refusé'**
  String get permissionDeniedTitle;

  /// No description provided for @permissionDeniedBody.
  ///
  /// In fr, this message translates to:
  /// **'Sans autorisation, GraceEdit ne peut pas ouvrir vos vidéos. Vous pouvez l\'accorder dans les réglages du téléphone.'**
  String get permissionDeniedBody;

  /// No description provided for @permissionOpenSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages'**
  String get permissionOpenSettings;

  /// No description provided for @pickerUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Le sélecteur de fichiers n\'est pas disponible.'**
  String get pickerUnavailable;

  /// No description provided for @pickerUnavailableBody.
  ///
  /// In fr, this message translates to:
  /// **'Fermez les applications qui pourraient l\'occuper, puis réessayez.'**
  String get pickerUnavailableBody;

  /// No description provided for @errorGenericTitle.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos projets sont intacts. Réessayez ; si le problème continue, redémarrez l\'application.'**
  String get errorGenericBody;

  /// No description provided for @semanticsBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get semanticsBack;

  /// No description provided for @semanticsClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get semanticsClose;

  /// No description provided for @semanticsMore.
  ///
  /// In fr, this message translates to:
  /// **'Plus d\'options'**
  String get semanticsMore;

  /// No description provided for @semanticsSelected.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionné'**
  String get semanticsSelected;

  /// No description provided for @semanticsUnselected.
  ///
  /// In fr, this message translates to:
  /// **'Non sélectionné'**
  String get semanticsUnselected;

  /// No description provided for @semanticsPlayhead.
  ///
  /// In fr, this message translates to:
  /// **'Tête de lecture'**
  String get semanticsPlayhead;

  /// No description provided for @semanticsPosition.
  ///
  /// In fr, this message translates to:
  /// **'Position {time}'**
  String semanticsPosition(String time);

  /// No description provided for @detailSeparator.
  ///
  /// In fr, this message translates to:
  /// **' · '**
  String get detailSeparator;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navProjects.
  ///
  /// In fr, this message translates to:
  /// **'Projets'**
  String get navProjects;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get navSettings;

  /// No description provided for @actionContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get actionContinue;

  /// No description provided for @homeSaved.
  ///
  /// In fr, this message translates to:
  /// **'Vos projets sont enregistrés automatiquement sur ce téléphone.'**
  String get homeSaved;

  /// No description provided for @homeStorageManage.
  ///
  /// In fr, this message translates to:
  /// **'Gérer'**
  String get homeStorageManage;

  /// No description provided for @modifiedJustNow.
  ///
  /// In fr, this message translates to:
  /// **'À l’instant'**
  String get modifiedJustNow;

  /// No description provided for @modifiedHoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{il y a 1 h} other{il y a {count} h}}'**
  String modifiedHoursAgo(num count);

  /// No description provided for @modifiedMinutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{il y a 1 min} other{il y a {count} min}}'**
  String modifiedMinutesAgo(num count);

  /// No description provided for @unitHoursShort.
  ///
  /// In fr, this message translates to:
  /// **'h'**
  String get unitHoursShort;

  /// No description provided for @unitMinutesShort.
  ///
  /// In fr, this message translates to:
  /// **'min'**
  String get unitMinutesShort;

  /// No description provided for @unitSecondsShort.
  ///
  /// In fr, this message translates to:
  /// **'s'**
  String get unitSecondsShort;

  /// No description provided for @dateYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get dateYesterday;

  /// No description provided for @projectLineLabel.
  ///
  /// In fr, this message translates to:
  /// **'{title}, {duration}, {when}'**
  String projectLineLabel(Object duration, Object title, Object when);

  /// No description provided for @importDurationTotal.
  ///
  /// In fr, this message translates to:
  /// **'Durée totale {duration}'**
  String importDurationTotal(Object duration);

  /// No description provided for @importIgnoredCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 ignoré} other{{count} ignorés}}'**
  String importIgnoredCount(num count);

  /// No description provided for @importIgnoredNotice.
  ///
  /// In fr, this message translates to:
  /// **'Le média non pris en charge sera ignoré.'**
  String get importIgnoredNotice;

  /// No description provided for @importNoneUsable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun de ces médias ne peut être utilisé. Ajoutez-en d’autres pour continuer.'**
  String get importNoneUsable;

  /// No description provided for @importOneVideo.
  ///
  /// In fr, this message translates to:
  /// **'1 vidéo'**
  String get importOneVideo;

  /// No description provided for @importVideos.
  ///
  /// In fr, this message translates to:
  /// **'{count} vidéos'**
  String importVideos(Object count);

  /// No description provided for @welcomeGuarantees.
  ///
  /// In fr, this message translates to:
  /// **'Garanties'**
  String get welcomeGuarantees;

  /// No description provided for @homeEmptyCta.
  ///
  /// In fr, this message translates to:
  /// **'Monter une vidéo'**
  String get homeEmptyCta;

  /// No description provided for @homeRecentCount.
  ///
  /// In fr, this message translates to:
  /// **'Récents'**
  String get homeRecentCount;

  /// No description provided for @importPicked.
  ///
  /// In fr, this message translates to:
  /// **'Médias choisis'**
  String get importPicked;

  /// No description provided for @importDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'18 oct., 14:32'**
  String get importDateLabel;

  /// No description provided for @editorTimecodeNow.
  ///
  /// In fr, this message translates to:
  /// **'Position actuelle'**
  String get editorTimecodeNow;

  /// No description provided for @editorTools.
  ///
  /// In fr, this message translates to:
  /// **'Outils'**
  String get editorTools;

  /// No description provided for @editorClipTools.
  ///
  /// In fr, this message translates to:
  /// **'Outils du clip'**
  String get editorClipTools;

  /// No description provided for @editorSplitHint.
  ///
  /// In fr, this message translates to:
  /// **'Placez la tête de lecture à l’intérieur du clip'**
  String get editorSplitHint;

  /// No description provided for @editorPreciseTrim.
  ///
  /// In fr, this message translates to:
  /// **'Rogner précisément'**
  String get editorPreciseTrim;

  /// No description provided for @editorDuplicateClip.
  ///
  /// In fr, this message translates to:
  /// **'Dupliquer le clip'**
  String get editorDuplicateClip;

  /// No description provided for @editorAddToTimeline.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à la timeline'**
  String get editorAddToTimeline;

  /// No description provided for @editorRemoveClip.
  ///
  /// In fr, this message translates to:
  /// **'Retirer ce clip'**
  String get editorRemoveClip;

  /// No description provided for @editorSavedAt.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde automatique'**
  String get editorSavedAt;

  /// No description provided for @editorTextSelected.
  ///
  /// In fr, this message translates to:
  /// **'Texte sélectionné'**
  String get editorTextSelected;

  /// No description provided for @editorAudioSelected.
  ///
  /// In fr, this message translates to:
  /// **'Musique sélectionnée'**
  String get editorAudioSelected;

  /// No description provided for @editorAutoCover.
  ///
  /// In fr, this message translates to:
  /// **'Couverture automatique'**
  String get editorAutoCover;

  /// No description provided for @editorCoverChosen.
  ///
  /// In fr, this message translates to:
  /// **'Couverture choisie'**
  String get editorCoverChosen;

  /// No description provided for @editorLocked.
  ///
  /// In fr, this message translates to:
  /// **'Lecture seule pendant l’export'**
  String get editorLocked;

  /// No description provided for @trimSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rogner précisément'**
  String get trimSheetTitle;

  /// No description provided for @trimStartLabel.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get trimStartLabel;

  /// No description provided for @trimEndLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get trimEndLabel;

  /// No description provided for @trimDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get trimDone;

  /// No description provided for @textAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter du texte'**
  String get textAddTitle;

  /// No description provided for @textEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le texte'**
  String get textEditTitle;

  /// No description provided for @textInputLabel.
  ///
  /// In fr, this message translates to:
  /// **'Texte'**
  String get textInputLabel;

  /// No description provided for @textFinish.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get textFinish;

  /// No description provided for @textEmptyError.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un texte'**
  String get textEmptyError;

  /// No description provided for @textColorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get textColorTitle;

  /// No description provided for @textStyleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Style'**
  String get textStyleTitle;

  /// No description provided for @textFontTitle.
  ///
  /// In fr, this message translates to:
  /// **'Police'**
  String get textFontTitle;

  /// No description provided for @textBackgroundTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fond'**
  String get textBackgroundTitle;

  /// No description provided for @textPresetPosition.
  ///
  /// In fr, this message translates to:
  /// **'Position'**
  String get textPresetPosition;

  /// No description provided for @textPresetAlignLeft.
  ///
  /// In fr, this message translates to:
  /// **'Gauche'**
  String get textPresetAlignLeft;

  /// No description provided for @textPresetAlignCenter.
  ///
  /// In fr, this message translates to:
  /// **'Centré'**
  String get textPresetAlignCenter;

  /// No description provided for @textPresetAlignRight.
  ///
  /// In fr, this message translates to:
  /// **'Droite'**
  String get textPresetAlignRight;

  /// No description provided for @textBackgroundNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get textBackgroundNone;

  /// No description provided for @textBackgroundLight.
  ///
  /// In fr, this message translates to:
  /// **'Léger'**
  String get textBackgroundLight;

  /// No description provided for @textBackgroundSolid.
  ///
  /// In fr, this message translates to:
  /// **'Plein'**
  String get textBackgroundSolid;

  /// No description provided for @textColorCream.
  ///
  /// In fr, this message translates to:
  /// **'Ivoire'**
  String get textColorCream;

  /// No description provided for @textColorInk.
  ///
  /// In fr, this message translates to:
  /// **'Encre'**
  String get textColorInk;

  /// No description provided for @textColorOrange.
  ///
  /// In fr, this message translates to:
  /// **'Vermillon'**
  String get textColorOrange;

  /// No description provided for @textColorHoney.
  ///
  /// In fr, this message translates to:
  /// **'Miel'**
  String get textColorHoney;

  /// No description provided for @textColorForest.
  ///
  /// In fr, this message translates to:
  /// **'Forêt'**
  String get textColorForest;

  /// No description provided for @textColorOcean.
  ///
  /// In fr, this message translates to:
  /// **'Océan'**
  String get textColorOcean;

  /// No description provided for @audioMix.
  ///
  /// In fr, this message translates to:
  /// **'Mixage'**
  String get audioMix;

  /// No description provided for @audioMuted.
  ///
  /// In fr, this message translates to:
  /// **'Coupé'**
  String get audioMuted;

  /// No description provided for @audioCustom.
  ///
  /// In fr, this message translates to:
  /// **'Personnalisé'**
  String get audioCustom;

  /// No description provided for @audioVolumeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Volume et fondus'**
  String get audioVolumeTitle;

  /// No description provided for @audioWaveformHint.
  ///
  /// In fr, this message translates to:
  /// **'Faites glisser pour déplacer, les poignées pour rogner.'**
  String get audioWaveformHint;

  /// No description provided for @adjustApplied.
  ///
  /// In fr, this message translates to:
  /// **'Appliqué à {count} clips'**
  String adjustApplied(Object count);

  /// No description provided for @adjustResetDone.
  ///
  /// In fr, this message translates to:
  /// **'Réglages réinitialisés'**
  String get adjustResetDone;

  /// No description provided for @formatFillHint.
  ///
  /// In fr, this message translates to:
  /// **'Remplir : l’image est recadrée pour couvrir tout le cadre, sans bandes.'**
  String get formatFillHint;

  /// No description provided for @cropFree.
  ///
  /// In fr, this message translates to:
  /// **'Libre'**
  String get cropFree;

  /// No description provided for @cropGridLabel.
  ///
  /// In fr, this message translates to:
  /// **'Grille des tiers'**
  String get cropGridLabel;

  /// No description provided for @coverImageInProjects.
  ///
  /// In fr, this message translates to:
  /// **'Dans vos projets'**
  String get coverImageInProjects;

  /// No description provided for @coverSlideHint.
  ///
  /// In fr, this message translates to:
  /// **'Faites glisser le cadre pour choisir l’image.'**
  String get coverSlideHint;

  /// No description provided for @coverModifiedNow.
  ///
  /// In fr, this message translates to:
  /// **'Modifié à l’instant'**
  String get coverModifiedNow;

  /// No description provided for @coverGalleryImage.
  ///
  /// In fr, this message translates to:
  /// **'Image de la galerie'**
  String get coverGalleryImage;

  /// No description provided for @coverChooseAnother.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une autre image'**
  String get coverChooseAnother;

  /// No description provided for @coverUseVideoImage.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser une image de la vidéo'**
  String get coverUseVideoImage;

  /// No description provided for @coverFromVideoLabel.
  ///
  /// In fr, this message translates to:
  /// **'Image de la vidéo'**
  String get coverFromVideoLabel;

  /// No description provided for @exportEstimatedSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille estimée : environ {size}'**
  String exportEstimatedSize(Object size);

  /// No description provided for @exportStep.
  ///
  /// In fr, this message translates to:
  /// **'Étape {current} sur {total}'**
  String exportStep(Object current, Object total);

  /// No description provided for @exportInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Export en cours'**
  String get exportInProgress;

  /// No description provided for @exportGallerySaved.
  ///
  /// In fr, this message translates to:
  /// **'Dans la galerie de votre téléphone'**
  String get exportGallerySaved;

  /// No description provided for @exportShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get exportShare;

  /// No description provided for @exportKeepEditing.
  ///
  /// In fr, this message translates to:
  /// **'Continuer à modifier'**
  String get exportKeepEditing;

  /// No description provided for @exportRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get exportRetry;

  /// No description provided for @exportTryStandardShort.
  ///
  /// In fr, this message translates to:
  /// **'Essayer en Standard · 720p'**
  String get exportTryStandardShort;

  /// No description provided for @exportSafeFileDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier incomplet a été supprimé'**
  String get exportSafeFileDeleted;

  /// No description provided for @exportNotLost.
  ///
  /// In fr, this message translates to:
  /// **'Votre vidéo n’est pas perdue'**
  String get exportNotLost;

  /// No description provided for @exportErrorDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails techniques'**
  String get exportErrorDetails;

  /// No description provided for @exportKeepInApp.
  ///
  /// In fr, this message translates to:
  /// **'conservé dans GraceEdit'**
  String get exportKeepInApp;

  /// No description provided for @exportCancelMessage.
  ///
  /// In fr, this message translates to:
  /// **'Export annulé. Votre projet n’est pas modifié.'**
  String get exportCancelMessage;

  /// No description provided for @exportSpaceNeededBody.
  ///
  /// In fr, this message translates to:
  /// **'Il faut environ {needed}. Il reste {free}.'**
  String exportSpaceNeededBody(Object free, Object needed);

  /// No description provided for @exportUnableRender.
  ///
  /// In fr, this message translates to:
  /// **'Un problème est survenu pendant la création de la vidéo. Rien n’a été enregistré dans votre galerie.'**
  String get exportUnableRender;

  /// No description provided for @exportUnableGallery.
  ///
  /// In fr, this message translates to:
  /// **'La vidéo a été créée, mais n’a pas pu être ajoutée à la galerie.'**
  String get exportUnableGallery;

  /// No description provided for @exportInterruptedBody.
  ///
  /// In fr, this message translates to:
  /// **'L’application a été fermée avant la fin. Votre projet est intact.'**
  String get exportInterruptedBody;

  /// No description provided for @exportBattery.
  ///
  /// In fr, this message translates to:
  /// **'Batterie très faible'**
  String get exportBattery;

  /// No description provided for @projectsSortTitle.
  ///
  /// In fr, this message translates to:
  /// **'Trier par'**
  String get projectsSortTitle;

  /// No description provided for @projectsViewToggleGrid.
  ///
  /// In fr, this message translates to:
  /// **'Passer en affichage en grille'**
  String get projectsViewToggleGrid;

  /// No description provided for @projectsViewToggleList.
  ///
  /// In fr, this message translates to:
  /// **'Passer en affichage en liste'**
  String get projectsViewToggleList;

  /// No description provided for @projectsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun projet} =1{1 projet} other{{count} projets}}'**
  String projectsCount(num count);

  /// No description provided for @projectsSelectAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout sélectionner'**
  String get projectsSelectAll;

  /// No description provided for @projectsDeselectAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout désélectionner'**
  String get projectsDeselectAll;

  /// No description provided for @projectsDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Dupliquer'**
  String get projectsDuplicate;

  /// No description provided for @projectsDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get projectsDelete;

  /// No description provided for @projectsExporting.
  ///
  /// In fr, this message translates to:
  /// **'Export en cours'**
  String get projectsExporting;

  /// No description provided for @projectsDuplicateDone.
  ///
  /// In fr, this message translates to:
  /// **'Projet dupliqué'**
  String get projectsDuplicateDone;

  /// No description provided for @projectsDuplicateMany.
  ///
  /// In fr, this message translates to:
  /// **'{count} projets dupliqués'**
  String projectsDuplicateMany(Object count);

  /// No description provided for @projectsDeleted.
  ///
  /// In fr, this message translates to:
  /// **'{count} projets supprimés'**
  String projectsDeleted(Object count);

  /// No description provided for @projectsDeleteSafeNote.
  ///
  /// In fr, this message translates to:
  /// **'Vos vidéos d’origine et vos vidéos exportées ne sont jamais supprimées.'**
  String get projectsDeleteSafeNote;

  /// No description provided for @projectsTrashEmpty.
  ///
  /// In fr, this message translates to:
  /// **'La corbeille est vide.'**
  String get projectsTrashEmpty;

  /// No description provided for @projectsTrashEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Les projets supprimés apparaissent ici pendant 30 jours.'**
  String get projectsTrashEmptyBody;

  /// No description provided for @trashDeletedAgo.
  ///
  /// In fr, this message translates to:
  /// **'Supprimé il y a {days} j'**
  String trashDeletedAgo(Object days);

  /// No description provided for @trashPurgeIn.
  ///
  /// In fr, this message translates to:
  /// **'Suppression dans {days} j'**
  String trashPurgeIn(Object days);

  /// No description provided for @trashPurgeTomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Suppression demain'**
  String get trashPurgeTomorrow;

  /// No description provided for @trashRestore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get trashRestore;

  /// No description provided for @trashDeleteForever.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement'**
  String get trashDeleteForever;

  /// No description provided for @trashPurgeAction.
  ///
  /// In fr, this message translates to:
  /// **'Vider'**
  String get trashPurgeAction;

  /// No description provided for @trashRestored.
  ///
  /// In fr, this message translates to:
  /// **'Projet restauré'**
  String get trashRestored;

  /// No description provided for @missingProjectLabel.
  ///
  /// In fr, this message translates to:
  /// **'Projet : {title}'**
  String missingProjectLabel(Object title);

  /// No description provided for @missingCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 média est introuvable} other{{count} médias sont introuvables}}'**
  String missingCount(num count);

  /// No description provided for @missingExplain.
  ///
  /// In fr, this message translates to:
  /// **'Il a peut-être été déplacé, renommé ou supprimé. Choisissez le fichier à utiliser à sa place.'**
  String get missingExplain;

  /// No description provided for @missingUsedIn.
  ///
  /// In fr, this message translates to:
  /// **'Utilisé dans {count} clips'**
  String missingUsedIn(Object count);

  /// No description provided for @missingReconnected.
  ///
  /// In fr, this message translates to:
  /// **'Reconnecté'**
  String get missingReconnected;

  /// No description provided for @missingChangeFile.
  ///
  /// In fr, this message translates to:
  /// **'Changer de fichier'**
  String get missingChangeFile;

  /// No description provided for @missingRemaining.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 média reste à reconnecter.} other{{count} médias restent à reconnecter.}}'**
  String missingRemaining(num count);

  /// No description provided for @missingUseAnyway.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser quand même'**
  String get missingUseAnyway;

  /// No description provided for @missingFileUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier ne peut pas être lu'**
  String get missingFileUnreadable;

  /// No description provided for @settingsValueAsk.
  ///
  /// In fr, this message translates to:
  /// **'Demander'**
  String get settingsValueAsk;

  /// No description provided for @settingsValueTrash.
  ///
  /// In fr, this message translates to:
  /// **'Corbeille'**
  String get settingsValueTrash;

  /// No description provided for @settingsThemeSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsThemeSheetTitle;

  /// No description provided for @settingsLanguageSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguageSheetTitle;

  /// No description provided for @settingsDeletionSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suppression'**
  String get settingsDeletionSheetTitle;

  /// No description provided for @storageGraceEditUses.
  ///
  /// In fr, this message translates to:
  /// **'GraceEdit utilise'**
  String get storageGraceEditUses;

  /// No description provided for @storageCacheThumbs.
  ///
  /// In fr, this message translates to:
  /// **'Cache et miniatures'**
  String get storageCacheThumbs;

  /// No description provided for @storageUnregistered.
  ///
  /// In fr, this message translates to:
  /// **'Exports non enregistrés'**
  String get storageUnregistered;

  /// No description provided for @storageTrash.
  ///
  /// In fr, this message translates to:
  /// **'Corbeille'**
  String get storageTrash;

  /// No description provided for @storageFreePhone.
  ///
  /// In fr, this message translates to:
  /// **'Espace libre sur le téléphone'**
  String get storageFreePhone;

  /// No description provided for @storageClear.
  ///
  /// In fr, this message translates to:
  /// **'Vider'**
  String get storageClear;

  /// No description provided for @storageNothingToClear.
  ///
  /// In fr, this message translates to:
  /// **'Rien à vider'**
  String get storageNothingToClear;

  /// No description provided for @storageCacheBody.
  ///
  /// In fr, this message translates to:
  /// **'Recréés au besoin'**
  String get storageCacheBody;

  /// No description provided for @storageLive.
  ///
  /// In fr, this message translates to:
  /// **'Espace libre'**
  String get storageLive;

  /// No description provided for @helpAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get helpAbout;

  /// No description provided for @helpReplayCta.
  ///
  /// In fr, this message translates to:
  /// **'Revoir la présentation'**
  String get helpReplayCta;

  /// No description provided for @helpDiagnosticTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rapport de diagnostic'**
  String get helpDiagnosticTitle;

  /// No description provided for @helpDiagnosticIntro.
  ///
  /// In fr, this message translates to:
  /// **'Ce rapport aide à comprendre un problème. Il est créé sur votre téléphone et n’est jamais envoyé automatiquement.'**
  String get helpDiagnosticIntro;

  /// No description provided for @helpContains.
  ///
  /// In fr, this message translates to:
  /// **'Ce qu’il contient'**
  String get helpContains;

  /// No description provided for @helpNotContains.
  ///
  /// In fr, this message translates to:
  /// **'Ce qu’il ne contient pas'**
  String get helpNotContains;

  /// No description provided for @helpDiagDevice.
  ///
  /// In fr, this message translates to:
  /// **'Modèle de l’appareil et version d’Android'**
  String get helpDiagDevice;

  /// No description provided for @helpDiagVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version de GraceEdit'**
  String get helpDiagVersion;

  /// No description provided for @helpDiagSpace.
  ///
  /// In fr, this message translates to:
  /// **'Espace libre et mémoire'**
  String get helpDiagSpace;

  /// No description provided for @helpDiagErrors.
  ///
  /// In fr, this message translates to:
  /// **'Derniers événements d’erreur'**
  String get helpDiagErrors;

  /// No description provided for @helpDiagNoVideos.
  ///
  /// In fr, this message translates to:
  /// **'Vos vidéos, vos photos, vos projets'**
  String get helpDiagNoVideos;

  /// No description provided for @helpDiagNoIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom, votre position'**
  String get helpDiagNoIdentity;

  /// No description provided for @helpDiagCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier le rapport'**
  String get helpDiagCopy;

  /// No description provided for @helpDiagShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get helpDiagShare;

  /// No description provided for @helpDiagCopied.
  ///
  /// In fr, this message translates to:
  /// **'Rapport copié'**
  String get helpDiagCopied;

  /// No description provided for @helpLicensesBody.
  ///
  /// In fr, this message translates to:
  /// **'Police Inter (licence SIL OFL) · Flutter (licence BSD) · Media3 (licence Apache 2.0)'**
  String get helpLicensesBody;

  /// No description provided for @helpTermsBody.
  ///
  /// In fr, this message translates to:
  /// **'GraceEdit est fourni tel quel, pour un usage personnel. Vous restez responsable des vidéos que vous montez et partagez. Aucune donnée n’est collectée.'**
  String get helpTermsBody;

  /// No description provided for @helpPrivacyBody.
  ///
  /// In fr, this message translates to:
  /// **'GraceEdit ne crée pas de compte, n’accède pas au réseau et n’envoie aucune donnée. Vos projets, réglages et vidéos restent sur votre appareil.'**
  String get helpPrivacyBody;

  /// No description provided for @recoverySavedAgo.
  ///
  /// In fr, this message translates to:
  /// **'Dernière sauvegarde {when}'**
  String recoverySavedAgo(Object when);

  /// No description provided for @recoveryLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get recoveryLater;

  /// No description provided for @recoverySafe.
  ///
  /// In fr, this message translates to:
  /// **'GraceEdit s’est fermé de façon inattendue. Votre travail a été récupéré.'**
  String get recoverySafe;

  /// No description provided for @saveFailedSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos modifications ne sont pas enregistrées'**
  String get saveFailedSheetTitle;

  /// No description provided for @saveFailedSheetBody.
  ///
  /// In fr, this message translates to:
  /// **'Le téléphone n’a pas pu enregistrer le projet : il manque de l’espace. Ne fermez pas l’application avant d’avoir résolu le problème.'**
  String get saveFailedSheetBody;

  /// No description provided for @saveRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get saveRetry;

  /// No description provided for @saveFreeSpace.
  ///
  /// In fr, this message translates to:
  /// **'Libérer de l’espace'**
  String get saveFreeSpace;

  /// No description provided for @storageFullSafe.
  ///
  /// In fr, this message translates to:
  /// **'Vos projets sont intacts.'**
  String get storageFullSafe;

  /// No description provided for @storageFullLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get storageFullLater;

  /// No description provided for @storageFullTrash.
  ///
  /// In fr, this message translates to:
  /// **'Voir la corbeille'**
  String get storageFullTrash;

  /// No description provided for @unsupportedOptionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Option non disponible'**
  String get unsupportedOptionTitle;

  /// No description provided for @unsupportedOptionBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre téléphone ne peut pas exporter en 1080p. Choisissez Standard · 720p.'**
  String get unsupportedOptionBody;

  /// No description provided for @unsupportedChooseStandard.
  ///
  /// In fr, this message translates to:
  /// **'Choisir Standard · 720p'**
  String get unsupportedChooseStandard;

  /// No description provided for @unsupportedClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get unsupportedClose;

  /// No description provided for @notificationWhy.
  ///
  /// In fr, this message translates to:
  /// **'GraceEdit peut afficher la progression et vous prévenir quand la vidéo est prête. L’export fonctionne aussi sans notification.'**
  String get notificationWhy;

  /// No description provided for @notificationAllow.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser les notifications'**
  String get notificationAllow;

  /// No description provided for @notificationLater.
  ///
  /// In fr, this message translates to:
  /// **'Pas maintenant'**
  String get notificationLater;

  /// No description provided for @permissionContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get permissionContinue;

  /// No description provided for @permissionChooseFiles.
  ///
  /// In fr, this message translates to:
  /// **'Choisir des fichiers un par un'**
  String get permissionChooseFiles;

  /// No description provided for @permissionSafe1.
  ///
  /// In fr, this message translates to:
  /// **'Vous choisissez ce que GraceEdit peut voir.'**
  String get permissionSafe1;

  /// No description provided for @permissionSafe2.
  ///
  /// In fr, this message translates to:
  /// **'Rien n’est envoyé en ligne.'**
  String get permissionSafe2;

  /// No description provided for @permissionDeniedPermission.
  ///
  /// In fr, this message translates to:
  /// **'Sans cet accès, GraceEdit ne peut pas afficher vos vidéos. Autorisez-le dans les réglages ou choisissez les fichiers un par un.'**
  String get permissionDeniedPermission;

  /// No description provided for @commonView.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get commonView;

  /// No description provided for @commonLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get commonLater;

  /// No description provided for @commonManage.
  ///
  /// In fr, this message translates to:
  /// **'Gérer'**
  String get commonManage;

  /// No description provided for @commonThisClip.
  ///
  /// In fr, this message translates to:
  /// **'Ce clip'**
  String get commonThisClip;

  /// No description provided for @commonWholeProject.
  ///
  /// In fr, this message translates to:
  /// **'Tout le projet'**
  String get commonWholeProject;

  /// No description provided for @commonOriginal.
  ///
  /// In fr, this message translates to:
  /// **'Original'**
  String get commonOriginal;

  /// No description provided for @commonCompare.
  ///
  /// In fr, this message translates to:
  /// **'Comparer'**
  String get commonCompare;

  /// No description provided for @commonReset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get commonReset;

  /// No description provided for @commonStep.
  ///
  /// In fr, this message translates to:
  /// **'Étape {current} sur {total}'**
  String commonStep(Object current, Object total);

  /// No description provided for @commonSeconds.
  ///
  /// In fr, this message translates to:
  /// **'{seconds} s'**
  String commonSeconds(Object seconds);

  /// No description provided for @commonMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min'**
  String commonMinutes(Object minutes);

  /// No description provided for @commonDays.
  ///
  /// In fr, this message translates to:
  /// **'{days} j'**
  String commonDays(Object days);

  /// No description provided for @commonPercent.
  ///
  /// In fr, this message translates to:
  /// **'{percent} %'**
  String commonPercent(Object percent);

  /// No description provided for @commonGigabytes.
  ///
  /// In fr, this message translates to:
  /// **'{value} Go'**
  String commonGigabytes(Object value);

  /// No description provided for @commonMegabytes.
  ///
  /// In fr, this message translates to:
  /// **'{value} Mo'**
  String commonMegabytes(Object value);

  /// No description provided for @commonSizeAndDuration.
  ///
  /// In fr, this message translates to:
  /// **'{size} · {duration}'**
  String commonSizeAndDuration(Object duration, Object size);

  /// No description provided for @commonDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get commonDone;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @commonOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir'**
  String get commonOpen;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get commonNext;

  /// No description provided for @commonPrevious.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get commonPrevious;

  /// No description provided for @commonPlay.
  ///
  /// In fr, this message translates to:
  /// **'Lire'**
  String get commonPlay;

  /// No description provided for @commonPause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get commonPause;

  /// No description provided for @commonMore.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get commonMore;

  /// No description provided for @commonLess.
  ///
  /// In fr, this message translates to:
  /// **'Moins'**
  String get commonLess;

  /// No description provided for @commonSaved.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré'**
  String get commonSaved;

  /// No description provided for @commonSaving.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement…'**
  String get commonSaving;

  /// No description provided for @commonNotSaved.
  ///
  /// In fr, this message translates to:
  /// **'Non enregistré'**
  String get commonNotSaved;

  /// No description provided for @commonAuto.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get commonAuto;

  ///
  ///
  /// In fr, this message translates to:
  /// **'Accessibilité'**
  String get settingsAccessibility;

  ///
  ///
  /// In fr, this message translates to:
  /// **'Suit le réglage de l\'appareil'**
  String get settingsMotionHint;

  ///
  ///
  /// In fr, this message translates to:
  /// **'Stockage et aide'**
  String get settingsStorageHelp;

  ///
  ///
  /// In fr, this message translates to:
  /// **'Stockage et cache'**
  String get settingsStorageCache;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
