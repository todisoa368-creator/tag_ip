---
title: "Chapitre 4 – Architecture et choix techniques"
date: "2026-06-01"
author: "Tag&IP"
---

# Chapitre 4 : Architecture et choix techniques

---

## 4.1 Architecture globale du système

### 4.1.1 Schéma architectural (MVC, API REST, n-tiers)

L'application Tag&IP suit une architecture **n-tiers** classique pour les applications web modernes, combinant les paradigmes **MVC (Modèle-Vue-Contrôleur)** pour l'interface utilisateur et **RESTful** pour les échanges de données.

```
┌──────────────────────────────────────────────────────────────────┐
│                    COUCHE PRÉSENTATION                           │
│                                                                  │
│  ┌─────────────┐   ┌──────────────┐   ┌──────────────────────┐  │
│  │  LiveView   │   │  HEEx (.heex)│   │  CSS (Tailwind v4)  │  │
│  │  (Templates)│   │  (HTML)      │   │  + JS vanilla       │  │
│  └──────┬──────┘   └──────┬───────┘   └──────────────────────┘  │
│         │                 │                                       │
│         └──────┬──────────┘                                       │
│                ▼                                                   │
│  ┌─────────────────────────────┐                                  │
│  │    WebSocket (Phoenix)      │                                  │
│  │    + HTTP (Req)             │                                  │
│  └──────────────┬──────────────┘                                  │
├─────────────────┼────────────────────────────────────────────────┤
│                 ▼           COUCHE APPLICATION                    │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │                Phoenix Router + Controllers              │    │
│  │     LiveView (état serveur, événements temps réel)       │    │
│  └──────────────────────────┬───────────────────────────────┘    │
│                             │                                     │
│  ┌──────────────────────────▼───────────────────────────────┐    │
│  │           Ash Framework (Domain-Driven Design)           │    │
│  │                                                          │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │    │
│  │  │   Domain     │  │  Resources   │  │   Actions    │   │    │
│  │  │   TagIp      │  │  (Entities)  │  │ (CRUD + biz) │   │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘   │    │
│  └──────────────────────────┬───────────────────────────────┘    │
│                             │                                     │
│              ┌──────────────▼──────────────┐                      │
│              │    AshPostgres (DataLayer)   │                      │
│              └──────────────┬──────────────┘                      │
├─────────────────────────────┼────────────────────────────────────┤
│                             ▼         COUCHE DONNÉES              │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │            PostgreSQL 16 (via Ecto)                       │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐   │    │
│  │  │  Tables  │  │  Indexes │  │  Migrations (Ecto)   │   │    │
│  │  └──────────┘  └──────────┘  └──────────────────────┘   │    │
│  └──────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────┘
```

**Flux d'une requête typique :**

```
Navigateur (LiveView)
    │
    ▼
Phoenix Endpoint
    │
    ▼
Router (définit le live_session)
    │
    ▼
LiveView.mount/3 (charge état initial)
    │
    ▼
Ash.Query → AshPostgres → PostgreSQL
    │
    ▼
Résultat → assign(socket, ...)
    │
    ▼
HEEx → HTML diff → WebSocket → Navigateur
```

---

### 4.1.2 Organisation générale

**Structure des répertoires :**

```
tag_ip/
├── lib/
│   ├── tag_ip/                       # Couche métier (Ash)
│   │   ├── tag_ip.ex                 # Définition du Domain Ash
│   │   ├── accounts/                 # Gestion des utilisateurs (phx.gen.auth)
│   │   ├── resources/                # Ressources Ash (entités)
│   │   │   ├── compatibilite.ex      # Évaluation de compatibilité
│   │   │   ├── profil_montage.ex     # Profil de montage
│   │   │   ├── modele_traceur.ex     # Modèle de traceur
│   │   │   ├── type_vehicule.ex      # Type d'actif
│   │   │   ├── alimentation.ex       # Alimentation
│   │   │   ├── capteur.ex            # Capteur
│   │   │   ├── feature.ex            # Fonctionnalité
│   │   │   ├── model_feature.ex      # Association M-N
│   │   │   ├── model_port.ex         # Port physique
│   │   │   ├── port_type.ex          # Type de port
│   │   │   ├── peripheral.ex         # Périphérique
│   │   │   └── ...                   # Autres associations M-N
│   │   └── compatibilite/            # Logique de calcul (future extraction)
│   │
│   ├── tag_ip_web/                   # Couche présentation (Phoenix)
│   │   ├── live/                     # LiveViews
│   │   │   ├── compatibilite_live/   # Écran de compatibilité
│   │   │   ├── profil_montage_live/  # CRUD profils
│   │   │   └── modele_traceur_live/  # CRUD traceurs
│   │   ├── controllers/              # Contrôleurs REST
│   │   ├── templates/                # Layouts, emails
│   │   └── router.ex                 # Routes
│   │
│   └── tag_ip_web.ex                 # Configuration du Web module
│
├── priv/
│   ├── repo/
│   │   ├── migrations/               # Migrations Ecto
│   │   ├── seeds.exs                 # Données de démo
│   │   └── data_setup.exs            # Configuration des 11 types
│   │
│   └── static/                       # Assets statiques
│
├── assets/
│   ├── js/app.js                     # JS client
│   └── css/app.css                   # Tailwind CSS v4
│
├── config/                           # Configuration (dev, prod, test)
├── test/                             # Tests
└── docs/                             # Documentation téléchargeable
```

**Séparation des responsabilités :**

| Couche | Technologie | Responsabilité |
|---|---|---|
| Présentation | Phoenix LiveView + HEEx + Tailwind | Interface utilisateur interactive, rendu HTML, WebSocket temps réel |
| Application | Ash Framework (Domain + Resources) | Logique métier, validation, calcul de compatibilité |
| Données | PostgreSQL 16 via AshPostgres/Ecto | Persistance, contraintes d'intégrité, migrations |
| Client | JavaScript (app.js) + Phoenix Socket | Hooks LiveView, interactions navigateur |

---

## 4.2 Choix technologiques

### 4.2.1 Backend / Base de données / Serveur

| Composant | Technologie choisie | Version |
|---|---|---|
| Langage | **Elixir** | 1.18 |
| Framework web | **Phoenix** | 1.8 |
| Framework métier | **Ash** (AshFramework) | 3.x |
| ORM / Data Layer | **AshPostgres** (sur Ecto) | — |
| Base de données | **PostgreSQL** | 16 |
| Client HTTP | **Req** | Inclusion par défaut Phoenix |
| CSS | **Tailwind CSS** | 4.x |
| Build JS | **esbuild** | — |
| Build CSS | **Tailwind CLI** | — |

**Déploiement (production) :**

| Composant | Choix | Justification |
|---|---|---|
| Serveur applicatif | **Phoenix HTTP** (bande de port 4000) | Serveur web intégré, performant |
| Proxy inverse | **Nginx** ou **Caddy** | Terminaison SSL, cache statique |
| Base de données | **PostgreSQL 16** (via Render, AWS RDS, ou auto-hébergé) | Robuste, fiable |
| Hébergement | Render / Fly.io / VPS | Déploiement simplifié, scalabilité |
| CI/CD | GitHub Actions | Tests automatisés, formatage |

---

### 4.2.2 Justifications et alternatives

#### Pourquoi Elixir / Phoenix ?

| Critère | Évaluation |
|---|---|
| **Concurrence** | La VM BEAM d'Erlang offre des processus légers (acteurs) idéaux pour gérer des centaines de connexions WebSocket simultanées |
| **Temps réel** | Phoenix LiveView permet une interface réactive sans écrire de code JavaScript complexe |
| **Productivité** | Le framework Ash élève le niveau d'abstraction : définir une ressource = avoir CRUD + validations + filtres + interface |
| **Fiabilité** | Philosophie "let it crash" avec superviseurs OTP pour une tolérance aux pannes |
| **Écosystème** | Hex.pm propose des milliers de packages de qualité |

#### Alternatives envisagées

| Alternative | Raison du refus |
|---|---|
| **Ruby on Rails** | Moins performant en concurrence, pas de WebSocket natif aussi intégré que Phoenix LiveView |
| **Node.js / Express** | Callback-heavy, moins structuré qu'Elixir, pas de framework métier comme Ash |
| **Django (Python)** | Performances limitées pour du temps réel, empreinte mémoire élevée |
| **Spring Boot (Java)** | Verbosité excessive, courbe d'apprentissage raide, configuration complexe |
| **FastAPI (Python)** | Bon pour les API REST mais pas de framework métier intégré |

#### Pourquoi Ash Framework ?

| Bénéfice | Description |
|---|---|
| **Domain-Driven Design** | Architecture claire avec Domain, Resources, Actions |
| **Déclaratif** | Définir une resource = avoir CRUD, filtres, pagination, validations, interface |
| **Upsert natif** | Support de l'upsert via identités uniques |
| **Code interface** | Génération automatique de fonctions `create`, `read`, `update`, `destroy` |
| **Multi-data-layer** | Flexible : PostgreSQL, SQLite, Mnesia, etc. |

#### Pourquoi PostgreSQL ?

| Critère | Évaluation |
|---|---|
| **Maturité** | Base de données relationnelle la plus avancée et fiable du marché |
| **JSONB** | Stockage du détail des compatibilités au format JSON structuré |
| **UUID natif** | Support natif des clés primaires UUID |
| **Extensions** | `pgcrypto`, `uuid-ossp`, `postgis` (pour la géolocalisation future) |

---

## 4.3 Architecture back-end et sécurité

### 4.3.1 Organisation en couches

L'application est structurée en **trois couches** bien distinctes, avec un flux de dépendance unidirectionnel :

```
 ┌──────────────────────────────────────────────────────────────────┐
 │  COUCHE WEB (tag_ip_web)                                         │
 │                                                                  │
 │  ┌─────────────┬──────────────┬─────────────┬────────────────┐   │
 │  │  Router     │  LiveViews   │ Controllers │ Templates/Html │   │
 │  └─────────────┴──────────────┴─────────────┴────────────────┘   │
 │                                                                  │
 │  Dépendances : tag_ip (uniquement)                               │
 └──────────────────────────┬───────────────────────────────────────┘
                            │
                            ▼
 ┌──────────────────────────────────────────────────────────────────┐
 │  COUCHE MÉTIER (tag_ip)                                          │
 │                                                                  │
 │  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐     │
 │  │   Domain     │  │  Resources   │  │  Accounts (Auth)   │     │
 │  │   TagIp      │  │  (Ash)       │  │  (phx.gen.auth)   │     │
 │  └──────────────┘  └──────────────┘  └────────────────────┘     │
 │                                                                  │
 │  Dépendances : Ash, AshPostgres, Ecto                            │
 └──────────────────────────┬───────────────────────────────────────┘
                            │
                            ▼
 ┌──────────────────────────────────────────────────────────────────┐
 │  COUCHE INFRASTRUCTURE / DONNÉES                                 │
 │                                                                  │
 │  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐     │
 │  │  PostgreSQL  │  │  Ecto/Ash   │  │  Migrations        │     │
 │  │              │  │  Postgres   │  │  (priv/repo/migr)  │     │
 │  └──────────────┘  └──────────────┘  └────────────────────┘     │
 │                                                                  │
 │  Dépendances : postgres (via npm ou Docker)                      │
 └──────────────────────────────────────────────────────────────────┘
```

**Principe de dépendance :**

- La couche Web ne connaît que la couche métier
- La couche métier ne connaît pas la couche Web
- La couche infrastructure est encapsulée par la couche métier via Ash

---

### 4.3.2 Patterns utilisés

#### Pattern Resource (Ash Framework)

Chaque entité métier est modélisée comme une **resource Ash**, qui encapsule :

- Les **attributs** (colonnes de la table)
- Les **identités** (contraintes d'unicité)
- Les **relations** (associations)
- Les **actions** (opérations CRUD + métier)
- L'interface de code (génération automatique de fonctions)

```elixir
# Exemple : Resource Compatibilite (simplifié)
defmodule TagIp.Resources.Compatibilite do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("compatibilites")
    repo(TagIp.Repo)
  end

  attributes do
    uuid_primary_key(:id)
    attribute :score_compatibilite, :integer
    attribute :details, :map  # JSONB
    timestamps()
  end

  relationships do
    belongs_to :profil_montage, TagIp.Resources.ProfilMontage do
      allow_nil?(false)
    end
    belongs_to :modele_traceur, TagIp.Resources.ModeleTraceur do
      allow_nil?(false)
    end
  end

  actions do
    defaults([:read, :destroy, :update])
    create :create do
      upsert?(true)
      upsert_identity(:unique_compatibilite)
    end
  end

  identities do
    identity(:unique_compatibilite, [:profil_montage_id, :modele_traceur_id])
  end
end
```

#### Pattern LiveView (Phoenix)

Les interfaces utilisateur sont construites avec **Phoenix LiveView**, qui maintient un état serveur et met à jour le DOM via WebSocket :

```
Flux LiveView :
1. mount/3        → Chargement initial des données via Ash
2. handle_params/3 → Gestion des paramètres d'URL
3. render/1       → Rendu HEEx
4. handle_event/3 → Traitement des événements utilisateur
5. assign/3       → Mise à jour de l'état
```

#### Pattern Calcul de compatibilité

Le calcul de compatibilité suit un **pattern stratégie** (Strategy) où chaque vérification est une fonction indépendante, combinée par somme pondérée :

```elixir
# Structure du calcul (conceptuel)
verifications = [
  &check_alimentation/2,   # Poids 10
  &check_can_bus/2,        # Poids 8
  &check_one_wire/2,       # Poids 5
  &check_rs232/2,          # Poids 5
  &check_rs485/2,          # Poids 5
  &check_accelerometer/2,  # Poids 7
  &check_geofence/2,       # Poids 5
  &check_buzzer/2,         # Poids 5
  &check_ultra_low_power/2,# Poids 10
  &check_antenne/2,        # Poids 5
  &check_exterieur/2,      # Poids 5
  &check_inputs/2,         # Poids 10
  &check_analog_inputs/2,  # Poids 8
  &check_outputs/2,        # Poids 7
  &check_buffer_memory/2,  # Poids 5
]
```

#### Pattern Upsert / Idempotence

Toutes les ressources de référence utilisent le pattern **upsert** pour garantir l'idempotence des seeds :

```elixir
create :create do
  upsert?(true)
  upsert_identity(:unique_slug)
end
```

#### Pattern Code Interface

Ash génère automatiquement des fonctions Elixir pour interagir avec les ressources :

```elixir
# Au lieu de
Ash.create!(resource, params)

# On peut écrire (généré automatiquement)
ModeleTraceur.create(params)
ModeleTraceur.read!()
ModeleTraceur.get_by_id!(id)
```

---

### 4.3.3 Sécurité

#### Authentification

Tag&IP utilise le module **`phx.gen.auth`** généré par Phoenix pour la gestion des utilisateurs :

- **Inscription** : email + mot de passe (hashé avec bcrypt)
- **Connexion** : session avec token de session
- **Confirmation** : email de confirmation obligatoire
- **Réinitialisation** de mot de passe par email

#### Contrôle d'accès

L'application utilise le système **LiveSession** de Phoenix Router pour restreindre l'accès :

```elixir
# Routes nécessitant une authentification
scope "/", TagIpWeb do
  pipe_through [:browser, :require_authenticated_user]

  live_session :require_authenticated_user,
    on_mount: [{TagIpWeb.UserAuth, :require_authenticated}] do
    live "/compatibilites", CompatibiliteLive.Index, :index
    live "/profils", ProfilMontageLive.Index, :index
    live "/traceurs", ModeleTraceurLive.Index, :index
  end
end
```

**Niveaux d'accès :**

| Rôle | Accès |
|---|---|
| Non authentifié | Page de connexion uniquement |
| Utilisateur authentifié | Toutes les fonctionnalités (CRUD profils, traceurs, compatibilités) |

#### Protection des données

| Mesure | Implémentation |
|---|---|
| **Hachage des mots de passe** | bcrypt via `phx.gen.auth` |
| **Protection CSRF** | Token CSRF automatique sur tous les formulaires LiveView |
| **Protection XSS** | Échappement automatique HEEx (aucune injection HTML possible) |
| **Rate limiting** | Middleware Plug (limitation tentative de connexion) |
| **HTTPS** | Terminaison SSL au niveau du proxy inverse (Nginx/Caddy) |
| **Session sécurisée** | Cookie signé + chiffré avec `secret_key_base` |
| **UUID** | Clés primaires UUID non séquentielles (pas d'énumération possible) |

#### Bonnes pratiques de développement

1. **Aucun secret dans le code** : toutes les clés et mots de passe via les variables d'environnement
2. **Migrations versionnées** : chaque modification de schéma est une migration Ecto réversible
3. **Tests obligatoires** : couverture minimale sur toutes les ressources et les actions métier
4. **Formatage automatique** : `mix format` applique le style de code Elixir standard
5. **Analyse statique** : `mix compile --warnings-as-errors` pour détecter les problèmes à la compilation

#### Sécurisation de la base de données

| Mesure | Description |
|---|---|
| **Utilisateur dédié** | Compte PostgreSQL avec privilèges minimaux (CRUD) |
| **Connexion chiffrée** | TLS/SSL pour la connexion entre l'application et la base |
| **Préparation des requêtes** | Ecto/AshPostgres utilise des requêtes paramétrées (pas d'injection SQL) |
| **Cascade des suppressions** | `ON DELETE CASCADE` pour l'intégrité référentielle |

---

> **Fin du chapitre 4** — Fin de la Partie II : Conception technique
