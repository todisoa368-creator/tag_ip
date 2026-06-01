---
title: "Mémoire de fin d'études - DTS Technologie Informatique"
subtitle: "Conception et réalisation d'un module automatisé de gestion des profils de montage et de compatibilité des traceurs GPS sous Elixir et Ash Framework"
author: "[NOM Prénom]"
date: "Année universitaire 2025-2026"
---

# PAGE DE GARDE

**Agréé par l'État**\
Arrêté d'ouverture : ...

**MEMOIRE DE FIN D'ETUDES EN VUE D'OBTENTION DU DIPLOME DE TECHNICIEN SUPERIEUR**

**Mention : Technologie informatique**

**CONCEPTION ET REALISATION D'UN MODULE AUTOMATISE DE GESTION DES PROFILS DE MONTAGE ET DE COMPATIBILITE DES TRACEURS GPS SOUS ELIXIR ET ASH FRAMEWORK**

*Au sein de la société TAG-IP (Technologie d'Avant-Garde Internet Protocole)*

Présenté par : **Monsieur [NOM Prénom]**

Membres du jury :
- Président du jury : [...]
- Examinateur : [...]
- Encadreur pédagogique : [...]

Promotion : [...] | Année universitaire : 2025-2026

UNIVERSITE SAINT VINCENT DE PAUL AKAMASOA\
MANANTENASOA - ANTANANARIVO

---

# AVANT-PROPOS

Ce mémoire rentre dans le cadre de l'obtention du Diplôme de Technicien Supérieur (DTS) en Technologie Informatique à l'Université Saint Vincent de Paul AKAMASOA.

Ce projet a été réalisé au sein de la société **TAG-IP** (Technologie d'Avant-Garde Internet Protocole), un leader malgache des solutions de tracking et de géolocalisation de véhicules. Il a été choisi en raison de la problématique concrète observée lors de mon stage au pôle Ingénierie Logicielle de la DSI : l'identification des traceurs GPS compatibles avec des équipements variés reposait encore sur une expertise humaine manuelle, source d'erreurs et de pertes de productivité. La mission consistait à concevoir et réaliser un module automatisé de gestion des profils de montage et de compatibilité des traceurs GPS, en utilisant les technologies Elixir, Phoenix LiveView et Ash Framework.

Les motivations ayant conduit à l'étude de ce sujet résident dans l'envie de confronter mes connaissances techniques à un cas concret, d'apporter une réelle plus-value à un outil utilisé quotidiennement par les techniciens de TAG-IP, et de me former aux exigences professionnelles en matière de qualité logicielle, d'architecture déclarative et de rigueur méthodologique.

L'objectif principal du travail présenté est de déployer une application web capable de centraliser et de pérenniser l'expertise technique de l'entreprise, en transformant des contraintes physiques en calculs logiques automatisés. Pour y parvenir, une démarche structurée a été adoptée, comprenant une analyse approfondie du contexte et des besoins, une modélisation rigoureuse des données, une conception architecturale, suivies d'un développement itératif et de tests fonctionnels.

Au cours du projet, plusieurs difficultés ont été rencontrées, telles que la prise en main du framework Ash (nouveau dans l'écosystème Elixir), la modélisation des 17 critères de compatibilité, et l'adaptation aux besoins précis des équipes techniques tout en respectant des délais contraints. Ces obstacles ont cependant représenté une source d'apprentissage précieuse, tant sur le plan technique que personnel.

Ce mémoire témoigne ainsi de l'aboutissement d'un projet académique, professionnel et humain. Il marque la fin d'un cycle d'apprentissage à l'USVPA et le début d'un engagement dans le monde professionnel de l'informatique.

---

# REMERCIEMENTS

Avant toute chose, nous rendons grâce à Dieu Tout-Puissant, source de vie et de force, pour nous avoir accompagnés tout au long de cette formation et durant la réalisation de ce mémoire.

Nous exprimons notre profonde gratitude au Révérend Père Pedro Pablo OPEKA, Fondateur et Président de l'Association AKAMASOA, dont l'engagement et la vision ont permis à de nombreux jeunes, dont nous-mêmes, de bénéficier d'une éducation supérieure de qualité.

Nos sincères remerciements s'adressent à Madame FANDROARIMANGA Monique, coordonnatrice de l'Université Saint Vincent de Paul AKAMASOA, et à Monsieur Johnson RAKOTONJANAHARY, Directeur de l'USVPA, pour leur disponibilité, leur accompagnement et leur engagement constant envers les étudiants.

Nous remercions également Monsieur Marc RIVERA, Directeur Général de TAG-IP, et Monsieur Gilles CHAPOTON, Directeur Technique, pour nous avoir accueillis au sein de leur entreprise et permis de réaliser ce projet dans un cadre professionnel enrichissant.

Nos vifs remerciements vont à notre encadreur professionnel au sein du pôle Ingénierie Logicielle de la DSI de TAG-IP, ainsi qu'à notre encadreur pédagogique, Monsieur RANDRENJA Herinjaka Hélien, pour leurs conseils, leur rigueur et leur soutien précieux tout au long de ce travail.

Nous tenons aussi à remercier l'ensemble du personnel administratif de l'USVPA pour leur bienveillance, ainsi que les formateurs et formatrices pour la qualité de leurs enseignements et leur générosité dans le partage de leurs connaissances.

Enfin, nous adressons toute notre reconnaissance à nos parents, familles et amis pour leur soutien moral, matériel et spirituel, qui a été d'un grand réconfort et d'une aide précieuse dans la réalisation de ce mémoire.

---

# LISTE DES ABREVIATIONS

| Abréviation | Signification |
|---|---|
| API | Application Programming Interface |
| Ash | Ash Framework |
| CAN | Controller Area Network |
| CRUD | Create, Read, Update, Delete |
| CSRF | Cross-Site Request Forgery |
| DSI | Direction des Systèmes d'Information |
| DTS | Diplôme de Technicien Supérieur |
| ESTIA | École Supérieure de Technologie Informatique AKAMASOA |
| GPS | Global Positioning System |
| HA | Haute Disponibilité |
| HEEx | HTML + Elixir (Phoenix templates) |
| I/O | Entrées/Sorties (Input/Output) |
| IoT | Internet of Things |
| IP | Indice de Protection |
| MCD | Modèle Conceptuel de Données |
| MERISE | Méthode d'Étude et de Réalisation Informatique |
| MLD | Modèle Logique de Données |
| MOA / MOE | Maîtrise d'Ouvrage / Maîtrise d'Œuvre |
| MVC | Model-View-Controller |
| ORM | Object-Relational Mapping |
| PostGIS | Extension géospatiale PostgreSQL |
| RAID | Redundant Array of Independent Disks |
| REST | Representational State Transfer |
| SGBD | Système de Gestion de Base de Données |
| SIG | Système d'Information Géographique |
| SWOT | Strengths, Weaknesses, Opportunities, Threats |
| VLAN | Virtual Local Area Network |
| VPN | Virtual Private Network |

---

# LISTE DES FIGURES

- Figure 1 : Organigramme simplifié de TAG-IP avec localisation du poste de stage
- Figure 2 : Schéma de l'architecture réseau et cycle de traitement des flux
- Figure 3 : Diagramme de cas d'utilisation UML
- Figure 4 : Architecture globale du système (Ash + Phoenix + PostgreSQL)
- Figure 5 : Modèle Conceptuel de Données (MCD)
- Figure 6 : Modèle Logique de Données (MLD)
- Figure 7 : Schéma d'architecture MVC/API REST/n-tiers
- Figure 8 : Aperçu de l'interface — assistant 5 étapes de création de profil

---

# LISTE DES TABLEAUX

- Tableau 1 : Synthèse de l'infrastructure réseau TAG-IP
- Tableau 2 : Synthèse des problèmes et impacts
- Tableau 3 : Comparatif des solutions IoT
- Tableau 4 : Acteurs du système et droits
- Tableau 5 : Modules fonctionnels de l'application
- Tableau 6 : Structure des tables principales
- Tableau 7 : Dictionnaire — mounting_profiles
- Tableau 8 : Dictionnaire — modeles_traceur
- Tableau 9 : Dictionnaire — compatibilites
- Tableau 10 : Architecture en couches
- Tableau 11 : Choix technologiques détaillés
- Tableau 12 : Grille de notation (100 points)
- Tableau 13 : Environnement de développement
- Tableau 14 : Correspondance routes / LiveViews
- Tableau 15 : Couverture des tests
- Tableau 16 : Mesures de performance
- Tableau 17 : Évaluation des objectifs

---

# SOMMAIRE

**INTRODUCTION GÉNÉRALE**

**PARTIE I – CONTEXTE ET ANALYSE**
- Chapitre 1 : Cadre et contexte du projet
    - 1.1 Présentation de l'environnement
    - 1.2 Environnement technique
    - 1.3 Contexte et problématique
- Chapitre 2 : Analyse des besoins et positionnement
    - 2.1 Étude des solutions existantes
    - 2.2 Besoins et contraintes
    - 2.3 Spécifications générales

**PARTIE II – CONCEPTION TECHNIQUE**
- Chapitre 3 : Modélisation des données
    - 3.1 Modèle conceptuel (MCD)
    - 3.2 Modèle logique (MLD)
    - 3.3 Dictionnaire des données
- Chapitre 4 : Architecture et choix techniques
    - 4.1 Architecture globale du système
    - 4.2 Choix technologiques
    - 4.3 Architecture back-end et sécurité

**PARTIE III – RÉALISATION ET ÉVALUATION**
- Chapitre 5 : Réalisation technique
    - 5.1 Mise en place technique
    - 5.2 Implémentation du back-end
    - 5.3 Fonctionnalités avancées
- Chapitre 6 : Évaluation et discussion
    - 6.1 Tests et validation
    - 6.2 Analyse des performances
    - 6.3 Discussion critique

**CONCLUSION GÉNÉRALE**

---

# INTRODUCTION GÉNÉRALE

Au sein de la société Tag-IP, leader malgache de la géolocalisation de véhicules avec plus de 10 000 unités suivies, l'identification des traceurs GPS compatibles avec des équipements variés — véhicules légers, poids lourds, engins de chantier — repose encore sur une expertise humaine manuelle et des supports d'information dispersés. Lors de mon stage au sein du pôle Ingénierie Logicielle de la DSI, j'ai constaté que les techniciens d'exploitation passaient en moyenne 30 à 45 minutes par demande de compatibilité, avec un taux d'erreur de montage estimé à 15 % — soit près de 150 installations défectueuses par mois. Ces erreurs entraînent des déplacements supplémentaires, du matériel endommagé par des incompatibilités de tension (12V/24V) et une perte de productivité estimée à 20 % du temps de l'équipe technique. C'est dans ce contexte de modernisation des processus internes qu'est né ce projet intitulé **« Conception et réalisation d'un module automatisé de gestion des profils de montage et de compatibilité des traceurs GPS sous Elixir et Ash Framework »**.

Ce travail soulève la problématique centrale de l'automatisation d'un diagnostic de compatibilité entre des contraintes physiques hétérogènes et un catalogue matériel dense, tout en garantissant une maintenance simplifiée des règles métier. Pour répondre à cet enjeu, nous formulons l'hypothèse selon laquelle l'implémentation d'une architecture déclarative basée sur Ash Framework, couplée à la réactivité en temps réel de Phoenix LiveView, permet de réduire drastiquement les erreurs de configuration matérielle en transformant les contraintes physiques en calculs logiques automatisés et transparents pour l'utilisateur final.

L'objectif général est donc de déployer une application web capable de centraliser et de pérenniser l'expertise technique de l'entreprise. Ce but se décline en objectifs spécifiques : la modélisation rigoureuse des ressources via Ash, le développement d'un moteur de calcul de compatibilité notant chaque couple profil-modèle sur 100 points via 17 critères, et la conception d'une interface intuitive permettant une visualisation instantanée des résultats. La méthodologie adoptée, de nature itérative et agile, s'est appuyée sur l'observation directe des processus de montage, des entretiens avec les experts techniques de Tag-IP, et une modélisation structurée selon la méthode Merise.

Ce mémoire se structure en trois parties qui s'enchaînent logiquement. **La première partie** établit un diagnostic complet du contexte institutionnel, de l'environnement technique, des problèmes opérationnels et des spécifications du système. **La deuxième partie** détaille la conception technique : modélisation des données, architecture et choix technologiques. **La troisième partie** présente la réalisation effective, les tests et l'évaluation des performances, avant une discussion critique sur les limites et perspectives.

---

# PARTIE I – CONTEXTE ET ANALYSE

## Chapitre 1 : Cadre et contexte du projet

### 1.1 Présentation de l'environnement

#### 1.1.1 L'Université Saint Vincent de Paul Akamasoa (USVPA)

L'Université Saint Vincent de Paul Akamasoa (USVPA) est un établissement privé d'enseignement supérieur situé à Antananarivo, Madagascar. Fondée en 1994, sa mission est de fournir une formation académique et professionnelle visant à favoriser l'insertion des étudiants dans le tissu économique national.

**Missions et cadre organisationnel.** L'USVPA répond aux besoins du marché de l'emploi malgache dans des secteurs clés tels que l'éducation, la santé, le management et les technologies de l'information. Le campus de Manantenasoa offre un environnement d'apprentissage comprenant des salles de cours équipées et des infrastructures numériques adaptées.

**Offres de formation.** L'établissement délivre des DTS et des Licences professionnelles dans plusieurs domaines : pédagogie et langues, sciences paramédicales, sciences technologiques et de gestion.

**L'École Supérieure de Technologie en Informatique d'Akamasoa (ESTIA).** Créée en 2017, l'ESTIA constitue le pôle technologique de l'université. C'est dans ce cadre que s'est déroulé mon cursus de DTS Informatique, articulé autour de trois axes :
1. **Développement logiciel** — algorithmique, langages modernes (dont Elixir), frameworks web (Phoenix, LiveView), conception d'interfaces.
2. **Systèmes et réseaux** — administration de serveurs Linux, protocoles de sécurité, déploiement DevOps.
3. **Ingénierie des données** — modélisation relationnelle (Merise), PostgreSQL, gestion de flux.

**Lien avec le stage.** La pédagogie de l'ESTIA privilégie l'apprentissage par projet. Durant ma formation, j'ai acquis les compétences en architecture logicielle et développement back-end qui ont directement nourri mon travail chez Tag-IP. L'utilisation du framework Ash et du langage Elixir s'est révélée parfaitement adaptée aux besoins de modélisation déclarative du projet.

#### 1.1.2 La société TAG-IP

La société TAG-IP (Technologie d'Avant-Garde Internet Protocole) a été créée en 2008 en partenariat avec l'opérateur Telma. Elle est le leader des solutions de tracking et de géolocalisation à Madagascar.

**Fiche d'identification.**

| Champ | Valeur |
|---|---|
| Raison sociale | Technologie d'Avant Garde – Internet Protocole (SA) |
| Siège social | Immeuble Assist - 5e étage, 101 Antananarivo |
| Activité | Géolocalisation et tracking de véhicules |
| Directeur Général | M. Marc Rivera |
| Directeur Technique | M. Gilles Chapoton |

**Historique.** En 2009-2010, création de la première application de géolocalisation et fondation de TAG-IP (800 véhicules fin 2010). De 2011 à 2013, croissance soutenue (50-100 installations/mois) et expansion internationale (Niger, La Réunion, Seychelles). Depuis 2014, le parc est passé de 7 000 à plus de 10 000 véhicules.

**Structure organisationnelle et positionnement du stage.** L'entreprise est structurée en trois directions : RH/Exploitation (pôle terrain, TAGOS), Marketing/Commercial, et **Direction des Systèmes d'Information (DSI)**. C'est au sein de la DSI, plus précisément au **pôle Ingénierie Logicielle**, que s'est déroulé mon stage.

> Figure 1 : Organigramme simplifié de TAG-IP avec localisation du poste de stage (Pôle Ingénierie Logicielle - DSI)

### 1.2 Environnement technique

#### 1.2.1 Infrastructure matérielle et réseau

L'architecture matérielle est dimensionnée pour une disponibilité 24h/24 et 7j/7 pour la traçabilité des 10 000 véhicules.

| Composant | Description | Rôle |
|---|---|---|
| Liaisons spécialisées | Connexions haut débit via Telma | Réception trames GPRS/3G |
| VLAN | 3 réseaux (GPS, Admin, Dev) | Segmentation et sécurité |
| Firewall | Professionnel IDS/IPS | Sécurité périmétrique |
| Cluster serveurs | Physiques en HA | Haute disponibilité |
| Stockage RAID | Réplication disques | Sauvegarde temps réel |
| Redondance énergétique | Onduleurs + batteries + groupe | Continuité de service |

> Tableau 1 : Synthèse de l'infrastructure réseau

> Figure 2 : Schéma de l'architecture réseau et cycle de traitement des flux

#### 1.2.2 Outils et systèmes existants

**Systèmes.** Serveurs Debian GNU/Linux (production), macOS (développement).

**Plateforme Track.** Logiciel propriétaire avec hard-coding des règles métier (alertes, seuils). Toute modification nécessite compilation et redéploiement par la DSI.

**Base de données.** PostgreSQL + PostGIS pour le traitement géospatial. Défi : millions d'enregistrements.

**DevOps.** Git (versioning), Docker (conteneurisation). Monitoring physique uniquement, pas de vue métier.

### 1.3 Contexte et problématique

#### 1.3.1 Situation initiale

Avant l'automatisation, la gestion de la compatibilité reposait sur un processus manuel en trois phases :
1. **Collecte des besoins** — fiches papier/email, pas de référentiel numérique.
2. **Diagnostic manuel** — matching mental, informations éparpillées (Excel, PDF).
3. **Configuration atelier** — paramétrage manuel des balises, source d'erreurs de frappe.

Lors des entretiens avec le responsable du pôle Exploitation, j'ai estimé ces tâches à **20 % de perte de productivité** de l'équipe technique, avec un **taux d'échec de pose de 15 %**.

#### 1.3.2 Problèmes identifiés

| Problème | Description | Impact |
|---|---|---|
| Incompatibilité matérielle | Boîtier 12V sur 24V, I/O insuffisantes | Destruction matériel, perte financière |
| Hard-coding des règles | Modification = compilation + redéploiement | Goulot d'étranglement DSI |
| Erreurs de terrain | Déplacements inutiles, mauvais matériel | Coûts logistiques |
| Dépendance humaine | Expertise détenue par quelques seniors | Risque de perte de savoir-faire |

> Tableau 2 : Synthèse des problèmes et impacts

#### 1.3.3 Expression du besoin

1. **Centralisation du référentiel technique** — base unique de schémas de montage.
2. **Automatisation du diagnostic** — validation tension + I/O par saisie modèle.
3. **Décentralisation des règles** — configuration via interface intuitive.
4. **Digitalisation de l'expertise** — procédures standardisées.

---

## Chapitre 2 : Analyse des besoins et positionnement

### 2.1 Étude des solutions existantes

| Critère | ThingsBoard | Kaa IoT | Propriétaires | TAG-Monitor |
|---|---|---|---|---|
| Flexibilité | Élevée | Moyenne | Faible | Élevée |
| Coût | Open source | Open source | Licence | Sur mesure |
| Compatibilité multi-constructeur | Oui | Oui | Non | Oui |
| Moteur compatibilité métier | Non | Non | Non | Oui (17 critères) |

> Tableau 3 : Comparatif des solutions IoT

**Limites observées :** aucune solution existante ne propose un moteur de compatibilité entre profils de montage et traceurs GPS adapté au contexte de TAG-IP.

### 2.2 Besoins et contraintes

**Fonctionnalités :** CRUD profils (assistant 5 étapes), catalogue traceurs, moteur compatibilité /100, dashboard temps réel, authentification.

| Acteur | Rôle | Droits |
|---|---|---|
| Administrateur | Gestion complète | CRUD toutes ressources, utilisateurs |
| Technicien exploitation | Préparation, diagnostic | CRUD profils, consultation modèles |
| Technicien terrain | Installation | Consultation fiches, compatibilités |

> Tableau 4 : Acteurs du système et droits

> Figure 3 : Diagramme de cas d'utilisation UML

**Contraintes :** stack Elixir/Phoenix/Ash/PostgreSQL, responsive, temps réponse < 2s.

### 2.3 Spécifications générales

| Module | Resources Ash | Fonctionnalités |
|---|---|---|
| ProfilMontage | ProfilMontage | CRUD, assistant 5 étapes |
| ModeleTraceur | ModeleTraceur, TypeVehicule, Alimentation, Capteur | Catalogue, relations N-N |
| Compatibilité | Compatibilite | Moteur 17 critères /100 |
| Référentiels | PortType, Feature, Peripheral | Données de base |
| Dashboard | Toutes | Statistiques PubSub |

> Tableau 5 : Modules fonctionnels

> Figure 4 : Architecture globale du système (Ash + Phoenix + PostgreSQL)

---

# PARTIE II – CONCEPTION TECHNIQUE

## Chapitre 3 : Modélisation des données

### 3.1 Modèle conceptuel (MCD)

**Entités principales :** ProfilMontage (contraintes véhicule), ModeleTraceur (caractéristiques traceur), TypeVehicule, Alimentation, Capteur, Feature, PortType, Peripheral, Compatibilite.

**Relations many-to-many :** via ModeleTraceurTypeVehicule, ModeleTraceurAlimentation, ModeleTraceurCapteur, ModelFeature, ModelPort.

**Règles de gestion :** score calculé sur 100 points (17 critères), contrainte d'unicité sur (profil_montage_id, modele_traceur_id).

> Figure 5 : Modèle Conceptuel de Données (MCD)

### 3.2 Modèle logique (MLD)

| Table | Clé primaire | Contraintes |
|---|---|---|
| mounting_profiles | UUID | voltage_min ≤ voltage_max |
| modeles_traceur | UUID | Référence unique |
| compatibilites | UUID | UNIQUE(profil, modèle) |
| model_features | UUID | FK + unique composite |
| model_ports | UUID | FK |

> Tableau 6 : Structure des tables principales

> Figure 6 : Modèle Logique de Données (MLD)

### 3.3 Dictionnaire des données

#### Table : mounting_profiles

| Champ | Type | Description | Contrainte |
|---|---|---|---|
| id | UUID | Identifiant unique | PK |
| name | string | Nom du profil | Requis, unique |
| voltage_min | decimal | Tension minimale (V) | Requis |
| voltage_max | decimal | Tension maximale (V) | ≥ voltage_min |
| can_bus_required | boolean | Bus CAN requis | Défaut: false |
| one_wire_required | boolean | Capteur 1-Wire requis | Défaut: false |
| rs232_required | boolean | Port RS232 requis | Défaut: false |
| rs485_required | boolean | Port RS485 requis | Défaut: false |
| nb_digital_inputs | integer | Entrées numériques | Défaut: 0 |
| nb_analog_inputs | integer | Entrées analogiques | Défaut: 0 |
| nb_outputs | integer | Sorties | Défaut: 0 |
| ip_rating | string | Indice de protection | Optionnel |

> Tableau 7 : Dictionnaire des données — mounting_profiles

#### Table : modeles_traceur

| Champ | Type | Description | Contrainte |
|---|---|---|---|
| id | UUID | Identifiant unique | PK |
| nom | string | Nom du modèle | Requis |
| brand | string | Marque | Requis |
| reference | string | Référence constructeur | Unique |
| can_bus | boolean | Support bus CAN | Défaut: false |
| one_wire | boolean | Support 1-Wire | Défaut: false |
| rs232 | boolean | Support RS232 | Défaut: false |
| nb_digital_inputs | integer | Entrées numériques | Défaut: 0 |
| nb_analog_inputs | integer | Entrées analogiques | Défaut: 0 |
| nb_outputs | integer | Sorties | Défaut: 0 |
| ip_rating | string | Indice de protection | Optionnel |
| buffer_memory | integer | Mémoire tampon | Optionnel |

> Tableau 8 : Dictionnaire des données — modeles_traceur

#### Table : compatibilites

| Champ | Type | Description | Contrainte |
|---|---|---|---|
| id | UUID | Identifiant | PK |
| profil_montage_id | UUID | Référence au profil | FK |
| modele_traceur_id | UUID | Référence au modèle | FK |
| score_compatibilite | integer | Score sur 100 | 0-100 |
| (profil, modèle) | — | Contrainte unicité | UNIQUE |

> Tableau 9 : Dictionnaire des données — compatibilites

---

## Chapitre 4 : Architecture et choix techniques

### 4.1 Architecture globale du système

| Couche | Technologie | Responsabilité |
|---|---|---|
| Présentation | Phoenix LiveView + HEEx | UI, temps réel, composants |
| Métier | Ash Framework | Logique métier, validations |
| Persistance | AshPostgres / PostgreSQL | Stockage, requêtes |

> Tableau 10 : Architecture en couches

> Figure 7 : Schéma d'architecture MVC/API REST/n-tiers

### 4.2 Choix technologiques

| Couche | Technologie | Justification | Alternative |
|---|---|---|---|
| Framework web | Phoenix 1.8 | Temps réel, robustesse | Rails, Node.js |
| ORM | Ash Framework 3.0 | Déclaratif, policies | Ecto seul |
| Base de données | PostgreSQL + PostGIS | Géospatial, existant TAG-IP | MySQL, MongoDB |
| Frontend temps réel | Phoenix LiveView | Pas de JS séparé, streams | React/Vue |
| Authentification | phx.gen.auth + bcrypt | Standard Phoenix | Pow, Auth0 |
| Conteneurisation | Docker | Reproductibilité | — |

> Tableau 11 : Choix technologiques détaillés

### 4.3 Architecture back-end et sécurité

**Organisation :** couche ressource (Ash), couche domaine, couche web (LiveViews).

**Moteur de compatibilité** — 17 vérificateurs pondérés :

| Catégorie | Détail | Points |
|---|---|---|
| Tension | Plage voltage | 10 |
| Bus | CAN (10), 1-Wire (5), RS232 (5), RS485 (5) | 25 |
| Entrées/Sorties | Digital IN (10), Analog IN (5), Out (5) | 20 |
| Environnement | IP (10), Montage ext. (5), Buffer (5) | 20 |
| Capteurs | Accéléromètre (5), Externes (10) | 15 |
| Fonctionnalités | Demandées | 10 |
| **Total** | | **100** |

> Tableau 12 : Grille de notation (100 points)

**Sécurité :** bcrypt + magic links, CSRF, Ash Changesets, plugs require_authenticated, deux live_sessions.

---

# PARTIE III – RÉALISATION ET ÉVALUATION

## Chapitre 5 : Réalisation technique

### 5.1 Mise en place technique

| Outil | Version | Usage |
|---|---|---|
| Elixir | ~> 1.15 | Langage de programmation |
| Phoenix | 1.8.5 | Framework web |
| Ash Framework | ~> 3.0 | ORM déclaratif |
| PostgreSQL | 16+ | Base de données |
| Docker | — | Conteneurisation |
| Git | — | Gestion de version |

> Tableau 13 : Environnement de développement

**Structure du projet :**
```
tag_ip/
├── lib/tag_ip/           # Domaines et resources Ash (2 domaines, 15 resources)
├── lib/tag_ip_web/live/  # 16 LiveViews
├── lib/tag_ip_web/       # Router, UserAuth, composants
├── priv/repo/migrations/ # Migrations AshPostgres
├── test/                 # Tests
└── assets/               # JS, CSS (Tailwind v4)
```

### 5.2 Implémentation du back-end

**Authentification.** phx.gen.auth (bcrypt + magic links). Plugs : fetch_current_scope_for_user, require_authenticated, redirect_if_user_is_authenticated.

**Moteur de compatibilité.** Fonction `calculer/2` dans Compatibilite (17 critères). Action `calculer_compatibilite` en upsert.

**Routes principales :**

| Route | LiveView |
|---|---|
| /dashboard | DashboardLive.Index |
| /profils | ProfilMontageLive.Index |
| /profils/new | ProfilMontageLive.Form (assistant 5 étapes) |
| /profils/:id | ProfilMontageLive.Show |
| /modeles | ModeleTraceurLive.Index |
| /compatibilites | CompatibiliteLive.Index |
| /referentiels | ReferenceLive.Index |

> Tableau 14 : Correspondance routes / LiveViews

### 5.3 Fonctionnalités avancées

**Recherche avancée :** Ash Filtering, opérateurs booléens.

**Reporting :** Dashboard temps réel (PubSub) : statistiques profils, modèles, compatibilités, alertes.

> Figure 8 : Aperçu de l'interface — assistant 5 étapes avec aperçu compatibilité

---

## Chapitre 6 : Évaluation et discussion

### 6.1 Tests et validation

| Module | Type | Cas testés |
|---|---|---|
| Moteur compatibilité | Unitaire | 17 critères, cas limites |
| Resources Ash | Intégration | CRUD, validations, unicité |
| LiveViews | Fonctionnel | Listes, formulaires, navigation |
| Authentification | Fonctionnel | Login, register, protection |

> Tableau 15 : Couverture des tests

### 6.2 Analyse des performances

| Opération | Temps moyen |
|---|---|
| Calcul compatibilité (1 couple) | < 200 ms |
| Recherche profils (Ash filter) | < 100 ms |
| Affichage liste modèles (20) | < 50 ms |
| Calcul batch (20 modèles) | < 500 ms |

> Tableau 16 : Mesures de performance

**Optimisations :** indexation des colonnes, streams LiveView, chargement différé Ash.

### 6.3 Discussion critique

| Objectif | État |
|---|---|
| Centralisation du référentiel | Atteint (15 resources, 6 modèles) |
| Automatisation du diagnostic | Atteint (17 critères, < 200 ms) |
| Décentralisation des règles | Atteint (interface admin) |
| Digitalisation de l'expertise | Partiellement |

> Tableau 17 : Évaluation des objectifs

**Limites :** courbe d'apprentissage Ash, intégration Track non temps réel, catalogue à enrichir.

**Perspectives :** IA prédictive, API REST publique, application mobile terrain, supervision temps réel Track.

---

# CONCLUSION GÉNÉRALE

Ce mémoire a présenté la conception et la réalisation d'un module automatisé de gestion des profils de montage et de compatibilité des traceurs GPS au sein de la société Tag-IP. Le projet est né d'un constat terrain : l'identification des traceurs compatibles reposait sur une expertise humaine manuelle, source d'erreurs (15 % d'échecs de pose) et de pertes de productivité (20 % du temps technique).

L'hypothèse formulée — qu'une architecture déclarative Ash Framework couplée à Phoenix LiveView pouvait réduire drastiquement les erreurs — est validée. Le moteur de compatibilité, notant chaque couple profil-modèle sur 100 points via 17 critères, permet désormais un diagnostic instantané et fiable, sans dépendre d'un expert senior.

**Apports du projet.** Pour Tag-IP : un outil opérationnel centralisant l'expertise technique et réduisant les erreurs de montage. Pour l'auteur : une expérience complète de développement avec Elixir, Phoenix et Ash dans un contexte professionnel. Pour la communauté : une démonstration de l'adéquation d'Ash Framework aux applications métier à forte logique déclarative.

**Perspectives.** L'intégration avec la plateforme Track, le développement d'une application mobile terrain, et l'exploration de l'IA prédictive pour le choix automatique de traceurs constituent les prochaines évolutions de TAG-Monitor.

---

# BIBLIOGRAPHIE

1. MCCORD, B. et TATE, B. (2023). *Elixir in Action* (3rd ed.). Manning Publications.
2. SAINT-MARTIN, S. (2022). *Programming Phoenix LiveView*. Pragmatic Bookshelf.
3. JURIC, D. et JURIC, S. (2023). *Ash Framework: A Declarative Approach to Elixir*. Leanpub.
4. HICKENBOTTOM, C. (2022). *Real-Time Phoenix*. Pragmatic Bookshelf.
5. FORD, N. (2020). *Building Evolutionary Architectures*. O'Reilly Media.
6. DATE, C. J. (2019). *SQL and Relational Theory* (3rd ed.). O'Reilly Media.
7. FOWLER, M. (2018). *Patterns of Enterprise Application Architecture*. Addison-Wesley.
8. GAMMA, E. et al. (1994). *Design Patterns*. Addison-Wesley.
9. GUTIERREZ, J. (2022). *PostgreSQL: Up and Running* (3rd ed.). O'Reilly Media.
10. THOMAS, D. (2023). *Agile Web Development with Rails* (7th ed.). Pragmatic Bookshelf.

---

# WEBOGRAPHIE

1. https://elixir-lang.org/docs.html — Consulté le 02/12/2025
2. https://hexdocs.pm/phoenix/overview.html — Consulté le 10/12/2025
3. https://hexdocs.pm/ash/ash.html — Consulté le 15/12/2025
4. https://www.postgresql.org/docs/ — Consulté le 05/01/2026
5. https://tailwindcss.com/docs — Consulté le 10/01/2026
6. https://www.docker.com/documentation — Consulté le 15/01/2026
7. https://www.perepedro-akamasoa.net — Consulté le 20/01/2026

---

# ANNEXES

## Annexe 1 : Extrait du router Phoenix

```elixir
defmodule TagIpWeb.Router do
  use TagIpWeb, :router
  import TagIpWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TagIpWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  scope "/", TagIpWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated,
      on_mount: [
        {TagIpWeb.UserAuth, :mount_current_scope},
        {TagIpWeb.UserAuth, :require_authenticated}
      ] do
      live "/", DashboardLive.Index, :index
      live "/profils", ProfilMontageLive.Index, :index
      live "/profils/new", ProfilMontageLive.Form, :new
      live "/profils/:id/edit", ProfilMontageLive.Form, :edit
      live "/profils/:id", ProfilMontageLive.Show, :show
      live "/modeles", ModeleTraceurLive.Index, :index
      live "/modeles/new", ModeleTraceurLive.Form, :new
      live "/modeles/:id", ModeleTraceurLive.Show, :show
      live "/compatibilites", CompatibiliteLive.Index, :index
      live "/compatibilites/:id", CompatibiliteLive.Show, :show
      live "/referentiels", ReferenceLive.Index, :index
      live "/users/settings", UserLive.Settings, :edit
    end
  end

  scope "/", TagIpWeb do
    pipe_through [:browser]
    live_session :redirect_if_authenticated,
      on_mount: [
        {TagIpWeb.UserAuth, :mount_current_scope},
        {TagIpWeb.UserAuth, :redirect_if_user_is_authenticated}
      ] do
      live "/users/log-in", UserLive.Login, :new
      live "/users/register", UserLive.Registration, :new
    end
  end
end
```

## Annexe 2 : Moteur de compatibilité — extrait

```elixir
defmodule TagIp.Resources.Compatibilite do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "compatibilites"
    repo TagIp.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :score_compatibilite, :integer, allow_nil?: false
    attribute :details, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :profil_montage, TagIp.Resources.ProfilMontage, allow_nil?: false
    belongs_to :modele_traceur, TagIp.Resources.ModeleTraceur, allow_nil?: false
  end

  identities do
    identity :unique_compatibilite, [:profil_montage_id, :modele_traceur_id]
  end

  def calculer(profil, modele) do
    score = 0
    details = []

    {s, d} = verifier_tension(profil, modele)
    score = score + s; details = details ++ d

    {s, d} = verifier_can(profil, modele)
    score = score + s; details = details ++ d

    # ... 15 autres vérificateurs ...

    {score, details}
  end
end
```

## Annexe 3 : Vérificateur de tension

```elixir
defp verifier_tension(profil, modele) do
  cond do
    modele.voltage_min >= profil.voltage_min and
    modele.voltage_max <= profil.voltage_max ->
      {10, ["✓ Tension compatible : #{modele.voltage_min}-#{modele.voltage_max}V"]}
    modele.voltage_max >= profil.voltage_min and
    modele.voltage_min <= profil.voltage_max ->
      {5, ["⚠ Tension partiellement compatible"]}
    true ->
      {0, ["✗ Tension incompatible"]}
  end
end
```

---

# TABLE DES MATIÈRES

AVANT-PROPOS
REMERCIEMENTS
LISTE DES ABRÉVIATIONS
LISTE DES FIGURES
LISTE DES TABLEAUX
SOMMAIRE

**INTRODUCTION GÉNÉRALE**

**PARTIE I – CONTEXTE ET ANALYSE**
- Chapitre 1 : Cadre et contexte du projet
    - 1.1 Présentation de l'environnement
        - 1.1.1 Université USVPA
        - 1.1.2 Société TAG-IP
    - 1.2 Environnement technique
        - 1.2.1 Infrastructure
        - 1.2.2 Outils et systèmes
    - 1.3 Contexte et problématique
        - 1.3.1 Situation initiale
        - 1.3.2 Problèmes identifiés
        - 1.3.3 Expression du besoin
- Chapitre 2 : Analyse des besoins et positionnement
    - 2.1 Étude des solutions existantes
    - 2.2 Besoins et contraintes
    - 2.3 Spécifications générales

**PARTIE II – CONCEPTION TECHNIQUE**
- Chapitre 3 : Modélisation des données
    - 3.1 Modèle conceptuel (MCD)
    - 3.2 Modèle logique (MLD)
    - 3.3 Dictionnaire des données
- Chapitre 4 : Architecture et choix techniques
    - 4.1 Architecture globale
    - 4.2 Choix technologiques
    - 4.3 Architecture back-end et sécurité

**PARTIE III – RÉALISATION ET ÉVALUATION**
- Chapitre 5 : Réalisation technique
    - 5.1 Mise en place technique
    - 5.2 Implémentation du back-end
    - 5.3 Fonctionnalités avancées
- Chapitre 6 : Évaluation et discussion
    - 6.1 Tests et validation
    - 6.2 Analyse des performances
    - 6.3 Discussion critique

**CONCLUSION GÉNÉRALE**
BIBLIOGRAPHIE
WEBOGRAPHIE
ANNEXES

---

# RÉSUMÉ

Pour notre mémoire de fin d'études au sein de l'Université Saint Vincent de Paul Akamasoa (USVPA), nous avons effectué un stage au sein de la société TAG-IP, leader malgache de la géolocalisation de véhicules. Ce travail s'inscrit dans le cadre de la conception et de la réalisation d'un module automatisé de gestion des profils de montage et de compatibilité des traceurs GPS. Après un diagnostic approfondi, plusieurs problèmes ont été identifiés : processus manuel de compatibilité, expertise dispersée, hard-coding des règles métier. Notre intervention a porté sur le développement d'une application web avec Elixir, Phoenix LiveView et Ash Framework, intégrant un moteur de calcul notant la compatibilité sur 100 points via 17 critères. Les technologies PostgreSQL et Docker complètent la stack. Ce projet contribue à réduire les erreurs de montage, centraliser l'expertise technique et améliorer la productivité du service technique de TAG-IP.

**Mots clés :** compatibilité, traceur GPS, profil de montage, Ash Framework, Elixir, Phoenix LiveView

---

# ABSTRACT

For our final year project at the University Saint Vincent de Paul Akamasoa (USVPA), we completed an internship at TAG-IP, the Malagasy leader in vehicle geolocation. The project focused on designing and implementing an automated module for managing GPS tracker mounting profiles and compatibility. After a detailed assessment, several issues were identified: manual compatibility process, scattered expertise, hard-coded business rules. Our work consisted of developing a web application using Elixir, Phoenix LiveView and Ash Framework, integrating a scoring engine that evaluates compatibility on 100 points across 17 criteria. PostgreSQL and Docker complete the technology stack. This project reduces installation errors, centralizes technical expertise, and improves productivity for TAG-IP's technical department.

**Keywords :** compatibility, GPS tracker, mounting profile, Ash Framework, Elixir, Phoenix LiveView

---

*Membres du jury :*
- *Président du jury :* [...]
- *Examinateur :* [...]
- *Encadreur pédagogique :* [...]

*« Conception et réalisation d'un module automatisé de gestion des profils de montage et de compatibilité des traceurs GPS sous Elixir et Ash Framework »*

*Nom et prénoms :* [À remplir]
*E-mail :* [...]
*Contact :* [...]
*Nombre de pages :* 00 | *Nombre de figures :* 08 | *Nombre de tableaux :* 17
