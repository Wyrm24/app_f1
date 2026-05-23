# Fantasy F1 App

## Description
Fantasy F1 est une application mobile Flutter pour gérer des ligues de fantasy Formule 1.

**Fonctionnalités principales :**
- Authentification utilisateur via Supabase
- Création/rejoindre des ligues privées (code invite F1-XXXXXX)
- Composition d'équipe : 3 pilotes + 2 écuries (budget max 100M)
- Classements ligues en temps réel
- Home avec top performers, prochaines courses
- Thème F1 dark/light personnalisé
- Profils utilisateurs, quiz, préférences

## Architecture Globale
```
Frontend (Flutter App) <--> Supabase (Auth + DB)
                              |
                       Backend Python (OpenF1 API → Supabase)
```

- **Frontend** : Flutter/Dart avec Supabase Flutter client (direct DB queries)
- **Backend** : Python (non dans ce repo) appelle OpenF1 API, popule Supabase (races/drivers/teams)
- **Database** : Supabase PostgreSQL (tables: users/profiles, fantasy_leagues/teams, compositions, races, drivers, teams)

## Structure lib/
```
lib/
├── main.dart
├── core/
│   └── theme.dart
├── data/
│   ├── constants.dart
│   ├── notifiers.dart
│   ├── classes/
│   ├── models/
│   │   ├── driver.dart
│   │   ├── team.dart
│   │   ├── fantasy_league_model.dart
│   │   ├── fantasy_team_model.dart
│   │   └── composition_model.dart
│   └── services/
│       ├── supabase_auth_service.dart
│       ├── league_service.dart
│       └── composition_service.dart
└── views/
    ├── widget_tree.dart
    ├── pages/
    │   ├── home_page.dart
    │   ├── league_page.dart
    │   ├── league_detail_page.dart
    │   ├── pick_team_page.dart
    │   ├── profile_page.dart
    │   └── ...
    └── widgets/
        ├── custom_nav_bar.dart
        ├── custom_app_bar.dart
        ├── league_card.dart
        ├── gp_card.dart
        └── ...
```

## Stack Technique
| Composant | Technologies |
|-----------|--------------|
| Frontend | Flutter 3.x, Dart, Material Design |
| État | ValueNotifier (simple) |
| DB/Auth | Supabase (Postgres + Auth) |
| API Données | OpenF1 (via backend Python) |
| Assets | Images GP, Lottie animations, fonts custom |
| Dépendances clés | supabase_flutter, shared_preferences, image_picker |

**Supabase project:** `yzonecxeqbtdijrbywue.supabase.co`

## Installation & Lancement
1. Clone le repo
2. `flutter pub get`
3. Vérifier `lib/data/constants.dart` pour Supabase URL/anonKey
4. `flutter run` (Android/iOS/web)

**Note dev :** Backend Python séparé pour sync OpenF1 → Supabase races/drivers.

## Modele Business
- **Ligue** : Créateur + membres (max ?), code invite unique
- **Équipe Fantasy** : 1/user/ligue, points cumulés
- **Composition** : Par GP, 3 pilotes (prix/rating) + 2 constructeurs ≤ 100M
- **Courses** : pick_deadline, status (finished/upcoming)
- **Classement** : Tri points, rang calculé dynamiquement

