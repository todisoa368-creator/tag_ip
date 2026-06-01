---
title: "Chapitre 3 – Modélisation des données"
date: "2026-06-01"
author: "Tag&IP"
---

# Chapitre 3 : Modélisation des données

---

## 3.1 Modèle conceptuel (MCD)

### 3.1.1 Entités

Le système Tag&IP repose sur un modèle de données orienté autour de la **compatibilité entre profils de montage et traceurs GPS**. Les entités principales sont décrites ci-dessous.

| Entité | Description | Occurrences |
|---|---|---|
| **ProfilMontage** | Définit les caractéristiques techniques et fonctionnelles d’un type d’actif à équiper (véhicule, personne, objet, etc.). Un profil décrit les besoins électriques, les interfaces de communication et les fonctionnalités attendues. | ~20 |
| **ModeleTraceur** | Référence un modèle de boîtier GPS traceur du marché, avec ses spécifications réelles (tension d’alimentation, ports, protocoles, mémoire). | ~10 |
| **Compatibilite** | Résultat de l’évaluation automatique entre un profil et un modèle. Stocke le score (0–100), le détail des vérifications, et est recalculée à chaque modification des données source. | Plusieurs centaines |
| **TypeVehicule** | Catégorie d’actif (ex. « Camion », « Moto », « Bateau ») avec des plages de tension et des besoins minimaux en entrées/sorties. | ~15 |
| **Alimentation** | Mode ou plage d’alimentation électrique (ex. « 12V », « 24V », « Filaire », « Batterie »). | ~8 |
| **Capteur** | Équipement ou grandeur mesurable (ex. « Moteur », « Niveau carburant », « Géofence »). | ~20 |
| **Feature** | Fonctionnalité logicielle offerte par un traceur (ex. « Real-time Tracking », « Geofencing »). | ~10 |
| **PortType** | Type d’interface physique (ex. « DIN », « AIN », « DOUT », « 1-Wire », « RS232 », « CAN-Bus »). | ~9 |
| **ModelPort** | Broche ou port physique présent sur un modèle de traceur. | ~60 |
| **Peripheral** | Périphérique compatible avec un type de port (ex. « DS18B20 Temperature Probe »). | ~11 |
| **TrackableType** | Type d’objet traçable (identique à TypeVehicule mais issu d’un CSV legacy). | ~15 |
| **User** | Utilisateur de l’application (admin). | 1+ |
| **ModelFeature** | Association many-to-many entre ModèleTraceur et Feature. | ~50 |
| **ModeleTraceurAlimentation** | Association many-to-many entre ModèleTraceur et Alimentation. | ~20 |
| **ModeleTraceurCapteur** | Association many-to-many entre ModèleTraceur et Capteur. | ~30 |
| **ModeleTraceurTypeVehicule** | Association many-to-many entre ModèleTraceur et TypeVehicule. | ~70 |

---

### 3.1.2 Relations

```
┌──────────────────┐       ┌────────────────────┐
│   ProfilMontage  │       │   ModeleTraceur    │
├──────────────────┤       ├────────────────────┤
│ PK id (uuid)     │       │ PK id (uuid)       │
│ name             │       │ nom                │
│ object_type      │       │ brand              │
│ voltage_min (V)  │1    * │ reference (unique) │
│ voltage_max (V)  │───────│ voltage_min (V)    │
│ inputs_requis    │       │ voltage_max (V)    │
│ outputs_requis   │       │ can_bus            │
│ buzzer           │       │ one_wire           │
│ geofence_enabled │       │ rs232 / rs485      │
│ can_bus_requis   │       │ accelerometer      │
│ ...              │       │ nb_digital_inputs  │
└──────────────────┘       │ nb_analog_inputs   │
        │                  │ nb_outputs         │
        │*                  │ buffer_memory      │
        │                  │ ip_rating          │
        ▼                  └────────┬───────────┘
┌──────────────────┐               │
│  Compatibilite   │               │
├──────────────────┤               │
│ PK id (uuid)     │              │
│ score (0-100)    │ *           *│
│ details (text)   │◄─────────────┘
│ FK profil        │
│ FK modele        │
└──────────────────┘

        ┌──────────────────┐
        │   TypeVehicule   │
        ├──────────────────┤
        │ PK id (uuid)     │
        │ slug (unique)    │
        │ label            │
        │ voltage_min (V)  │
        │ voltage_max (V)  │
        │ inputs_requis    │
        │ outputs_requis   │
        └────────┬─────────┘
                 │
                 │ many-to-many
                 │
        ┌────────▼─────────┐
        │ModeleTraceurType │
        │  Vehicule        │
        └──────────────────┘

┌──────────────┐     ┌───────────────┐     ┌──────────────┐
│ Alimentation │     │   Capteur     │     │   Feature    │
├──────────────┤     ├───────────────┤     ├──────────────┤
│ slug (uniq)  │     │ slug (uniq)   │     │ slug (uniq)  │
│ label        │     │ label         │     │ label        │
│ category     │     │ category      │     │ description  │
└──────┬───────┘     └───────┬───────┘     └──────┬───────┘
       │                     │                     │
       │ many-to-many        │ many-to-many        │ many-to-many
       ▼                     ▼                     ▼
┌──────────────┐     ┌───────────────┐     ┌──────────────┐
│ModeleTraceur │     │ModeleTraceur  │     │ModelFeature  │
│Alimentation  │     │  Capteur      │     │              │
└──────────────┘     └───────────────┘     └──────────────┘

┌──────────────┐     ┌───────────────┐
│  PortType    │     │  ModelPort    │
├──────────────┤     ├───────────────┤
│ slug (uniq)  │1   *│ pin_label     │
│ label        │─────│ FK modele     │
│ description  │     │ FK port_type  │
└──────────────┘     └───────────────┘
                            │
                            │
                     ┌──────▼───────┐
                     │ Peripheral   │
                     ├──────────────┤
                     │ name         │
                     │ description  │
                     │ FK port_type │
                     └──────────────┘
```

**Cardinalités principales :**

| Entité A | Cardinalité | Entité B | Cardinalité | Signification |
|---|---|---|---|---|
| ProfilMontage | 1,* | Compatibilite | 1,1 | Un profil peut avoir plusieurs compatibilités ; une compatibilité appartient à un seul profil |
| ModeleTraceur | 1,* | Compatibilite | 1,1 | Un modèle peut avoir plusieurs compatibilités ; une compatibilité appartient à un seul modèle |
| ProfilMontage | * | ModeleTraceur | * | Relation many-to-many via Compatibilite (évaluation) |
| ModeleTraceur | * | TypeVehicule | * | Many-to-many via ModeleTraceurTypeVehicule |
| ModeleTraceur | * | Alimentation | * | Many-to-many via ModeleTraceurAlimentation |
| ModeleTraceur | * | Capteur | * | Many-to-many via ModeleTraceurCapteur |
| ModeleTraceur | * | Feature | * | Many-to-many via ModelFeature |
| ModeleTraceur | 1,* | ModelPort | 1,1 | Un modèle peut avoir plusieurs ports ; un port appartient à un modèle |
| PortType | 1,* | ModelPort | 1,1 | Un type de port peut concerner plusieurs ports ; un port a un type |
| PortType | 1,* | Peripheral | 1,1 | Un type de port peut avoir plusieurs périphériques compatibles |

---

### 3.1.3 Règles de gestion

#### RG-ALIM : Vérification de l'alimentation

Un profil de montage est compatible électriquement avec un traceur si et seulement si la plage de tension du profil est entièrement incluse dans la plage de tension du traceur.

```
Profil.voltage_min >= ModeleTraceur.voltage_min ET
Profil.voltage_max <= ModeleTraceur.voltage_max
```

Toutes les tensions sont exprimées en **Volts (V)**.

#### RG-SCORE : Calcul du score de compatibilité

Le score de compatibilité est la somme pondérée de plusieurs sous-vérifications :

| Vérification | Poids | Description |
|---|---|---|
| Alimentation | 10 | Correspondance des plages de tension |
| CAN-Bus | 8 | Présence du bus CAN si requis |
| 1-Wire | 5 | Présence de l'interface 1-Wire si requise |
| RS232 | 5 | Présence de l'interface RS232 si requise |
| RS485 | 5 | Présence de l'interface RS485 si requise |
| Accéléromètre | 7 | Présence de l'accéléromètre si requis |
| Géofence | 5 | Support du géofencing si requis |
| Buzzer | 5 | Présence du buzzer si requis |
| Ultra Low Power | 10 | Mode basse consommation si requis |
| Antenne déportée | 5 | Support antenne externe si requis |
| Montage extérieur | 5 | Résistance IP appropriée |
| Entrées numériques | 10 | Nombre suffisant de DIN |
| Entrées analogiques | 8 | Nombre suffisant d'AIN |
| Sorties numériques | 7 | Nombre suffisant de DOUT |
| Mémoire tampon | 5 | Capacité de buffer suffisante |

**Total : 100 points** (pondération configurable).

#### RG-MODIF : Recalcul automatique

Toute modification d'un profil de montage ou d'un modèle de traceur entraîne la **suppression** de toutes les compatibilités associées, qui seront recalculées à la prochaine consultation.

#### RG-CLEAR : Effacement global

Un administrateur peut effacer **toutes** les compatibilités en un clic depuis l'interface de listing.

#### RG-IOTYPES : Adéquation entrées/sorties

Un profil avec `inputs_requis = N` nécessite au moins `N` entrées numériques sur le traceur. De même pour les sorties (`outputs_requis`).

---

## 3.2 Modèle logique (MLD)

### 3.2.1 Tables

#### Table `mounting_profiles`

| Colonne | Type | Contrainte | Défaut |
|---|---|---|---|
| id | uuid | PK | gen_random_uuid() |
| name | varchar(255) | NOT NULL | — |
| description | text | NULL | — |
| object_type | varchar(100) | NULL | — |
| voltage_min | float | NULL | — |
| voltage_max | float | NULL | — |
| inputs_requis | integer | NULL | 0 |
| outputs_requis | integer | NULL | 0 |
| buzzer | boolean | NULL | false |
| geofence_enabled | boolean | NULL | false |
| can_bus_requis | boolean | NULL | false |
| accelerometre_requis | boolean | NULL | false |
| montage_exterieur | boolean | NULL | false |
| antenne_deportee | boolean | NULL | false |
| ultra_low_power_requis | boolean | NULL | false |
| one_wire_requis | boolean | NULL | false |
| rs232_requis | boolean | NULL | false |
| rs485_requis | boolean | NULL | false |
| reporting_interval | varchar(50) | NULL | 'interval_30s' |
| driver_id_type | varchar(50) | NULL | — |
| fuel_probe_type | varchar(50) | NULL | — |
| analog_inputs_requis | integer | NULL | 0 |
| organization_id | uuid | NULL | — |
| inserted_at | timestamptz | NOT NULL | now() |
| updated_at | timestamptz | NOT NULL | now() |

#### Table `modeles_traceur`

| Colonne | Type | Contrainte | Défaut |
|---|---|---|---|
| id | uuid | PK | gen_random_uuid() |
| nom | varchar(100) | NOT NULL | — |
| brand | varchar(255) | NULL | — |
| reference | varchar(50) | NOT NULL, UNIQUE | — |
| description | text | NULL | — |
| voltage_min | float | NULL | — |
| voltage_max | float | NULL | — |
| standby_current | float | NULL | — |
| ultra_low_power | boolean | NULL | false |
| can_bus | boolean | NULL | false |
| one_wire | boolean | NULL | false |
| rs232 | boolean | NULL | false |
| rs485 | boolean | NULL | false |
| nb_digital_inputs | integer | NULL | — |
| nb_analog_inputs | integer | NULL | — |
| nb_outputs | integer | NULL | — |
| ip_rating | varchar(20) | NULL | — |
| antennes_externes | boolean | NULL | false |
| accelerometer | boolean | NULL | false |
| buffer_memory | integer | NULL | — |
| inserted_at | timestamptz | NOT NULL | now() |
| updated_at | timestamptz | NOT NULL | now() |

#### Table `compatibilites`

| Colonne | Type | Contrainte | Défaut |
|---|---|---|---|
| id | uuid | PK | gen_random_uuid() |
| profil_montage_id | uuid | FK → mounting_profiles(id) ON DELETE CASCADE | — |
| modele_traceur_id | uuid | FK → modeles_traceur(id) ON DELETE CASCADE | — |
| score_compatibilite | integer | NULL | — |
| details | jsonb | NULL | — |
| inserted_at | timestamptz | NOT NULL | now() |
| updated_at | timestamptz | NOT NULL | now() |
| **UNIQUE** | | (profil_montage_id, modele_traceur_id) | |

#### Table `types_vehicule`

| Colonne | Type | Contrainte | Défaut |
|---|---|---|---|
| id | uuid | PK | gen_random_uuid() |
| slug | varchar(100) | NOT NULL, UNIQUE | — |
| label | varchar(255) | NULL | — |
| description | text | NULL | — |
| voltage_min | float | NULL | — |
| voltage_max | float | NULL | — |
| inputs_requis | integer | NULL | 0 |
| outputs_requis | integer | NULL | 0 |
| inserted_at | timestamptz | NOT NULL | now() |
| updated_at | timestamptz | NOT NULL | now() |

#### Tables d'association

| Table | Colonnes | Clés étrangères |
|---|---|---|
| `modeles_traceur_types_vehicule` | modele_traceur_id, type_vehicule_id | FK → modeles_traceur(id), FK → types_vehicule(id) |
| `modeles_traceur_alimentations` | modele_traceur_id, alimentation_id | FK → modeles_traceur(id), FK → alimentations(id) |
| `modeles_traceur_capteurs` | modele_traceur_id, capteur_id | FK → modeles_traceur(id), FK → capteurs(id) |
| `model_features` | modele_traceur_id, feature_id | FK → modeles_traceur(id), FK → features(id) |
| `model_ports` | id, modele_traceur_id, port_type_id, pin_label | FK → modeles_traceur(id), FK → port_types(id) |
| `peripherals` | id, port_type_id, name, description | FK → port_types(id) |

---

### 3.2.2 Clés et contraintes

**Contraintes d'unicité :**

- `mounting_profiles` : aucune contrainte d'unicité explicite (plusieurs profils peuvent avoir le même nom)
- `modeles_traceur.reference` : unique (un modèle est identifié par sa référence constructeur)
- `types_vehicule.slug` : unique (un type est identifié par son slug)
- `compatibilites` : contrainte unique composite `(profil_montage_id, modele_traceur_id)` — un couple (profil, modèle) ne peut être évalué qu'une seule fois
- `alimentations.slug`, `capteurs.slug`, `features.slug`, `port_types.slug`, `trackable_types.slug` : uniques

**Contraintes d'intégrité référentielle :**

- `compatibilites.profil_montage_id` → `mounting_profiles(id)` **ON DELETE CASCADE**
- `compatibilites.modele_traceur_id` → `modeles_traceur(id)` **ON DELETE CASCADE**
- Toutes les FK des tables d'association sont en cascade (`ON DELETE CASCADE`)
- `model_ports.modele_traceur_id` → `modeles_traceur(id)` **ON DELETE CASCADE**
- `model_ports.port_type_id` → `port_types(id)` **ON DELETE CASCADE**
- `peripherals.port_type_id` → `port_types(id)` **ON DELETE CASCADE**

**Contraintes métier (application) :**

- Un score de compatibilité est compris entre 0 et 100
- Les tensions minimales et maximales doivent être cohérentes : `voltage_min <= voltage_max`
- Un profil avec `inputs_requis = 0` n'a pas besoin d'entrées numériques sur le traceur
- La suppression d'un profil ou d'un modèle entraîne la suppression en cascade de ses compatibilités

---

## 3.3 Dictionnaire des données

### 3.3.1 Description des champs

#### mounting_profiles

| Champ | Description | Unité / Format | Domaine de valeurs |
|---|---|---|---|
| `id` | Identifiant unique du profil | UUID v4 | — |
| `name` | Nom du profil (ex. « Voiture tourisme ») | Chaîne (255) | Libre |
| `description` | Description détaillée du profil | Texte | Libre |
| `object_type` | Slug du type d'actif (ex. « car », « truck ») | Chaîne (100) | Liste définie dans types_vehicule.slug |
| `voltage_min` | Tension d'alimentation minimale requise | Float (Volts) | 0.0 – 100.0 |
| `voltage_max` | Tension d'alimentation maximale requise | Float (Volts) | 0.0 – 100.0 |
| `inputs_requis` | Nombre d'entrées numériques nécessaires | Entier | 0 – 10 |
| `outputs_requis` | Nombre de sorties numériques nécessaires | Entier | 0 – 10 |
| `buzzer` | Besoin d'un avertisseur sonore | Booléen | true / false |
| `geofence_enabled` | Besoin de zones géographiques | Booléen | true / false |
| `can_bus_requis` | Besoin d'un bus CAN | Booléen | true / false |
| `accelerometre_requis` | Besoin d'un accéléromètre | Booléen | true / false |
| `montage_exterieur` | Montage en extérieur (résistance IP) | Booléen | true / false |
| `antenne_deportee` | Besoin d'une antenne externe | Booléen | true / false |
| `ultra_low_power_requis` | Besoin de mode ultra basse consommation | Booléen | true / false |
| `one_wire_requis` | Besoin d'une interface 1-Wire | Booléen | true / false |
| `rs232_requis` | Besoin d'un port RS232 | Booléen | true / false |
| `rs485_requis` | Besoin d'un port RS485 | Booléen | true / false |
| `reporting_interval` | Intervalle de rapport préféré | Chaîne (50) | 'interval_30s', 'interval_1min', 'interval_5min' |
| `analog_inputs_requis` | Nombre d'entrées analogiques nécessaires | Entier | 0 – 10 |
| `organization_id` | Organisation propriétaire (multi-tenant) | UUID | Nullable |
| `inserted_at` | Date de création | Timestamp | — |
| `updated_at` | Date de dernière modification | Timestamp | — |

#### modeles_traceur

| Champ | Description | Unité / Format | Domaine de valeurs |
|---|---|---|---|
| `id` | Identifiant unique du modèle de traceur | UUID v4 | — |
| `nom` | Nom commercial du traceur | Chaîne (100) | Ex. « FMC120 (FMx120) » |
| `brand` | Marque du fabricant | Chaîne | Teltonika, Systech, Wondeproud |
| `reference` | Référence constructeur unique | Chaîne (50) | Ex. « TLT-FMC120 » |
| `description` | Description des caractéristiques clés | Texte | Libre |
| `voltage_min` | Tension d'alimentation minimale supportée | Float (Volts) | 3.0 – 60.0 |
| `voltage_max` | Tension d'alimentation maximale supportée | Float (Volts) | 3.0 – 60.0 |
| `can_bus` | Présence d'une interface CAN-Bus | Booléen | true / false |
| `one_wire` | Présence d'une interface 1-Wire | Booléen | true / false |
| `rs232` | Présence d'un port RS232 | Booléen | true / false |
| `rs485` | Présence d'un port RS485 | Booléen | true / false |
| `accelerometer` | Présence d'un accéléromètre intégré | Booléen | true / false |
| `nb_digital_inputs` | Nombre d'entrées numériques disponibles | Entier | 1 – 4 |
| `nb_analog_inputs` | Nombre d'entrées analogiques disponibles | Entier | 0 – 4 |
| `nb_outputs` | Nombre de sorties numériques disponibles | Entier | 1 – 4 |
| `buffer_memory` | Capacité de la mémoire tampon | Entier (Ko) | 64 – 512 |
| `ip_rating` | Indice de protection IP | Chaîne (20) | IP54, IP65 |
| `ultra_low_power` | Support du mode ultra basse consommation | Booléen | true / false |
| `antennes_externes` | Support d'antennes externes | Booléen | true / false |
| `standby_current` | Courant de veille | Float (mA) | — |

#### compatibilites

| Champ | Description | Format | Domaine de valeurs |
|---|---|---|---|
| `id` | Identifiant unique | UUID v4 | — |
| `profil_montage_id` | Référence au profil de montage | UUID | FK → mounting_profiles |
| `modele_traceur_id` | Référence au modèle de traceur | UUID | FK → modeles_traceur |
| `score_compatibilite` | Score de compatibilité (0-100) | Entier | 0 – 100 |
| `details` | Résultat détaillé par vérification | JSONB | Voir ci-dessous |
| `inserted_at` | Date d'évaluation | Timestamp | — |
| `updated_at` | Dernière mise à jour | Timestamp | — |

Format du champ `details` (JSON) :

```json
{
  "alimentation": {"score": 10, "detail": "✓ Alimentation compatible"},
  "can_bus": {"score": 8, "detail": "✓ Interface CAN-Bus supportée"},
  "one_wire": {"score": 5, "detail": "✓ Interface 1-Wire supportée"},
  "digital_inputs": {"score": 10, "detail": "✓ 2 DIN requis, 4 disponibles"},
  "outputs": {"score": 7, "detail": "✓ 1 DOUT requis, 2 disponibles"},
  "accelerometer": {"score": 7, "detail": "✓ Accéléromètre présent"},
  "total": 47
}
```

---

### 3.3.2 Règles et validations

**Règle VLT-001 — Cohérence des tensions**

```elixir
voltage_min <= voltage_max
```

Vérifiée au niveau application avant tout calcul de compatibilité. Si `voltage_min > voltage_max`, le profil (ou modèle) est considéré comme invalide pour l'évaluation et la vérification alimentation est ignorée avec un score par défaut (10 pts).

**Règle VLT-002 — Unité**

Toutes les tensions sont stockées et comparées en **Volts (V)**. Aucune conversion n'est appliquée lors des comparaisons entre profils et modèles (correction de la version précédente qui utilisait des millivolts pour les profils).

**Règle IO-001 — Nombre de ports**

```elixir
modele.nb_digital_inputs >= profil.inputs_requis
modele.nb_analog_inputs >= profil.analog_inputs_requis
modele.nb_outputs >= profil.outputs_requis
```

Si `inputs_requis = 0`, aucun minimum n'est exigé (score total accordé).

**Règle BOOL-001 — Présence requise**

Pour chaque fonctionnalité booléenne (buzzer, geofence, can_bus, etc.) où le profil a `true`, le traceur doit avoir la capacité correspondante à `true`. Si le profil n'a pas le besoin (`false` ou `nil`), le score total est accordé.

**Règle CASCADE-001 — Suppression**

La suppression d'un profil de montage ou d'un modèle de traceur entraîne :

1. La suppression en cascade de toutes les compatibilités associées (`ON DELETE CASCADE`)
2. La suppression des enregistrements dans les tables d'association (types, alimentations, capteurs, features)

**Règle UPSERT-001 — Idempotence**

Toutes les ressources de référence (`types_vehicule`, `alimentations`, `capteurs`, `modeles_traceur`) supportent l'**upsert** via une contrainte d'unicité. Le fichier de seed peut être exécuté plusieurs fois sans effet de bord.

---

> **Fin du chapitre 3** — Prochain chapitre : Architecture et choix techniques
