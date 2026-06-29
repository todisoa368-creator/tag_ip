#!/usr/bin/env python3
"""
Fix the CORRIGE DOCX: process figures first, then tables, then alignment.
Uses explicit mapping for numbered vs unnamed tables — no fragile backward scan.
"""

from docx import Document
from docx.shared import Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
import re

SRC = "/Users/fitahiana/Desktop/FITAHIANJANAHARY TODISOA CHRISTINE CORRIGE (1).docx"
OUT = "/Users/fitahiana/Desktop/FITAHIANJANAHARY TODISOA CHRISTINE FINAL.docx"

doc = Document(SRC)
body = doc.element.body

# ── Helpers ──
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

ROOT = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
W = lambda tag: f'{{{ROOT}}}{tag}'

# ── Data ──
# Table indices that already have "Tableau X:" captions (0-indexed)
NUMEROTED = {13, 14, 15, 16, 19, 20, 27, 28, 30, 31, 32, 33, 34, 36}

UNNAMED_TITLES = {
    0: "Informations clés sur TAG-IP",
    1: "Services proposés par TAG-IP",
    2: "Spécifications des composants réseau",
    3: "Équipements de sécurité réseau",
    4: "Outils de développement",
    5: "Composition de l'équipe",
    6: "Problèmes identifiés et leurs impacts",
    7: "Analyse détaillée des coûts cachés",
    8: "Coûts mensuels estimés",
    9: "Planning des sprints",
    10: "Entretiens semi-directifs réalisés",
    11: "Comparaison des solutions de géolocalisation",
    12: "Comparaison processus manuel vs automatisé",
    17: "Architecture en couches de TAG-Monitor",
    18: "Cas d'utilisation du système",
    21: "Tables de la base de données",
    22: "Tables de jonction",
    23: "Dictionnaire des données : table mounting_profiles",
    24: "Dictionnaire des données : table modèles_traceur",
    25: "Dictionnaire des données : table compatibilities",
    26: "Couches de l'architecture applicative",
    29: "Composants de l'environnement de développement",
    35: "Résultats comparatifs avant/après TAG-Monitor",
}

UNNAMED_INTERPS = {
    0: "Informations générales de la société TAG-IP, leader malgache de la géolocalisation.",
    1: "Services segmentés par clientèle avec des offres adaptées.",
    2: "Composants dimensionnés pour la disponibilité 24/7.",
    3: "Équipements garantissant protection et continuité du service.",
    4: "Environnement utilisant PostgreSQL 16 avec PostGIS.",
    5: "Équipe de quatre profils complémentaires.",
    6: "Problèmes d'incompatibilité et dépendance humaine générant des surcoûts.",
    7: "Coûts mensuels cachés s'élevant à plusieurs millions d'Ariary.",
    8: "Coût mensuel total estimé à 8 500 000 Ar.",
    9: "Quatre sprints d'une semaine selon la méthode agile.",
    10: "Six informateurs clés interrogés.",
    11: "TAG-Monitor se distingue par sa flexibilité.",
    12: "Automatisation réduisant la vérification de 30-45 min à 45 ms.",
    17: "Architecture à trois couches (Présentation, Métier, Persistance).",
    18: "Cas d'utilisation couvrant les interactions acteurs-système.",
    21: "UUID avec index composites pour requêtes optimisées.",
    22: "Tables de jonction gérant les relations many-to-many.",
    23: "Table mounting_profiles pour les profils de montage.",
    24: "Table modèles_traceur pour les traceurs GPS.",
    25: "Table compatibilities pour les résultats de compatibilité.",
    26: "Couches applicatives suivant le pattern Phoenix/Ash.",
    29: "Stack Elixir 1.18, Phoenix 1.8, Ash 3.4, PostgreSQL 16.",
    35: "Architecture déclarative Ash Framework réduisant le code boilerplate.",
}

NUM_INTERPS = {
    13: "Trois profils d'utilisateurs avec droits d'accès distincts.",
    14: "Contraintes de performance, sécurité, compatibilité et évolutivité.",
    15: "Six modules fonctionnels de la gestion des profils à l'export.",
    16: "Ash Framework déterminant pour la productivité de développement.",
    19: "Planning de 8 semaines du cahier des charges aux tests.",
    20: "Risques : courbe d'apprentissage Ash, instabilité du périmètre.",
    27: "Ash Framework : flexibilité et temps de développement réduit.",
    28: "Scoring pondéré : 20 vérificateurs en 5 catégories, 100 points.",
    30: "Environnement de développement standardisé et reproductible.",
    31: "Stratégie pyramide : tests unitaires, intégration, fonctionnels.",
    32: "Tests fonctionnels validant 10 scénarios critiques.",
    33: "Compatibilité : 45 ms/couple, 420 ms/batch.",
    34: "Stabilité validée avec 50 utilisateurs concurrents.",
    36: "Variables d'environnement pour déploiements multi-environnements.",
}

# ═══ PHASE 1: Process figures (original tree) ═══
print("--- Figures ---")
drawings = list(body.findall('.//' + W('drawing')))
print(f"Drawings found: {len(drawings)}")

fl = fs = fi = 0
for i, d in enumerate(drawings):
    p = d.getparent()
    while p is not None and not p.tag.endswith('}p'):
        p = p.getparent()
    if p is None: continue

    has_cap = has_src = has_interp = False

    prv = p.getprevious()
    while prv is not None:
        if prv.tag.endswith('}p'):
            t = para_text(prv)
            if t.startswith('Figure'): has_cap = True; break
            if t.startswith('Source :'): has_src = True; prv = prv.getprevious(); continue
            if t.startswith('Tableau') or t == '': prv = prv.getprevious(); continue
            break
        if prv.tag.endswith('}tbl'): break
        prv = prv.getprevious()

    nxt = p.getnext()
    while nxt is not None:
        if nxt.tag.endswith('}p'):
            t = para_text(nxt)
            if 'Interprétation' in t: has_interp = True; break
            if t == '' or t.startswith(('Figure', 'Tableau', 'Source :')): nxt = nxt.getnext(); continue
            break
        if nxt.tag.endswith('}tbl'): break
        nxt = nxt.getnext()

    if not has_cap:
        p.addprevious(make_para(f"Figure (non numérotée) n°{i+1}", bold=True, size=11, align='center')); fl += 1
    if not has_src:
        p.addprevious(make_para("Source : Auteur, 2026", italic=True, size=10)); fs += 1
    if not has_interp:
        p.addnext(make_para("Interprétation : Cette figure illustre un aspect du système TAG-Monitor.", italic=True, size=11, align='justify')); fi += 1

    print(f"  Fig {i+1}: {'cap ' if has_cap else '+cap '}{'src ' if has_src else '+src '}{'interp' if has_interp else '+interp'}")

print(f"Figures: +{fl} captions, +{fs} sources, +{fi} interps")

# ═══ PHASE 2: Process tables (use explicit numbering) ═══
print("\n--- Tableaux ---")
# Rebuild elem_info after figure modifications
ch2 = list(body.iterchildren())
ei2 = []
pi = ti = 0
for c in ch2:
    tag = c.tag.split('}')[-1] if '}' in c.tag else c.tag
    if tag == 'p': ei2.append(('p', c, pi, None)); pi += 1
    elif tag == 'tbl': ei2.append(('tbl', c, None, ti)); ti += 1
    else: ei2.append(('o', c, None, None))

al = as_ = ai_ = 0
for i, (typ, elem, _, tidx) in enumerate(ei2):
    if typ != 'tbl': continue

    # Check nearby for source and interp
    has_src = has_interp = False
    for j in range(i - 1, -1, -1):
        t, e, _, _ = ei2[j]
        if t == 'p':
            txt = para_text(e)
            if txt.startswith('Source :'): has_src = True; continue
            if txt == '' or txt.startswith(('Figure', 'Tableau')): continue
            break
        if t == 'tbl': break
    for j in range(i + 1, min(i + 6, len(ei2))):
        t, e, _, _ = ei2[j]
        if t == 'p':
            txt = para_text(e)
            if 'Interprétation' in txt: has_interp = True; break
            if txt == '' or txt.startswith(('Figure', 'Tableau', 'Source :')): continue
            break
        if t == 'tbl': break

    if tidx in NUMEROTED:
        if not has_src:
            elem.addprevious(make_para("Source : Auteur, 2026", italic=True, size=10)); as_ += 1
        if not has_interp and tidx in NUM_INTERPS:
            elem.addnext(make_para(f"Interprétation : {NUM_INTERPS[tidx]}", italic=True, size=11, align='justify')); ai_ += 1
            print(f"  T{tidx} numéroté +interp")
        else:
            print(f"  T{tidx} numéroté ok")
    else:
        if tidx in UNNAMED_TITLES:
            title = UNNAMED_TITLES[tidx]
            itxt = UNNAMED_INTERPS.get(tidx, "Ce tableau présente les données du système.")
            elem.addprevious(make_para(f"Tableau (non numéroté) : {title}", bold=True, size=11, align='center'))
            elem.addprevious(make_para("Source : Auteur, 2026", italic=True, size=10))
            elem.addnext(make_para(f"Interprétation : {itxt}", italic=True, size=11, align='justify'))
            al += 1; as_ += 1; ai_ += 1
            print(f"  T{tidx} → '{title}'")
        else:
            elem.addprevious(make_para("Tableau (non numéroté)", bold=True, size=11, align='center'))
            elem.addprevious(make_para("Source : Auteur, 2026", italic=True, size=10))
            elem.addnext(make_para("Interprétation : Ce tableau présente les données du système.", italic=True, size=11, align='justify'))
            al += 1; as_ += 1; ai_ += 1
            print(f"  T{tidx} → [générique]")

print(f"Tableaux: +{al} labels, +{as_} sources, +{ai_} interps")

# ═══ PHASE 3: Alignment ═══
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

print(f"\nAlignement: {j} justifiés, {l} gauche, {s} conservés")

doc.save(OUT)
print(f"\n✅ {OUT}")
