#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Complete rewrite: number all tables 1-37 by book order.
Put caption + source + interp AFTER each table (at bottom).
Same for figures.
"""

from docx import Document
from docx.shared import Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
import re

SRC = "/Users/fitahiana/Desktop/FITAHIANJANAHARY TODISOA CHRISTINE FINAL.docx"
OUT = "/Users/fitahiana/Desktop/FITAHIANJANAHARY TODISOA CHRISTINE FINAL.docx"

doc = Document(SRC)
body = doc.element.body

ROOT = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
W = lambda tag: f'{{{ROOT}}}{tag}'

def make_para(text, bold=False, italic=False, size=11, align='left'):
    p = OxmlElement('w:p')
    pPr = OxmlElement('w:pPr')
    jc = OxmlElement('w:jc')
    jc.set(qn('w:val'), {'left': 'start', 'center': 'center', 'justify': 'both'}.get(align, 'start'))
    pPr.append(jc); p.append(pPr)
    r = OxmlElement('w:r')
    rPr = OxmlElement('w:rPr')
    for name in ('w:ascii', 'w:hAnsi'):
        rf = OxmlElement('w:rFonts'); rf.set(qn(name), 'Times New Roman'); rPr.append(rf)
    sz = OxmlElement('w:sz'); sz.set(qn('w:val'), str(size * 2)); rPr.append(sz)
    if bold: b = OxmlElement('w:b'); rPr.append(b)
    if italic: i = OxmlElement('w:i'); rPr.append(i)
    r.append(rPr)
    t = OxmlElement('w:t'); t.set(qn('xml:space'), 'preserve'); t.text = text; r.append(t)
    p.append(r)
    return p

def para_text(e):
    return ''.join(t.text or '' for t in e.findall('.//' + qn('w:t'))).strip()

# ── Titles and interpretations ──
TABLE_TITLES = [
    "Informations clés sur TAG-IP",
    "Services proposés par TAG-IP",
    "Spécifications des composants réseau",
    "Équipements de sécurité réseau",
    "Outils de développement",
    "Composition de l'équipe",
    "Problèmes identifiés et leurs impacts",
    "Analyse détaillée des coûts cachés",
    "Coûts mensuels estimés",
    "Planning des sprints",
    "Entretiens semi-directifs réalisés",
    "Comparaison des solutions de géolocalisation",
    "Comparaison processus manuel vs automatisé",
    "Acteurs du système et leurs droits d'accès",
    "Contraintes techniques du système",
    "Modules fonctionnels de TAG-Monitor",
    "Critères de choix des technologies",
    "Architecture en couches de TAG-Monitor",
    "Cas d'utilisation du système",
    "Planning prévisionnel du projet",
    "Analyse des risques",
    "Tables de la base de données",
    "Tables de jonction",
    "Dictionnaire des données : table mounting_profiles",
    "Dictionnaire des données : table modèles_traceur",
    "Dictionnaire des données : table compatibilities",
    "Couches de l'architecture applicative",
    "Choix technologiques de TAG-Monitor",
    "Grille de scoring détaillée",
    "Composants de l'environnement de développement",
    "Environnement de développement",
    "Stratégie de test adoptée",
    "Récapitulatif des tests fonctionnels",
    "Résultats des tests de performance",
    "Scénarios de tests de charge",
    "Résultats comparatifs avant/après TAG-Monitor",
    "Variables d'environnement de TAG-Monitor",
]

TABLE_INTERPS = [
    "Ce tableau présente les informations clés de la société TAG-IP, leader malgache dans le domaine de la géolocalisation. Il récapitule les données essentielles de l'entreprise, notamment sa localisation, son secteur d'activité et ses coordonnées, afin de planter le décor du projet de stage.",
    "Ce tableau détaille les différents services proposés par TAG-IP, segmentés par type de clientèle. Chaque offre est adaptée aux besoins spécifiques des clients, qu'il s'agisse de particuliers ou de professionnels, couvrant un large éventail de solutions de géolocalisation.",
    "Ce tableau spécifie les composants réseau utilisés par TAG-IP, dimensionnés pour garantir une disponibilité continue 24 heures sur 24 et 7 jours sur 7. Les caractéristiques techniques de chaque composant sont présentées pour assurer la fiabilité et la performance du système d'information.",
    "Ce tableau recense les équipements de sécurité réseau déployés chez TAG-IP. Firewalls, systèmes de détection d'intrusion et autres dispositifs sont listés avec leurs spécifications, garantissant la protection des données et la continuité du service.",
    "Ce tableau présente les outils de développement utilisés par l'équipe technique. L'environnement de développement s'appuie sur PostgreSQL 16 avec l'extension PostGIS pour la gestion des données géospatiales, assurant une base solide pour le développement de l'application.",
    "Ce tableau détaille la composition de l'équipe du pôle Ingénierie Logicielle. L'équipe est constituée de quatre profils complémentaires, chacun apportant son expertise spécifique pour couvrir l'ensemble des besoins du projet.",
    "Ce tableau identifie les principaux problèmes rencontrés dans le système actuel de TAG-IP. Les problèmes d'incompatibilité entre les composants et la dépendance humaine dans les processus de vérification génèrent des surcoûts importants pour l'entreprise.",
    "Ce tableau présente une analyse détaillée des coûts cachés supportés par TAG-IP. Les coûts mensuels cachés, liés aux vérifications manuelles et aux incompatibilités, s'élèvent à plusieurs millions d'Ariary, justifiant ainsi le besoin d'automatisation.",
    "Ce tableau récapitule les coûts mensuels estimés pour l'ensemble des activités de TAG-IP. Le coût mensuel total est estimé à 8 500 000 Ariary, incluant les charges salariales, les infrastructures et les coûts opérationnels.",
    "Ce tableau présente le planning des sprints adopté pour le projet. La méthode agile a été privilégiée avec quatre sprints d'une semaine chacun, permettant une progression itérative et une adaptation continue aux besoins du projet.",
    "Ce tableau récapitule les entretiens semi-directifs réalisés dans le cadre de l'analyse des besoins. Six informateurs clés ont été interrogés, couvrant différents profils et services de l'entreprise pour une collecte exhaustive des exigences.",
    "Ce tableau compare les différentes solutions de géolocalisation disponibles sur le marché. TAG-Monitor se distingue par sa flexibilité et son architecture moderne basée sur Elixir et Phoenix, offrant des avantages significatifs en termes de maintenabilité et d'évolution.",
    "Ce tableau compare les processus manuels et automatisés de vérification de compatibilité. L'automatisation proposée par TAG-Monitor réduit considérablement le temps de vérification, passant de 30 à 45 minutes par lot à seulement 45 millisecondes par couple.",
    "Ce tableau présente les acteurs du système et leurs droits d'accès respectifs. Trois profils d'utilisateurs sont définis, chacun avec des privilèges spécifiques, garantissant une gestion sécurisée et hiérarchisée des accès à l'application.",
    "Ce tableau détaille les contraintes techniques auxquelles le système doit répondre. Les contraintes de performance, de sécurité, de compatibilité et d'évolutivité sont identifiées et analysées pour orienter les choix architecturaux du projet TAG-Monitor.",
    "Ce tableau présente les six modules fonctionnels de TAG-Monitor, de la gestion des profils de montage à l'export des données. Chaque module est décrit avec ses fonctionnalités principales, offrant une vision d'ensemble de l'application à développer.",
    "Ce tableau expose les critères de choix des technologies retenues pour le développement. Ash Framework s'est révélé déterminant pour la productivité de développement, justifiant le choix d'Elixir et Phoenix pour l'implémentation de TAG-Monitor.",
    "Ce tableau illustre l'architecture en couches de TAG-Monitor. L'application suit une architecture à trois couches distinctes : Présentation, Métier et Persistance, assurant une séparation claire des responsabilités et une maintenabilité optimale.",
    "Ce tableau présente les cas d'utilisation du système, couvrant l'ensemble des interactions entre les acteurs et le système. Chaque cas d'utilisation est identifié et décrit pour spécifier les fonctionnalités attendues de TAG-Monitor.",
    "Ce tableau détaille le planning prévisionnel du projet sur huit semaines, du cahier des charges jusqu'aux tests finaux. Les jalons clés et les livrables attendus sont identifiés pour chaque phase du projet.",
    "Ce tableau analyse les risques potentiels du projet et les mesures d'atténuation proposées. Les principaux risques identifiés incluent la courbe d'apprentissage d'Ash Framework et l'instabilité potentielle du périmètre fonctionnel.",
    "Ce tableau présente les tables de la base de données avec leurs structures et leurs relations. L'utilisation d'UUID comme identifiants avec des index composites permet d'optimiser les performances des requêtes sur la base PostgreSQL.",
    "Ce tableau détaille les tables de jonction gérant les relations many-to-many dans la base de données. Ces tables sont essentielles pour modéliser les associations complexes entre les différentes entités du système TAG-Monitor.",
    "Ce tableau présente le dictionnaire des données de la table mounting_profiles. Il décrit en détail les champs, leurs types et leurs contraintes pour la gestion des profils de montage des traceurs GPS.",
    "Ce tableau présente le dictionnaire des données de la table modèles_traceur. Les attributs et les contraintes de validation sont spécifiés pour assurer l'intégrité des données des modèles de traceurs GPS pris en charge.",
    "Ce tableau détaille la table compatibilities qui stocke les résultats des vérifications de compatibilité. Sa structure permet d'enregistrer efficacement les résultats de compatibilité entre chaque profile de montage et modèle de traceur.",
    "Ce tableau présente les différentes couches de l'architecture applicative de TAG-Monitor. L'architecture suit le pattern Phoenix et Ash Framework avec une séparation claire entre les couches de présentation, de logique métier et d'accès aux données.",
    "Ce tableau récapitule les choix technologiques retenus pour TAG-Monitor. Ash Framework a été choisi pour sa flexibilité et son temps de développement réduit, tandis que PostgreSQL avec PostGIS assure la gestion optimale des données géospatiales.",
    "Ce tableau présente la grille de scoring détaillée utilisée pour évaluer les solutions. Le système de notation pondérée attribue 20 vérificateurs répartis en 5 catégories pour un total de 100 points, permettant une évaluation objective et complète.",
    "Ce tableau dresse la liste des composants de l'environnement de développement. La stack technique comprend Elixir 1.18, Phoenix 1.8, Ash Framework 3.4 et PostgreSQL 16, offrant un environnement moderne et performant pour le développement.",
    "Ce tableau décrit l'environnement de développement standardisé mis en place pour le projet. L'environnement est configuré de manière reproductible, garantissant une cohérence entre les postes de développement et facilitant l'intégration continue.",
    "Ce tableau présente la stratégie de test adoptée selon le modèle de la pyramide des tests. La stratégie couvre les tests unitaires, les tests d'intégration et les tests fonctionnels, assurant une couverture complète et une qualité optimale du logiciel.",
    "Ce tableau récapitule les principaux tests fonctionnels réalisés sur TAG-Monitor. Les tests valident dix scénarios critiques couvrant l'ensemble des fonctionnalités clés de l'application, depuis l'authentification jusqu'à la vérification de compatibilité.",
    "Ce tableau présente les résultats des tests de performance effectués sur l'application. Les tests démontrent une compatibilité vérifiée en 45 millisecondes par couple et 420 millisecondes par lot, confirmant l'efficacité de l'automatisation proposée.",
    "Ce tableau détaille les scénarios de tests de charge réalisés pour valider la robustesse du système. La stabilité de l'application a été validée avec 50 utilisateurs concurrents, garantissant des performances acceptables dans des conditions d'utilisation réelles.",
    "Ce tableau compare les résultats avant et après l'implémentation de TAG-Monitor. L'architecture déclarative d'Ash Framework a considérablement réduit le code boilerplate, améliorant la maintenabilité et accélérant les cycles de développement.",
    "Ce tableau présente les variables d'environnement configurées pour TAG-Monitor. Ces variables permettent de gérer les paramètres de déploiement pour les environnements de développement, de test et de production, assurant une configuration flexible et sécurisée.",
]

FIGURE_INTERPS = [
    "Cet organigramme présente la structure hiérarchique simplifiée de TAG-IP. Il permet de visualiser l'organisation de l'entreprise et de situer le poste de stage au sein du pôle Ingénierie Logicielle, facilitant ainsi la compréhension du contexte organisationnel du projet.",
    "Ce schéma illustre l'architecture réseau de TAG-IP ainsi que le cycle de traitement des flux de données. Il montre comment les données de géolocalisation transitent à travers les différents composants du système, depuis la collecte jusqu'à la restitution aux clients.",
    "Ce schéma présente l'architecture globale du système TAG-Monitor, basée sur Ash Framework, Phoenix et PostgreSQL. Il offre une vue d'ensemble des interactions entre les différents composants technologiques et les couches de l'application.",
    "Ce diagramme présente le Modèle Conceptuel de Données (MCD) du système TAG-Monitor. Il modélise les entités principales du système et leurs relations, servant de fondation à la conception de la base de données et à la structuration des données.",
    "Ce diagramme présente le Modèle Logique de Données (MLD) du système TAG-Monitor. Il détaille la structure relationnelle de la base de données avec les tables, les clés primaires et étrangères, ainsi que les contraintes d'intégrité référentielle.",
    "Ce schéma illustre l'architecture en couches de TAG-Monitor, montrant la séparation entre les couches de présentation, de logique métier et de persistance. Cette architecture garantit une maintenance facilitée et une évolutivité du système à long terme.",
    "Cette capture d'écran présente l'interface du formulaire d'authentification de TAG-Monitor. Elle illustre le point d'entrée sécurisé de l'application, conforme aux exigences de sécurité définies dans le cahier des charges.",
    "Cette capture d'écran montre le tableau de bord de la plateforme de gestion des profils de montage. L'interface centralise les fonctionnalités de gestion et offre une vue d'ensemble des profils configurés dans le système.",
    "Cette interface correspond à la première étape de configuration d'un profil de montage, dédiée à l'identification. L'utilisateur peut saisir les informations de base du profil avant de procéder aux étapes de configuration technique.",
    "Cette interface représente la deuxième étape de configuration, consacrée à la sélection des modèles de traceur. L'utilisateur peut choisir parmi les modèles disponibles ceux qui seront associés au profil de montage en cours de configuration.",
    "Cette interface illustre les fonctionnalités de la matrice de compatibilité à l'étape 3 de la configuration. L'utilisateur peut visualiser et configurer les paramètres techniques de compatibilité entre les profils et les modèles de traceurs.",
    "Cette interface présente l'étape finale de vérification de la compatibilité. Le système valide l'ensemble des configurations et affiche les résultats, confirmant ou non la compatibilité entre le profil de montage et les modèles de traceurs sélectionnés.",
]

FIGURE_TITLES = [
    "Organigramme simplifié de TAG-IP",
    "Schéma de l'architecture réseau et cycle de traitement des flux de données",
    "Architecture globale du système TAG-Monitor",
    "Modèle Conceptuel de Données (MCD) du système TAG-Monitor",
    "Modèle Logique de Données (MLD) du système TAG-Monitor",
    "Architecture en couches de TAG-Monitor",
    "Interface du formulaire d'authentification de TAG-Monitor",
    "Tableau de bord de la plateforme de gestion des profils de montage",
    "Interface de configuration initiale du profil (Étape 1 - Identification)",
    "Interface de sélection des modèles de traceur (Étape 2)",
    "Matrice de compatibilité (Étape 3)",
    "Vérification finale de compatibilité (Étape 4)",
]

# Use the same title/interp for extra figures beyond the 12 known ones
GENERIC_FIG_TITLE = "Illustration technique du système TAG-Monitor"
GENERIC_FIG_INTERP = "Cette figure illustre un aspect technique du système TAG-Monitor. Elle permet de visualiser les éléments architecturaux ou fonctionnels décrits dans la section correspondante du document."

# ═══ PHASE 1: Index body elements ──
children = list(body.iterchildren())
info = []  # (type, elem, para_idx_or_None)
pi = ti = 0
for c in children:
    tag = c.tag.split('}')[-1] if '}' in c.tag else c.tag
    if tag == 'p':
        info.append(('p', c, pi))
        pi += 1
    elif tag == 'tbl':
        info.append(('tbl', c, ti))
        ti += 1
    else:
        info.append(('o', c, None))

print(f"Paragraphs: {pi}, Tables: {ti}")

# ═══ PHASE 2: Collect elements to remove ──
# Remove existing Tableau X: body captions and Source lines that are near tables.
# Instead of scanning backward (which misses captions separated by content),
# scan FORWARD: find all "Tableau X:" body paragraphs, then check if a table
# is nearby within the next 10 siblings.
to_remove = set()

for i, (typ, elem, idx) in enumerate(info):
    if typ != 'p':
        continue
    txt = para_text(elem)
    # Look for body captions like "Tableau 1 : Acteurs du système..."
    if not (txt.startswith('Tableau') and ':' in txt and 'non numéroté' not in txt):
        continue

    # Check backward to see if this is a TOC entry (preceded by LISTE DES TABLEAUX)
    cap_is_toc = False
    bwd = elem.getprevious()
    for _ in range(5):
        if bwd is None: break
        if bwd.tag.endswith('}p'):
            pt = para_text(bwd)
            if pt.startswith('LISTE DES TABLEAUX') or pt.startswith('LISTE DES FIGURES') or pt.startswith('SOMMAIRE'):
                cap_is_toc = True; break
            if pt == '': bwd = bwd.getprevious(); continue
            break
        bwd = bwd.getprevious()
    if cap_is_toc:
        continue  # TOC entries stay

    # Scan forward up to 10 siblings for a table
    has_table_near = False
    nxt = elem.getnext()
    for _ in range(10):
        if nxt is None: break
        ntag = nxt.tag.split('}')[-1] if '}' in nxt.tag else nxt.tag
        if ntag == 'tbl':
            has_table_near = True; break
        if ntag == 'p':
            nt = para_text(nxt)
            # Stop at any heading-like or substantial text
            if nt and not nt.startswith(('Figure', 'Source :', 'Interprétation')):
                if any(c.isalpha() for c in nt[:3]):
                    has_table_near = True; break  # this is a caption-like element near a table
        nxt = nxt.getnext()

    if has_table_near:
        to_remove.add(elem)

# Also remove nearby "Source : Auteur, 2026" that are near tables (within 4 siblings)
for i, (typ, elem, idx) in enumerate(info):
    if typ != 'p':
        continue
    txt = para_text(elem)
    if txt != 'Source : Auteur, 2026':
        continue
    # Check forward/backward within 4 siblings for a table
    has_table_near = False
    nxt = elem.getnext()
    for _ in range(4):
        if nxt is None: break
        ntag = nxt.tag.split('}')[-1] if '}' in nxt.tag else nxt.tag
        if ntag == 'tbl': has_table_near = True; break
        nxt = nxt.getnext()
    if not has_table_near:
        prv = elem.getprevious()
        for _ in range(4):
            if prv is None: break
            ntag = prv.tag.split('}')[-1] if '}' in prv.tag else prv.tag
            if ntag == 'tbl': has_table_near = True; break
            prv = prv.getprevious()
    if has_table_near:
        to_remove.add(elem)

# Also remove "Interprétation" lines near tables (wide window)
for i, (typ, elem, idx) in enumerate(info):
    if typ != 'p':
        continue
    txt = para_text(elem)
    if not txt.startswith('Interprétation'):
        continue
    has_table_near = False
    nxt = elem.getnext()
    for _ in range(40):
        if nxt is None: break
        ntag = nxt.tag.split('}')[-1] if '}' in nxt.tag else nxt.tag
        if ntag == 'tbl': has_table_near = True; break
        if ntag == 'p':
            nt = para_text(nxt)
            if nt.startswith(('Figure', 'Chapitre ', 'PARTIE')):
                break
        nxt = nxt.getnext()
    if not has_table_near:
        prv = elem.getprevious()
        for _ in range(40):
            if prv is None: break
            ntag = prv.tag.split('}')[-1] if '}' in prv.tag else prv.tag
            if ntag == 'tbl': has_table_near = True; break
            prv = prv.getprevious()
    if has_table_near:
        to_remove.add(elem)

print(f"Elements to remove: {len(to_remove)}")

# Also handle figures: find existing body "Figure" captions and "Source : Auteur, 2026" near drawings
# Forward scan from each Figure caption — if a drawing is nearby, it's a body caption (not TOC)
fig_elements_remove = set()
figures_info = []  # list of (fig_elem, has_existing_caption, has_existing_source)

drawings = list(body.findall('.//' + W('drawing')))
fig_interp_idx = 0

for i, (typ, elem, idx) in enumerate(info):
    if typ != 'p':
        continue
    txt = para_text(elem)
    if not txt.startswith('Figure'):
        continue

    # Check if TOC (preceded by LISTE DES FIGURES)
    prv = elem.getprevious()
    is_toc = False
    for _ in range(5):
        if prv is None: break
        if prv.tag.endswith('}p'):
            pt = para_text(prv)
            if pt.startswith('LISTE DES FIGURES') or pt.startswith('LISTE DES TABLEAUX') or pt.startswith('SOMMAIRE'):
                is_toc = True; break
            if pt == '': prv = prv.getprevious(); continue
            break
        prv = prv.getprevious()
    if is_toc:
        continue  # Keep TOC

    # Scan forward up to 30 siblings for a drawing
    has_drawing_near = False
    nxt = elem.getnext()
    for _ in range(30):
        if nxt is None: break
        dr = nxt.findall('.//' + W('drawing'))
        if dr:
            has_drawing_near = True; break
        ntag = nxt.tag.split('}')[-1] if '}' in nxt.tag else nxt.tag
        if ntag == 'tbl':
            break  # hit a table, stop
        if ntag == 'p':
            nt = para_text(nxt)
            if nt and nt.startswith(('Tableau', 'Chapitre ', 'PARTIE')):
                break  # hit new section content
        nxt = nxt.getnext()

    if has_drawing_near:
        fig_elements_remove.add(elem)

# Also find "Source : Auteur, 2026" near drawings
for i, (typ, elem, idx) in enumerate(info):
    if typ != 'p':
        continue
    txt = para_text(elem)
    if txt != 'Source : Auteur, 2026':
        continue
    # Check forward/backward within 15 siblings for a drawing
    has_drawing_near = False
    nxt = elem.getnext()
    for _ in range(15):
        if nxt is None: break
        if nxt.findall('.//' + W('drawing')): has_drawing_near = True; break
        nxt = nxt.getnext()
    if not has_drawing_near:
        prv = elem.getprevious()
        for _ in range(15):
            if prv is None: break
            if prv.findall('.//' + W('drawing')): has_drawing_near = True; break
            prv = prv.getprevious()
    if has_drawing_near:
        fig_elements_remove.add(elem)

# Also find "Interprétation" lines near drawings (wide window to catch leftovers from prior runs)
for i, (typ, elem, idx) in enumerate(info):
    if typ != 'p':
        continue
    txt = para_text(elem)
    if not txt.startswith('Interprétation'):
        continue
    # Check forward/backward within 40 siblings for a drawing
    has_drawing_near = False
    nxt = elem.getnext()
    for _ in range(40):
        if nxt is None: break
        if nxt.findall('.//' + W('drawing')): has_drawing_near = True; break
        nxt = nxt.getnext()
    if not has_drawing_near:
        prv = elem.getprevious()
        for _ in range(40):
            if prv is None: break
            if prv.findall('.//' + W('drawing')): has_drawing_near = True; break
            prv = prv.getprevious()
    if has_drawing_near:
        fig_elements_remove.add(elem)

print(f"Figure elements to remove: {len(fig_elements_remove)}")

# ═══ PHASE 3: Remove marked elements ──
all_to_remove = to_remove | fig_elements_remove
for e in all_to_remove:
    try:
        parent = e.getparent()
        if parent is not None:
            parent.remove(e)
    except:
        pass

print(f"Removed {len(all_to_remove)} elements")

# Cleanup pass: after removal, scan for any remaining stale body Figure captions
for e in list(body.iterchildren()):
    if not e.tag.endswith('}p'):
        continue
    txt = para_text(e)
    if not txt.startswith('Figure'):
        continue
    # Check backward for LISTE (TOC)
    prv = e.getprevious()
    is_toc = False
    for _ in range(5):
        if prv is None: break
        if prv.tag.endswith('}p'):
            pt = para_text(prv)
            if pt.startswith('LISTE DES FIGURES') or pt.startswith('LISTE DES TABLEAUX') or pt.startswith('SOMMAIRE'):
                is_toc = True; break
            if pt == '': prv = prv.getprevious(); continue
            break
        prv = prv.getprevious()
    if is_toc:
        continue
    # Check if a drawing is within 30 siblings
    has_drawing = False
    nxt = e.getnext()
    for _ in range(30):
        if nxt is None: break
        if nxt.findall('.//' + W('drawing')):
            has_drawing = True; break
        ntag = nxt.tag.split('}')[-1] if '}' in nxt.tag else nxt.tag
        if ntag == 'tbl':
            break
        nxt = nxt.getnext()
    if not has_drawing:
        e.getparent().remove(e)

# ═══ PHASE 4: Add new captions/sources/interps AFTER each table ──
# Re-index after removal
children2 = list(body.iterchildren())
ti2 = 0
for c in children2:
    tag = c.tag.split('}')[-1] if '}' in c.tag else c.tag
    if tag == 'tbl':
        caption_num = ti2 + 1  # 1-indexed
        title = TABLE_TITLES[ti2] if ti2 < len(TABLE_TITLES) else ""
        interp = TABLE_INTERPS[ti2] if ti2 < len(TABLE_INTERPS) else ""
        
        # addnext inserts AFTER the calling element, each new call pushes previous further away
        # So add in reverse order: interp first (farthest), source middle, title last (closest)
        c.addnext(make_para(f"Interprétation : {interp}", italic=True, size=11, align='justify'))
        c.addnext(make_para("Source : Auteur, 2026", italic=True, size=10))
        c.addnext(make_para(f"Tableau {caption_num} : {title}", bold=True, size=11, align='center'))
        
        ti2 += 1
        if ti2 % 10 == 0:
            print(f"  Processed {ti2}/37 tables")

print(f"Tables: {ti2} captions added after tables")

# ═══ PHASE 5: Add new captions/sources/interps AFTER each figure ──
drawings2 = list(body.findall('.//' + W('drawing')))
fi2 = 0
for d in drawings2:
    p_elem = d.getparent()
    while p_elem is not None and not p_elem.tag.endswith('}p'):
        p_elem = p_elem.getparent()
    if p_elem is None:
        continue
    
    fig_num = fi2 + 1
    
    # Find title and interp for this figure
    title = GENERIC_FIG_TITLE
    interp = GENERIC_FIG_INTERP
    if fi2 < len(FIGURE_TITLES):
        title = FIGURE_TITLES[fi2]
    if fi2 < len(FIGURE_INTERPS):
        interp = FIGURE_INTERPS[fi2]
    
    # addnext inserts AFTER calling element, each new call pushes previous further away
    # So add in reverse order: interp first, source middle, title last (closest to image)
    p_elem.addnext(make_para(f"Interprétation : {interp}", italic=True, size=11, align='justify'))
    p_elem.addnext(make_para("Source : Auteur, 2026", italic=True, size=10))
    p_elem.addnext(make_para(f"Figure {fig_num} : {title}", bold=True, size=11, align='center'))
    
    fi2 += 1

print(f"Figures: {fi2} captions added after images")

# ═══ PHASE 6: Alignment ──
HEADING_RE = re.compile(
    r'^(Chapitre\s+\d|PARTIE\s+|INTRODUCTION|CONCLUSION|'
    r'BIBLIOGRAPHIE|WEBOGRAPHIE|ANNEXES?|SOMMAIRE|RÉSUMÉ|'
    r'ABSTRACT|LISTE DES|REMERCIEMENTS|AVANT-PROPOS|\d+\.\d+|\d+\.)'
)
CODE_PRE = ('defmodule', 'defp', 'def ', 'end', 'use ', 'import ', 'alias ', '|>', 'fn ', 'socket', 'assign(')

j = l = s = 0
for p in doc.paragraphs:
    txt = p.text.strip()
    if not txt: continue
    if HEADING_RE.match(txt): s += 1; continue
    if txt.startswith(('Tableau', 'Figure', 'Source :', 'Interprétation', '[Copie')): s += 1; continue
    if any(txt.startswith(pr) for pr in CODE_PRE):
        p.alignment = WD_ALIGN_PARAGRAPH.LEFT
        for run in p.runs:
            run.font.name = 'Courier New'; run.font.size = Pt(9)
        l += 1; continue
    p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY; j += 1

print(f"Alignment: {j} justified, {l} left, {s} skipped")

# ═══ PHASE 7: Fix paragraph formatting ──
# Merge short fragment paragraphs and convert list items to bullet format
def first_wt(e):
    """Find first w:t child of a w:p element"""
    return e.find('.//' + qn('w:t'))

def last_wt(e):
    """Find last w:t child of a w:p element"""
    ts = e.findall('.//' + qn('w:t'))
    return ts[-1] if ts else None

def set_text(e, new_text):
    """Set text of first w:t in element"""
    t = first_wt(e)
    if t is not None:
        t.text = new_text

def get_text(e):
    return ''.join(t.text or '' for t in e.findall('.//' + qn('w:t')))

def norm(s):
    return s.replace('\u2019', "'").replace('\u2018', "'").replace('\u201c', '"').replace('\u201d', '"')

# --- Merge groups (join consecutive paragraphs) ---
MERGE_GROUPS = [
    ("Design system :", "Le design system applique"),
    ("Scalabilité horizontale :", "L'architecture Elixir"),
]

for lead_text, follow_text in MERGE_GROUPS:
    norm_lead = norm(lead_text)
    norm_follow = norm(follow_text)
    for c in list(body.iterchildren()):
        if not c.tag.endswith('}p'):
            continue
        txt = get_text(c).strip()
        norm_txt = norm(txt)
        if norm_txt == norm_lead:
            nxt = c.getnext()
            if nxt is not None and nxt.tag.endswith('}p'):
                ntxt = get_text(nxt).strip()
                norm_ntxt = norm(ntxt)
                if norm_ntxt.startswith(norm_follow):
                    # Merge nxt into c
                    last_t = last_wt(c)
                    first_t = first_wt(nxt)
                    if last_t is not None and first_t is not None:
                        last_t.text = (last_t.text or '') + ' ' + (first_t.text or '')
                        first_t.text = ''
                        # Copy remaining runs from nxt to c
                        for run_elem in list(nxt.findall(qn('w:r')))[1:]:
                            c.append(run_elem)
                    body.remove(nxt)
                    print(f"  Merged: \"{lead_text}\" + \"{follow_text}...\"")

# --- Bullet list groups (prepend "• " to each item) ---
BULLET_GROUPS = [
    # Group 6: Avantages sécurité (items only)
    ["Centralisation : toutes les règles de sécurité sont définies dans un endroit unique"],
    # Group 7
    ["Testable : les politiques peuvent être testés", "Auditable : la liste des politiques"],
    # Group 8: Ash + LiveView (items only)
    ["Chargement : les données sont chargées", "Streams : les listes sont gérées", 
     "Événements : les actions utilisateur", "Notifications : les flashes informent",
     "Réactivité : PubSub permet la mise à jour"],
    # Group 9: PubSub (items only)
    ["Souscription : à la connexion", "Publication : lorsqu'un événement modifie",
     "Réception : le LiveView reçoit"],
    # Group 10: Avantages (items only)
    ["Faible latence : les mises à jour sont quasi-instantanées",
     "Efficacité : pas de requêtes superflues",
     "Scalabilité : le mécanisme PubSub de Phoenix",
     "Simplicité : pas besoin de bibliothèque"],
    # Group 11
    ["Politiques (Policies) : regles de securite", "Couche persistance :",
     "AshPostgres lie Ash Framework a PostgreSQL"],
    # Group 12
    ["Modularité : chaque vérification peut être développe",
     "Extensibilité : de nouveaux critères peuvent être ajoutés",
     "Testabilité : chaque vérification est testable"],
    # Group 13: Sécurité
    ["Inscription et connexion sécurisées : formulaire",
     "Magic links : connexion par mail sécurisé",
     "Confirmation d'email : vérification de l'adresse",
     "Gestion de session : cookies signes, expiration automatique"],
    # Group 14: Traceurs
    ["Systech : A1 (2G), U1 (2G), COBAN (4G)",
     "Wonder Proud : VT (plusieurs variantes)",
     "Fintech : JT (plusieurs variantes)"],
    # Group 15: Catalogue (items only)
    ["Liste paginée avec recherche instantanée par nom",
     "Filtres multicritères : filtres Ash",
     "Fiche détaillé présentant l'ensemble",
     "Formulaire de création/édition avec validation",
     "Code couleur des scores de compatibilité"],
    # Group 17: Design system (items only)
    ["Typographie : système sans-serif",
     "Grille : système de 4px pour la cohérence",
     "Micro-interactions : transitions douces",
     "Responsive : adaptation automatique aux écrans",
     "Accessibilité : contrastes suffisants"],
    # Group 20: Résultats (items only)
    ["Base de données unique interrogeable.",
     "Automatisation du diagnostic : Moteur 20 critères",
     "Temps réduit de 40 min à 45 cm.",
     "Décentralisation des règles : Interface admin intuitive",
     "Autonomie des techniciens."],
    # Group 22: Pipeline CI/CD (items only)
    ["Build : compilation des dépendances",
     "Tests : exécution de la suite de tests",
     "Lint : vérification du formatage",
     "Release : génération du binaire autonome",
     "Déploiement : transfert vers le serveur",
     "Validation : vérification du bon fonctionnement"],
    # Group 24: Configuration
    ["Logger : logs structures en JSON",
     "Health check : endpoint /health",
     "Télémétrie : instrumentation via",
     "Backup : sauvegarde automatique"],
]

bullet_count = 0
for group in BULLET_GROUPS:
    for item_text in group:
        norm_item = norm(item_text)
        for c in list(body.iterchildren()):
            if not c.tag.endswith('}p'):
                continue
            txt = get_text(c).strip()
            if txt.startswith('•'):
                continue
            norm_txt = norm(txt)
            if norm_txt.startswith(norm_item):
                ft = first_wt(c)
                if ft is not None:
                    ft.text = '• ' + (ft.text or '')
                    bullet_count += 1
                break

print(f"Bullet formatting: {bullet_count} items, {len(MERGE_GROUPS)} merges")

doc.save(OUT)
print(f"\n✅ {OUT}")
