import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
/// import 'l10n/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'OverFlow'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Abidjan - Protéger - Agir'**
  String get appTagline;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @commonOr.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get commonOr;

  /// No description provided for @commonContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// No description provided for @commonDemoMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode démonstration'**
  String get commonDemoMode;

  /// No description provided for @commonUpdatedAt.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour {time}'**
  String commonUpdatedAt(String time);

  /// No description provided for @errorNetworkTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion'**
  String get errorNetworkTitle;

  /// No description provided for @errorNetworkMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre connexion internet puis réessayez.'**
  String get errorNetworkMessage;

  /// No description provided for @errorGenericTitle.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericMessage.
  ///
  /// In fr, this message translates to:
  /// **'Nous n\'avons pas pu charger les données. Réessayez dans un instant.'**
  String get errorGenericMessage;

  /// No description provided for @errorNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Élément introuvable'**
  String get errorNotFound;

  /// No description provided for @errorSession.
  ///
  /// In fr, this message translates to:
  /// **'Votre session a expiré. Reconnectez-vous.'**
  String get errorSession;

  /// No description provided for @errorUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Cette fonction n\'est pas disponible dans cette configuration.'**
  String get errorUnavailable;

  /// No description provided for @offlineBanner.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne - affichage des dernières données reçues'**
  String get offlineBanner;

  /// No description provided for @severityNormal.
  ///
  /// In fr, this message translates to:
  /// **'Normal'**
  String get severityNormal;

  /// No description provided for @severityVigilance.
  ///
  /// In fr, this message translates to:
  /// **'Vigilance'**
  String get severityVigilance;

  /// No description provided for @severityDanger.
  ///
  /// In fr, this message translates to:
  /// **'Danger'**
  String get severityDanger;

  /// No description provided for @riskHigh.
  ///
  /// In fr, this message translates to:
  /// **'Risque élevé'**
  String get riskHigh;

  /// No description provided for @riskMedium.
  ///
  /// In fr, this message translates to:
  /// **'Risque moyen'**
  String get riskMedium;

  /// No description provided for @riskLow.
  ///
  /// In fr, this message translates to:
  /// **'Risque faible'**
  String get riskLow;

  /// No description provided for @trendRising.
  ///
  /// In fr, this message translates to:
  /// **'En augmentation'**
  String get trendRising;

  /// No description provided for @trendStable.
  ///
  /// In fr, this message translates to:
  /// **'Stable'**
  String get trendStable;

  /// No description provided for @trendFalling.
  ///
  /// In fr, this message translates to:
  /// **'En baisse'**
  String get trendFalling;

  /// No description provided for @splashHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Ensemble contre les inondations en Côte d\'Ivoire'**
  String get splashHeadline;

  /// No description provided for @splashStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get splashStart;

  /// No description provided for @authLoginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Heureux de vous retrouver ! Retrouvez les alertes et les informations de votre zone.'**
  String get authLoginSubtitle;

  /// No description provided for @authPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneHint.
  ///
  /// In fr, this message translates to:
  /// **'07 00 00 00 00'**
  String get authPhoneHint;

  /// No description provided for @authSendCode.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir le code SMS'**
  String get authSendCode;

  /// No description provided for @authContinueGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get authContinueGoogle;

  /// No description provided for @authNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get authNoAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get authCreateAccount;

  /// No description provided for @authBannerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ensemble, anticipons les inondations.'**
  String get authBannerTitle;

  /// No description provided for @authBannerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Abidjan · Protéger · Agir'**
  String get authBannerSubtitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez OverFlow pour être informé et mieux protéger votre quartier.'**
  String get authRegisterSubtitle;

  /// No description provided for @authFullNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get authFullNameLabel;

  /// No description provided for @authFullNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Koffi Aya Marie'**
  String get authFullNameHint;

  /// No description provided for @authAcceptPrefix.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte les '**
  String get authAcceptPrefix;

  /// No description provided for @authTerms.
  ///
  /// In fr, this message translates to:
  /// **'conditions d\'utilisation'**
  String get authTerms;

  /// No description provided for @authAnd.
  ///
  /// In fr, this message translates to:
  /// **' et la '**
  String get authAnd;

  /// No description provided for @authPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'politique de confidentialité'**
  String get authPrivacy;

  /// No description provided for @authHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get authHaveAccount;

  /// No description provided for @authSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authSignIn;

  /// No description provided for @authOtpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérification OTP'**
  String get authOtpTitle;

  /// No description provided for @authOtpSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le code à 6 chiffres envoyé par SMS au '**
  String get authOtpSubtitle;

  /// No description provided for @authOtpCodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code de vérification'**
  String get authOtpCodeLabel;

  /// No description provided for @authOtpValidity.
  ///
  /// In fr, this message translates to:
  /// **'Ce code est valable pendant 5 minutes.'**
  String get authOtpValidity;

  /// No description provided for @authOtpVerify.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier le code'**
  String get authOtpVerify;

  /// No description provided for @authOtpChangeNumber.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le numéro'**
  String get authOtpChangeNumber;

  /// No description provided for @authOtpNotReceived.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas reçu le code ?'**
  String get authOtpNotReceived;

  /// No description provided for @authOtpResendIn.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le SMS dans '**
  String get authOtpResendIn;

  /// No description provided for @authOtpResend.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le SMS'**
  String get authOtpResend;

  /// No description provided for @authOtpResent.
  ///
  /// In fr, this message translates to:
  /// **'Un nouveau code a été envoyé.'**
  String get authOtpResent;

  /// No description provided for @authOtpDemoHint.
  ///
  /// In fr, this message translates to:
  /// **'Mode démonstration : saisissez n\'importe quel code à 6 chiffres.'**
  String get authOtpDemoHint;

  /// No description provided for @authLoginDemoHint.
  ///
  /// In fr, this message translates to:
  /// **'Mode démonstration : compte de test au 07 00 00 00 00.'**
  String get authLoginDemoHint;

  /// No description provided for @authErrorInvalidPhone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide. Saisissez les 10 chiffres de votre numéro.'**
  String get authErrorInvalidPhone;

  /// No description provided for @authErrorInvalidCode.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect. Vérifiez le SMS et réessayez.'**
  String get authErrorInvalidCode;

  /// No description provided for @authErrorExpiredCode.
  ///
  /// In fr, this message translates to:
  /// **'Ce code a expiré. Demandez un nouveau SMS.'**
  String get authErrorExpiredCode;

  /// No description provided for @authErrorTooMany.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Patientez quelques minutes.'**
  String get authErrorTooMany;

  /// No description provided for @authErrorNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez votre nom complet.'**
  String get authErrorNameRequired;

  /// No description provided for @authErrorTermsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Acceptez les conditions pour continuer.'**
  String get authErrorTermsRequired;

  /// No description provided for @authErrorGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion Google impossible. Réessayez.'**
  String get authErrorGoogle;

  /// No description provided for @authZoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre zone'**
  String get authZoneTitle;

  /// No description provided for @authZoneSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Nous vous enverrons les alertes et le niveau d\'eau de cette commune.'**
  String get authZoneSubtitle;

  /// No description provided for @authZoneConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Valider ma zone'**
  String get authZoneConfirm;

  /// No description provided for @authZoneSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une commune'**
  String get authZoneSearchHint;

  /// No description provided for @authZoneLocate.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser ma position'**
  String get authZoneLocate;

  /// No description provided for @authZoneLocated.
  ///
  /// In fr, this message translates to:
  /// **'Commune détectée : {commune}'**
  String authZoneLocated(String commune);

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navMap.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get navMap;

  /// No description provided for @navAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get navAlerts;

  /// No description provided for @navReport.
  ///
  /// In fr, this message translates to:
  /// **'Signalement'**
  String get navReport;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @homeSituation.
  ///
  /// In fr, this message translates to:
  /// **'Situation actuelle'**
  String get homeSituation;

  /// No description provided for @homeNoAlert.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte dans votre zone'**
  String get homeNoAlert;

  /// No description provided for @homeAlertActive.
  ///
  /// In fr, this message translates to:
  /// **'Alerte inondation dans votre zone'**
  String get homeAlertActive;

  /// No description provided for @homeVigilanceActive.
  ///
  /// In fr, this message translates to:
  /// **'Vigilance dans votre zone'**
  String get homeVigilanceActive;

  /// No description provided for @homeRealtimeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Niveau d\'eau en temps réel'**
  String get homeRealtimeTitle;

  /// No description provided for @homeSeeAllStations.
  ///
  /// In fr, this message translates to:
  /// **'Voir toutes les stations'**
  String get homeSeeAllStations;

  /// No description provided for @homeZoneStatusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statut de ma zone'**
  String get homeZoneStatusTitle;

  /// No description provided for @homeZoneNoFlood.
  ///
  /// In fr, this message translates to:
  /// **'Aucune inondation signalée'**
  String get homeZoneNoFlood;

  /// No description provided for @homeZoneVigilance.
  ///
  /// In fr, this message translates to:
  /// **'Niveau d\'eau à surveiller'**
  String get homeZoneVigilance;

  /// No description provided for @homeZoneDanger.
  ///
  /// In fr, this message translates to:
  /// **'Inondation en cours'**
  String get homeZoneDanger;

  /// No description provided for @homeNoStations.
  ///
  /// In fr, this message translates to:
  /// **'Aucune station disponible pour le moment.'**
  String get homeNoStations;

  /// No description provided for @homeQuickWeather.
  ///
  /// In fr, this message translates to:
  /// **'Météo'**
  String get homeQuickWeather;

  /// No description provided for @homeQuick3d.
  ///
  /// In fr, this message translates to:
  /// **'Vue 3D'**
  String get homeQuick3d;

  /// No description provided for @homeQuickAssistant.
  ///
  /// In fr, this message translates to:
  /// **'Assistant'**
  String get homeQuickAssistant;

  /// No description provided for @homeQuickReport.
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get homeQuickReport;

  /// No description provided for @homeAssistantTitle.
  ///
  /// In fr, this message translates to:
  /// **'Une question ? Demandez à l\'assistant'**
  String get homeAssistantTitle;

  /// No description provided for @homeAssistantSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Conseils de sécurité et explication des alertes'**
  String get homeAssistantSubtitle;

  /// No description provided for @homeOtherAlerts.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 alerte en cours ailleurs à Abidjan} other{{count} alertes en cours ailleurs à Abidjan}}'**
  String homeOtherAlerts(int count);

  /// No description provided for @stationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stations de mesure'**
  String get stationsTitle;

  /// No description provided for @stationsSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une station ou une commune'**
  String get stationsSearchHint;

  /// No description provided for @stationsFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get stationsFilterAll;

  /// No description provided for @stationsFilterMyZone.
  ///
  /// In fr, this message translates to:
  /// **'Ma zone'**
  String get stationsFilterMyZone;

  /// No description provided for @stationsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune station ne correspond à votre recherche.'**
  String get stationsEmpty;

  /// No description provided for @stationDetailLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau d\'eau'**
  String get stationDetailLevel;

  /// No description provided for @stationThresholds.
  ///
  /// In fr, this message translates to:
  /// **'Seuils d\'alerte'**
  String get stationThresholds;

  /// No description provided for @stationVigilanceThreshold.
  ///
  /// In fr, this message translates to:
  /// **'Vigilance à partir de {value}'**
  String stationVigilanceThreshold(String value);

  /// No description provided for @stationDangerThreshold.
  ///
  /// In fr, this message translates to:
  /// **'Danger à partir de {value}'**
  String stationDangerThreshold(String value);

  /// No description provided for @station24h.
  ///
  /// In fr, this message translates to:
  /// **'Dernières 24 heures'**
  String get station24h;

  /// No description provided for @stationInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get stationInfo;

  /// No description provided for @stationSensor.
  ///
  /// In fr, this message translates to:
  /// **'Capteur'**
  String get stationSensor;

  /// No description provided for @stationSensorOnline.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get stationSensorOnline;

  /// No description provided for @stationSensorOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get stationSensorOffline;

  /// No description provided for @stationBattery.
  ///
  /// In fr, this message translates to:
  /// **'Batterie'**
  String get stationBattery;

  /// No description provided for @stationLastUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Dernière mesure'**
  String get stationLastUpdate;

  /// No description provided for @stationLocation.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement'**
  String get stationLocation;

  /// No description provided for @stationAboveStreet.
  ///
  /// In fr, this message translates to:
  /// **'Eau sur la chaussée'**
  String get stationAboveStreet;

  /// No description provided for @stationView3d.
  ///
  /// In fr, this message translates to:
  /// **'Voir en 3D'**
  String get stationView3d;

  /// No description provided for @stationSeeOnMap.
  ///
  /// In fr, this message translates to:
  /// **'Voir sur la carte'**
  String get stationSeeOnMap;

  /// No description provided for @stationNoHistory.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore d\'historique pour cette station.'**
  String get stationNoHistory;

  /// No description provided for @mapSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une zone'**
  String get mapSearchHint;

  /// No description provided for @mapLegend.
  ///
  /// In fr, this message translates to:
  /// **'Légende'**
  String get mapLegend;

  /// No description provided for @mapLastUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Dernière mise à jour {time}'**
  String mapLastUpdate(String time);

  /// No description provided for @mapZoneStations.
  ///
  /// In fr, this message translates to:
  /// **'Stations de la zone'**
  String get mapZoneStations;

  /// No description provided for @mapZoneLastFlood.
  ///
  /// In fr, this message translates to:
  /// **'Dernière inondation : {date}'**
  String mapZoneLastFlood(String date);

  /// No description provided for @mapZoneNoStation.
  ///
  /// In fr, this message translates to:
  /// **'Aucune station dans cette zone pour le moment.'**
  String get mapZoneNoStation;

  /// No description provided for @mapLocationDenied.
  ///
  /// In fr, this message translates to:
  /// **'Autorisez la localisation pour vous situer sur la carte.'**
  String get mapLocationDenied;

  /// No description provided for @mapLocationError.
  ///
  /// In fr, this message translates to:
  /// **'Position indisponible pour le moment.'**
  String get mapLocationError;

  /// No description provided for @mapNoResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucune zone trouvée'**
  String get mapNoResult;

  /// No description provided for @mapSatellite.
  ///
  /// In fr, this message translates to:
  /// **'Satellite'**
  String get mapSatellite;

  /// No description provided for @mapPlan.
  ///
  /// In fr, this message translates to:
  /// **'Plan'**
  String get mapPlan;

  /// No description provided for @mapZoomIn.
  ///
  /// In fr, this message translates to:
  /// **'Zoomer'**
  String get mapZoomIn;

  /// No description provided for @mapZoomOut.
  ///
  /// In fr, this message translates to:
  /// **'Dézoomer'**
  String get mapZoomOut;

  /// No description provided for @mapMyPosition.
  ///
  /// In fr, this message translates to:
  /// **'Ma position'**
  String get mapMyPosition;

  /// No description provided for @mapTwin.
  ///
  /// In fr, this message translates to:
  /// **'Jumeau numérique 3D'**
  String get mapTwin;

  /// No description provided for @alertsHistoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des alertes'**
  String get alertsHistoryTitle;

  /// No description provided for @alertsAwarenessTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sensibilisation'**
  String get alertsAwarenessTitle;

  /// No description provided for @alertsFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get alertsFilterAll;

  /// No description provided for @alertsFilterMyZone.
  ///
  /// In fr, this message translates to:
  /// **'Ma zone'**
  String get alertsFilterMyZone;

  /// No description provided for @alertsFilterFloods.
  ///
  /// In fr, this message translates to:
  /// **'Inondations'**
  String get alertsFilterFloods;

  /// No description provided for @alertsFilterTips.
  ///
  /// In fr, this message translates to:
  /// **'Conseils'**
  String get alertsFilterTips;

  /// No description provided for @alertKindFlood.
  ///
  /// In fr, this message translates to:
  /// **'Inondation'**
  String get alertKindFlood;

  /// No description provided for @alertKindWarning.
  ///
  /// In fr, this message translates to:
  /// **'Alerte'**
  String get alertKindWarning;

  /// No description provided for @alertKindEnded.
  ///
  /// In fr, this message translates to:
  /// **'Fin d\'alerte'**
  String get alertKindEnded;

  /// No description provided for @alertsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte pour ce filtre.'**
  String get alertsEmpty;

  /// No description provided for @alertsEmptyZone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte dans votre zone. Bonne nouvelle !'**
  String get alertsEmptyZone;

  /// No description provided for @alertsActiveBadge.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get alertsActiveBadge;

  /// No description provided for @alertScreenFlood.
  ///
  /// In fr, this message translates to:
  /// **'Alerte inondation'**
  String get alertScreenFlood;

  /// No description provided for @alertScreenWarning.
  ///
  /// In fr, this message translates to:
  /// **'Vigilance crue'**
  String get alertScreenWarning;

  /// No description provided for @alertScreenEnded.
  ///
  /// In fr, this message translates to:
  /// **'Fin d\'alerte'**
  String get alertScreenEnded;

  /// No description provided for @alertLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau d\'eau'**
  String get alertLevel;

  /// No description provided for @alertInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Consignes'**
  String get alertInstructions;

  /// No description provided for @alertSeeMap.
  ///
  /// In fr, this message translates to:
  /// **'Voir la carte'**
  String get alertSeeMap;

  /// No description provided for @alertExplainAi.
  ///
  /// In fr, this message translates to:
  /// **'Comprendre avec l\'assistant'**
  String get alertExplainAi;

  /// No description provided for @alertSeeStation.
  ///
  /// In fr, this message translates to:
  /// **'Voir la station'**
  String get alertSeeStation;

  /// No description provided for @alertIssuedAt.
  ///
  /// In fr, this message translates to:
  /// **'Émise le {date}'**
  String alertIssuedAt(String date);

  /// No description provided for @awarenessEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun conseil disponible pour le moment.'**
  String get awarenessEmpty;

  /// No description provided for @awarenessKeyPoints.
  ///
  /// In fr, this message translates to:
  /// **'À retenir'**
  String get awarenessKeyPoints;

  /// No description provided for @awarenessAskAi.
  ///
  /// In fr, this message translates to:
  /// **'Poser une question à l\'assistant'**
  String get awarenessAskAi;

  /// No description provided for @reportTabTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signalement'**
  String get reportTabTitle;

  /// No description provided for @reportCtaTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un problème'**
  String get reportCtaTitle;

  /// No description provided for @reportCtaSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Caniveau bouché, route inondée... Prévenez les autorités en 1 minute.'**
  String get reportCtaSubtitle;

  /// No description provided for @reportMyReports.
  ///
  /// In fr, this message translates to:
  /// **'Mes signalements'**
  String get reportMyReports;

  /// No description provided for @reportEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez encore envoyé aucun signalement.'**
  String get reportEmpty;

  /// No description provided for @reportFormTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un problème'**
  String get reportFormTitle;

  /// No description provided for @reportPhotoPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Prenez une capture de la situation actuelle qui augmente le risque d\'inondation'**
  String get reportPhotoPrompt;

  /// No description provided for @reportChangePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get reportChangePhoto;

  /// No description provided for @reportTakePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get reportTakePhoto;

  /// No description provided for @reportFromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get reportFromGallery;

  /// No description provided for @reportRemovePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la photo'**
  String get reportRemovePhoto;

  /// No description provided for @reportDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get reportDescription;

  /// No description provided for @reportDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez la situation (lieu exact, depuis quand...)'**
  String get reportDescriptionHint;

  /// No description provided for @reportLocation.
  ///
  /// In fr, this message translates to:
  /// **'Localisation'**
  String get reportLocation;

  /// No description provided for @reportLocationAuto.
  ///
  /// In fr, this message translates to:
  /// **'Localisation automatique'**
  String get reportLocationAuto;

  /// No description provided for @reportLocationManual.
  ///
  /// In fr, this message translates to:
  /// **'Choisie manuellement'**
  String get reportLocationManual;

  /// No description provided for @reportLocationLocating.
  ///
  /// In fr, this message translates to:
  /// **'Recherche de votre position...'**
  String get reportLocationLocating;

  /// No description provided for @reportLocationUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Position indisponible, choisissez la commune'**
  String get reportLocationUnavailable;

  /// No description provided for @reportModify.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get reportModify;

  /// No description provided for @reportType.
  ///
  /// In fr, this message translates to:
  /// **'Type de problème'**
  String get reportType;

  /// No description provided for @reportTypeBlockedDrain.
  ///
  /// In fr, this message translates to:
  /// **'Caniveau bouché'**
  String get reportTypeBlockedDrain;

  /// No description provided for @reportTypeFloodedRoad.
  ///
  /// In fr, this message translates to:
  /// **'Route inondée'**
  String get reportTypeFloodedRoad;

  /// No description provided for @reportTypeOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get reportTypeOther;

  /// No description provided for @reportSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get reportSend;

  /// No description provided for @reportSentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signalement envoyé'**
  String get reportSentTitle;

  /// No description provided for @reportSentMessage.
  ///
  /// In fr, this message translates to:
  /// **'Merci ! Votre signalement a été transmis aux autorités. Suivez son traitement dans Mes signalements.'**
  String get reportSentMessage;

  /// No description provided for @reportTrack.
  ///
  /// In fr, this message translates to:
  /// **'Suivre mon signalement'**
  String get reportTrack;

  /// No description provided for @reportErrorDescription.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez la situation en quelques mots.'**
  String get reportErrorDescription;

  /// No description provided for @reportErrorPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'accéder à l\'appareil photo ou à la galerie.'**
  String get reportErrorPhoto;

  /// No description provided for @reportStatusSent.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé'**
  String get reportStatusSent;

  /// No description provided for @reportStatusInReview.
  ///
  /// In fr, this message translates to:
  /// **'En cours d\'examen'**
  String get reportStatusInReview;

  /// No description provided for @reportStatusInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Intervention en cours'**
  String get reportStatusInProgress;

  /// No description provided for @reportStatusResolved.
  ///
  /// In fr, this message translates to:
  /// **'Résolu'**
  String get reportStatusResolved;

  /// No description provided for @reportStatusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Non retenu'**
  String get reportStatusRejected;

  /// No description provided for @reportDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivi du signalement'**
  String get reportDetailTitle;

  /// No description provided for @reportDetailHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get reportDetailHistory;

  /// No description provided for @reportPickCommune.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la commune'**
  String get reportPickCommune;

  /// No description provided for @weatherTitle.
  ///
  /// In fr, this message translates to:
  /// **'Météo'**
  String get weatherTitle;

  /// No description provided for @weatherToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get weatherToday;

  /// No description provided for @weatherConfidence.
  ///
  /// In fr, this message translates to:
  /// **'Indice de confiance : {pct}%'**
  String weatherConfidence(int pct);

  /// No description provided for @weatherForecast5.
  ///
  /// In fr, this message translates to:
  /// **'Prévisions sur 5 jours'**
  String get weatherForecast5;

  /// No description provided for @weatherClear.
  ///
  /// In fr, this message translates to:
  /// **'Ensoleillé'**
  String get weatherClear;

  /// No description provided for @weatherPartlyCloudy.
  ///
  /// In fr, this message translates to:
  /// **'Éclaircies'**
  String get weatherPartlyCloudy;

  /// No description provided for @weatherCloudy.
  ///
  /// In fr, this message translates to:
  /// **'Nuageux'**
  String get weatherCloudy;

  /// No description provided for @weatherDrizzle.
  ///
  /// In fr, this message translates to:
  /// **'Bruine'**
  String get weatherDrizzle;

  /// No description provided for @weatherRain.
  ///
  /// In fr, this message translates to:
  /// **'Pluie modérée'**
  String get weatherRain;

  /// No description provided for @weatherHeavyRain.
  ///
  /// In fr, this message translates to:
  /// **'Fortes pluies'**
  String get weatherHeavyRain;

  /// No description provided for @weatherStorm.
  ///
  /// In fr, this message translates to:
  /// **'Orages'**
  String get weatherStorm;

  /// No description provided for @weatherRainAdvice.
  ///
  /// In fr, this message translates to:
  /// **'Pluies attendues : évitez les bas-fonds et suivez les alertes de votre zone.'**
  String get weatherRainAdvice;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get profileTitle;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get profilePersonalInfo;

  /// No description provided for @profileZone.
  ///
  /// In fr, this message translates to:
  /// **'Ma zone d\'habitation'**
  String get profileZone;

  /// No description provided for @profileSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get profileSettings;

  /// No description provided for @profileHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide et support'**
  String get profileHelp;

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get profileLogoutConfirmTitle;

  /// No description provided for @profileLogoutConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne recevrez plus les alertes sur cet appareil tant que vous serez déconnecté.'**
  String get profileLogoutConfirmMessage;

  /// No description provided for @profileNoEmail.
  ///
  /// In fr, this message translates to:
  /// **'Aucun e-mail renseigné'**
  String get profileNoEmail;

  /// No description provided for @profileNoZone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune zone choisie'**
  String get profileNoZone;

  /// No description provided for @profileEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get profileEmailLabel;

  /// No description provided for @profileEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'exemple@mail.com'**
  String get profileEmailHint;

  /// No description provided for @profileSaved.
  ///
  /// In fr, this message translates to:
  /// **'Modifications enregistrées'**
  String get profileSaved;

  /// No description provided for @profileInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide'**
  String get profileInvalidEmail;

  /// No description provided for @profileZoneUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Zone mise à jour : {commune}'**
  String profileZoneUpdated(String commune);

  /// No description provided for @profilePhoneReadonly.
  ///
  /// In fr, this message translates to:
  /// **'Le numéro sert à la connexion et ne peut pas être modifié ici.'**
  String get profilePhoneReadonly;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsPushAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes push'**
  String get settingsPushAlerts;

  /// No description provided for @settingsPushAlertsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir les alertes de ma zone'**
  String get settingsPushAlertsDesc;

  /// No description provided for @settingsVigilance.
  ///
  /// In fr, this message translates to:
  /// **'Alertes de vigilance'**
  String get settingsVigilance;

  /// No description provided for @settingsVigilanceDesc.
  ///
  /// In fr, this message translates to:
  /// **'Être prévenu dès le niveau Vigilance'**
  String get settingsVigilanceDesc;

  /// No description provided for @settingsAllZones.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les communes'**
  String get settingsAllZones;

  /// No description provided for @settingsAllZonesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir aussi les alertes des autres communes'**
  String get settingsAllZonesDesc;

  /// No description provided for @settingsSms.
  ///
  /// In fr, this message translates to:
  /// **'Alertes par SMS'**
  String get settingsSms;

  /// No description provided for @settingsSmsDesc.
  ///
  /// In fr, this message translates to:
  /// **'En complément des notifications'**
  String get settingsSmsDesc;

  /// No description provided for @settingsTestAlert.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir une alerte de test'**
  String get settingsTestAlert;

  /// No description provided for @settingsTestAlertSent.
  ///
  /// In fr, this message translates to:
  /// **'Alerte de test demandée. Elle arrive dans quelques secondes.'**
  String get settingsTestAlertSent;

  /// No description provided for @settingsData.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get settingsData;

  /// No description provided for @settingsDataSource.
  ///
  /// In fr, this message translates to:
  /// **'Source des données'**
  String get settingsDataSource;

  /// No description provided for @settingsDataMock.
  ///
  /// In fr, this message translates to:
  /// **'Données de démonstration'**
  String get settingsDataMock;

  /// No description provided for @settingsDataLive.
  ///
  /// In fr, this message translates to:
  /// **'Serveur Overflow'**
  String get settingsDataLive;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageValue.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get settingsLanguageValue;

  /// No description provided for @settingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsTerms.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get settingsTerms;

  /// No description provided for @helpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aide et support'**
  String get helpTitle;

  /// No description provided for @helpEmergency.
  ///
  /// In fr, this message translates to:
  /// **'Numéros d\'urgence'**
  String get helpEmergency;

  /// No description provided for @helpFirefighters.
  ///
  /// In fr, this message translates to:
  /// **'Sapeurs-pompiers'**
  String get helpFirefighters;

  /// No description provided for @helpSamu.
  ///
  /// In fr, this message translates to:
  /// **'SAMU'**
  String get helpSamu;

  /// No description provided for @helpPolice.
  ///
  /// In fr, this message translates to:
  /// **'Police secours'**
  String get helpPolice;

  /// No description provided for @helpCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get helpCall;

  /// No description provided for @helpFaq.
  ///
  /// In fr, this message translates to:
  /// **'Questions fréquentes'**
  String get helpFaq;

  /// No description provided for @helpQ1.
  ///
  /// In fr, this message translates to:
  /// **'D\'où viennent les niveaux d\'eau ?'**
  String get helpQ1;

  /// No description provided for @helpA1.
  ///
  /// In fr, this message translates to:
  /// **'Des capteurs à ultrasons installés dans des boîtiers sur les lampadaires mesurent la hauteur d\'eau des caniveaux et des bas-fonds, toutes les quelques minutes.'**
  String get helpA1;

  /// No description provided for @helpQ2.
  ///
  /// In fr, this message translates to:
  /// **'Que signifient Normal, Vigilance et Danger ?'**
  String get helpQ2;

  /// No description provided for @helpA2.
  ///
  /// In fr, this message translates to:
  /// **'Normal : l\'eau s\'écoule bien. Vigilance : le niveau monte, restez attentifs. Danger : l\'eau déborde ou va déborder, suivez les consignes.'**
  String get helpA2;

  /// No description provided for @helpQ3.
  ///
  /// In fr, this message translates to:
  /// **'Comment recevoir les alertes ?'**
  String get helpQ3;

  /// No description provided for @helpA3.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre zone d\'habitation dans le profil et activez les notifications dans les paramètres. Les alertes sont aussi envoyées par SMS et les sirènes se déclenchent sur le terrain.'**
  String get helpA3;

  /// No description provided for @helpQ4.
  ///
  /// In fr, this message translates to:
  /// **'Que deviennent mes signalements ?'**
  String get helpQ4;

  /// No description provided for @helpA4.
  ///
  /// In fr, this message translates to:
  /// **'Ils sont transmis aux services techniques de votre mairie. Vous suivez leur traitement dans l\'onglet Signalement.'**
  String get helpA4;

  /// No description provided for @helpAbout.
  ///
  /// In fr, this message translates to:
  /// **'Overflow est développé par l\'équipe Overflow Minds (ESATIC) pour la prévention et la gestion des risques d\'inondation en Côte d\'Ivoire.'**
  String get helpAbout;

  /// No description provided for @termsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get termsTitle;

  /// No description provided for @termsBody.
  ///
  /// In fr, this message translates to:
  /// **'Overflow fournit des informations sur le niveau d\'eau mesuré par des capteurs et des alertes émises par les autorités. Ces informations sont données à titre indicatif et ne remplacent pas les consignes officielles.\n\nVos données (nom, numéro de téléphone, zone suivie, signalements et photos) servent uniquement à vous envoyer des alertes et à traiter vos signalements. Elles ne sont pas revendues.\n\nVotre position n\'est utilisée que lorsque vous la demandez (carte, signalement). Vous pouvez supprimer votre compte à tout moment en contactant l\'équipe Overflow.'**
  String get termsBody;

  /// No description provided for @assistantTitle.
  ///
  /// In fr, this message translates to:
  /// **'Assistant Overflow'**
  String get assistantTitle;

  /// No description provided for @assistantSubtitleAi.
  ///
  /// In fr, this message translates to:
  /// **'Propulsé par Gemini'**
  String get assistantSubtitleAi;

  /// No description provided for @assistantSubtitleOffline.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors ligne : réponses préparées'**
  String get assistantSubtitleOffline;

  /// No description provided for @assistantWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour ! Je peux vous donner des conseils de sécurité ou vous expliquer une alerte. Que voulez-vous savoir ?'**
  String get assistantWelcome;

  /// No description provided for @assistantInputHint.
  ///
  /// In fr, this message translates to:
  /// **'Écrivez votre question...'**
  String get assistantInputHint;

  /// No description provided for @assistantSuggest1.
  ///
  /// In fr, this message translates to:
  /// **'Que faire en cas d\'alerte ?'**
  String get assistantSuggest1;

  /// No description provided for @assistantSuggest2.
  ///
  /// In fr, this message translates to:
  /// **'Comment préparer un kit d\'urgence ?'**
  String get assistantSuggest2;

  /// No description provided for @assistantSuggest3.
  ///
  /// In fr, this message translates to:
  /// **'Que signifie le niveau Vigilance ?'**
  String get assistantSuggest3;

  /// No description provided for @assistantSuggestExplain.
  ///
  /// In fr, this message translates to:
  /// **'Explique-moi cette alerte'**
  String get assistantSuggestExplain;

  /// No description provided for @assistantError.
  ///
  /// In fr, this message translates to:
  /// **'Réponse impossible pour le moment. Touchez pour réessayer.'**
  String get assistantError;

  /// No description provided for @assistantDisclaimer.
  ///
  /// In fr, this message translates to:
  /// **'Les conseils de l\'assistant ne remplacent pas les consignes des autorités.'**
  String get assistantDisclaimer;

  /// No description provided for @assistantSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get assistantSend;

  /// No description provided for @twinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Jumeau numérique 3D'**
  String get twinTitle;

  /// No description provided for @twinLive.
  ///
  /// In fr, this message translates to:
  /// **'Temps réel'**
  String get twinLive;

  /// No description provided for @twinScenarios.
  ///
  /// In fr, this message translates to:
  /// **'Simulations'**
  String get twinScenarios;

  /// No description provided for @twinLiveLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mesure capteur'**
  String get twinLiveLabel;

  /// No description provided for @twinNoSensor.
  ///
  /// In fr, this message translates to:
  /// **'Aucun capteur relié à ce site : affichage des simulations.'**
  String get twinNoSensor;

  /// No description provided for @twinNoSites.
  ///
  /// In fr, this message translates to:
  /// **'Aucun site 3D disponible.'**
  String get twinNoSites;

  /// No description provided for @notifChannelName.
  ///
  /// In fr, this message translates to:
  /// **'Alertes inondation'**
  String get notifChannelName;

  /// No description provided for @notifChannelDesc.
  ///
  /// In fr, this message translates to:
  /// **'Alertes de niveau d\'eau de votre zone'**
  String get notifChannelDesc;
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
      <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
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
