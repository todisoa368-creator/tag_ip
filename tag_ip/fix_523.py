#!/usr/bin/env python3
"""Add missing code example and explanation to section 5.2.3."""

from docx import Document
from docx.shared import Pt, RGBColor
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

SRC = "/Users/fitahiana/Desktop/ftc_corrige.docx"
DST = "/Users/fitahiana/Desktop/ftc_corrige.docx"

FONT_NAME = "Times New Roman"
FONT_SIZE = Pt(12)


def make_run_elem(text, bold=False, italic=False, font_name=FONT_NAME, font_size=FONT_SIZE):
    r = OxmlElement('w:r')
    rPr = OxmlElement('w:rPr')

    rFonts = OxmlElement('w:rFonts')
    rFonts.set(qn('w:ascii'), font_name)
    rFonts.set(qn('w:hAnsi'), font_name)
    rPr.append(rFonts)

    sz = OxmlElement('w:sz')
    sz.set(qn('w:val'), str(int(font_size.pt * 2)))
    rPr.append(sz)

    if bold:
        b = OxmlElement('w:b')
        rPr.append(b)
    if italic:
        i = OxmlElement('w:i')
        rPr.append(i)

    r.append(rPr)
    t = OxmlElement('w:t')
    t.text = text
    t.set(qn('xml:space'), 'preserve')
    r.append(t)
    return r


def insert_element_after(ref_elem, new_elem):
    ref_elem.addnext(new_elem)
    return new_elem


def add_paragraph_after(ref_para, text="", bold=False, italic=False, font_name=FONT_NAME, font_size=FONT_SIZE):
    new_p = OxmlElement('w:p')
    if hasattr(ref_para, '_p'):
        ref_para._p.addnext(new_p)
    else:
        ref_para.addnext(new_p)
    if text:
        new_p.append(make_run_elem(text, bold=bold, italic=italic, font_name=font_name, font_size=font_size))
    return new_p


def add_code_line(ref, code_text):
    """Add a code-formatted line (monospace, smaller font)."""
    return add_paragraph_after(ref, code_text,
                                font_name="Courier New", font_size=Pt(9))


def process():
    doc = Document(SRC)

    # Find the intro paragraph (para 242)
    intro_para = None
    next_para = None
    for i, p in enumerate(doc.paragraphs):
        if "Voici l" in p.text and "exemple du vérificateur de tension" in p.text:
            intro_para = p
            # The next paragraph should be 5.2.5
            if i + 1 < len(doc.paragraphs):
                next_para = doc.paragraphs[i + 1]
            break

    if intro_para is None:
        print("❌ Could not find the target paragraph")
        return

    print(f"Found target paragraph. Next is: {next_para.text[:60] if next_para else 'None'}")

    # ── 1. Add code example ──
    code_lines = [
        "defp verifier_tension(profil, modele) do",
        "  cond do",
        "    modele.voltage_min >= profil.voltage_min and",
        "    modele.voltage_max <= profil.voltage_max ->",
        '      {10, ["Tension compatible : #{modele.voltage_min}-#{modele.voltage_max}V " <>',
        '            "dans la plage #{profil.voltage_min}-#{profil.voltage_max}V"]}',
        "",
        "    modele.voltage_max >= profil.voltage_min and",
        "    modele.voltage_min <= profil.voltage_max ->",
        '      {5, ["Tension partiellement compatible : chevauchement des plages"]}',
        "",
        "    true ->",
        '      {0, ["Tension incompatible : #{modele.voltage_min}-#{modele.voltage_max}V " <>',
        '            "hors plage #{profil.voltage_min}-#{profil.voltage_max}V"]}',
        "  end",
        "end",
    ]

    current_ref = intro_para
    for line in code_lines:
        if line == "":
            current_ref = add_paragraph_after(current_ref, "")
        else:
            current_ref = add_code_line(current_ref, line)

    # ── 2. Add explanation paragraph ──
    expl1_ref = add_paragraph_after(current_ref, "")
    expl1 = add_paragraph_after(expl1_ref,
        "Ce vérificateur illustre les trois cas possibles pour chaque critère de compatibilité. "
        "Le premier cas (lignes 3-6) correspond à une compatibilité totale : la plage de tension "
        "du modèle est entièrement incluse dans celle du profil, le score maximal de 10 points "
        "est attribué. Le deuxième cas (lignes 8-10) représente une compatibilité partielle : "
        "les plages se chevauchent sans inclusion complète, un score intermédiaire de 5 points "
        "est accordé. Le troisième cas (lignes 12-14) correspond à une incompatibilité totale : "
        "les plages de tension ne se chevauchent pas du tout, le score est de 0 point."
    )
    expl2 = add_paragraph_after(expl1,
        "Cette structure se retrouve dans l'ensemble des 20 vérificateurs du moteur de compatibilité, "
        "avec des adaptations selon la nature du critère : vérification binaire pour les bus de "
        "communication (CAN, 1-Wire, RS232, RS485), évaluation proportionnelle pour les entrées/"
        "sorties (le score est calculé au prorata du nombre d'entrées disponibles par rapport au "
        "nombre requis), et vérification de type pour les critères environnementaux (indice de "
        "protection IP, mémoire tampon, accéléromètre)."
    )

    doc.save(DST)
    print(f"✅ Saved: {DST}")
    print("📝 Section 5.2.3 complétée avec code + explication")


if __name__ == "__main__":
    process()
