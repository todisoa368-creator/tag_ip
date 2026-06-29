#!/usr/bin/env python3
"""
Fix the CORRIGE DOCX properly:
1. Justify body text (except headings, code, captions)
2. Add titles/sources/interpretations to unnamed tables
3. Add sources/interpretations to numbered tableaux
4. Add titles/sources/interpretations to figures
"""

from docx import Document
from docx.shared import Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from lxml import etree
import re

SRC = "/Users/fitahiana/Desktop/FITAHIANJANAHARY TODISOA CHRISTINE CORRIGE (1).docx"
OUT = "/Users/fitahiana/Desktop/FITAHIANJANAHARY TODISOA CHRISTINE FINAL.docx"

doc = Document(SRC)
body = doc.element.body

NSMAP = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
         'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
         'wp': 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',
         'a': 'http://schemas.openxmlformats.org/drawingml/2006/main',
         'pic': 'http://schemas.openxmlformats.org/drawingml/2006/picture'}

# ── Known numbered tableaux captions (paragraph body index) ──
KNOWN_TABLEAU_BODY_PARAS = {342, 347, 352, 357, 380, 383, 568, 644, 709, 840, 856, 861, 873, 931}

# ── Unnamed table titles & interps (by sequential table index 0-36) ──
UNNAMED_TABLE_DATA = {
    0:  ("Informations clés sur TAG-IP",
         "Ce tableau présente les informations générales de la société TAG-IP, leader malgache de la géolocalisation."),
    1:  ("Services proposés par TAG-IP",
         "Les services de TAG-IP sont segmentés par clientèle (entreprises, particuliers, assurances) avec des offres adaptées."),
    2:  ("Spécifications des composants réseau",
         "Les composants réseau sont dimensionnés pour la disponibilité 24/7 et le traitement temps réel des données de géolocalisation."),
    3:  ("Équipements de sécurité réseau",
         "Les équipements de sécurité garantissent la protection du réseau et la continuité du service pour 10 000 véhicules."),
    4:  ("Outils de développement",
         "L'environnement de développement utilise PostgreSQL 16 avec PostGIS pour les opérations géospatiales."),
    5:  ("Composition de l'équipe",
         "L'équipe du pôle Ingénierie Logicielle comprend un responsable, un développeur senior, un stagiaire et deux techniciens."),
    6:  ("Problèmes identifiés et leurs impacts",
         "Les problèmes incluent l'incompatibilité matérielle et la dépendance humaine, générant des surcoûts significatifs."),
    7:  ("Analyse détaillée des coûts cachés",
         "Les coûts mensuels cachés (déplacements inutiles, matériel endommagé, heures supplémentaires) s'élèvent à plusieurs millions d'Ariary."),
    8:  ("Coûts mensuels estimés",
         "Le coût mensuel total estimé à 8 500 000 Ar justifie l'investissement dans une solution automatisée."),
    9:  ("Planning des sprints",
         "Le projet a été organisé en quatre sprints d'une semaine selon la méthodologie agile."),
    10: ("Entretiens semi-directifs réalisés",
         "Six informateurs clés ont été interrogés pour recueillir les besoins et contraintes du système."),
    11: ("Comparaison des solutions de géolocalisation",
         "TAG-Monitor se distingue par sa flexibilité et son approche sur mesure comparé aux solutions existantes."),
    12: ("Comparaison processus manuel vs automatisé",
         "L'automatisation réduit le temps de diagnostic de 30-45 min à 45 ms et élimine les erreurs humaines."),
    # 13=Tableau 1 (skip)
    # 14=Tableau 2 (skip)
    # 15=Tableau 3 (skip)
    # 16=Tableau 4 (skip)
    17: ("Architecture en couches de TAG-Monitor",
         "L'architecture à trois couches (Présentation, Métier, Persistance) assure une séparation claire des responsabilités."),
    18: ("Cas d'utilisation du système",
         "Les six cas d'utilisation couvrent les interactions entre les acteurs et le système TAG-Monitor."),
    # 19=Tableau 5 (skip)
    # 20=Tableau 6 (skip)
    21: ("Tables de la base de données",
         "La base de données utilise des UUID comme clés primaires avec des index composites pour optimiser les requêtes."),
    22: ("Tables de jonction",
         "Les tables de jonction gèrent les relations many-to-many entre profils, modèles et associations."),
    23: ("Dictionnaire des données : table mounting_profiles",
         "La table mounting_profiles stocke les profils de montage avec leurs caractéristiques techniques."),
    24: ("Dictionnaire des données : table modèles_traceur",
         "La table modèles_traceur référence les modèles de traceurs GPS avec leurs spécifications."),
    25: ("Dictionnaire des données : table compatibilities",
         "La table compatibilities enregistre les résultats des vérifications de compatibilité par profil et modèle."),
    26: ("Couches de l'architecture applicative",
         "Les couches applicatives détaillent l'organisation du code selon le pattern Phoenix/Ash."),
    # 27=Tableau 7 (skip)
    # 28=Tableau 8 (skip)
    29: ("Composants de l'environnement de développement",
         "L'environnement de développement utilise une stack Elixir 1.18, Phoenix 1.8, Ash 3.4 avec PostgreSQL 16."),
    # 30=Tableau 9 (skip)
    # 31=Tableau 10 (skip)
    # 32=Tableau 11 (skip)
    # 33=Tableau 12 (skip)
    # 34=Tableau 13 (skip)
    35: ("Résultats comparatifs avant/après TAG-Monitor",
         "L'architecture déclarative Ash Framework réduit le code boilerplate et accélère le développement."),
    # 36=Tableau 14 (skip)
}

def make_para_elem(text, bold=False, italic=False, size=11, align='left', font='Times New Roman'):
    """Create a w:p element with desired formatting."""
    p = OxmlElement('w:p')
    pPr = OxmlElement('w:pPr')
    jc = OxmlElement('w:jc')
    val_map = {'left': 'start', 'center': 'center', 'justify': 'both'}
    jc.set(qn('w:val'), val_map.get(align, 'start'))
    pPr.append(jc)
    p.append(pPr)
    r = OxmlElement('w:r')
    rPr = OxmlElement('w:rPr')
    rFonts = OxmlElement('w:rFonts')
    rFonts.set(qn('w:ascii'), font)
    rFonts.set(qn('w:hAnsi'), font)
    rPr.append(rFonts)
    sz = OxmlElement('w:sz')
    sz.set(qn('w:val'), str(size * 2))
    rPr.append(sz)
    if bold:
        b = OxmlElement('w:b'); rPr.append(b)
    if italic:
        i = OxmlElement('w:i'); rPr.append(i)
    r.append(rPr)
    t = OxmlElement('w:t')
    t.set(qn('xml:space'), 'preserve')
    t.text = text
    r.append(t)
    p.append(r)
    return p

def get_paragraph_text(p_elem):
    texts = p_elem.findall('.//' + qn('w:t'))
    return ''.join(t.text or '' for t in texts).strip()

# ═══ PHASE 0: Build sequential body element index ═══
children = list(body.iterchildren())
elem_types = []  # list of (element, type, body_pidx or table_idx or -1)

# For tracking: maps table_idx -> list of "Tableau X:" caption body_pidx found before it
body_para_idx = 0
table_idx = 0
drawing_count = 0

# First pass: build type index
for child in children:
    tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
    if tag == 'p':
        elem_types.append(('p', child, body_para_idx, None))
        body_para_idx += 1
    elif tag == 'tbl':
        elem_types.append(('tbl', child, None, table_idx))
        table_idx += 1
    else:
        # Check for drawings inside any element
        elem_types.append(('other', child, None, None))

print(f"Total paragraphs: {body_para_idx}, Total tables: {table_idx}")

# ═══ PHASE 1: Insert missing table captions/sources/interpretations ═══
# For each table, find nearest preceding "Tableau X:" in body paragraphs
# and also check if source already exists

TAB_ADDED_LABEL = 0
TAB_ADDED_SRC = 0
TAB_ADDED_INTERP = 0

for i, (typ, elem, pidx, tidx) in enumerate(elem_types):
    if typ != 'tbl' or tidx is None:
        continue
    
    # Find the last "Tableau X:" caption paragraph before this table
    # Search backwards from current position
    last_tableau_caption = None
    last_tableau_caption_idx = None
    has_source_before = False
    has_interp_after = False
    
    # Check earlier elements for caption and source
    for j in range(i - 1, -1, -1):
        t2, e2, p2, _ = elem_types[j]
        if t2 == 'p':
            txt = get_paragraph_text(e2)
            if txt.startswith('Tableau'):
                last_tableau_caption = txt
                last_tableau_caption_idx = p2
                break
            elif txt.startswith('Source :'):
                has_source_before = True
            elif txt == '':
                continue
        elif t2 == 'tbl':
            # Previous table — stop here
            break
    
    # Is this a numbered tableau?
    is_numbered = last_tableau_caption_idx in KNOWN_TABLEAU_BODY_PARAS
    
    # Check for interpretation after table
    for j in range(i + 1, min(i + 6, len(elem_types))):
        t2, e2, _, _ = elem_types[j]
        if t2 == 'p':
            txt = get_paragraph_text(e2)
            if 'Interprétation' in txt:
                has_interp_after = True
                break
            elif txt.startswith('Figure') or txt.startswith('Tableau') or txt.startswith('Source :'):
                continue
            elif txt == '':
                continue
            else:
                break
        elif t2 == 'tbl':
            break
    
    if is_numbered:
        # Numbered table: only add source and/or interpretation if missing
        if not has_source_before:
            src_para = make_para_elem("Source : Auteur, 2026", italic=True, size=10)
            elem.addprevious(src_para)
            TAB_ADDED_SRC += 1
            print(f"  Table {tidx} (numbered, caption: {last_tableau_caption[:50]}): added source")
        if not has_interp_after:
            table_data = UNNAMED_TABLE_DATA.get(tidx)
            if table_data:
                interp_text = f"Interprétation : {table_data[1]}"
                interp_para = make_para_elem(interp_text, italic=True, size=11, align='left')
                elem.addnext(interp_para)
                TAB_ADDED_INTERP += 1
                print(f"  Table {tidx} (numbered): added interp")
    else:
        # Unnumbered table: add label + source + interpretation
        table_data = UNNAMED_TABLE_DATA.get(tidx)
        if table_data:
            title, interp_text = table_data
            
            # Add caption label
            cap_para = make_para_elem(f"Tableau (non numéroté) : {title}", bold=True, size=11, align='center')
            elem.addprevious(cap_para)
            TAB_ADDED_LABEL += 1
            
            # Add source (always for unnamed tables)
            src_para = make_para_elem("Source : Auteur, 2026", italic=True, size=10, align='left')
            elem.addprevious(src_para)
            TAB_ADDED_SRC += 1
            
            # Add interpretation
            interp_full = f"Interprétation : {interp_text}"
            interp_para = make_para_elem(interp_full, italic=True, size=11, align='justify')
            elem.addnext(interp_para)
            TAB_ADDED_INTERP += 1
            
            print(f"  Table {tidx} (unnamed): '{title}' + source + interp")
        else:
            # No specific data, use generic
            cap_para = make_para_elem("Tableau (non numéroté)", bold=True, size=11, align='center')
            elem.addprevious(cap_para)
            src_para = make_para_elem("Source : Auteur, 2026", italic=True, size=10)
            elem.addprevious(src_para)
            interp_para = make_para_elem("Interprétation : Ce tableau présente les données du système.", italic=True, size=11)
            elem.addnext(interp_para)
            print(f"  Table {tidx} (unnamed): generic labels")

print(f"\nTable summary: +{TAB_ADDED_LABEL} labels, +{TAB_ADDED_SRC} sources, +{TAB_ADDED_INTERP} interps")

# ═══ PHASE 2: Handle figures ═══
print(f"\n--- Figures ---")

# Re-build children list after table modifications
children = list(body.iterchildren())

drawing_count = 0
fig_label_added = 0
fig_src_added = 0
fig_interp_added = 0

for child in children:
    # Find all drawing elements
    drawings = child.findall('.//' + qn('w:drawing'), NSMAP) if hasattr(child, 'findall') else []
    if not drawings:
        drawings = child.findall('.//' + qn('w:drawing'))
    if not drawings:
        continue
    
    for drawing in drawings:
        drawing_count += 1
        
        # Find the containing paragraph
        p_elem = drawing.getparent()
        while p_elem is not None and not p_elem.tag.endswith('}p'):
            p_elem = p_elem.getparent()
        
        if p_elem is None:
            continue
        
        # Check if there's a "Figure X:" caption before this image
        has_fig_caption = False
        has_source = False
        has_interp = False
        
        prev = p_elem.getprevious()
        while prev is not None:
            if prev.tag.endswith('}p'):
                txt = get_paragraph_text(prev)
                if txt.startswith('Figure'):
                    has_fig_caption = True
                    break
                elif txt.startswith('Source :'):
                    has_source = True
                elif txt.startswith('Tableau'):
                    break
                elif txt == '':
                    prev = prev.getprevious()
                    continue
                else:
                    break
            elif prev.tag.endswith('}tbl'):
                break
            else:
                prev = prev.getprevious()
                continue
        
        # Always add interpretation after figure
        nxt = p_elem.getnext()
        while nxt is not None:
            if nxt.tag.endswith('}p'):
                txt = get_paragraph_text(nxt)
                if 'Interprétation' in txt:
                    has_interp = True
                    break
                elif txt.startswith('Figure') or txt.startswith('Tableau') or txt.startswith('Source :'):
                    nxt = nxt.getnext()
                    continue
                elif txt == '':
                    nxt = nxt.getnext()
                    continue
                else:
                    break
            elif nxt.tag.endswith('}tbl'):
                break
            else:
                nxt = nxt.getnext()
                continue
        
        if not has_fig_caption:
            # Add generic figure caption
            fig_title = f"Figure (non numérotée) n°{drawing_count}"
            cap_para = make_para_elem(fig_title, bold=True, size=11, align='center')
            p_elem.addprevious(cap_para)
            fig_label_added += 1
        
        if not has_source:
            src_para = make_para_elem("Source : Auteur, 2026", italic=True, size=10)
            p_elem.addprevious(src_para)
            fig_src_added += 1
        
        if not has_interp:
            interp_full = f"Interprétation : Cette figure illustre un aspect du système TAG-Monitor."
            interp_para = make_para_elem(interp_full, italic=True, size=11, align='justify')
            p_elem.addnext(interp_para)
            fig_interp_added += 1
        
        print(f"  Drawing {drawing_count}: +{'label ' if not has_fig_caption else ''}{'+src ' if not has_source else ''}{'+interp' if not has_interp else ''}")

print(f"Figure summary: +{fig_label_added} labels, +{fig_src_added} sources, +{fig_interp_added} interps")

# ═══ PHASE 3: Fix paragraph alignment ═══
HEADING_PATTERN = re.compile(
    r'^(Chapitre\s+\d|PARTIE\s+|INTRODUCTION|CONCLUSION|'
    r'BIBLIOGRAPHIE|WEBOGRAPHIE|ANNEXES?|SOMMAIRE|RÉSUMÉ|'
    r'ABSTRACT|LISTE DES|REMERCIEMENTS|AVANT-PROPOS|\d+\.\d+|\d+\.)'
)

CODE_PREFIXES = ('defmodule', 'defp', 'def ', 'end', 'use ', 'import ', 'alias ', '|>', 'fn ', 'socket', 'assign(')

justified = 0
left_aligned = 0
skipped = 0

for p in doc.paragraphs:
    txt = p.text.strip()
    if not txt:
        continue
    
    # Skip headings
    if HEADING_PATTERN.match(txt):
        skipped += 1
        continue
    
    # Skip captions and source lines
    if txt.startswith('Tableau') or txt.startswith('Figure') or txt.startswith('Source :') or txt.startswith('Interprétation') or txt.startswith('[Copie'):
        skipped += 1
        continue
    
    # Left-align code
    if any(txt.startswith(prefix) for prefix in CODE_PREFIXES):
        p.alignment = WD_ALIGN_PARAGRAPH.LEFT
        for run in p.runs:
            run.font.name = 'Courier New'
            run.font.size = Pt(9)
        left_aligned += 1
        continue
    
    # Justify everything else
    p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    justified += 1

print(f"\nAlignment: {justified} justified, {left_aligned} left-aligned (code), {skipped} skipped (headings/captions)")

# ═══ SAVE ═══
doc.save(OUT)
print(f"\n✅ Saved: {OUT}")
