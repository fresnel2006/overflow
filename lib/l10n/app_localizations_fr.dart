// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'OverFlow';

  @override
  String get appTagline => 'Abidjan - Protéger - Agir';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonOr => 'ou';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonDemoMode => 'Mode démonstration';

  @override
  String commonUpdatedAt(String time) {
    return 'Mis à jour $time';
  }

  @override
  String get errorNetworkTitle => 'Pas de connexion';

  @override
  String get errorNetworkMessage =>
      'Vérifiez votre connexion internet puis réessayez.';

  @override
  String get errorGenericTitle => 'Une erreur est survenue';

  @override
  String get errorGenericMessage =>
      'Nous n\'avons pas pu charger les données. Réessayez dans un instant.';

  @override
  String get errorNotFound => 'Élément introuvable';

  @override
  String get errorSession => 'Votre session a expiré. Reconnectez-vous.';

  @override
  String get errorUnavailable =>
      'Cette fonction n\'est pas disponible dans cette configuration.';

  @override
  String get offlineBanner =>
      'Hors ligne - affichage des dernières données reçues';

  @override
  String get severityNormal => 'Normal';

  @override
  String get severityVigilance => 'Vigilance';

  @override
  String get severityDanger => 'Danger';

  @override
  String get riskHigh => 'Risque élevé';

  @override
  String get riskMedium => 'Risque moyen';

  @override
  String get riskLow => 'Risque faible';

  @override
  String get trendRising => 'En augmentation';

  @override
  String get trendStable => 'Stable';

  @override
  String get trendFalling => 'En baisse';

  @override
  String get splashHeadline =>
      'Ensemble contre les inondations en Côte d\'Ivoire';

  @override
  String get splashStart => 'Commencer';

  @override
  String get authLoginTitle => 'Connexion';

  @override
  String get authLoginSubtitle =>
      'Heureux de vous retrouver ! Retrouvez les alertes et les informations de votre zone.';

  @override
  String get authPhoneLabel => 'Numéro de téléphone';

  @override
  String get authPhoneHint => '07 00 00 00 00';

  @override
  String get authSendCode => 'Recevoir le code SMS';

  @override
  String get authContinueGoogle => 'Continuer avec Google';

  @override
  String get authNoAccount => 'Pas encore de compte ?';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authBannerTitle => 'Ensemble, anticipons les inondations.';

  @override
  String get authBannerSubtitle => 'Abidjan · Protéger · Agir';

  @override
  String get authRegisterTitle => 'Créer un compte';

  @override
  String get authRegisterSubtitle =>
      'Rejoignez OverFlow pour être informé et mieux protéger votre quartier.';

  @override
  String get authFullNameLabel => 'Nom complet';

  @override
  String get authFullNameHint => 'Ex : Koffi Aya Marie';

  @override
  String get authAcceptPrefix => 'J\'accepte les ';

  @override
  String get authTerms => 'conditions d\'utilisation';

  @override
  String get authAnd => ' et la ';

  @override
  String get authPrivacy => 'politique de confidentialité';

  @override
  String get authHaveAccount => 'Déjà un compte ?';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authOtpTitle => 'Vérification OTP';

  @override
  String get authOtpSubtitle =>
      'Saisissez le code à 6 chiffres envoyé par SMS au ';

  @override
  String get authOtpCodeLabel => 'Code de vérification';

  @override
  String get authOtpValidity => 'Ce code est valable pendant 5 minutes.';

  @override
  String get authOtpVerify => 'Vérifier le code';

  @override
  String get authOtpChangeNumber => 'Modifier le numéro';

  @override
  String get authOtpNotReceived => 'Vous n\'avez pas reçu le code ?';

  @override
  String get authOtpResendIn => 'Renvoyer le SMS dans ';

  @override
  String get authOtpResend => 'Renvoyer le SMS';

  @override
  String get authOtpResent => 'Un nouveau code a été envoyé.';

  @override
  String get authOtpDemoHint =>
      'Mode démonstration : saisissez n\'importe quel code à 6 chiffres.';

  @override
  String get authLoginDemoHint =>
      'Mode démonstration : compte de test au 07 00 00 00 00.';

  @override
  String get authErrorInvalidPhone =>
      'Numéro invalide. Saisissez les 10 chiffres de votre numéro.';

  @override
  String get authErrorInvalidCode =>
      'Code incorrect. Vérifiez le SMS et réessayez.';

  @override
  String get authErrorExpiredCode =>
      'Ce code a expiré. Demandez un nouveau SMS.';

  @override
  String get authErrorTooMany =>
      'Trop de tentatives. Patientez quelques minutes.';

  @override
  String get authErrorNameRequired => 'Indiquez votre nom complet.';

  @override
  String get authErrorTermsRequired =>
      'Acceptez les conditions pour continuer.';

  @override
  String get authErrorGoogle => 'Connexion Google impossible. Réessayez.';

  @override
  String get authZoneTitle => 'Choisissez votre zone';

  @override
  String get authZoneSubtitle =>
      'Nous vous enverrons les alertes et le niveau d\'eau de cette commune.';

  @override
  String get authZoneConfirm => 'Valider ma zone';

  @override
  String get authZoneSearchHint => 'Rechercher une commune';

  @override
  String get authZoneLocate => 'Utiliser ma position';

  @override
  String authZoneLocated(String commune) {
    return 'Commune détectée : $commune';
  }

  @override
  String get navHome => 'Accueil';

  @override
  String get navMap => 'Carte';

  @override
  String get navAlerts => 'Alertes';

  @override
  String get navReport => 'Signalement';

  @override
  String get navProfile => 'Profil';

  @override
  String get homeSituation => 'Situation actuelle';

  @override
  String get homeNoAlert => 'Aucune alerte dans votre zone';

  @override
  String get homeAlertActive => 'Alerte inondation dans votre zone';

  @override
  String get homeVigilanceActive => 'Vigilance dans votre zone';

  @override
  String get homeRealtimeTitle => 'Niveau d\'eau en temps réel';

  @override
  String get homeSeeAllStations => 'Voir toutes les stations';

  @override
  String get homeZoneStatusTitle => 'Statut de ma zone';

  @override
  String get homeZoneNoFlood => 'Aucune inondation signalée';

  @override
  String get homeZoneVigilance => 'Niveau d\'eau à surveiller';

  @override
  String get homeZoneDanger => 'Inondation en cours';

  @override
  String get homeNoStations => 'Aucune station disponible pour le moment.';

  @override
  String get homeQuickWeather => 'Météo';

  @override
  String get homeQuick3d => 'Vue 3D';

  @override
  String get homeQuickAssistant => 'Assistant';

  @override
  String get homeQuickReport => 'Signaler';

  @override
  String get homeAssistantTitle => 'Une question ? Demandez à l\'assistant';

  @override
  String get homeAssistantSubtitle =>
      'Conseils de sécurité et explication des alertes';

  @override
  String homeOtherAlerts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alertes en cours ailleurs à Abidjan',
      one: '1 alerte en cours ailleurs à Abidjan',
    );
    return '$_temp0';
  }

  @override
  String get stationsTitle => 'Stations de mesure';

  @override
  String get stationsSearchHint => 'Rechercher une station ou une commune';

  @override
  String get stationsFilterAll => 'Toutes';

  @override
  String get stationsFilterMyZone => 'Ma zone';

  @override
  String get stationsEmpty => 'Aucune station ne correspond à votre recherche.';

  @override
  String get stationDetailLevel => 'Niveau d\'eau';

  @override
  String get stationThresholds => 'Seuils d\'alerte';

  @override
  String stationVigilanceThreshold(String value) {
    return 'Vigilance à partir de $value';
  }

  @override
  String stationDangerThreshold(String value) {
    return 'Danger à partir de $value';
  }

  @override
  String get station24h => 'Dernières 24 heures';

  @override
  String get stationInfo => 'Informations';

  @override
  String get stationSensor => 'Capteur';

  @override
  String get stationSensorOnline => 'En ligne';

  @override
  String get stationSensorOffline => 'Hors ligne';

  @override
  String get stationBattery => 'Batterie';

  @override
  String get stationLastUpdate => 'Dernière mesure';

  @override
  String get stationLocation => 'Emplacement';

  @override
  String get stationAboveStreet => 'Eau sur la chaussée';

  @override
  String get stationView3d => 'Voir en 3D';

  @override
  String get stationSeeOnMap => 'Voir sur la carte';

  @override
  String get stationNoHistory => 'Pas encore d\'historique pour cette station.';

  @override
  String get mapSearchHint => 'Rechercher une zone';

  @override
  String get mapLegend => 'Légende';

  @override
  String mapLastUpdate(String time) {
    return 'Dernière mise à jour $time';
  }

  @override
  String get mapZoneStations => 'Stations de la zone';

  @override
  String mapZoneLastFlood(String date) {
    return 'Dernière inondation : $date';
  }

  @override
  String get mapZoneNoStation =>
      'Aucune station dans cette zone pour le moment.';

  @override
  String get mapLocationDenied =>
      'Autorisez la localisation pour vous situer sur la carte.';

  @override
  String get mapLocationError => 'Position indisponible pour le moment.';

  @override
  String get mapNoResult => 'Aucune zone trouvée';

  @override
  String get mapSatellite => 'Satellite';

  @override
  String get mapPlan => 'Plan';

  @override
  String get mapZoomIn => 'Zoomer';

  @override
  String get mapZoomOut => 'Dézoomer';

  @override
  String get mapMyPosition => 'Ma position';

  @override
  String get mapTwin => 'Jumeau numérique 3D';

  @override
  String get alertsHistoryTitle => 'Historique des alertes';

  @override
  String get alertsAwarenessTitle => 'Sensibilisation';

  @override
  String get alertsFilterAll => 'Tous';

  @override
  String get alertsFilterMyZone => 'Ma zone';

  @override
  String get alertsFilterFloods => 'Inondations';

  @override
  String get alertsFilterTips => 'Conseils';

  @override
  String get alertKindFlood => 'Inondation';

  @override
  String get alertKindWarning => 'Alerte';

  @override
  String get alertKindEnded => 'Fin d\'alerte';

  @override
  String get alertsEmpty => 'Aucune alerte pour ce filtre.';

  @override
  String get alertsEmptyZone =>
      'Aucune alerte dans votre zone. Bonne nouvelle !';

  @override
  String get alertsActiveBadge => 'En cours';

  @override
  String get alertScreenFlood => 'Alerte inondation';

  @override
  String get alertScreenWarning => 'Vigilance crue';

  @override
  String get alertScreenEnded => 'Fin d\'alerte';

  @override
  String get alertLevel => 'Niveau d\'eau';

  @override
  String get alertInstructions => 'Consignes';

  @override
  String get alertSeeMap => 'Voir la carte';

  @override
  String get alertExplainAi => 'Comprendre avec l\'assistant';

  @override
  String get alertSeeStation => 'Voir la station';

  @override
  String alertIssuedAt(String date) {
    return 'Émise le $date';
  }

  @override
  String get awarenessEmpty => 'Aucun conseil disponible pour le moment.';

  @override
  String get awarenessKeyPoints => 'À retenir';

  @override
  String get awarenessAskAi => 'Poser une question à l\'assistant';

  @override
  String get reportTabTitle => 'Signalement';

  @override
  String get reportCtaTitle => 'Signaler un problème';

  @override
  String get reportCtaSubtitle =>
      'Caniveau bouché, route inondée... Prévenez les autorités en 1 minute.';

  @override
  String get reportMyReports => 'Mes signalements';

  @override
  String get reportEmpty => 'Vous n\'avez encore envoyé aucun signalement.';

  @override
  String get reportFormTitle => 'Signaler un problème';

  @override
  String get reportPhotoPrompt =>
      'Prenez une capture de la situation actuelle qui augmente le risque d\'inondation';

  @override
  String get reportChangePhoto => 'Changer la photo';

  @override
  String get reportTakePhoto => 'Prendre une photo';

  @override
  String get reportFromGallery => 'Choisir dans la galerie';

  @override
  String get reportRemovePhoto => 'Retirer la photo';

  @override
  String get reportDescription => 'Description';

  @override
  String get reportDescriptionHint =>
      'Décrivez la situation (lieu exact, depuis quand...)';

  @override
  String get reportLocation => 'Localisation';

  @override
  String get reportLocationAuto => 'Localisation automatique';

  @override
  String get reportLocationManual => 'Choisie manuellement';

  @override
  String get reportLocationLocating => 'Recherche de votre position...';

  @override
  String get reportLocationUnavailable =>
      'Position indisponible, choisissez la commune';

  @override
  String get reportModify => 'Modifier';

  @override
  String get reportType => 'Type de problème';

  @override
  String get reportTypeBlockedDrain => 'Caniveau bouché';

  @override
  String get reportTypeFloodedRoad => 'Route inondée';

  @override
  String get reportTypeOther => 'Autre';

  @override
  String get reportSend => 'Envoyer';

  @override
  String get reportSentTitle => 'Signalement envoyé';

  @override
  String get reportSentMessage =>
      'Merci ! Votre signalement a été transmis aux autorités. Suivez son traitement dans Mes signalements.';

  @override
  String get reportTrack => 'Suivre mon signalement';

  @override
  String get reportErrorDescription =>
      'Décrivez la situation en quelques mots.';

  @override
  String get reportErrorPhoto =>
      'Impossible d\'accéder à l\'appareil photo ou à la galerie.';

  @override
  String get reportStatusSent => 'Envoyé';

  @override
  String get reportStatusInReview => 'En cours d\'examen';

  @override
  String get reportStatusInProgress => 'Intervention en cours';

  @override
  String get reportStatusResolved => 'Résolu';

  @override
  String get reportStatusRejected => 'Non retenu';

  @override
  String get reportDetailTitle => 'Suivi du signalement';

  @override
  String get reportDetailHistory => 'Historique';

  @override
  String get reportPickCommune => 'Choisir la commune';

  @override
  String get weatherTitle => 'Météo';

  @override
  String get weatherToday => 'Aujourd\'hui';

  @override
  String weatherConfidence(int pct) {
    return 'Indice de confiance : $pct%';
  }

  @override
  String get weatherForecast5 => 'Prévisions sur 5 jours';

  @override
  String get weatherClear => 'Ensoleillé';

  @override
  String get weatherPartlyCloudy => 'Éclaircies';

  @override
  String get weatherCloudy => 'Nuageux';

  @override
  String get weatherDrizzle => 'Bruine';

  @override
  String get weatherRain => 'Pluie modérée';

  @override
  String get weatherHeavyRain => 'Fortes pluies';

  @override
  String get weatherStorm => 'Orages';

  @override
  String get weatherRainAdvice =>
      'Pluies attendues : évitez les bas-fonds et suivez les alertes de votre zone.';

  @override
  String get profileTitle => 'Mon profil';

  @override
  String get profilePersonalInfo => 'Informations personnelles';

  @override
  String get profileZone => 'Ma zone d\'habitation';

  @override
  String get profileSettings => 'Paramètres';

  @override
  String get profileHelp => 'Aide et support';

  @override
  String get profileLogout => 'Déconnexion';

  @override
  String get profileLogoutConfirmTitle => 'Se déconnecter ?';

  @override
  String get profileLogoutConfirmMessage =>
      'Vous ne recevrez plus les alertes sur cet appareil tant que vous serez déconnecté.';

  @override
  String get profileNoEmail => 'Aucun e-mail renseigné';

  @override
  String get profileNoZone => 'Aucune zone choisie';

  @override
  String get profileEmailLabel => 'Adresse e-mail';

  @override
  String get profileEmailHint => 'exemple@mail.com';

  @override
  String get profileSaved => 'Modifications enregistrées';

  @override
  String get profileInvalidEmail => 'Adresse e-mail invalide';

  @override
  String profileZoneUpdated(String commune) {
    return 'Zone mise à jour : $commune';
  }

  @override
  String get profilePhoneReadonly =>
      'Le numéro sert à la connexion et ne peut pas être modifié ici.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPushAlerts => 'Alertes push';

  @override
  String get settingsPushAlertsDesc => 'Recevoir les alertes de ma zone';

  @override
  String get settingsVigilance => 'Alertes de vigilance';

  @override
  String get settingsVigilanceDesc => 'Être prévenu dès le niveau Vigilance';

  @override
  String get settingsAllZones => 'Toutes les communes';

  @override
  String get settingsAllZonesDesc =>
      'Recevoir aussi les alertes des autres communes';

  @override
  String get settingsSms => 'Alertes par SMS';

  @override
  String get settingsSmsDesc => 'En complément des notifications';

  @override
  String get settingsTestAlert => 'Recevoir une alerte de test';

  @override
  String get settingsTestAlertSent =>
      'Alerte de test demandée. Elle arrive dans quelques secondes.';

  @override
  String get settingsData => 'Données';

  @override
  String get settingsDataSource => 'Source des données';

  @override
  String get settingsDataMock => 'Données de démonstration';

  @override
  String get settingsDataLive => 'Serveur Overflow';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageValue => 'Français';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsTerms => 'Conditions d\'utilisation';

  @override
  String get helpTitle => 'Aide et support';

  @override
  String get helpEmergency => 'Numéros d\'urgence';

  @override
  String get helpFirefighters => 'Sapeurs-pompiers';

  @override
  String get helpSamu => 'SAMU';

  @override
  String get helpPolice => 'Police secours';

  @override
  String get helpCall => 'Appeler';

  @override
  String get helpFaq => 'Questions fréquentes';

  @override
  String get helpQ1 => 'D\'où viennent les niveaux d\'eau ?';

  @override
  String get helpA1 =>
      'Des capteurs à ultrasons installés dans des boîtiers sur les lampadaires mesurent la hauteur d\'eau des caniveaux et des bas-fonds, toutes les quelques minutes.';

  @override
  String get helpQ2 => 'Que signifient Normal, Vigilance et Danger ?';

  @override
  String get helpA2 =>
      'Normal : l\'eau s\'écoule bien. Vigilance : le niveau monte, restez attentifs. Danger : l\'eau déborde ou va déborder, suivez les consignes.';

  @override
  String get helpQ3 => 'Comment recevoir les alertes ?';

  @override
  String get helpA3 =>
      'Choisissez votre zone d\'habitation dans le profil et activez les notifications dans les paramètres. Les alertes sont aussi envoyées par SMS et les sirènes se déclenchent sur le terrain.';

  @override
  String get helpQ4 => 'Que deviennent mes signalements ?';

  @override
  String get helpA4 =>
      'Ils sont transmis aux services techniques de votre mairie. Vous suivez leur traitement dans l\'onglet Signalement.';

  @override
  String get helpAbout =>
      'Overflow est développé par l\'équipe Overflow Minds (ESATIC) pour la prévention et la gestion des risques d\'inondation en Côte d\'Ivoire.';

  @override
  String get termsTitle => 'Conditions d\'utilisation';

  @override
  String get termsBody =>
      'Overflow fournit des informations sur le niveau d\'eau mesuré par des capteurs et des alertes émises par les autorités. Ces informations sont données à titre indicatif et ne remplacent pas les consignes officielles.\n\nVos données (nom, numéro de téléphone, zone suivie, signalements et photos) servent uniquement à vous envoyer des alertes et à traiter vos signalements. Elles ne sont pas revendues.\n\nVotre position n\'est utilisée que lorsque vous la demandez (carte, signalement). Vous pouvez supprimer votre compte à tout moment en contactant l\'équipe Overflow.';

  @override
  String get assistantTitle => 'Assistant Overflow';

  @override
  String get assistantSubtitleAi => 'Propulsé par Gemini';

  @override
  String get assistantSubtitleOffline => 'Mode hors ligne : réponses préparées';

  @override
  String get assistantWelcome =>
      'Bonjour ! Je peux vous donner des conseils de sécurité ou vous expliquer une alerte. Que voulez-vous savoir ?';

  @override
  String get assistantInputHint => 'Écrivez votre question...';

  @override
  String get assistantSuggest1 => 'Que faire en cas d\'alerte ?';

  @override
  String get assistantSuggest2 => 'Comment préparer un kit d\'urgence ?';

  @override
  String get assistantSuggest3 => 'Que signifie le niveau Vigilance ?';

  @override
  String get assistantSuggestExplain => 'Explique-moi cette alerte';

  @override
  String get assistantError =>
      'Réponse impossible pour le moment. Touchez pour réessayer.';

  @override
  String get assistantDisclaimer =>
      'Les conseils de l\'assistant ne remplacent pas les consignes des autorités.';

  @override
  String get assistantSend => 'Envoyer';

  @override
  String get twinTitle => 'Jumeau numérique 3D';

  @override
  String get twinLive => 'Temps réel';

  @override
  String get twinScenarios => 'Simulations';

  @override
  String get twinLiveLabel => 'Mesure capteur';

  @override
  String get twinNoSensor =>
      'Aucun capteur relié à ce site : affichage des simulations.';

  @override
  String get twinNoSites => 'Aucun site 3D disponible.';

  @override
  String get notifChannelName => 'Alertes inondation';

  @override
  String get notifChannelDesc => 'Alertes de niveau d\'eau de votre zone';

  @override
  String get emergencySos => 'SOS';

  @override
  String get emergencyTitle => 'Besoin d\'aide ?';

  @override
  String get emergencySubtitle =>
      'Appelez directement les secours. Les numéros d\'urgence sont gratuits.';

  @override
  String get emergencySendSos => 'Envoyer un SOS avec ma position';

  @override
  String get emergencySosHint =>
      'Votre position est transmise aux autorités qui supervisent les inondations.';

  @override
  String emergencySosSent(String ref) {
    return 'SOS reçu (réf. $ref)';
  }

  @override
  String get emergencySosSentDetail =>
      'Les autorités ont votre position. Si votre vie est en danger, appelez aussi les sapeurs-pompiers.';

  @override
  String get emergencySosOffline =>
      'Pas de connexion : le SOS n\'est pas parti. Appelez directement un numéro ci-dessous.';

  @override
  String get emergencyCallTitle => 'Appeler les secours';

  @override
  String emergencyCallSemantics(String name, String number) {
    return 'Appeler $name au $number';
  }

  @override
  String get emergencyShareSms => 'Partager ma position par SMS';

  @override
  String emergencySmsBody(String commune, String location) {
    return 'URGENCE inondation. J\'ai besoin d\'aide à $commune.$location (envoyé depuis Overflow)';
  }

  @override
  String emergencyCallError(String number) {
    return 'Impossible d\'ouvrir le téléphone. Composez le $number.';
  }

  @override
  String get emergencyLaunchError => 'Impossible d\'ouvrir l\'application SMS.';

  @override
  String get emergencyCallButton => 'Appeler les secours';

  @override
  String get emergencyBannerTitle => 'Vous êtes dans une zone inondée ?';

  @override
  String get emergencyBannerSubtitle =>
      'Appelez les secours ou envoyez un SOS en un geste.';

  @override
  String get mapEmergency => 'Urgence';
}
