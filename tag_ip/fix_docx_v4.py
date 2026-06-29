#!/usr/bin/env python3
"""
Fix the CORRIGE DOCX: justify text, add table/figure captions, sources, interpretations.
Process figures FIRST (before table tree modifications), then tables, then alignment.
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
    pPr.append(jc)
    p.append(pPr)
    r = OxmlElement('w:r')
    rPr = OxmlElement('w:rPr')
    for name in ('w:ascii', 'w:hAnsi'):
        rf = OxmlElement('w:rFonts')
        rf.set(qn(name), 'Times New Roman')
        rPr.append(rf)
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

def para_text(e):
    return ''.join(t.text or '' for t in e.findall('.//' + qn('w:t'))).strip()

# ── Data ──
NUMEROTED_TABLEAU_PARAS = {342, 347, 352, 357, 380, 383, 568, 644, 709, 840, 856, 861, 873, 931}

UNNAMED_TABLE_TITLES = {
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

UNNAMED_TABLE_INTERPS = {
    0: "Ce tableau présente les informations générales de la société TAG-IP.",
    1: "Les services de TAG-IP sont segmentés par type de clientèle avec des offres adaptées.",
    2: "Les composants sont dimensionnés pour la disponibilité 24/7 de la plateforme.",
    3: "Les équipements garantissent la protection du réseau et la continuité du service.",
    4: "L'environnement utilise PostgreSQL 16 avec PostGIS pour les opérations géospatiales.",
    5: "L'équipe est structurée avec quatre profils complémentaires.",
    6: "Les problèmes d'incompatibilité et de dépendance humaine génèrent des surcoûts.",
    7: "Les coûts mensuels cachés s'élèvent à plusieurs millions d'Ariary.",
    8: "Le coût mensuel total estimé à 8 500 000 Ar justifie l'automatisation.",
    9: "Le projet a été organisé en quatre sprints d'une semaine selon la méthode agile.",
    10: "Six informateurs clés ont été interrogés pour recueillir les besoins.",
    11: "TAG-Monitor se distingue par sa flexibilité et son approche sur mesure.",
    12: "L'automatisation réduit la vérification de compatibilité de 30-45 min à 45 ms.",
    17: "L'architecture à trois couches assure une séparation claire des responsabilités.",
    18: "Les cas d'utilisation couvrent les interactions entre acteurs et système.",
    21: "La base de données utilise des UUID avec des index composites optimisés.",
    22: "Les tables de jonction gèrent les relations many-to-many.",
    23: "La table mounting_profiles stocke les profils de montage.",
    24: "La table modèles_traceur référence les modèles de traceurs GPS.",
    25: "La table compatibilities enregistre les résultats de compatibilité.",
    26: "Les couches applicatives suivent le pattern Phoenix/Ash.",
    29: "L'environnement utilise Elixir 1.18, Phoenix 1.8, Ash 3.4, PostgreSQL 16.",
    35: "L'architecture déclarative Ash Framework réduit le code boilerplate.",
}

NUMEROTED_TABLEAU_INTERPS = {
    13: "Trois profils ont des droits d'accès distincts, de la configuration à la consultation.",
    14: "Les contraintes couvrent performance, sécurité, compatibilité et évolutivité.",
    15: "Six modules fonctionnels couvrent de la gestion des profils à l'export de données.",
    16: "Le choix d'Ash Framework est déterminant pour la productivité du développement.",
    19: "Le planning s'étend sur 8 semaines, du cahier des charges aux tests de charge.",
    20: "La courbe d'apprentissage Ash et l'instabilité du périmètre sont les risques majeurs.",
    27: "Ash Framework offre la meilleure flexibilité et un temps de développement réduit.",
    28: "Le scoring pondéré répartit 20 vérificateurs en 5 catégories sur 100 points.",
    30: "L'environnement de développement est standardisé pour la reproductibilité.",
    31: "La stratégie pyramide couvre tests unitaires, d'intégration et fonctionnels.",
    32: "Les tests fonctionnels valident 10 scénarios critiques du parcours utilisateur.",
    33: "Le calcul de compatibilité atteint 45 ms en couple et 420 ms en batch.",
    34: "Les tests de charge valident la stabilité avec 50 utilisateurs concurrents.",
    36: "Les variables d'environnement permettent des déploiements multi-environnements.",
}

# ═══ PHASE 0: Index body elements (original tree) ═══
children = list(body.iterchildren())
elem_info = []
para_idx = 0; tbl_idx = 0
for c in children:
    tag = c.tag.split('}')[-1] if '}' in c.tag else c.tag
    if tag == 'p':
        elem_info.append(('p', c, para_idx, None))
        para_idx += 1
    elif tag == 'tbl':
        elem_info.append(('tbl', c, None, tbl_idx))
        tbl_idx += 1
    else:
        elem_info.append(('o', c, None, None))

print(f"Body: {para_idx} paragraphs, {tbl_idx} tables")

# ═══ PHASE 1: Process figures (before any tree modifications) ═══
print("\n--- Figures ---")
drawings = body.findall('.//' + qn('w:drawing'))
print(f"Found {len(drawings)} drawings")

fig_label = fig_src = fig_interp = 0

for i, d in enumerate(drawings):
    # Find containing paragraph
    p_elem = d.getparent()
    while p_elem is not None and not p_elem.tag.endswith('}p'):
        p_elem = p_elem.getparent()
    if p_elem is None:
        continue

    has_cap = False; has_src = False

    # Scan backwards for Figure caption + Source
    prev = p_elem.getprevious()
    while prev is not None:
        if prev.tag.endswith('}p'):
            txt = para_text(prev)
            if txt.startswith('Figure'):
                has_cap = True
                break
            if txt.startswith('Source :'):
                has_src = True
                prev = prev.getprevious()
                continue
            if txt.startswith('Tableau') or txt == '':
                prev = prev.getprevious()
                continue
            break  # non-empty text, not figure/source/tableau → stop
        if prev.tag.endswith('}tbl'):
            break
        prev = prev.getprevious()

    has_interp = False
    nxt = p_elem.getnext()
    while nxt is not None:
        if nxt.tag.endswith('}p'):
            txt = para_text(nxt)
            if 'Interprétation' in txt:
                has_interp = True
                break
            if txt.startswith(('Figure', 'Tableau', 'Source :')) or txt == '':
                nxt = nxt.getnext()
                continue
            break
        if nxt.tag.endswith('}tbl'):
            break
        nxt = nxt.getnext()

    if not has_cap:
        p_elem.addprevious(make_para(f"Figure (non numérotée) n°{i+1}", bold=True, size=11, align='center'))
        fig_label += 1
    if not has_src:
        p_elem.addprevious(make_para("Source : Auteur, 2026", italic=True, size=10))
        fig_src += 1
    if not has_interp:
        p_elem.addnext(make_para("Interprétation : Cette figure illustre un aspect du système TAG-Monitor.",
                                  italic=True, size=11, align='justify'))
        fig_interp += 1

print(f"Figures : +{fig_label} captions, +{fig_src} sources, +{fig_interp} interps")

# ═══ PHASE 2: Process tables (modify tree) ═══
print("\n--- Tableaux ---")
# Rebuild elem_info since tree was modified by Phase 1
children2 = list(body.iterchildren())
elem_info2 = []
para_idx2 = 0; tbl_idx2 = 0
for c in children2:
    tag = c.tag.split('}')[-1] if '}' in c.tag else c.tag
    if tag == 'p':
        elem_info2.append(('p', c, para_idx2, None))
        para_idx2 += 1
    elif tag == 'tbl':
        elem_info2.append(('tbl', c, None, tbl_idx2))
        tbl_idx2 += 1
    else:
        elem_info2.append(('o', c, None, None))

added_label = added_src = added_interp = 0

for i, (typ, elem, pidx, tidx) in enumerate(elem_info2):
    if typ != 'tbl':
        continue

    # Find preceding Tableau caption + source
    last_cap = None; last_cap_idx = None; has_src = False
    for j in range(i - 1, -1, -1):
        t, e, p, _ = elem_info2[j]
        if t == 'p':
            txt = para_text(e)
            if txt.startswith('Tableau'):
                last_cap = txt; last_cap_idx = p; break
            if txt.startswith('Source :'):
                has_src = True
            if txt.startswith('Figure') or txt == '':
                continue
            break
        if t == 'tbl':
            break

    is_num = last_cap_idx in NUMEROTED_TABLEAU_PARAS

    # Check for interpretation after
    has_interp = False
    for j in range(i + 1, min(i + 6, len(elem_info2))):
        t, e, _, _ = elem_info2[j]
        if t == 'p':
            txt = para_text(e)
            if 'Interprétation' in txt:
                has_interp = True; break
            if txt == '' or txt.startswith(('Figure', 'Tableau', 'Source :')):
                continue
            break
        if t == 'tbl':
            break

    if is_num:
        if not has_src:
            elem.addprevious(make_para("Source : Auteur, 2026", italic=True, size=10))
            added_src += 1
        if not has_interp and tidx in NUMEROTED_TABLEAU_INTERPS:
            elem.addnext(make_para(f"Interprétation : {NUMEROTED_TABLEAU_INTERPS[tidx]}",
                                    italic=True, size=11, align='justify'))
            added_interp += 1
            print(f"  T{tidx} numéroté +interp (caption: {last_cap[:50] if last_cap else '?'})")
        else:
            print(f"  T{tidx} numéroté : ok (had src={has_src}, interp={has_interp or tidx not in NUMEROTED_TABLEAU_INTERPS})")
    else:
        if tidx in UNNAMED_TABLE_TITLES:
            title = UNNAMED_TABLE_TITLES[tidx]
            interp_txt = UNNAMED_TABLE_INTERPS.get(tidx, "Ce tableau présente les données du système.")
            elem.addprevious(make_para(f"Tableau (non numéroté) : {title}", bold=True, size=11, align='center'))
            elem.addprevious(make_para("Source : Auteur, 2026", italic=True, size=10))
            elem.addnext(make_para(f"Interprétation : {interp_txt}", italic=True, size=11, align='justify'))
            added_label += 1; added_src += 1; added_interp += 1
            print(f"  T{tidx} → '{title}' +label+src+interp")
        else:
            elem.addprevious(make_para("Tableau (non numéroté)", bold=True, size=11, align='center'))
            elem.addprevious(make_para("Source : Auteur, 2026", italic=True, size=10))
            elem.addnext(make_para("Interprétation : Ce tableau présente les données du système.", italic=True, size=11, align='justify'))
            added_label += 1; added_src += 1; added_interp += 1
            print(f"  T{tidx} → [générique] +label+src+interp")

print(f"Tableaux : +{added_label} labels, +{added_src} sources, +{added_interp} interps")

# ═══ PHASE 3: Fix paragraph alignment ═══
HEADING_RE = re.compile(
    r'^(Chapitre\s+\d|PARTIE\s+|INTRODUCTION|CONCLUSION|'
    r'BIBLIOGRAPHIE|WEBOGRAPHIE|ANNEXES?|SOMMAIRE|RÉSUMÉ|'
    r'ABSTRACT|LISTE DES|REMERCIEMENTS|AVANT-PROPOS|\d+\.\d+|\d+\.)'
)
CODE_PREFIXES = ('defmodule', 'defp', 'def ', 'end', 'use ', 'import ', 'alias ', '|>', 'fn ', 'socket', 'assign(')

j = l = s = 0
for p in doc.paragraphs:
    txt = p.text.strip()
    if not txt:
        continue
    if HEADING_RE.match(txt):
        s += 1; continue
    if txt.startswith(('Tableau', 'Figure', 'Source :', 'Interprétation', '[Copie')):
        s += 1; continue
    if any(txt.startswith(pr) for pr in CODE_PREFIXES):
        p.alignment = WD_ALIGN_PARAGRAPH.LEFT
        for run in p.runs:
            run.font.name = 'Courier New'
            run.font.size = Pt(9)
        l += 1; continue
    p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    j += 1

print(f"\nAlignement : {j} justifiés, {l} gauche (code), {s} conservés")

# ═══ SAVE ═══
doc.save(OUT)
print(f"\n✅ Enregistré : {OUT}")
