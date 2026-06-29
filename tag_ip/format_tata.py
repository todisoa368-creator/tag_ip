#!/usr/bin/env python3
"""Bold all titles/subtitles, figure/table captions, and add lists."""

from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
import re

SRC = "/Users/fitahiana/Desktop/moi.docx"
DST = SRC

ns_w = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'


def bold_paragraph(p):
    """Make all runs in a paragraph bold."""
    for r in p._p.findall(f'.//{{{ns_w}}}r'):
        rPr = r.find(f'{{{ns_w}}}rPr')
        if rPr is None:
            rPr = OxmlElement('w:rPr')
            r.insert(0, rPr)
        b = rPr.find(f'{{{ns_w}}}b')
        if b is None:
            rPr.append(OxmlElement('w:b'))


def main():
    doc = Document(SRC)
    paras = list(doc.paragraphs)

    # ── 1. Bold all heading patterns ──
    heading_patterns = [
        r'^PARTIE\s+(I|II|III)\b',
        r'^Chapitre\s+\d+',
        r'^\d+\.\d+[\s:]',
        r'^INTRODUCTION$',
        r'^CONCLUSION$',
        r'^BIBLIOGRAPHIE$',
        r'^ANNEXE',
    ]

    bolded_headings = 0
    for p in paras:
        t = p.text.strip()
        if not t:
            continue
        if any(re.match(pat, t) for pat in heading_patterns):
            bold_paragraph(p)
            bolded_headings += 1
        # Also bold short lines ending with :
        elif t.endswith(':') and len(t) < 70 and not t.startswith('http'):
            bold_paragraph(p)
            bolded_headings += 1

    print(f"  Titres/sous-titres mis en gras: {bolded_headings}")

    # ── 2. Bold figure and table captions ──
    bolded_captions = 0
    for p in paras:
        t = p.text.strip()
        if t.startswith('Figure ') or t.startswith('Tableau '):
            bold_paragraph(p)
            bolded_captions += 1

    print(f"  Légendes mises en gras: {bolded_captions}")

    # ── 3. Add Liste des figures and Liste des tableaux before PARTIE I ──
    partie_elem = None
    for p in paras:
        if p.text.strip().startswith('PARTIE I'):
            partie_elem = p._p
            break

    if partie_elem is not None:
        figures = [p.text.strip() for p in paras if p.text.strip().startswith('Figure ')]
        tables = [p.text.strip() for p in paras if p.text.strip().startswith('Tableau ')]

        # Build all elements in display order
        elements = []

        # Liste des figures heading
        fig_heading = OxmlElement('w:p')
        fig_heading.append(make_run('Liste des figures', bold=True, size_pt=14))
        elements.append(fig_heading)
        for fig in figures:
            fp = OxmlElement('w:p')
            fp.append(make_run(fig, size_pt=11))
            elements.append(fp)

        # Spacer
        elements.append(OxmlElement('w:p'))

        # Liste des tableaux heading
        tbl_heading = OxmlElement('w:p')
        tbl_heading.append(make_run('Liste des tableaux', bold=True, size_pt=14))
        elements.append(tbl_heading)
        for tbl in tables:
            tp = OxmlElement('w:p')
            tp.append(make_run(tbl, size_pt=11))
            elements.append(tp)

        # Insert in reverse order before PARTIE I (so they appear in correct order)
        for elem in reversed(elements):
            partie_elem.addprevious(elem)

        print(f"  Liste des figures ({len(figures)}) et tableaux ({len(tables)}) ajoutée")
    else:
        print("  ⚠️  'PARTIE I' non trouvée")

    doc.save(DST)
    print(f"\n✅ Formaté: {DST}")


def make_run(text, bold=False, italic=False, size_pt=12, color=None, font_name='Times New Roman'):
    r = OxmlElement('w:r')
    rPr = OxmlElement('w:rPr')
    rFonts = OxmlElement('w:rFonts')
    rFonts.set(qn('w:ascii'), font_name)
    rFonts.set(qn('w:hAnsi'), font_name)
    rPr.append(rFonts)
    sz = OxmlElement('w:sz')
    sz.set(qn('w:val'), str(int(size_pt * 2)))
    rPr.append(sz)
    if bold:
        rPr.append(OxmlElement('w:b'))
    if italic:
        rPr.append(OxmlElement('w:i'))
    if color:
        c = OxmlElement('w:color')
        c.set(qn('w:val'), color)
        rPr.append(c)
    r.append(rPr)
    t = OxmlElement('w:t')
    t.text = text
    t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
    r.append(t)
    return r


if __name__ == "__main__":
    main()
