#!/usr/bin/env python3
"""Expand the Akamasoa history section in ftc_corrige.docx."""

from docx import Document
from docx.shared import Pt
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

SRC = "/Users/fitahiana/Desktop/ftc_corrige.docx"
DST = "/Users/fitahiana/Desktop/ftc_corrige.docx"

FONT_NAME = "Times New Roman"
FONT_SIZE = Pt(12)
NS = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'


def make_run_elem(text, bold=False, italic=False):
    """Create a w:r element with text."""
    r = OxmlElement('w:r')
    rPr = OxmlElement('w:rPr')

    rFonts = OxmlElement('w:rFonts')
    rFonts.set(qn('w:ascii'), FONT_NAME)
    rFonts.set(qn('w:hAnsi'), FONT_NAME)
    rPr.append(rFonts)

    sz = OxmlElement('w:sz')
    sz.set(qn('w:val'), str(int(FONT_SIZE.pt * 2)))  # half-points
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


def insert_paragraph_after(paragraph_or_elem, text=""):
    """Insert a new paragraph after the given paragraph or CT_P element."""
    new_p = OxmlElement('w:p')
    if hasattr(paragraph_or_elem, '_p'):
        paragraph_or_elem._p.addnext(new_p)
    else:
        paragraph_or_elem.addnext(new_p)
    if text:
        new_p.append(make_run_elem(text))
    return new_p


def process():
    doc = Document(SRC)

    # Find USVPA paragraph
    usvpa_para = None
    for i, p in enumerate(doc.paragraphs):
        if "Université Saint Vincent de Paul Akamasoa (USVPA)" in p.text:
            usvpa_para = p
            break

    if usvpa_para is None:
        print("❌ USVPA paragraph not found")
        return

    # Clear the USVPA paragraph and turn it into a heading
    for run in usvpa_para.runs:
        run.text = ""
    usvpa_para.runs[0].text = "1.1.1 L'Université Saint Vincent de Paul Akamasoa (USVPA)"
    usvpa_para.runs[0].bold = True
    usvpa_para.runs[0].font.name = FONT_NAME
    usvpa_para.runs[0].font.size = Pt(14)

    # ── Insert expanded history (3 paragraphs) ────────────────

    def add_para_after(ref_para, text):
        new = insert_paragraph_after(ref_para, text)
        return new

    p1 = add_para_after(usvpa_para,
        "L'Association Akamasoa (qui signifie « Les Bons Amis » en malgache) a été "
        "fondée en 1989 par le Père Pedro Pablo OPEKA, missionnaire lazariste d'origine "
        "argentine. Arrivé à Madagascar pour la première fois en 1970, le Père Pedro a été "
        "profondément marqué par la découverte, en mai 1989, de la décharge d'Andralanitra "
        "à Antananarivo, où des centaines de familles survivaient en fouillant les ordures "
        "parmi les chiens et les porcs. Convaincu qu'aucun être humain ne mérite de vivre "
        "dans de telles conditions, il entreprit de convaincre ces familles de quitter la "
        "décharge pour construire ensemble un avenir meilleur. En décembre 1989, avant Noël, "
        "il fonda officiellement l'association Akamasoa."
    )

    p2 = add_para_after(p1,
        "Depuis sa création, le mouvement Akamasoa a connu une croissance remarquable : "
        "18 villages ont été construits, plus de 500 000 personnes ont été aidées, et "
        "environ 40 000 personnes vivent aujourd'hui dans les centres Akamasoa. L'association "
        "repose sur trois piliers fondamentaux : un toit (logement digne), un travail (emploi "
        "et formation professionnelle), et une éducation (scolarisation et formation supérieure). "
        "Le réseau scolaire comprend six écoles primaires, quatre collèges, quatre lycées et "
        "une université, avec un taux de réussite au baccalauréat de 97 % en 2025, contre "
        "environ 50 % au niveau national. Le Père Pedro s'est entouré de 460 collaborateurs "
        "malgaches pour assurer le développement de l'association."
    )

    p3 = add_para_after(p2,
        "L'Université Saint Vincent de Paul Akamasoa (USVPA) a été fondée en 1994 dans le "
        "cadre de cette mission éducative. Située sur le site de Manantenasoa à Antananarivo, "
        "elle accueille des étudiants venus de toutes les régions de Madagascar (22 régions "
        "sur 23 représentées). L'université délivre des Diplômes de Technicien Supérieur (DTS) "
        "et des Licences professionnelles dans plusieurs domaines : Pédagogie et Langues, "
        "Sciences Paramédicales (infirmiers et sages-femmes), Sciences Technologiques et de "
        "Gestion, et Technologies Informatiques. En janvier 2024, une bibliothèque moderne, "
        "don de la Fondation Alain Mérieux, a été inaugurée, témoignant de la reconnaissance "
        "internationale de l'action d'Akamasoa. C'est dans ce cadre académique que s'inscrit "
        "le présent mémoire, fruit de la formation dispensée par l'ESTIA, le pôle technologique "
        "de l'université créé en 2017."
    )

    doc.save(DST)
    print(f"✅ Enregistré: {DST}")
    print("📝 Section historique d'Akamasoa développée (3 nouveaux paragraphes)")


if __name__ == "__main__":
    process()
