#!/usr/bin/env python3
"""Compact the document by removing excessive page breaks and empty paragraphs."""

from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

SRC = "/Users/fitahiana/Desktop/ftc_corrige.docx"
DST = SRC

ns_w = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'


def main():
    doc = Document(SRC)
    paras = list(doc.paragraphs)
    body = doc.element.body

    # ── 1. Remove pageBreakBefore from all non-major paragraphs ──
    major_prefixes = [
        "INTRODUCTION", "PARTIE I", "PARTIE II", "PARTIE III",
        "CONCLUSION", "BIBLIOGRAPHIE", "ANNEXE",
        "TABLE DES MATI", "LISTE DES",
    ]
    removed_pbb = 0
    kept_pbb = 0
    for p in paras:
        pPr = p._p.find(f'{{{ns_w}}}pPr')
        if pPr is None:
            continue
        pbb = pPr.find(f'{{{ns_w}}}pageBreakBefore')
        if pbb is None:
            continue
        txt = p.text.strip().upper()
        if any(txt.startswith(pre) for pre in major_prefixes):
            kept_pbb += 1
        else:
            pPr.remove(pbb)
            removed_pbb += 1

    print(f"  Page breaks removed: {removed_pbb}, kept: {kept_pbb}")

    # ── 2. Remove ALL empty paragraphs ──
    to_remove = []
    for p in paras:
        if p._p.getparent() is None:
            continue
        texts = p._p.findall(f'.//{{{ns_w}}}t')
        drawings = p._p.findall(f'.//{{{ns_w}}}drawing')
        is_empty = not drawings and (
            not texts or all(
                t.text is None or t.text.strip() == '' for t in texts
            )
        )
        if is_empty:
            to_remove.append(p._p)

    for elem in to_remove:
        parent = elem.getparent()
        if parent is not None:
            parent.remove(elem)

    print(f"  Empty paragraphs removed: {len(to_remove)}")

    # ── 3. Set line spacing to 1.5 and justify body text ──
    # Skip headings (16pt+), skip image/drawing paragraphs
    formatted = 0
    for p in doc.paragraphs:
        if not p.text.strip():
            continue
        if p._p.find(f'.//{{{ns_w}}}drawing') is not None:
            continue
        # Check if it's a heading (large font)
        is_heading = False
        for r in p._p.findall(f'.//{{{ns_w}}}r'):
            rPr = r.find(f'{{{ns_w}}}rPr')
            if rPr is not None:
                sz = rPr.find(f'{{{ns_w}}}sz')
                if sz is not None:
                    val = int(sz.get(qn('w:val')))
                    if val >= 28:  # 14pt+
                        is_heading = True
                        break
        # Also skip center-aligned paragraphs (captions, titles)
        pPr = p._p.find(f'{{{ns_w}}}pPr')
        if pPr is not None:
            jc = pPr.find(f'{{{ns_w}}}jc')
            if jc is not None and jc.get(qn('w:val')) == 'center':
                is_heading = True

        if not is_heading:
            pPr = p._p.find(f'{{{ns_w}}}pPr')
            if pPr is None:
                pPr = OxmlElement('w:pPr')
                p._p.insert(0, pPr)
            spacing = pPr.find(f'{{{ns_w}}}spacing')
            if spacing is None:
                spacing = OxmlElement('w:spacing')
                pPr.append(spacing)
            spacing.set(qn('w:line'), '360')
            spacing.set(qn('w:lineRule'), 'auto')
            spacing.set(qn('w:before'), '0')
            spacing.set(qn('w:after'), '60')
            # Justify text
            jc = pPr.find(f'{{{ns_w}}}jc')
            if jc is None:
                jc = OxmlElement('w:jc')
                pPr.append(jc)
            jc.set(qn('w:val'), 'both')
            formatted += 1

    print(f"  Body paragraphs formatted (1.5 spacing, justified): {formatted}")

    # ── 4. Reduce page margins ──
    for section in doc.sections:
        from docx.shared import Emu
        section.top_margin = Emu(685800)      # 0.75 inch
        section.bottom_margin = Emu(685800)
        section.left_margin = Emu(685800)
        section.right_margin = Emu(685800)
    print(f"  Margins reduced to 0.75in")

    # ── 5. Add pageBreakBefore for major sections ──
    keep_prefixes = [
        "INTRODUCTION", "PARTIE I", "PARTIE II", "PARTIE III",
        "CONCLUSION", "BIBLIOGRAPHIE",
    ]
    added_pbb = 0
    for p in doc.paragraphs:
        txt = p.text.strip().upper()
        if any(txt.startswith(pre) for pre in keep_prefixes):
            pPr = p._p.find(f'{{{ns_w}}}pPr')
            if pPr is None:
                pPr = OxmlElement('w:pPr')
                p._p.insert(0, pPr)
            existing = pPr.find(f'{{{ns_w}}}pageBreakBefore')
            if existing is None:
                pbb = OxmlElement('w:pageBreakBefore')
                pPr.append(pbb)
                added_pbb += 1

    print(f"  Page breaks added for major sections: {added_pbb}")

    # ── 6. Add a space before major sections if needed ──
    added_space = 0
    for p in doc.paragraphs:
        txt = p.text.strip()
        if txt.startswith("INTRODUCTION") or txt.startswith("PARTIE "):
            prev = p._p.getprevious()
            if prev is not None:
                texts = prev.findall(f'.//{{{ns_w}}}t')
                drawings = prev.findall(f'.//{{{ns_w}}}drawing')
                has_content = drawings or any(
                    t.text and t.text.strip() for t in texts
                )
                if has_content:
                    spacer = OxmlElement('w:p')
                    p._p.addprevious(spacer)
                    added_space += 1

    if added_space:
        print(f"  Spacers added before major sections: {added_space}")

    doc.save(DST)
    print(f"\n✅ Compacted: {DST}")

    # Final stats
    paras2 = list(doc.paragraphs)
    empty2 = sum(1 for p in paras2
                 if not p._p.findall(f'.//{{{ns_w}}}t') or all(
                     t.text is None or t.text.strip() == '' for t in p._p.findall(f'.//{{{ns_w}}}t')))
    print(f"  Avant: {len(paras)} paras, {len([p for p in paras if p.text.strip() == ''])} vides")
    print(f"  Après: {len(paras2)} paras, {empty2} vides")


if __name__ == "__main__":
    main()
