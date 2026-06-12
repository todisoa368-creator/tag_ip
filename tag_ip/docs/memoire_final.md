# Mémoire — Projet TAG-IP (Version rédigée finale)

Auteur: [Votre nom]
Université: USVPA

---

## INTRODUCTION

Contexte et genèse

Le projet TAG-IP est né d'un besoin opérationnel exprimé par une équipe technique en charge de l'intégration et du déploiement de traceurs GPS au sein d'une flotte hétérogène de véhicules. Les informations relatives aux modèles de traceurs, aux capteurs compatibles, aux alimentations et aux profils de montage étaient disséminées dans des feuilles de calcul, des documents Word et des courriels, rendant la recherche et la validation longues et sujettes à erreurs. L'objectif du projet est de centraliser ces données, d'automatiser les contrôles de compatibilité et de fournir une interface réactive pour les acteurs métiers.

Titre

Conception et réalisation d'un système de gestion de compatibilités de traceurs — TAG-IP

Problématique

Comment concevoir et mettre en oeuvre une application capable de centraliser l'information technique autour des traceurs et d'offrir des outils fiables de recherche, de correspondance et d'export afin de réduire les erreurs opérationnelles et d'accélérer la mise en service des équipements ?

Hypothèse

Nous postulons qu'un référentiel central structuré, complété par des algorithmes de scoring de compatibilité et une interface LiveView réactive, permettra de diminuer significativement le temps de configuration et le taux d'erreurs lors des déploiements.

Objectifs

- Modéliser le domaine technique (traceurs, capteurs, alimentations, profils de montage) de manière pérenne.
- Développer une application web (Elixir/Phoenix + LiveView) fournissant des écrans CRUD, une recherche avancée et des exports.
- Assurer la qualité via tests automatisés et bonnes pratiques de sécurité.

Méthodologie

Approche itérative combinant analyse terrain (entretiens, collecte de fichiers existants), conception (MCD/MLD), développement incrémental, tests unitaires et fonctionnels, et validation par des démonstrations auprès des utilisateurs finaux.

Annonce du plan

Le document s'articule en trois parties : contexte et analyse (Partie I), conception technique (Partie II), réalisation et évaluation (Partie III). Chaque partie contient deux chapitres détaillés.

---

# PARTIE I – CONTEXTE ET ANALYSE

## Chapitre 1 : Cadre et contexte du projet

1.1 Présentation de l'environnement

Université USVPA

L'Université USVPA offre des formations en systèmes d'information et en génie logiciel. Le projet TAG-IP a été conduit dans le cadre d'une collaboration entre le cursus et une entreprise partenaire, offrant un contexte réel pour l'application des compétences acquises en architecture logicielle et en gestion de projets.

Organisme d'accueil

L'organisme d'accueil est une équipe technique en charge de l'intégration de traceurs au sein de parcs véhicules. Ses missions principales sont la validation technique des équipements, la production de guides d'installation et le support aux équipes de pose. Le besoin d'un référentiel structuré est né des difficultés rencontrées pour valider rapidement si un traceur donné est compatible avec un profil de montage ou un capteur spécifique.

1.2 Environnement technique

Infrastructure

Le projet repose sur une architecture moderne : Elixir/BEAM pour la couche applicative, Phoenix 1.8 et LiveView pour l'interface web, PostgreSQL comme base relationnelle, et des assets gérés via esbuild et Tailwind CSS. Le dépôt contient des migrations SQL, des scripts d'import et une configuration Docker pour le développement et le déploiement.

Outils et systèmes existants

Les données initiales proviennent majoritairement de fichiers CSV/Excel et de documents techniques fournis par les fabricants. L'équipe utilise des outils internes (scripts et exportations) pour préparer ces données. TAG-IP vise à remplacer progressivement ces fichiers sources par un référentiel unique accessible via une interface web et des endpoints d'export/import.

1.3 Contexte et problématique

Situation initiale

Avant TAG-IP, la gestion des informations s'effectuait manuellement : rapprochement de fiches techniques, vérification manuelle des broches et voltages, et échanges par mail pour clarification. Ce processus était long, error-prone et difficilement traçable.

Problèmes identifiés

- Redondance et divergence des sources d'information.
- Absence d'outil unique pour valider la compatibilité matériel/équipement.
- Temps élevé pour trouver et valider une configuration.

Expression du besoin

Le besoin prioritaire est la construction d'un référentiel centralisé, structuré et interrogeable, fournissant :
- des écrans de saisie et de consultation ;
- des fonctionnalités de recherche et de filtrage multicritères ;
- des exports (CSV/JSON) pour intégration avec d'autres systèmes ;
- une gestion des accès (rôles) pour protéger les modifications.

Conclusion du chapitre

Ce chapitre cadre le périmètre fonctionnel et technique du projet et prépare la phase de conception, centrée sur la modélisation des données et sur une architecture capable de supporter des évolutions futures.

---

## Chapitre 2 : Analyse des besoins et positionnement

2.1 Étude des solutions existantes

Outils similaires

Une rapide revue du marché révèle des solutions PLM/ERP et des catalogues de produits qui couvrent partiellement les besoins, mais souvent avec une lourdeur d'utilisation et un coût d'intégration élevés. Les outils open-source de gestion de catalogue peuvent être une base, mais ils manquent fréquemment des critères métiers spécifiques aux traceurs GPS.

Limites observées

Les solutions existantes présentent les limites suivantes : faible adaptation aux contraintes matérielles (voltages, ports physiques), interfaces peu ergonomiques pour des techniciens, absence d'algorithme de scoring pour la compatibilité et coûts de personnalisation élevés.

2.2 Besoins et contraintes

Fonctionnalités principales

- Gestion complète des entités (CRUD) : modèles, capteurs, alimentations, profils de montage, périphériques.
- Recherche multicritère : filtrage par voltage, ports, features, IP rating.
- Algorithme de scoring : calcul automatique d'un indice de compatibilité.
- Import/export et scripts d'automatisation.

Acteurs et cas d'utilisation

- Administrateurs : gestion des référentiels et des imports.
- Techniciens : consultation et validation de montage.
- Produit/ingénierie : définition des règles de compatibilité et validation finale.

Contraintes techniques et organisationnelles

- Sécurité : authentification, rôles et gestion des sessions.
- Performance : requêtes rapides sur jeux de données potentiellement volumineux.
- Gouvernance : maintien de la qualité des données et processus de revue.

2.3 Spécifications générales

Modules principaux

- `Resources` : contexte métier (Ecto/Ash) gérant entités et règles.
- `Web` : LiveViews, composants et controllers pour l'UI.
- `Export/Import` : scripts et endpoints pour échange de données.
- `Auth` : gestion des utilisateurs et des sessions.

Vue globale du système

L'architecture se compose d'une couche présentation (LiveView), d'une couche application (contexts et services métier), et d'une couche persistance (Ecto/AshPostgres). Les échanges externes se font via des endpoints d'export et via des fichiers CSV standardisés.

Conclusion du chapitre

Les besoins fonctionnels et les contraintes sont clairement définis : la solution doit être spécialisée, performante, et extensible, avec une attention particulière portée sur la qualité des données et les interfaces métiers.

---

# PARTIE II – CONCEPTION TECHNIQUE

## Chapitre 3 : Modélisation des données

3.1 Modèle conceptuel (MCD)

Entités

Le MCD identifie les entités clés : `ModeleTraceur`, `Capteur`, `Alimentation`, `ProfilMontage`, `Peripheral`, `Compatibilite`, ainsi que des tables de référence (`Feature`, `PortType`, `TypeVehicule`). Chaque entité contient des attributs pertinents pour la validation technique : voltage, nombre d'entrées, IP rating, etc.

Relations et cardinalités

- `ModeleTraceur` ↔ `Compatibilite` ↔ `ProfilMontage` (relation M:N avec attributs de score et de détails). 
- `ModeleTraceur` ↔ `Capteur` (M:N) pour indiquer quels capteurs sont supportés.
- `ModeleTraceur` ↔ `Alimentation` (M:N) pour lister les alimentations compatibles.

Règles de gestion

- Validation des plages de voltages : un profil nécessite une tension entre `voltage_min` et `voltage_max` ; tout modèle dont la plage fournie ne respecte pas la contrainte est marqué incompatible.
- Unicité logique : `reference` et `slug` sont des identifiants uniques pour éviter les doublons.

3.2 Modèle logique (MLD)

Tables principales

La version logique transpose le MCD en tables SQL : `modeles_traceur`, `capteurs`, `alimentations`, `mounting_profiles`, `compatibilites`, `model_ports`, `features`, `port_types`, etc. Les migrations disponibles dans `priv/repo/migrations` reflètent cette structure.

Clés et contraintes

Les tables incluent des clés primaires en UUID et des contraintes d'intégrité référentielle (FK) avec suppression en cascade lorsque pertinent. Des indexes sont ajoutés sur `name`, `slug` et les colonnes utilisées pour les recherches fréquentes.

3.3 Dictionnaire des données

Description des champs

Chaque champ clé est documenté : type SQL, contraintes (NOT NULL, UNIQUE), format attendu (ex: `ip_rating` comme string pattern), et exemples de valeurs. Les règles de validation côté application sont également détaillées (`validate_required`, `validate_number`, `unique_constraint`).

Règles et validations

- Checks de cohérence (ex : `voltage_min <= voltage_max`).
- Validation des formats (email, slug) et limites numériques.

Annexes et diagrammes

Les diagrammes MCD/MLD (`docs/mcd_diagramme.svg`, `docs/mld_diagramme.svg`) sont inclus en annexe pour faciliter la lecture structurelle.

Conclusion du chapitre

Le modèle de données couvre les besoins identifiés et fournit une base solide pour l'implémentation et l'évolution du système.

---

## Chapitre 4 : Architecture et choix techniques

4.1 Architecture globale du système

Le système adopte une architecture en couches : présentation (LiveView), application (contexts et services), persistance (Ecto/AshPostgres). LiveView permet des interactions réactives tout en minimisant le JavaScript côté client, ce qui simplifie le développement et la maintenance.

Organisation générale

- `lib/tag_ip` pour la logique métier et les contexts.
- `lib/tag_ip_web` pour les LiveViews, les templates et les composants.
- `assets/` pour les styles et scripts front-end.

4.2 Choix technologiques

Backend / DB / serveur

- Elixir/Phoenix : robustesse, concurrence, productivité.
- PostgreSQL : transactions, indices, support JSON pour certains rapports.
- Déploiement : Docker + docker-compose pour reproductibilité; possibilité de déployer sur des plateformes BEAM-friendly.

Justifications + alternatives

Les alternatives (Node.js, Django, Rails) sont viables mais impliqueraient des compromis sur la tolérance à la charge ou sur la simplicité de développement en mode fonctionnel/actor model. Elixir s'est imposé par sa simplicité pour gérer des connexions simultanées et des LiveViews.

4.3 Architecture back-end et sécurité

Organisation en couches

La couche back-end est séparée en contexts (un pour les ressources métier), modules d'export/import, et modules de services pour la logique de scoring.

Patterns utilisés

- Contexts Phoenix pour découpler les domaines métier.
- Changesets pour la validation et la transformation des données.
- Strategy pattern pour les importeurs/exporteurs afin d'adapter différents formats.

Sécurité

- Authentification et gestion de sessions via `phx.gen.auth`.
- Contrôles d'accès par rôle et politiques côté serveur.
- Protections CSRF et validations approfondies côté back-end pour éviter l'injection de données invalides.

Conclusion du chapitre

Les choix architecturaux satisfont les besoins de scalabilité, de maintenabilité et de sécurité, tout en gardant une courbe d'apprentissage raisonnable pour l'équipe.

---

# PARTIE III – RÉALISATION ET ÉVALUATION

## Chapitre 5 : Réalisation technique

5.1 Mise en place technique

Environnement de développement

Procédure pour démarrer le projet localement :

```bash
mix deps.get
mix ecto.setup
cd assets
npm install
npm run build
mix phx.server
```

Structure du projet

Le projet présente une séparation claire des responsabilités : contexts métier dans `lib/tag_ip`, LiveViews et templates dans `lib/tag_ip_web`, migrations et seeds dans `priv/repo`.

Base de données

Les migrations présentes définissent les tables et index nécessaires. Des scripts d'import sont fournis pour transformer les CSV d'origine et initialiser le référentiel.

5.2 Implémentation du back-end

Authentification / utilisateurs

L'authentification utilise `phx.gen.auth` et permet la gestion des comptes, la réinitialisation de mot de passe et la confirmation d'email. Les rôles (admin, user, technician) sont gérés via des vérifications dans les plugs et les LiveViews.

Logique métier

Les contexts exposent des API claires : création et mise à jour de modèles, calcul de score de compatibilité, suggestions de ports et filtres de recherche. Les règles métier sont implémentées dans des modules séparés pour faciliter les tests.

API

Un `ExportController` fournit des endpoints pour l'export CSV/JSON. Le projet peut être étendu par des endpoints REST pour intégration externe.

5.3 Fonctionnalités avancées

Recherche avancée

Les filtres combinés sont implémentés au niveau du context et optimisés par des index et des préchargements (`preload`) pour réduire le nombre de requêtes. Pour des besoins plus avancés, on propose l'ajout d'un index tsvector ou un moteur externe (Elasticsearch).

Reporting

Des scripts de génération de rapports et des exports programmés (cron) sont prévus pour la production de rapports périodiques sur l'état des compatibilités et des modèles.

Interface (aperçu)

Les LiveViews fournissent des pages listant les modèles, leurs compatibilités et des formulaires d'édition. Les composants réutilisables (`core_components.ex`) facilitent l'homogénéité visuelle.

Conclusion du chapitre

La réalisation technique couvre les besoins essentiels et fournit une base prête à être testée en environnement de préproduction.

---

## Chapitre 6 : Évaluation et discussion

6.1 Tests et validation

Tests fonctionnels

Des tests LiveView et controller vérifient les principaux scénarios (création, modification, accès restreint). Les fixtures et helpers facilitent l'écriture de cas de test reproductibles.

Tests techniques (unitaires/intégration)

Les contexts métiers possèdent des tests unitaires. L'intégration est testée via `mix test` et des fixtures de base de données.

Sécurité + résultats

Les contrôles d'accès ont été testés manuellement et automatisés pour les workflows critiques. Des recommandations supplémentaires incluent un audit externe des endpoints exposés en production.

6.2 Analyse des performances

Temps de réponse

La pile BEAM offre de bonnes performances pour des interactions LiveView concurrentes. Des tests de charge de base (wrk, ab) sont recommandés pour valider les temps de réponse sur des volumes de données importants.

Optimisations

- Indexation des colonnes utilisées pour le filtrage.
- Utilisation de `stream`/`stream_insert` pour les longues listes.
- Mise en cache des résultats coûteux si nécessaire.

Résultats

Les optimisations prioritaires consistent en une revue des requêtes N+1, l'ajout d'indexes et la vérification des plans d'exécution pour les requêtes lourdes.

6.3 Discussion critique

Évaluation objectifs/hypothèse

Le système implémenté répond de manière satisfaisante aux objectifs initiaux : centralisation des données, recherche et export. L'hypothèse selon laquelle une interface réactive et un modèle bien conçu améliorent la productivité est corroborée par les premières évaluations qualitatives.

Limites et difficultés

- Importations massives encore peu optimisées.
- Tests de montée en charge incomplets à grande échelle.
- Adoption métier nécessite formation et documentation.

Perspectives

- Ajout d'un moteur de recherche full-text.
- Automatisation avancée des imports.
- Tableau de bord analytique pour suivre l'adoption et la qualité des données.

---

## CONCLUSION

Synthèse

TAG-IP fournit une solution pragmatique et extensible pour centraliser la gestion des compatibilités entre modèles de traceurs et composants. Le choix d'une architecture Elixir/Phoenix permet un développement rapide tout en garantissant robustesse et scalabilité.

Validation hypothèse

Les concepts développés (modèle de données, scoring, UI LiveView) répondent aux objectifs initiaux, même si des tests de charge et des améliorations d'import restent nécessaires.

Apports

- Référentiel central et structuré.
- Outils d'exportation et de reporting.
- Base technique permettant des évolutions futures.

Perspectives

Pistes d'amélioration : moteur full-text, API publique, automatisation des imports, et enrichissement des scénarios de tests de charge.

---

### Annexes

- Diagrammes : `docs/mcd_diagramme.svg`, `docs/mld_diagramme.svg`
- Migrations : `priv/repo/migrations`
- Scripts : `priv/repo/scripts`

*Version rédigée finale générée à partir du dépôt — relire pour validation métier et mise en forme finale.*
