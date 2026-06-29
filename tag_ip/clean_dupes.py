#!/usr/bin/env python3
"""Clean duplicate interpretations near figures and tables."""
from docx import Document
from docx.oxml.ns import qn

SRC = "/Users/fitahiana/Desktop/FITAHIANJANAHARY TODISOA CHRISTINE FINAL.docx"
doc = Document(SRC)
body = doc.element.body

ROOT = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
W = lambda tag: f'{{{ROOT}}}{tag}'

def get_text(p_elem):
    texts = p_elem.findall('.//' + qn('w:t'))
    return ''.join(t.text or '' for t in texts).strip()

# Build element index
children = list(body.iterchildren())
info = []
for i, c in enumerate(children):
    tagname = c.tag.split('}')[-1] if '}' in c.tag else c.tag
    if tagname == 'p':
        txt = get_text(c)
        info.append((i, 'p', txt, c))
    elif tagname == 'tbl':
        info.append((i, 'tbl', '', c))
    else:
        dr = c.findall('.//' + W('drawing'))
        if dr:
            info.append((i, 'drawing', '', c))
        else:
            info.append((i, 'other', tagname, c))

# For each drawing/table, find ALL interpretations after it (before next media)
# and remove all but the FIRST one
to_remove = set()
total_interps_removed = 0

for i, (idx, typ, txt, elem) in enumerate(info):
    if typ not in ('drawing', 'tbl'):
        continue
    
    # Scan forward up to 20 elements for interps
    interp_positions = []
    for j in range(i + 1, min(i + 20, len(info))):
        j_idx, j_typ, j_txt, j_elem = info[j]
        if j_typ == 'p' and j_txt.startswith('Interprétation'):
            interp_positions.append((j, j_idx, j_txt))
        elif j_typ in ('drawing', 'tbl'):
            break
    
    # Keep first interp, mark rest for removal
    if len(interp_positions) > 1:
        for _, j_idx, j_txt in interp_positions[1:]:
            to_remove.add(j_idx)
            total_interps_removed += 1
            print(f"  Removing duplicate interp at [{j_idx}]: {j_txt[:80]}")
        first = interp_positions[0]
        print(f"  Keeping interp at [{first[1]}]: {first[2][:80]}")

# Remove marked elements (in reverse to avoid index issues)
sorted_remove = sorted(to_remove, reverse=True)
for idx in sorted_remove:
    c = children[idx]
    try:
        parent = c.getparent()
        if parent is not None:
            parent.remove(c)
    except:
        pass

print(f"\nRemoved {total_interps_removed} duplicate interpretations")

doc.save(SRC)
print(f"Saved: {SRC}")
