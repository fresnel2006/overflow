# Overflow - application mobile

Application citoyenne de prévention des inondations en Côte d'Ivoire (projet APP3 26-27, ESATIC, équipe Overflow Minds).
Niveau d'eau en temps réel, carte des zones à risque, alertes, signalements, météo, assistant IA (Gemini) et jumeau numérique 3D.

## Lancer le projet

Prérequis : Flutter 3.47+ (Dart 3.13), un émulateur Android (API 24+) ou un iPhone.

```bash
flutter pub get
flutter run
```

Par défaut l'application tourne avec des **données fictives d'Abidjan** (`USE_MOCKS=true`) : aucun backend n'est nécessaire.

- Connexion de démonstration : numéro `07 00 00 00 00`, puis n'importe quel code à 6 chiffres (`000000` simule un code faux).
- Un autre numéro crée un nouveau compte (choix de la zone à la première connexion).
- Profil > Paramètres > « Recevoir une alerte de test » : déclenche une alerte Danger dans votre zone (notification + écran rouge).

Vérifications :

```bash
flutter analyze
```

## Configuration (`assets/config/app.env`)

Copiez `assets/config/app.env.example` en `assets/config/app.env` (ignoré par git) puis remplissez :

| Clé | Rôle |
|---|---|
| `USE_MOCKS` | `true` : données fictives. `false` : API FastAPI + Firebase |
| `API_BASE_URL` | URL de l'API FastAPI, ex. `https://api.overflow.ci/api/v1` (émulateur Android + serveur local : `http://10.0.2.2:8000/api/v1`) |
| `REFRESH_INTERVAL_SECONDS` | Rafraîchissement automatique des niveaux d'eau (30 s par défaut) |
| `REALTIME_SOURCE` | `polling` (API) ou `firestore` (collection `stations`) |
| `FIREBASE_*` | Options Firebase (Auth, Firestore, Storage, FCM). Vide = Firebase désactivé |
| `GEMINI_API_KEY`, `GEMINI_MODEL` | Assistant IA en appel direct |
| `AI_PROXY_URL` | Route FastAPI qui relaie Gemini (recommandé en production) |

Chaque clé peut aussi être passée à la compilation : `flutter run --dart-define=GEMINI_API_KEY=...` (prioritaire sur le fichier).
Aucune clé n'est écrite dans le code. Attention : une clé placée dans l'app (fichier ou `--dart-define`) reste extractible de l'APK ; en production, utilisez `AI_PROXY_URL` pour garder la clé Gemini côté serveur.

Sans clé Gemini, l'assistant répond avec des conseils préparés (mode hors ligne).

## Architecture

```
lib/
  main.dart, app.dart              Chargement de la config, Firebase, ProviderScope, MaterialApp.router
  core/
    config/      AppConfig (.env + --dart-define)
    router/      go_router : routes, redirection d'authentification, carte de navigation
    theme/       Couleurs (relevées sur les maquettes), Poppins, styles de gravité
    network/     Client Dio (jeton Firebase, erreurs typées), état de connexion
    widgets/     Boutons, cartes, badges, filtres, états chargement / erreur / vide / hors ligne
    services/    Notifications locales, géolocalisation
    domain/      Gravité, communes d'Abidjan
    l10n/        Accès aux traductions
  features/<nom>/{domain, data, presentation}
    auth          Connexion SMS / Google, OTP, choix de la zone
    home          Accueil et barre d'onglets
    water_levels  Stations, niveaux temps réel, historique 24 h
    map           Carte des zones à risque (flutter_map)
    alerts        Historique, sensibilisation, écran d'alerte, push FCM
    reports       Signalements citoyens (photo, GPS) et suivi
    weather       Prévisions (Open-Meteo en mode réel)
    profile       Profil, zone, paramètres, aide
    assistant     Assistant IA (Gemini)
    digital_twin  Jumeau numérique 3D (viewer Three.js en WebView)
  l10n/app_fr.arb  Textes de l'interface
```

- **État** : Riverpod 3 (déjà utilisé par le jumeau numérique, donc un seul système dans toute l'app).
- **Données** : chaque feature expose une interface (`domain/*_repository.dart`) et deux implémentations (`data/`) : mock et réelle. Le choix se fait dans les providers selon `USE_MOCKS`.
- **Carte** : `flutter_map` avec imagerie satellite Esri et plan OpenStreetMap. Pas de clé API ni de facturation Google, et les tuiles se mettent en cache.

## Navigation

```
/welcome -> /login <-> /register -> /otp -> (/zone-setup) -> /home
Onglets : Accueil /home, Carte /map, Alertes /alerts, Signalement /reports, Profil /profile
/home          -> météo, toutes les stations, station, alerte de ma zone, carte de ma zone, assistant, vue 3D, signaler
/station/:id   -> vue 3D du site, position sur la carte
/map           -> fiche de zone -> station, vue 3D
/alerts        -> filtres Tous / Ma zone / Inondations / Conseils -> /alert/:id, /awareness/:id
/alert/:id     -> carte, assistant (« Comprendre avec l'assistant »), station
/reports       -> /report/new -> /report/:id (suivi)
/profile       -> infos, zone, paramètres (alerte de test), aide, conditions
Notification ou alerte Danger dans ma zone -> /alert/:id en plein écran
```

## Jumeau numérique 3D

Le viewer de `flutter_flood_viewer` est intégré dans `lib/features/digital_twin` (scène compilée dans `assets/viewer/index.html`).
Il est relié au backend de deux façons :

- **Simulations** : géométrie des sites et scénarios de crue via `GET /twin/sites` (même format JSON que le dashboard web). Si l'API est injoignable, les sites embarqués (`assets/data/twin_sites_abidjan.json`) prennent le relais.
- **Temps réel** : chaque station a un `twin_site_id` et un `street_level_cm` (profondeur du caniveau). L'app construit un scénario « Mesure capteur » dont la hauteur = niveau mesuré - profondeur du caniveau, avec l'historique 24 h comme frise. À chaque nouvelle mesure, l'eau monte ou descend dans la scène. Les crues simulées restent visibles comme repères.

Pour recompiler la scène web : voir le README de `flutter_flood_viewer/viewer_web`, puis copier `index.html` dans `assets/viewer/`.

## Brancher le vrai backend

### API FastAPI attendue (JSON en snake_case, auth `Authorization: Bearer <Firebase ID token>`)

| Méthode | Route | Réponse |
|---|---|---|
| GET | `/stations` | `[{id, name, commune, place, lat, lon, level_cm, vigilance_cm, danger_cm, trend, updated_at, online, battery_pct, twin_site_id, street_level_cm}]` |
| GET | `/stations/{id}` | une station |
| GET | `/stations/{id}/readings?hours=24` | `[{time, level_cm}]` |
| GET | `/zones` | `[{id, name, commune, lat, lon, radius_m, risk: high/medium/low, description, station_ids, last_flood_at, twin_site_id}]` |
| GET | `/communes` | `[{id, name, city, lat, lon}]` |
| GET | `/alerts` (option `?active=true`) | `[{id, kind: flood/warning/ended, severity: normal/vigilance/danger, commune, place, created_at, level_cm, trend, message, instructions: [{icon, text}], station_id, active}]` |
| GET | `/alerts/{id}` | une alerte |
| POST | `/alerts/test` | `{commune}` : alerte de test (push + SMS) |
| GET | `/awareness` | `[{id, title, summary, paragraphs, tips, icon, published_at}]` |
| GET | `/reports/me` | signalements de l'utilisateur |
| GET | `/reports/{id}` | `{id, type, description, commune, status, created_at, lat, lon, photo_url, history: [{status, at, note}]}` |
| POST | `/reports` | JSON (avec `photo_url` si Firebase Storage) ou multipart avec le champ `photo` |
| POST | `/devices` | `{token, platform, commune}` : jeton FCM |
| GET | `/twin/sites` | jeux de données du jumeau 3D |
| POST | `AI_PROXY_URL` | `{messages: [{role, text}], context}` -> `{reply}` |

Valeurs : `trend` = `rising` / `stable` / `falling` ; `type` = `blocked_drain` / `flooded_road` / `other` ; `status` = `sent` / `in_review` / `in_progress` / `resolved` / `rejected`.

### Firebase

1. Créez le projet Firebase et ajoutez une app Android (`com.example.overflow`, à changer avant publication) et iOS.
2. Reportez les valeurs dans `FIREBASE_*` de `app.env` (pas besoin de `google-services.json`, l'initialisation se fait par options).
3. Activez Authentication > Téléphone et Google. Pour Android, ajoutez l'empreinte SHA-1 / SHA-256 de votre clé de signature.
4. Firestore : collection `users/{uid}` (profil), et si `REALTIME_SOURCE=firestore`, collection `stations` alimentée par le backend.
5. Storage : dossier `reports/{uid}/`.
6. FCM : le backend envoie sur le sujet `zone_<commune>` (ex. `zone_cocody`, sans accents) avec `data.alert_id`. Sur iOS, ajoutez la capacité Push Notifications et la clé APNs dans Firebase.

### Production

- Retirez `android:usesCleartextTraffic="true"` du manifeste une fois l'API en HTTPS (il sert au serveur local en HTTP).
- Changez `applicationId` et configurez une clé de signature de publication.

## Ajouter l'anglais

Créez `lib/l10n/app_en.arb` avec les mêmes clés que `app_fr.arb`, puis retirez `locale: const Locale('fr')` dans `lib/app.dart`. Les classes sont régénérées automatiquement au build (`flutter gen-l10n`).

## Image d'accueil

L'écran d'accueil affiche `assets/images/splash_abidjan.jpg` s'il existe (photo d'Abidjan des maquettes). Sinon, une illustration vectorielle de la lagune et du Plateau la remplace.
#   o v e r f l o w  
 