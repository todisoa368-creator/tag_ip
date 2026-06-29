#!/usr/bin/env python3
"""
Fix the CORRIGE DOCX: justify text, add table/figure titles, sources, interpretations.
"""

from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
import re, copy

src_path = "/Users/fitahiana/Desktop/FITAHIANJANAHARY TODISOA CHRISTINE CORRIGE (1).docx"
out_path = "/Users/fitahiana/Desktop/FITAHIANJANAHARY TODISOA CHRISTINE FINAL.docx"

doc = Document(src_path)

# ---- Table/figure identification ----
# Tables in the original that need "Tableau X:" captions (indexed by first cell content)
TABLE_TITLES = {
    "Champ": "Informations clés sur TAG-IP",
    "Service": "Services proposés par TAG-IP",
    "Composant": "Spécifications des composants réseau",
    "Equipement": "Équipements de sécurité réseau",
    "Outil": "Outils de développement",
    "Rôle": "Composition de l'équipe",
    "Problème": "Problèmes identifiés et leurs impacts",
    "Type de coût": "Analyse détaillée des coûts cachés",
    "Poste de coût": "Coûts mensuels estimés",
    "Sprint": "Planning des sprints",
    "Informateur": "Entretiens semi-directifs réalisés",
    "Critère": "Comparaison des solutions de géolocalisation",
    "Aspect": "Comparaison processus manuel vs automatisé",
    "Acteur": "Acteurs du système et droits d'accès",
    "Type": "Contraintes techniques",
    "Module": "Modules fonctionnels de TAG-Monitor",
    "Couche": "Architecture en couches",
    "ID": "Cas d'utilisation du système",
    "Semaine": "Planning prévisionnel",
    "Risque": "Analyse des risques",
    "Table": "Tables de la base de données",
    "Table de jonction": "Tables de jonction",
    "Catégorie": "Grille de scoring détaillée",
    "Niveau de test": "Stratégie de test",
    "Opération": "Résultats des tests de performance",
    "Scénario": "Scénarios de tests de charge",
    "Variable": "Variables d'environnement",
}

TABLE_INTERPS = {
    "Informations clés sur TAG-IP": "Ce tableau présente les informations générales et les services de la société TAG-IP, leader malgache de la géolocalisation.",
    "Services proposés par TAG-IP": "Les différents services de TAG-IP sont segmentés par clientèle (entreprises, particuliers, assurances) avec des offres adaptées.",
    "Spécifications des composants réseau": "Les composants réseau sont dimensionnés pour assurer une disponibilité 24/7 et le traitement en temps réel des données de géolocalisation.",
    "Équipements de sécurité réseau": "Les équipements de sécurité garantissent la protection du réseau et la continuité du service de suivi des 10 000 véhicules.",
    "Outils de développement": "L'environnement de développement utilise des outils standards avec PostgreSQL 16 et l'extension PostGIS pour les opérations géospatiales.",
    "Composition de l'équipe": "L'équipe du pôle Ingénierie Logicielle est structurée avec un responsable, un développeur senior, un stagiaire et deux techniciens.",
    "Problèmes identifiés et leurs impacts": "Les problèmes recensés incluent l'incompatibilité matérielle, le hard-coding des règles et la dépendance humaine, générant des surcoûts significatifs.",
    "Analyse détaillée des coûts cachés": "Les coûts mensuels cachés (déplacements inutiles, matériel endommagé, heures supplémentaires) s'élèvent à plusieurs millions d'Ariary.",
    "Coûts mensuels estimés": "Le coût mensuel total estimé à 8 500 000 Ar justifie l'investissement dans une solution automatisée de diagnostic de compatibilité.",
    "Planning des sprints": "Le projet a été organisé en quatre sprints d'une semaine selon la méthodologie agile, de l'immersion à l'intégration.",
    "Entretiens semi-directifs réalisés": "Six informateurs clés (direction, exploitation, terrain) ont été interrogés pour recueillir les besoins et les contraintes.",
    "Comparaison des solutions de géolocalisation": "TAG-Monitor se distingue par sa flexibilité et son approche sur mesure par rapport aux solutions existantes du marché.",
    "Comparaison processus manuel vs automatisé": "L'automatisation avec TAG-Monitor réduit le temps de diagnostic de 30-45 minutes à 45 ms et élimine les erreurs humaines.",
    "Acteurs du système et droits d'accès": "Trois profils d'utilisateurs (administrateur, technicien exploitation, technicien terrain) ont des niveaux d'accès distincts.",
    "Contraintes techniques": "Les contraintes techniques couvrent la performance, la sécurité, la compatibilité et l'évolutivité du système.",
    "Modules fonctionnels de TAG-Monitor": "Les six modules fonctionnels couvrent l'ensemble du périmètre, de la gestion des profils à l'export de données.",
    "Architecture en couches": "L'architecture à trois couches (Présentation, Métier, Persistance) assure une séparation claire des responsabilités.",
    "Cas d'utilisation du système": "Les six cas d'utilisation identifiés couvrent les interactions entre les acteurs et le système TAG-Monitor.",
    "Planning prévisionnel": "Le planning prévisionnel s'étend sur 8 semaines avec des jalons clés : cahier des charges, MCD/MLD, développement et tests.",
    "Analyse des risques": "Les principaux risques identifiés incluent la courbe d'apprentissage Ash Framework et l'instabilité du périmètre.",
    "Tables de la base de données": "La base de données utilise des UUID comme clés primaires avec des index composites pour optimiser les requêtes.",
    "Tables de jonction": "Les tables de jonction gèrent les relations many-to-many entre profils, modèles et leurs associations.",
    "Grille de scoring détaillée": "Le scoring pondéré sur 100 points répartit 20 vérificateurs en 5 catégories : tension, bus, E/S, environnement et capteurs.",
    "Stratégie de test": "La stratégie de test pyramide couvre les tests unitaires, d'intégration et fonctionnels avec plus de 145 cas de test.",
    "Choix technologiques de TAG-Monitor": "Le comparatif montre qu'Ash Framework offre la meilleure flexibilité et un temps de développement réduit.",
    "Environnement de développement": "L'environnement de développement utilise une stack Elixir 1.18, Phoenix 1.8, Ash 3.4 avec PostgreSQL 16.",
    "Résultats des tests de performance": "Les tests montrent que le calcul de compatibilité s'effectue en 45 ms (couple) et 420 ms (batch), dépassant les objectifs.",
    "Scénarios de tests de charge": "Les tests de charge confirment la stabilité du système avec 50 utilisateurs concurrents et des calculs batch simultanés.",
    "Variables d'environnement": "Les variables d'environnement centralisent la configuration du système pour les déploiements Docker multi-environnements.",
}

FIGURES = [
    (46, "Organisation du code source du projet", "Ce code illustre la structure des répertoires du projet conforme aux conventions Phoenix."),
    (47, "Exemple de politiques Ash pour la ressource ProfilMontage", "Cet exemple montre la déclaration des politiques de sécurité au niveau de la ressource Ash."),
    (48, "Vue du tableau de bord avec cartes statistiques", "Le dashboard présente les indicateurs clés sous forme de cartes Bento avec code couleur."),
    (49, "Architecture PubSub de Phoenix", "Le mécanisme PubSub assure les mises à jour en temps réel sans polling HTTP."),
    (53, "Définition d'une ressource Ash (ModèleTraceur)", "La définition déclarative des ressources Ash unifie schéma, relations et contraintes."),
    (57, "Implémentation de l'assistant multi-étapes (wizard)", "L'assistant guide l'utilisateur à travers 4 étapes avec validation progressive."),
    (64, "Composants d'interface réutilisables", "Les composants réutilisables suivent un design system cohérent avec micro-interactions."),
    (66, "Exemple de test unitaire pour le vérificateur de tension", "Chaque vérificateur du moteur de compatibilité est testé avec trois scénarios."),
    (67, "Exemple de test fonctionnel LiveView", "Les tests automatisés via Phoenix.LiveViewTest couvrent les parcours utilisateur."),
]

# ---- Phase 1: Fix paragraph alignment ----
# Headings and captions should stay as-is; body text should be justified
heading_pattern = re.compile(r'^(Chapitre\s+\d|PARTIE\s+|INTRODUCTION|CONCLUSION|BIBLIOGRAPHIE|WEBOGRAPHIE|ANNEXES?|SOMMAIRE|RÉSUMÉ|ABSTRACT|LISTE DES|REMERCIEMENTS|AVANT-PROPOS|\d+\.\d+)')

for p in doc.paragraphs:
    txt = p.text.strip()
    if not txt:
        continue
    
    # Don't change alignment of headings, table captions, figure captions, source lines
    if heading_pattern.match(txt):
        continue
    if txt.startswith('Tableau') or txt.startswith('Figure'):
        continue
    if txt.startswith('Source :'):
        continue
    if txt.startswith('Interprétation'):
        continue
    if txt.startswith('Tableau (non numéroté)'):
        continue
    if txt.startswith('[Copie'):
        continue
    
    # Code-like content: left-align
    code_keywords = ['defmodule', 'defp', 'def ', 'end', 'use ', 'import ', 'alias ', '|>', 'fn ', 'socket', 'assign(']
    is_code = any(txt.startswith(k) for k in code_keywords)
    if is_code:
        p.alignment = WD_ALIGN_PARAGRAPH.LEFT
        for run in p.runs:
            run.font.name = 'Courier New'
            run.font.size = Pt(9)
    else:
        # Justify regular text
        if p.alignment is None or p.alignment != WD_ALIGN_PARAGRAPH.JUSTIFY:
            p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY

# ---- Phase 2: Add table titles, sources, interpretations ----
# Find tables that lack proper captions
# We'll track which table numbers have been used
next_tableau_num = 1

for ti, table in enumerate(doc.tables):
    # Get first cell text to identify the table
    first_cell = ""
    for row in table.rows:
        for cell in row.cells:
            if cell.text.strip():
                first_cell = cell.text.strip()
                break
        if first_cell: break
    
    # Determine if this table already has a caption
    # We need to find the table's position
    # python-docx doesn't directly give position, but we can search paragraphs before
    
    # Determine title and interpretation
    title = TABLE_TITLES.get(first_cell)
    if not title:
        # Try to match by checking if any TABLE_TITLES key is in the first cell
        for key, val in TABLE_TITLES.items():
            if key.lower() in first_cell.lower():
                title = val
                break
    
    if title:
        interp = TABLE_INTERPS.get(title, "")
        # Add a caption paragraph before the table
        # We need to insert before the table - use the table's XML element
        tbl_elem = table._tbl
        parent = tbl_elem.getparent()
        
        # Check if there's already a Tableau caption before this table
        has_existing_caption = False
        prev = tbl_elem.getprevious()
        while prev is not None:
            # Check if previous element is a paragraph with Tableau caption
            if prev.tag.endswith('}p'):
                # Get text from paragraph
                texts = prev.findall('.//' + qn('w:t'))
                p_text = ''.join(t.text or '' for t in texts)
                if p_text.strip().startswith('Tableau'):
                    has_existing_caption = True
                    break
                elif p_text.strip().startswith('Tableau (non numéroté)'):
                    has_existing_caption = True
                    break
                elif p_text.strip() == '':
                    prev = prev.getprevious()
                    continue
                else:
                    break
            elif prev.tag.endswith('}tbl'):
                break
            else:
                break
        
        if not has_existing_caption:
            # Insert "Tableau (non numéroté)" caption
            from docx.oxml import OxmlElement
            from docx.shared import Pt
            from lxml import etree
            
            def make_para(text, bold=False, size=11, align='left', italic=False):
                p_elem = OxmlElement('w:p')
                pPr = OxmlElement('w:pPr')
                jc = OxmlElement('w:jc')
                jc.set(qn('w:val'), {'left': 'start', 'center': 'center', 'justify': 'both'}[align])
                pPr.append(jc)
                p_elem.append(pPr)
                r_elem = OxmlElement('w:r')
                rPr = OxmlElement('w:rPr')
                rFonts = OxmlElement('w:rFonts')
                rFonts.set(qn('w:ascii'), 'Times New Roman')
                rFonts.set(qn('w:hAnsi'), 'Times New Roman')
                rPr.append(rFonts)
                sz = OxmlElement('w:sz')
                sz.set(qn('w:val'), str(size * 2))
                rPr.append(sz)
                if bold:
                    b_elem = OxmlElement('w:b')
                    rPr.append(b_elem)
                if italic:
                    i_elem = OxmlElement('w:i')
                    rPr.append(i_elem)
                r_elem.append(rPr)
                t_elem = OxmlElement('w:t')
                t_elem.set(qn('xml:space'), 'preserve')
                t_elem.text = text
                r_elem.append(t_elem)
                p_elem.append(r_elem)
                return p_elem
            
            # Insert caption
            cap_para = make_para(f"Tableau (non numéroté) : {title}", bold=True)
            parent.insert(list(parent).index(tbl_elem), cap_para)
            
            # Check if Source exists nearby
            has_source = False
            prev = tbl_elem.getprevious()
            while prev is not None:
                if prev.tag.endswith('}p'):
                    texts = prev.findall('.//' + qn('w:t'))
                    p_text = ''.join(t.text or '' for t in texts)
                    if p_text.strip().startswith('Source :'):
                        has_source = True
                        break
                    elif p_text.strip() == '':
                        prev = prev.getprevious()
                        continue
                    else:
                        break
                elif prev.tag.endswith('}tbl'):
                    break
                else:
                    break
            
            if not has_source:
                src_para = make_para("Source : Auteur, 2026", italic=True, size=10)
                # Insert after table caption but before table
                # Actually insert after the last inserted element
                parent.insert(list(parent).index(tbl_elem), src_para)
            
            # Add interpretation after table
            if interp:
                interp_para = make_para(f"Interprétation : {interp}", italic=True, size=11)
                # Insert after the table
                parent.insert(list(parent).index(tbl_elem) + 1, interp_para)
            
            print(f"  Added '{title}' + source + interp")
        else:
            # Caption exists, check for interpretation
            has_interp = False
            nxt = tbl_elem.getnext()
            while nxt is not None:
                if nxt.tag.endswith('}p'):
                    texts = nxt.findall('.//' + qn('w:t'))
                    p_text = ''.join(t.text or '' for t in texts)
                    if 'Interprétation' in p_text:
                        has_interp = True
                        break
                    elif p_text.strip() == '':
                        nxt = nxt.getnext()
                        continue
                    else:
                        break
                elif nxt.tag.endswith('}tbl'):
                    break
                else:
                    break
            
            if not has_interp and interp:
                from docx.oxml import OxmlElement
                def make_para(text, bold=False, size=11, align='left', italic=False):
                    p_elem = OxmlElement('w:p')
                    pPr = OxmlElement('w:pPr')
                    jc = OxmlElement('w:jc')
                    jc.set(qn('w:val'), 'start')
                    pPr.append(jc)
                    p_elem.append(pPr)
                    r_elem = OxmlElement('w:r')
                    rPr = OxmlElement('w:rPr')
                    rFonts = OxmlElement('w:rFonts')
                    rFonts.set(qn('w:ascii'), 'Times New Roman')
                    rFonts.set(qn('w:hAnsi'), 'Times New Roman')
                    rPr.append(rFonts)
                    sz = OxmlElement('w:sz')
                    sz.set(qn('w:val'), str(size * 2))
                    rPr.append(sz)
                    if bold:
                        b_elem = OxmlElement('w:b'); rPr.append(b_elem)
                    if italic:
                        i_elem = OxmlElement('w:i'); rPr.append(i_elem)
                    r_elem.append(rPr)
                    t_elem = OxmlElement('w:t')
                    t_elem.set(qn('xml:space'), 'preserve')
                    t_elem.text = text
                    r_elem.append(t_elem)
                    p_elem.append(r_elem)
                    return p_elem
                interp_para = make_para(f"Interprétation : {interp}", italic=True, size=11)
                parent.insert(list(parent).index(tbl_elem) + 1, interp_para)
                print(f"  Added interpretation for '{title}'")

# ---- Phase 3: Handle figures ----
# Check which figures have captions and add for those that don't
# We look for images in the document, but python-docx doesn't give easy access
# to inline images. We'll check for paragraphs that look like figure placeholders.

# Look for images in the XML
nsmap = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
         'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
         'wp': 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',
         'a': 'http://schemas.openxmlformats.org/drawingml/2006/main',
         'pic': 'http://schemas.openxmlformats.org/drawingml/2006/picture'}

body = doc.element.body
drawings = body.findall('.//w:drawing', nsmap) if hasattr(body, 'findall') else []

print(f"\nFound {len(drawings)} images in document")

# For each image, check if there's a Figure caption nearby
drawing_index = 0
for elem in body.iter():
    if elem.tag.endswith('}drawing'):
        drawing_index += 1
        # Find the paragraph containing this drawing
        parent = elem.getparent()
        while parent is not None and not parent.tag.endswith('}p'):
            parent = parent.getparent()
        
        if parent is not None:
            # Check if there's a Figure caption before this paragraph
            has_fig_caption = False
            has_source = False
            has_interp = False
            
            prev = parent.getprevious()
            while prev is not None:
                if prev.tag.endswith('}p'):
                    texts = prev.findall('.//' + qn('w:t'))
                    p_text = ''.join(t.text or '' for t in texts).strip()
                    if p_text.startswith('Figure'):
                        has_fig_caption = True
                        break
                    elif p_text.startswith('Source :'):
                        has_source = True
                        prev = prev.getprevious()
                        continue
                    elif p_text == '':
                        prev = prev.getprevious()
                        continue
                    else:
                        break
                elif prev.tag.endswith('}tbl'):
                    break
                else:
                    break

doc.save(out_path)
print(f"\nDONE: {out_path}")
