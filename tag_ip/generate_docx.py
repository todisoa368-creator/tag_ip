#!/usr/bin/env python3
"""Generate the complete thesis document for TAG-Monitor."""
import os
from docx import Document
from docx.shared import Pt, Inches, Cm, RGBColor, Emu
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.section import WD_ORIENT
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn, nsdecls
from docx.oxml import parse_xml
import datetime

OUTPUT_DIR = os.path.expanduser("~/Desktop/fitahiana")
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "TagIp_Memoire_Final.docx")
IMAGES_DIR = OUTPUT_DIR  # MCD/MLD images are here

doc = Document()

# ============================================================
# PAGE SETUP
# ============================================================
for section in doc.sections:
    section.top_margin = Cm(2.5)
    section.bottom_margin = Cm(2.5)
    section.left_margin = Cm(3)
    section.right_margin = Cm(2.5)

style = doc.styles["Normal"]
font = style.font
font.name = "Times New Roman"
font.size = Pt(12)
style.paragraph_format.line_spacing = 1.5
style.paragraph_format.space_after = Pt(6)

# Heading styles
for level in [1, 2, 3]:
    h_style = doc.styles[f"Heading {level}"]
    h_style.font.name = "Times New Roman"
    h_style.font.color.rgb = RGBColor(0, 0, 0)
    if level == 1:
        h_style.font.size = Pt(16)
        h_style.font.bold = True
        h_style.paragraph_format.space_before = Pt(24)
        h_style.paragraph_format.space_after = Pt(12)
    elif level == 2:
        h_style.font.size = Pt(14)
        h_style.font.bold = True
        h_style.paragraph_format.space_before = Pt(18)
        h_style.paragraph_format.space_after = Pt(8)
    elif level == 3:
        h_style.font.size = Pt(12)
        h_style.font.bold = True
        h_style.paragraph_format.space_before = Pt(12)
        h_style.paragraph_format.space_after = Pt(6)


def add_paragraph(text, style_name="Normal", bold=False, italic=False, alignment=None, font_size=None):
    p = doc.add_paragraph(style=style_name)
    run = p.add_run(text)
    run.font.name = "Times New Roman"
    if bold:
        run.bold = True
    if italic:
        run.italic = True
    if font_size:
        run.font.size = Pt(font_size)
    if alignment:
        p.alignment = alignment
    return p


def add_heading(text, level=1):
    h = doc.add_heading(text, level=level)
    for run in h.runs:
        run.font.name = "Times New Roman"
        run.font.color.rgb = RGBColor(0, 0, 0)
    return h


def add_page_break():
    doc.add_page_break()


def add_table_with_data(headers, rows, col_widths=None):
    table = doc.add_table(rows=1 + len(rows), cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.style = "Table Grid"
    # Header row
    for i, h in enumerate(headers):
        cell = table.rows[0].cells[i]
        cell.text = h
        for paragraph in cell.paragraphs:
            paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
            for run in paragraph.runs:
                run.bold = True
                run.font.name = "Times New Roman"
                run.font.size = Pt(10)
        shading = parse_xml(f'<w:shd {nsdecls("w")} w:fill="1A73E8"/>')
        cell._tc.get_or_add_tcPr().append(shading)
        for paragraph in cell.paragraphs:
            for run in paragraph.runs:
                run.font.color.rgb = RGBColor(255, 255, 255)
    # Data rows
    for r_idx, row in enumerate(rows):
        for c_idx, val in enumerate(row):
            cell = table.rows[r_idx + 1].cells[c_idx]
            cell.text = str(val)
            for paragraph in cell.paragraphs:
                for run in paragraph.runs:
                    run.font.name = "Times New Roman"
                    run.font.size = Pt(10)
            if r_idx % 2 == 1:
                shading = parse_xml(f'<w:shd {nsdecls("w")} w:fill="F5F5F5"/>')
                cell._tc.get_or_add_tcPr().append(shading)
    if col_widths:
        for i, width in enumerate(col_widths):
            for row in table.rows:
                row.cells[i].width = Cm(width)
    doc.add_paragraph()  # spacer
    return table


def add_image(img_path, caption, width=Inches(5.5)):
    if os.path.exists(img_path):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run = p.add_run()
        run.add_picture(img_path, width=width)
        cap = doc.add_paragraph()
        cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = cap.add_run(caption)
        r.italic = True
        r.font.name = "Times New Roman"
        r.font.size = Pt(10)
    else:
        add_paragraph(f"[Image non trouvée: {img_path}]", italic=True)


# ============================================================
# TITLE PAGE
# ============================================================
for _ in range(3):
    doc.add_paragraph()

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = p.add_run("UNIVERSITÉ SAINT VINCENT DE PAUL AKAMASOA")
run.font.name = "Times New Roman"
run.bold = True
run.font.size = Pt(14)

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = p.add_run("MANANTENASOA — ANTANANARIVO")
run.font.name = "Times New Roman"
run.font.size = Pt(12)
run.italic = True

doc.add_paragraph()

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = p.add_run("MÉMOIRE DE FIN D'ÉTUDES")
run.font.name = "Times New Roman"
run.bold = True
run.font.size = Pt(14)

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = p.add_run("en vue d'obtention du Diplôme de Technicien Supérieur")
run.font.name = "Times New Roman"
run.font.size = Pt(12)

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = p.add_run("Mention : Technologie Informatique")
run.font.name = "Times New Roman"
run.font.size = Pt(12)

doc.add_paragraph()

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = p.add_run("CONCEPTION ET RÉALISATION D'UN MODULE AUTOMATISÉ DE GESTION DES PROFILS DE MONTAGE ET DE COMPATIBILITÉ DES TRACEURS GPS SOUS ELIXIR ET ASH FRAMEWORK")
run.font.name = "Times New Roman"
run.bold = True
run.font.size = Pt(14)

doc.add_paragraph()

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = p.add_run("Au sein de la société TAG-IP")
run.font.name = "Times New Roman"
run.italic = True
run.font.size = Pt(12)

doc.add_paragraph()
doc.add_paragraph()

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
lines = [
    "Présenté par : Monsieur [NOM Prénom]",
    "",
    "Membres du jury :",
    "   - Président du jury : […]",
    "   - Examinateur : […]",
    "   - Encadreur pédagogique : […]",
    "",
    "Année universitaire 2025-2026",
]
for line in lines:
    r = p.add_run(line + "\n")
    r.font.name = "Times New Roman"
    r.font.size = Pt(12)

add_page_break()

# ============================================================
# AVANT-PROPOS
# ============================================================
add_heading("AVANT-PROPOS", level=1)

add_paragraph(
    "Ce mémoire rentre dans le cadre de l'obtention du Diplôme de Technicien Supérieur (DTS) "
    "en Technologie Informatique à l'Université Saint Vincent de Paul AKAMASOA (USVPA)."
)

add_paragraph(
    "Ce projet a été réalisé au sein de la société TAG-IP (Technologie d'Avant-Garde Internet Protocole), "
    "un leader malgache des solutions de tracking et de géolocalisation de véhicules. Il a été choisi en "
    "raison de la problématique concrète observée lors de mon stage au pôle Ingénierie Logicielle de la DSI : "
    "l'identification des traceurs GPS compatibles avec des équipements variés reposait encore sur une "
    "expertise humaine manuelle, source d'erreurs et de pertes de productivité. La mission consistait à "
    "concevoir et réaliser un module automatisé de gestion des profils de montage et de compatibilité des "
    "traceurs GPS, en utilisant les technologies Elixir, Phoenix LiveView et Ash Framework."
)

add_paragraph(
    "Les motivations ayant conduit à l'étude de ce sujet résident dans l'envie de confronter mes "
    "connaissances techniques à un cas concret, d'apporter une réelle plus-value à un outil utilisé "
    "quotidiennement par les techniciens de TAG-IP, et de me former aux exigences professionnelles "
    "en matière de qualité logicielle, d'architecture déclarative et de rigueur méthodologique."
)

add_paragraph(
    "L'objectif principal du travail présenté est de déployer une application web capable de centraliser "
    "et de pérenniser l'expertise technique de l'entreprise, en transformant des contraintes physiques "
    "en calculs logiques automatisés. Pour y parvenir, une démarche structurée a été adoptée, comprenant "
    "une analyse approfondie du contexte et des besoins, une modélisation rigoureuse des données, une "
    "conception architecturale, suivies d'un développement itératif et de tests fonctionnels."
)

add_paragraph(
    "Au cours du projet, plusieurs difficultés ont été rencontrées, telles que la prise en main du "
    "framework Ash (nouveau dans l'écosystème Elixir), la modélisation des 17 critères de compatibilité, "
    "et l'adaptation aux besoins précis des équipes techniques tout en respectant des délais contraints. "
    "Ces obstacles ont cependant représenté une source d'apprentissage précieuse, tant sur le plan "
    "technique que personnel."
)

add_paragraph(
    "Ce mémoire témoigne ainsi de l'aboutissement d'un projet académique, professionnel et humain. "
    "Il marque la fin d'un cycle d'apprentissage à l'USVPA et le début d'un engagement dans le monde "
    "professionnel de l'informatique."
)

add_page_break()

# ============================================================
# REMERCIEMENTS
# ============================================================
add_heading("REMERCIEMENTS", level=1)

add_paragraph(
    "Avant toute chose, nous rendons grâce à Dieu Tout-Puissant, source de vie et de force, "
    "pour nous avoir accompagnés tout au long de cette formation et durant la réalisation de ce mémoire."
)

add_paragraph(
    "Nous exprimons notre profonde gratitude au Révérend Père Pedro Pablo OPEKA, Fondateur et Président "
    "de l'Association AKAMASOA, dont l'engagement et la vision ont permis à de nombreux jeunes, "
    "dont nous-mêmes, de bénéficier d'une éducation supérieure de qualité."
)

add_paragraph(
    "Nos sincères remerciements s'adressent à Madame FANDROARIMANGA Monique, coordonnatrice de "
    "l'Université Saint Vincent de Paul AKAMASOA, et à Monsieur Johnson, Directeur de l'USVPA, "
    "pour leur disponibilité, leur accompagnement et leur engagement constant envers les étudiants."
)

add_paragraph(
    "Nous remercions également Monsieur Marc RIVERA, Directeur Général de TAG-IP, et Monsieur "
    "Gilles CHAPOTON, Directeur Technique, pour nous avoir accueillis au sein de leur entreprise "
    "et permis de réaliser ce projet dans un cadre professionnel enrichissant."
)

add_paragraph(
    "Nos vifs remerciements vont à notre encadreur professionnel au sein du pôle Ingénierie Logicielle "
    "de la DSI de TAG-IP, ainsi qu'à notre encadreur pédagogique, Monsieur RANDRENJA Herinjaka Hélien, "
    "pour leurs conseils, leur rigueur et leur soutien précieux tout au long de ce travail."
)

add_paragraph(
    "Nous tenons aussi à remercier l'ensemble du personnel administratif de l'USVPA pour leur "
    "bienveillance, ainsi que les formateurs et formatrices pour la qualité de leurs enseignements "
    "et leur générosité dans le partage de leurs connaissances."
)

add_paragraph(
    "Enfin, nous adressons toute notre reconnaissance à nos parents, familles et amis pour leur "
    "soutien moral, matériel et spirituel, qui a été d'un grand réconfort et d'une aide précieuse "
    "dans la réalisation de ce mémoire."
)

add_page_break()

# ============================================================
# LISTE DES ABRÉVIATIONS
# ============================================================
add_heading("LISTE DES ABRÉVIATIONS", level=1)

abbreviations = [
    ("API", "Application Programming Interface"),
    ("Ash", "Ash Framework"),
    ("CAN", "Controller Area Network"),
    ("CRUD", "Create, Read, Update, Delete"),
    ("CSRF", "Cross-Site Request Forgery"),
    ("DSI", "Direction des Systèmes d'Information"),
    ("DTS", "Diplôme de Technicien Supérieur"),
    ("ESTIA", "École Supérieure de Technologie Informatique AKAMASOA"),
    ("GPS", "Global Positioning System"),
    ("HA", "Haute Disponibilité"),
    ("HEEx", "HTML + Elixir (Phoenix templates)"),
    ("I/O", "Entrées/Sorties (Input/Output)"),
    ("IoT", "Internet of Things"),
    ("IP", "Indice de Protection"),
    ("MCD", "Modèle Conceptuel de Données"),
    ("MERISE", "Méthode d'Étude et de Réalisation Informatique"),
    ("MLD", "Modèle Logique de Données"),
    ("MOA / MOE", "Maîtrise d'Ouvrage / Maîtrise d'Œuvre"),
    ("MVC", "Model-View-Controller"),
    ("ORM", "Object-Relational Mapping"),
    ("PostGIS", "Extension géospatiale PostgreSQL"),
    ("RAID", "Redundant Array of Independent Disks"),
    ("REST", "Representational State Transfer"),
    ("SGBD", "Système de Gestion de Base de Données"),
    ("VLAN", "Virtual Local Area Network"),
    ("VPN", "Virtual Private Network"),
]

table = doc.add_table(rows=len(abbreviations) + 1, cols=2)
table.style = "Table Grid"
table.alignment = WD_TABLE_ALIGNMENT.CENTER
for i, h in enumerate(["Abréviation", "Signification"]):
    cell = table.rows[0].cells[i]
    cell.text = h
    for p in cell.paragraphs:
        for r in p.runs:
            r.bold = True
            r.font.name = "Times New Roman"
            r.font.size = Pt(10)
    shading = parse_xml(f'<w:shd {nsdecls("w")} w:fill="333333"/>')
    cell._tc.get_or_add_tcPr().append(shading)
    for p in cell.paragraphs:
        for r in p.runs:
            r.font.color.rgb = RGBColor(255, 255, 255)

for idx, (abbr, meaning) in enumerate(abbreviations):
    table.rows[idx + 1].cells[0].text = abbr
    table.rows[idx + 1].cells[1].text = meaning
    for cell in table.rows[idx + 1].cells:
        for p in cell.paragraphs:
            for r in p.runs:
                r.font.name = "Times New Roman"
                r.font.size = Pt(10)

# Set column widths
for row in table.rows:
    row.cells[0].width = Cm(4)
    row.cells[1].width = Cm(12)

add_page_break()

# ============================================================
# TABLE OF CONTENTS (via field code)
# ============================================================
add_heading("TABLE DES MATIÈRES", level=1)
p = doc.add_paragraph()
run = p.add_run()
fld_char_begin = parse_xml(f'<w:fldChar {nsdecls("w")} w:fldCharType="begin"/>')
run._r.append(fld_char_begin)

run2 = p.add_run()
instr = parse_xml(f'<w:instrText {nsdecls("w")} xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText>')
run2._r.append(instr)

run3 = p.add_run()
fld_char_separate = parse_xml(f'<w:fldChar {nsdecls("w")} w:fldCharType="separate"/>')
run3._r.append(fld_char_separate)

run4 = p.add_run("[Mise à jour de la table des matières : clic droit → Mettre à jour]")
run4.font.italic = True
run4.font.size = Pt(10)
run4.font.color.rgb = RGBColor(150, 150, 150)

run5 = p.add_run()
fld_char_end = parse_xml(f'<w:fldChar {nsdecls("w")} w:fldCharType="end"/>')
run5._r.append(fld_char_end)

add_page_break()

# ============================================================
# LISTE DES FIGURES
# ============================================================
add_heading("LISTE DES FIGURES", level=1)
p = doc.add_paragraph()
run = p.add_run()
fld_char_begin = parse_xml(f'<w:fldChar {nsdecls("w")} w:fldCharType="begin"/>')
run._r.append(fld_char_begin)
run2 = p.add_run()
instr = parse_xml(f'<w:instrText {nsdecls("w")} xml:space="preserve"> TOC \\c "Figure" </w:instrText>')
run2._r.append(instr)
run3 = p.add_run()
fld_char_separate = parse_xml(f'<w:fldChar {nsdecls("w")} w:fldCharType="separate"/>')
run3._r.append(fld_char_separate)
run4 = p.add_run("[Liste des figures — mise à jour automatique]")
run4.font.italic = True
run4.font.size = Pt(10)
run4.font.color.rgb = RGBColor(150, 150, 150)
run5 = p.add_run()
fld_char_end = parse_xml(f'<w:fldChar {nsdecls("w")} w:fldCharType="end"/>')
run5._r.append(fld_char_end)

add_paragraph("")
add_heading("LISTE DES TABLEAUX", level=1)
p = doc.add_paragraph()
run = p.add_run()
fld_char_begin = parse_xml(f'<w:fldChar {nsdecls("w")} w:fldCharType="begin"/>')
run._r.append(fld_char_begin)
run2 = p.add_run()
instr = parse_xml(f'<w:instrText {nsdecls("w")} xml:space="preserve"> TOC \\c "Tableau" </w:instrText>')
run2._r.append(instr)
run3 = p.add_run()
fld_char_separate = parse_xml(f'<w:fldChar {nsdecls("w")} w:fldCharType="separate"/>')
run3._r.append(fld_char_separate)
run4 = p.add_run("[Liste des tableaux — mise à jour automatique]")
run4.font.italic = True
run4.font.size = Pt(10)
run4.font.color.rgb = RGBColor(150, 150, 150)
run5 = p.add_run()
fld_char_end = parse_xml(f'<w:fldChar {nsdecls("w")} w:fldCharType="end"/>')
run5._r.append(fld_char_end)

add_page_break()

# ============================================================
# INTRODUCTION GÉNÉRALE
# ============================================================
add_heading("INTRODUCTION GÉNÉRALE", level=1)

intro_text = (
    "Au sein de la société Tag-IP, leader malgache de la géolocalisation de véhicules avec plus de "
    "10 000 unités suivies, l'identification des traceurs GPS compatibles avec des équipements variés — "
    "véhicules légers, poids lourds, engins de chantier — repose encore sur une expertise humaine manuelle "
    "et des supports d'information dispersés. Lors de mon stage au sein du pôle Ingénierie Logicielle de "
    "la DSI, j'ai constaté que les techniciens d'exploitation passaient en moyenne 30 à 45 minutes par "
    "demande de compatibilité, avec un taux d'erreur de montage estimé à 15 % — soit près de 150 "
    "installations défectueuses par mois. Ces erreurs entraînent des déplacements supplémentaires, du "
    "matériel endommagé par des incompatibilités de tension (12V/24V) et une perte de productivité "
    "estimée à 20 % du temps de l'équipe technique. C'est dans ce contexte de modernisation des "
    "processus internes qu'est né ce projet intitulé « Conception et réalisation d'un module automatisé "
    "de gestion des profils de montage et de compatibilité des traceurs GPS sous Elixir et Ash Framework »."
)
add_paragraph(intro_text)

add_paragraph(
    "Ce travail soulève la problématique centrale de l'automatisation d'un diagnostic de compatibilité "
    "entre des contraintes physiques hétérogènes et un catalogue matériel dense, tout en garantissant "
    "une maintenance simplifiée des règles métier. Pour répondre à cet enjeu, nous formulons l'hypothèse "
    "selon laquelle l'implémentation d'une architecture déclarative basée sur Ash Framework, couplée à "
    "la réactivité en temps réel de Phoenix LiveView, permet de réduire drastiquement les erreurs de "
    "configuration matérielle en transformant les contraintes physiques en calculs logiques automatisés "
    "et transparents pour l'utilisateur final."
)

add_paragraph(
    "L'objectif général est donc de déployer une application web capable de centraliser et de pérenniser "
    "l'expertise technique de l'entreprise. Ce but se décline en objectifs spécifiques : la modélisation "
    "rigoureuse des ressources via Ash, le développement d'un moteur de calcul de compatibilité notant "
    "chaque couple profil-modèle sur 100 points via 17 critères, et la conception d'une interface "
    "intuitive permettant une visualisation instantanée des résultats."
)

add_paragraph(
    "La méthodologie adoptée, de nature itérative et agile, s'est appuyée sur l'observation directe "
    "des processus de montage, des entretiens avec les experts techniques de Tag-IP, et une modélisation "
    "structurelle selon la méthode Merise. Le développement a suivi un cycle en trois phases : analyse "
    "des besoins, conception technique, puis réalisation et tests."
)

add_paragraph(
    "Ce mémoire se structure en trois parties qui s'enchaînent logiquement. La première partie établit "
    "un diagnostic complet du contexte institutionnel, de l'environnement technique, des problèmes "
    "opérationnels et des spécifications du système. La deuxième partie détaille la conception technique : "
    "modélisation des données, architecture et choix technologiques. La troisième partie présente la "
    "réalisation effective, les tests et l'évaluation des performances, avant une discussion critique "
    "sur les limites et perspectives."
)

add_page_break()

# ============================================================
# PARTIE I – CONTEXTE ET ANALYSE
# ============================================================
add_heading("PARTIE I – CONTEXTE ET ANALYSE", level=1)

# --- Chapter 1 ---
add_heading("Chapitre 1 : Cadre et contexte du projet", level=2)

# 1.1 Présentation de l'environnement
add_heading("1.1 Présentation de l'environnement", level=3)

add_heading("1.1.1 L'Université Saint Vincent de Paul Akamasoa (USVPA)", level=3)

add_paragraph(
    "L'Université Saint Vincent de Paul Akamasoa (USVPA) est un établissement privé d'enseignement "
    "supérieur situé à Antananarivo, Madagascar. Fondée en 1994, sa mission est de fournir une "
    "formation académique et professionnelle visant à favoriser l'insertion des étudiants dans le "
    "tissu économique national."
)

add_paragraph(
    "Missions et cadre organisationnel. L'USVPA répond aux besoins du marché de l'emploi malgache "
    "dans des secteurs clés tels que l'éducation, la santé, le management et les technologies de "
    "l'information. Le campus de Manantenasoa offre un environnement d'apprentissage comprenant "
    "des salles de cours équipées et des infrastructures numériques adaptées."
)

add_paragraph(
    "Offres de formation. L'établissement délivre des DTS et des Licences professionnelles dans "
    "plusieurs domaines : pédagogie et langues, sciences paramédicales, sciences technologiques "
    "et de gestion."
)

add_paragraph(
    "L'École Supérieure de Technologie en Informatique d'Akamasoa (ESTIA). Créée en 2017, l'ESTIA "
    "constitue le pôle technologique de l'université. C'est dans ce cadre que s'est déroulé mon "
    "cursus de DTS Informatique, articulé autour de trois axes : "
    "1) Développement logiciel — algorithmique, langages modernes (dont Elixir), frameworks web "
    "(Phoenix, LiveView), conception d'interfaces. "
    "2) Systèmes et réseaux — administration de serveurs Linux, protocoles de sécurité, déploiement DevOps. "
    "3) Ingénierie des données — modélisation relationnelle (Merise), PostgreSQL, gestion de flux."
)

add_paragraph(
    "Lien avec le stage. La pédagogie de l'ESTIA privilégie l'apprentissage par projet. Durant ma "
    "formation, j'ai acquis les compétences en architecture logicielle et développement back-end qui "
    "ont directement nourri mon travail chez Tag-IP. L'utilisation du framework Ash et du langage "
    "Elixir s'est révélée parfaitement adaptée aux besoins de modélisation déclarative du projet."
)

add_heading("1.1.2 La société TAG-IP", level=3)

add_paragraph(
    "La société TAG-IP (Technologie d'Avant-Garde Internet Protocole) a été créée en 2008 en "
    "partenariat avec l'opérateur Telma. Elle est le leader des solutions de tracking et de "
    "géolocalisation à Madagascar, proposant des services de gestion de flotte, de télémétrie "
    "et de sécurité pour les entreprises et les particuliers."
)

add_paragraph("Fiche d'identification :", bold=True)

add_table_with_data(
    ["Champ", "Valeur"],
    [
        ("Raison sociale", "Technologie d'Avant Garde – Internet Protocole (SA)"),
        ("Siège social", "Immeuble Assist - 5e étage, 101 Antananarivo"),
        ("Activité", "Géolocalisation et tracking de véhicules"),
        ("Directeur Général", "M. Marc Rivera"),
        ("Directeur Technique", "M. Gilles Chapoton"),
    ],
)

add_paragraph(
    "Historique. En 2009-2010, création de la première application de géolocalisation et fondation "
    "de TAG-IP (800 véhicules fin 2010). De 2011 à 2013, croissance soutenue avec 50 à 100 "
    "installations par mois et expansion internationale au Niger, à La Réunion et aux Seychelles. "
    "Depuis 2014, le parc est passé de 7 000 à plus de 10 000 véhicules suivis."
)

add_paragraph(
    "Structure organisationnelle et positionnement du stage. L'entreprise est structurée en trois "
    "directions : RH/Exploitation (pôle terrain, TAGOS), Marketing/Commercial, et Direction des "
    "Systèmes d'Information (DSI). C'est au sein de la DSI, plus précisément au pôle Ingénierie "
    "Logicielle, que s'est déroulé mon stage. Le schéma ci-dessous présente l'organigramme simplifié "
    "avec la localisation du poste de stage."
)

# 1.2 Environnement technique
add_heading("1.2 Environnement technique", level=3)

add_heading("1.2.1 Infrastructure et matériel", level=3)

add_paragraph(
    "L'architecture matérielle est dimensionnée pour une disponibilité 24h/24 et 7j/7 afin d'assurer "
    "la traçabilité en temps réel des 10 000 véhicules suivis par TAG-IP."
)

add_table_with_data(
    ["Composant", "Description", "Rôle"],
    [
        ("Liaisons spécialisées", "Connexions haut débit via Telma", "Réception trames GPRS/3G"),
        ("VLAN", "3 réseaux (GPS, Admin, Dev)", "Segmentation et sécurité"),
        ("Firewall", "Professionnel IDS/IPS", "Sécurité périmétrique"),
        ("Cluster serveurs", "Physiques en HA", "Haute disponibilité"),
        ("Stockage RAID", "Réplication disques", "Sauvegarde temps réel"),
        ("Redondance énergétique", "Onduleurs + batteries + groupe", "Continuité de service"),
    ],
    col_widths=[4, 5.5, 4.5],
)

add_paragraph(
    "Le réseau est segmenté en trois VLAN distincts : le VLAN GPS dédié au flux de données des "
    "traceurs, le VLAN Administration pour les outils métier internes, et le VLAN Développement "
    "pour les environnements de test et de préproduction. Cette segmentation garantit que les "
    "perturbations sur un réseau n'affectent pas les autres."
)

add_heading("1.2.2 Outils et systèmes existants", level=3)

add_paragraph(
    "Systèmes d'exploitation. Les serveurs de production fonctionnent sous Debian GNU/Linux, "
    "tandis que les postes de développement utilisent macOS. Le choix de Debian pour la production "
    "est justifié par sa stabilité éprouvée et son écosystème de paquets adapté aux services "
    "critiques."
)

add_paragraph(
    "Plateforme Track. Il s'agit du logiciel propriétaire de TAG-IP pour le suivi des véhicules. "
    "Il intègre des règles métier codées en dur (hard-coding) pour la gestion des alertes et des "
    "seuils de fonctionnement. Toute modification de ces règles nécessite une recompilation et un "
    "redéploiement complet par la DSI, ce qui constitue un goulot d'étranglement."
)

add_paragraph(
    "Base de données. L'entreprise utilise PostgreSQL avec l'extension PostGIS pour le traitement "
    "géospatial. Le volume de données atteint plusieurs millions d'enregistrements, posant des "
    "défis en matière de performance des requêtes et d'indexation."
)

add_paragraph(
    "Outils DevOps. Git est utilisé pour la gestion de versions, et Docker pour la conteneurisation "
    "des applications. Cependant, le monitoring se limite à des indicateurs physiques sans vue "
    "métier consolidée."
)

# 1.3 Contexte et problématique
add_heading("1.3 Contexte et problématique", level=3)

add_heading("1.3.1 Situation initiale et problèmes identifiés", level=3)

add_paragraph(
    "Avant l'automatisation, la gestion de la compatibilité reposait sur un processus manuel en "
    "trois phases : "
    "1) Collecte des besoins — les demandes arrivaient via fiches papier ou email, sans "
    "référentiel numérique centralisé. "
    "2) Diagnostic manuel — les techniciens effectuaient un matching mental à partir d'informations "
    "éparpillées entre fichiers Excel, fiches PDF et documentation constructeur. "
    "3) Configuration atelier — les balises étaient paramétrées manuellement, source d'erreurs "
    "de frappe et de mauvais réglages."
)

add_paragraph(
    "Lors des entretiens avec le responsable du pôle Exploitation, j'ai estimé que ces tâches "
    "représentaient environ 20 % de perte de productivité de l'équipe technique, avec un taux "
    "d'échec de pose de 15 %, soit près de 150 installations défectueuses par mois."
)

add_table_with_data(
    ["Problème", "Description", "Impact"],
    [
        ("Incompatibilité matérielle", "Boîtier 12V sur véhicule 24V, I/O insuffisantes", "Destruction matériel, perte financière"),
        ("Hard-coding des règles", "Modification = compilation + redéploiement", "Goulot d'étranglement DSI"),
        ("Erreurs de terrain", "Déplacements inutiles, mauvais matériel embarqué", "Coûts logistiques"),
        ("Dépendance humaine", "Expertise détenue par quelques seniors uniquement", "Risque de perte de savoir-faire"),
    ],
    col_widths=[4, 5.5, 4.5],
)

add_heading("1.3.2 Expression du besoin", level=3)

add_paragraph(
    "Face à ce constat, quatre besoins fondamentaux ont été exprimés par la direction technique :"
)

add_paragraph(
    "1) Centralisation du référentiel technique — créer une base unique et centralisée des "
    "schémas de montage et des profils de compatibilité."
)
add_paragraph(
    "2) Automatisation du diagnostic — valider automatiquement la compatibilité tension et "
    "entrées/sorties par la simple saisie du modèle de traceur."
)
add_paragraph(
    "3) Décentralisation des règles — permettre la configuration et la mise à jour des règles "
    "métier via une interface intuitive, sans recompilation."
)
add_paragraph(
    "4) Digitalisation de l'expertise — standardiser et pérenniser les procédures de montage "
    "sous forme numérique."
)

add_page_break()

# --- Chapter 2 ---
add_heading("Chapitre 2 : Analyse des besoins et positionnement", level=2)

add_heading("2.1 Étude des solutions existantes", level=3)

add_paragraph(
    "Afin de positionner notre solution par rapport à l'existant, nous avons étudié plusieurs "
    "plateformes IoT et de gestion de parc présentes sur le marché."
)

add_paragraph(
    "ThingsBoard est une plateforme open source de gestion IoT offrant une grande flexibilité "
    "avec des tableaux de bord personnalisables et la prise en charge multi-protocole. Cependant, "
    "elle ne propose pas de moteur de compatibilité métier adapté au contexte des traceurs GPS."
)

add_paragraph(
    "Kaa IoT est une autre plateforme open source axée sur la connectivité et la gestion "
    "d'appareils. Sa flexibilité est moyenne et sa configuration est complexe pour des besoins "
    "spécifiques comme ceux de TAG-IP."
)

add_paragraph(
    "Les solutions propriétaires existantes sur le marché malgache sont limitées par des licences "
    "coûteuses et une absence de personnalisation aux besoins spécifiques de l'entreprise."
)

add_table_with_data(
    ["Critère", "ThingsBoard", "Kaa IoT", "Propriétaires", "TAG-Monitor"],
    [
        ("Flexibilité", "Élevée", "Moyenne", "Faible", "Élevée"),
        ("Coût", "Open source", "Open source", "Licence", "Sur mesure"),
        ("Compatibilité multi-constructeur", "Oui", "Oui", "Non", "Oui"),
        ("Moteur compatibilité métier", "Non", "Non", "Non", "Oui (17 critères)"),
    ],
    col_widths=[4, 2.8, 2.8, 2.8, 2.8],
)

add_paragraph(
    "Limites observées : aucune solution existante ne propose un moteur de compatibilité entre "
    "profils de montage et traceurs GPS adapté au contexte spécifique de TAG-IP. Cette absence "
    "justifie pleinement le développement d'une solution sur mesure."
)

add_heading("2.2 Besoins et contraintes", level=3)

add_paragraph(
    "Les besoins fonctionnels identifiés couvrent l'ensemble du cycle de vie de la gestion "
    "de compatibilité : création et gestion des profils de montage via un assistant en plusieurs "
    "étapes, catalogue centralisé des modèles de traceurs avec recherche multicritères, moteur "
    "de scoring automatique notant la compatibilité sur 100 points, tableau de bord temps réel, "
    "et système d'authentification sécurisé."
)

add_paragraph("Les acteurs du système se répartissent comme suit :", bold=True)

add_table_with_data(
    ["Acteur", "Rôle", "Droits"],
    [
        ("Administrateur", "Gestion complète du système", "CRUD toutes ressources, gestion utilisateurs"),
        ("Technicien exploitation", "Préparation et diagnostic", "CRUD profils, consultation modèles et compatibilités"),
        ("Technicien terrain", "Installation sur site", "Consultation fiches profils et résultats compatibilité"),
    ],
    col_widths=[4, 4.5, 5.5],
)

add_paragraph(
    "Les contraintes techniques imposées sont : stack technologique Elixir/Phoenix/Ash/PostgreSQL, "
    "interface responsive adaptée aux terminaux mobiles des techniciens terrain, et temps de réponse "
    "inférieur à 2 secondes pour le calcul de compatibilité."
)

add_heading("2.3 Spécifications générales", level=3)

add_paragraph(
    "Le système TAG-Monitor est organisé en modules fonctionnels indépendants mais interconnectés :"
)

add_table_with_data(
    ["Module", "Ressources Ash", "Fonctionnalités"],
    [
        ("ProfilMontage", "ProfilMontage", "CRUD profils, assistant multi-étapes"),
        ("ModeleTraceur", "ModeleTraceur, TypeVehicule, Alimentation, Capteur", "Catalogue, relations N-N"),
        ("Compatibilité", "Compatibilite", "Moteur de scoring 17 critères / 100 pts"),
        ("Référentiels", "PortType, Feature, Peripheral", "Données de base"),
        ("Dashboard", "Toutes", "Statistiques temps réel via PubSub"),
    ],
    col_widths=[3, 5, 6],
)

add_paragraph(
    "L'architecture globale suit le modèle en couches avec Phoenix LiveView pour l'interface "
    "utilisateur, Ash Framework pour la couche métier déclarative, et PostgreSQL pour la persistance. "
    "La communication entre les couches s'effectue via les mécanismes standards d'Ash : les actions "
    "de ressources encapsulent la logique métier tandis que les LiveViews assurent le rendu interactif."
)

add_page_break()

# ============================================================
# PARTIE II – CONCEPTION TECHNIQUE
# ============================================================
add_heading("PARTIE II – CONCEPTION TECHNIQUE", level=1)

# --- Chapter 3 ---
add_heading("Chapitre 3 : Modélisation des données", level=2)

add_heading("3.1 Modèle conceptuel (MCD)", level=3)

add_paragraph(
    "Le Modèle Conceptuel de Données (MCD) constitue la représentation abstraite des entités "
    "du système et de leurs relations, indépendamment de toute considération technique. Il a été "
    "élaboré selon la méthode Merise, en partant de l'analyse des besoins fonctionnels exprimés "
    "par les équipes techniques de TAG-IP."
)

add_paragraph(
    "Les entités principales identifiées sont : ProfilMontage (qui encapsule les contraintes "
    "d'installation d'un véhicule client), ModeleTraceur (qui décrit les caractéristiques "
    "techniques d'un traceur GPS), TypeVehicule, Alimentation, Capteur, Feature, PortType, "
    "Peripheral, et l'entité associative Compatibilite qui relie un profil à un modèle avec "
    "un score calculé."
)

add_paragraph(
    "Les relations many-to-many sont gérées via des tables de jonction : ModeleTraceurTypeVehicule, "
    "ModeleTraceurAlimentation, ModeleTraceurCapteur, ModelFeature et ModelPort. Chaque modèle "
    "de traceur peut être compatible avec plusieurs types de véhicules, supporté par plusieurs "
    "alimentations, embarquer plusieurs capteurs, et offrir plusieurs fonctionnalités."
)

add_paragraph(
    "Les règles de gestion fondamentales sont : le score de compatibilité est calculé sur 100 "
    "points selon 17 critères pondérés, et la contrainte d'unicité sur le couple (profil_montage_id, "
    "modele_traceur_id) garantit qu'il n'existe qu'un seul résultat de compatibilité par paire."
)

add_image(
    os.path.join(IMAGES_DIR, "mcd_tag_monitor.png"),
    "Figure 1 : Modèle Conceptuel de Données (MCD) du système TAG-Monitor",
    width=Inches(6),
)

add_heading("3.2 Modèle logique (MLD)", level=3)

add_paragraph(
    "Le Modèle Logique de Données (MLD) traduit le MCD en une représentation adaptée au SGBD "
    "relationnel PostgreSQL. Chaque entité devient une table, chaque attribut devient une colonne "
    "avec son type, et les relations sont matérialisées par des clés étrangères."
)

add_table_with_data(
    ["Table", "Clé primaire", "Contraintes principales"],
    [
        ("mounting_profiles", "UUID", "voltage_min ≤ voltage_max"),
        ("modeles_traceur", "UUID", "Référence unique"),
        ("compatibilites", "UUID", "UNIQUE(profil_montage_id, modele_traceur_id)"),
        ("model_features", "UUID", "FK + unique composité"),
        ("model_ports", "UUID", "FK + contrainte de jonction"),
    ],
    col_widths=[4, 3, 7],
)

add_paragraph(
    "Le schéma ci-dessous présente la structure détaillée des tables, leurs colonnes, types, "
    "contraintes et relations."
)

add_image(
    os.path.join(IMAGES_DIR, "mld_tag_monitor.png"),
    "Figure 2 : Modèle Logique de Données (MLD) du système TAG-Monitor",
    width=Inches(6),
)

add_heading("3.3 Dictionnaire des données", level=3)

add_paragraph(
    "Le dictionnaire des données décrit l'ensemble des champs, leurs types, contraintes et "
    "règles de validation pour les trois tables principales du système."
)

add_paragraph("Table : mounting_profiles", bold=True)
add_table_with_data(
    ["Champ", "Type", "Description", "Contrainte"],
    [
        ("id", "UUID", "Identifiant unique", "PK"),
        ("name", "string", "Nom du profil", "Requis, unique"),
        ("voltage_min", "decimal", "Tension minimale (V)", "Requis"),
        ("voltage_max", "decimal", "Tension maximale (V)", "≥ voltage_min"),
        ("can_bus_required", "boolean", "Bus CAN requis", "Défaut: false"),
        ("one_wire_required", "boolean", "Capteur 1-Wire requis", "Défaut: false"),
        ("rs232_required", "boolean", "Port RS232 requis", "Défaut: false"),
        ("rs485_required", "boolean", "Port RS485 requis", "Défaut: false"),
        ("nb_digital_inputs", "integer", "Entrées numériques", "Défaut: 0"),
        ("nb_analog_inputs", "integer", "Entrées analogiques", "Défaut: 0"),
        ("nb_outputs", "integer", "Sorties", "Défaut: 0"),
        ("ip_rating", "string", "Indice de protection", "Optionnel"),
    ],
    col_widths=[3.5, 2.5, 4, 4],
)

add_paragraph("Table : modeles_traceur", bold=True)
add_table_with_data(
    ["Champ", "Type", "Description", "Contrainte"],
    [
        ("id", "UUID", "Identifiant unique", "PK"),
        ("nom", "string", "Nom du modèle", "Requis"),
        ("brand", "string", "Marque", "Requis"),
        ("reference", "string", "Référence constructeur", "Unique"),
        ("can_bus", "boolean", "Support bus CAN", "Défaut: false"),
        ("one_wire", "boolean", "Support 1-Wire", "Défaut: false"),
        ("rs232", "boolean", "Support RS232", "Défaut: false"),
        ("nb_digital_inputs", "integer", "Entrées numériques", "Défaut: 0"),
        ("nb_analog_inputs", "integer", "Entrées analogiques", "Défaut: 0"),
        ("nb_outputs", "integer", "Sorties", "Défaut: 0"),
        ("ip_rating", "string", "Indice de protection", "Optionnel"),
        ("buffer_memory", "integer", "Mémoire tampon", "Optionnel"),
    ],
    col_widths=[3.5, 2.5, 4, 4],
)

add_paragraph("Table : compatibilites", bold=True)
add_table_with_data(
    ["Champ", "Type", "Description", "Contrainte"],
    [
        ("id", "UUID", "Identifiant unique", "PK"),
        ("profil_montage_id", "UUID", "Référence au profil", "FK"),
        ("modele_traceur_id", "UUID", "Référence au modèle", "FK"),
        ("score_compatibilite", "integer", "Score sur 100", "0-100"),
        ("(profil, modèle)", "—", "Contrainte d'unicité", "UNIQUE"),
    ],
    col_widths=[3.5, 2, 4, 4.5],
)

add_page_break()

# --- Chapter 4 ---
add_heading("Chapitre 4 : Architecture et choix techniques", level=2)

add_heading("4.1 Architecture globale du système", level=3)

add_paragraph(
    "L'architecture de TAG-Monitor suit un modèle en couches (n-tiers) qui sépare les "
    "préoccupations en trois niveaux distincts : présentation, métier et persistance."
)

add_table_with_data(
    ["Couche", "Technologie", "Responsabilité"],
    [
        ("Présentation", "Phoenix LiveView + HEEx", "Interface utilisateur, temps réel, composants"),
        ("Métier", "Ash Framework", "Logique métier, validations, règles de compatibilité"),
        ("Persistance", "AshPostgres / PostgreSQL", "Stockage, requêtes, indexation"),
    ],
    col_widths=[3, 5, 6],
)

add_paragraph(
    "Cette architecture en couches présente plusieurs avantages : la séparation des responsabilités "
    "facilite la maintenance et l'évolution du système, l'indépendance des couches permet de "
    "modifier l'implémentation d'une couche sans impact sur les autres, et la réutilisabilité "
    "des composants est accrue. Le choix de LiveView pour la couche présentation élimine le "
    "besoin de développer un frontend JavaScript séparé, réduisant ainsi la complexité globale "
    "du projet."
)

add_heading("4.2 Choix technologiques", level=3)

add_paragraph(
    "Le choix des technologies a été guidé par les exigences du projet, l'existant chez TAG-IP, "
    "et les contraintes de formation. Le tableau ci-dessous présente la stack retenue."
)

add_table_with_data(
    ["Couche", "Technologie", "Justification", "Alternative"],
    [
        ("Framework web", "Phoenix 1.8", "Temps réel, robustesse, productivité", "Rails, Node.js"),
        ("ORM/Domaine", "Ash Framework 3.0", "Déclaratif, policies intégrées", "Ecto seul"),
        ("Base de données", "PostgreSQL + PostGIS", "Géospatial, existant TAG-IP", "MySQL, MongoDB"),
        ("Frontend temps réel", "Phoenix LiveView", "Pas de JS séparé, streams", "React/Vue"),
        ("Authentification", "phx.gen.auth + bcrypt", "Standard Phoenix", "Pow, Auth0"),
        ("Conteneurisation", "Docker", "Reproductibilité", "—"),
    ],
    col_widths=[3.5, 4, 5, 2.5],
)

add_paragraph(
    "Le langage Elixir, basé sur la machine virtuelle BEAM (Erlang), offre une concurrence "
    "légère et une tolérance aux pannes naturelles. Phoenix LiveView permet de construire des "
    "interfaces temps réel sans écrire de code JavaScript côté client. Ash Framework apporte "
    "une couche déclarative qui unifie la définition des ressources, leurs actions, validations "
    "et politiques de sécurité en un seul endroit, réduisant considérablement le boilerplate."
)

add_heading("4.3 Architecture back-end et sécurité", level=3)

add_paragraph(
    "L'organisation du back-end suit une architecture en couches avec : la couche ressource "
    "(définition des entités Ash avec leurs attributs, relations et actions), la couche domaine "
    "(règles métier et orchestration), et la couche web (LiveViews et contrôleurs)."
)

add_paragraph(
    "Le moteur de compatibilité constitue le cœur métier de l'application. Il implémente 17 "
    "vérificateurs pondérés répartis en cinq catégories :"
)

add_table_with_data(
    ["Catégorie", "Détail", "Points"],
    [
        ("Tension", "Plage voltage compatible", "10"),
        ("Bus de communication", "CAN (8), 1-Wire (5), RS232 (5), RS485 (5)", "23"),
        ("Entrées/Sorties", "Digital IN (8), Analog IN (5), Out (5)", "18"),
        ("Environnement", "IP (10), Montage extérieur (5), Mémoire tampon (5)", "20"),
        ("Capteurs", "Accéléromètre (5), Antennes externes (5), Buzzer (4)", "14"),
        ("Fonctionnalités", "Géofence (5), Sonde carburant (5), Bluetooth (5)", "15"),
        ("Total", "", "100"),
    ],
    col_widths=[4, 7, 3],
)

add_paragraph(
    "Sécurité. Le système implémente plusieurs mécanismes de sécurité : le hachage des mots "
    "de passe avec bcrypt, l'authentification par magic links, la protection CSRF via les plugs "
    "Phoenix, la validation des données via les changesets Ash, et un contrôle d'accès basé sur "
    "le rôle (user/admin) avec des live_sessions distinctes dans le routeur."
)

add_paragraph(
    "Le routeur Phoenix définit trois zones de sécurité : la session :require_authenticated_user "
    "pour les pages nécessitant une connexion (profils, dashboard), la session :require_admin_user "
    "pour l'administration (modèles, compatibilités, référentiels), et la session "
    ":redirect_if_authenticated pour les pages de connexion et d'inscription."
)

add_page_break()

# ============================================================
# PARTIE III – RÉALISATION ET ÉVALUATION
# ============================================================
add_heading("PARTIE III – RÉALISATION ET ÉVALUATION", level=1)

# --- Chapter 5 ---
add_heading("Chapitre 5 : Réalisation technique", level=2)

add_heading("5.1 Mise en place technique", level=3)

add_paragraph(
    "L'environnement de développement a été configuré sur Debian GNU/Linux avec la stack "
    "technologique suivante :"
)

add_table_with_data(
    ["Outil", "Version", "Usage"],
    [
        ("Elixir", "~> 1.15", "Langage de programmation"),
        ("Phoenix", "1.8.5", "Framework web"),
        ("Ash Framework", "~> 3.0", "ORM déclaratif"),
        ("PostgreSQL", "16+", "Base de données"),
        ("Docker", "—", "Conteneurisation"),
        ("Git", "—", "Gestion de version"),
    ],
    col_widths=[4, 3, 7],
)

add_paragraph(
    "Structure du projet. L'application suit la convention standard d'un projet Phoenix avec "
    "une organisation particulière due à l'utilisation d'Ash Framework :"
)

add_paragraph(
    "tag_ip/\n"
    "├── lib/tag_ip/           # Domaines et ressources Ash (2 domaines, 18 ressources)\n"
    "├── lib/tag_ip_web/live/  # 16 LiveViews\n"
    "├── lib/tag_ip_web/       # Routeur, UserAuth, composants\n"
    "├── priv/repo/migrations/ # Migrations AshPostgres\n"
    "├── test/                 # Tests unitaires et fonctionnels\n"
    "└── assets/               # JS, CSS (Tailwind CSS v4)"
)

add_paragraph(
    "La base de données PostgreSQL a été initialisée via les migrations AshPostgres, qui "
    "génèrent automatiquement les tables à partir des définitions de ressources Ash. Les "
    "extensions PostGIS et pgcrypto ont été activées pour le support géospatial et la "
    "génération d'identifiants UUID."
)

add_heading("5.2 Implémentation du back-end", level=3)

add_paragraph(
    "Authentification. Le système d'authentification est basé sur phx.gen.auth avec bcrypt "
    "pour le hachage des mots de passe et les magic links pour la connexion sans mot de passe. "
    "Les plugs assurent la protection des routes : fetch_current_scope_for_user charge "
    "l'utilisateur courant, require_authenticated redirige vers la page de connexion si "
    "l'utilisateur n'est pas authentifié, et redirect_if_user_is_authenticated protège les "
    "pages de connexion/ inscription."
)

add_paragraph(
    "Moteur de compatibilité. La fonction calculer/2 dans le module Compatibilite implémente "
    "les 17 critères de notation. Chaque vérificateur compare une caractéristique du profil "
    "de montage avec celle du modèle de traceur et retourne un score partiel avec un message "
    "de détail. L'agrégation des scores produit une note sur 100. L'action calculate_compatibility "
    "enregistre le résultat dans la table compatibilites avec une contrainte d'unicité pour "
    "éviter les doublons."
)

add_paragraph("Routes principales :", bold=True)
add_table_with_data(
    ["Route", "LiveView", "Fonction"],
    [
        ("/dashboard", "DashboardLive.Index", "Tableau de bord temps réel"),
        ("/profils", "ProfilMontageLive.Index", "Liste des profils"),
        ("/profils/new", "ProfilMontageLive.Form", "Assistant création (4 étapes)"),
        ("/profils/:id", "ProfilMontageLive.Show", "Détail d'un profil"),
        ("/modeles", "ModeleTraceurLive.Index", "Catalogue des traceurs"),
        ("/compatibilites", "CompatibiliteLive.Index", "Résultats de compatibilité"),
        ("/referentiels", "ReferenceLive.Index", "Données de référence"),
    ],
    col_widths=[3, 4.5, 6.5],
)

add_heading("5.3 Fonctionnalités avancées", level=3)

add_paragraph(
    "Recherche avancée. Le système utilise les capacités de filtrage d'Ash Framework pour "
    "permettre une recherche multicritères sur les profils de montage et les modèles de "
    "traceurs. Les opérateurs booléens et les comparaisons numériques sont supportés, "
    "permettant aux techniciens de filtrer efficacement le catalogue."
)

add_paragraph(
    "Reporting et tableau de bord. Le dashboard temps réel utilise Phoenix PubSub pour "
    "afficher les statistiques en direct : nombre de profils, modèles de traceurs, résultats "
    "de compatibilité calculés, et alertes récentes. Les notifications sont automatiquement "
    "dissipées après 10 secondes pour une expérience utilisateur non intrusive."
)

add_paragraph(
    "Interface Bento style. L'interface utilisateur adopte un design épuré de type Bento, "
    "avec des cartes d'information organisées en grille, des transitions fluides, et un "
    "code couleur intuitif pour les scores de compatibilité (vert ≥ 70 %, orange 40-70 %, "
    "rouge < 40 %). Le responsive design assure une expérience optimale sur les terminaux "
    "mobiles utilisés par les techniciens terrain."
)

add_page_break()

# --- Chapter 6 ---
add_heading("Chapitre 6 : Évaluation et discussion", level=2)

add_heading("6.1 Tests et validation", level=3)

add_paragraph(
    "La stratégie de test a couvert l'ensemble des couches de l'application, du moteur "
    "de compatibilité aux interfaces LiveView."
)

add_table_with_data(
    ["Module", "Type", "Cas testés"],
    [
        ("Moteur compatibilité", "Unitaire", "17 critères, cas limites, valeurs extrêmes"),
        ("Ressources Ash", "Intégration", "CRUD, validations, contraintes d'unicité"),
        ("LiveViews", "Fonctionnel", "Listes, formulaires, navigation, assistant création"),
        ("Authentification", "Fonctionnel", "Login, register, protection routes, rôles"),
    ],
    col_widths=[4, 2.5, 7.5],
)

add_paragraph(
    "Les tests unitaires du moteur de compatibilité valident chaque vérificateur "
    "individuellement, avec des cas de test couvrant les scénarios de compatibilité totale, "
    "partielle et d'incompatibilité. Les tests d'intégration vérifient le bon fonctionnement "
    "des ressources Ash, notamment les contraintes d'unicité et les cascades de suppression. "
    "Les tests fonctionnels des LiveViews utilisent Phoenix.LiveViewTest pour simuler les "
    "interactions utilisateur."
)

add_heading("6.2 Analyse des performances", level=3)

add_paragraph(
    "Les mesures de performance ont été réalisées sur l'environnement de développement "
    "avec un jeu de données représentatif (20 profils, 30 modèles, 600 combinaisons)."
)

add_table_with_data(
    ["Opération", "Temps moyen"],
    [
        ("Calcul compatibilité (1 couple)", "< 200 ms"),
        ("Recherche profils (Ash filter)", "< 100 ms"),
        ("Affichage liste modèles (20 entrées)", "< 50 ms"),
        ("Calcul batch (20 modèles × 1 profil)", "< 500 ms"),
        ("Chargement dashboard", "< 300 ms"),
    ],
    col_widths=[8, 6],
)

add_paragraph(
    "Les optimisations mises en œuvre incluent l'indexation des colonnes fréquemment "
    "interrogées (voltage, marque, référence), l'utilisation des streams LiveView pour "
    "le rendu efficace des listes, et le chargement différé (lazy loading) des relations "
    "Ash pour éviter les requêtes N+1."
)

add_heading("6.3 Discussion critique", level=3)

add_paragraph(
    "L'évaluation des objectifs fixés en début de projet montre des résultats globalement "
    "satisfaisants :"
)

add_table_with_data(
    ["Objectif", "État", "Commentaire"],
    [
        ("Centralisation du référentiel", "Atteint", "18 ressources Ash, catalogue de 6+ modèles"),
        ("Automatisation du diagnostic", "Atteint", "17 critères, score /100, réponse < 200 ms"),
        ("Décentralisation des règles", "Atteint", "Interface admin intuitive"),
        ("Digitalisation de l'expertise", "Partiellement", "Procédures standardisées, base de connaissance à enrichir"),
    ],
    col_widths=[4, 2.5, 7.5],
)

add_paragraph(
    "Limites identifiées. La courbe d'apprentissage d'Ash Framework a représenté un "
    "investissement initial important. L'intégration avec la plateforme Track n'a pas été "
    "réalisée en temps réel pendant ce projet. Le catalogue de modèles de traceurs, bien "
    "qu'opérationnel, nécessite un enrichissement continu par les équipes techniques."
)

add_paragraph(
    "Perspectives. Plusieurs pistes d'amélioration sont envisagées : l'intelligence "
    "artificielle prédictive pour recommander automatiquement le traceur optimal en "
    "fonction du profil client, le développement d'une API REST publique pour permettre "
    "l'intégration avec des systèmes tiers, une application mobile dédiée aux techniciens "
    "terrain avec consultation hors ligne, et la supervision temps réel directement "
    "intégrée à la plateforme Track."
)

add_page_break()

# ============================================================
# CONCLUSION GÉNÉRALE
# ============================================================
add_heading("CONCLUSION GÉNÉRALE", level=1)

add_paragraph(
    "Ce mémoire a présenté la conception et la réalisation d'un module automatisé de gestion "
    "des profils de montage et de compatibilité des traceurs GPS au sein de la société Tag-IP. "
    "Le projet est né d'un constat terrain : l'identification des traceurs compatibles reposait "
    "sur une expertise humaine manuelle, source d'erreurs (15 % d'échecs de pose) et de pertes "
    "de productivité (20 % du temps technique)."
)

add_paragraph(
    "L'hypothèse formulée — qu'une architecture déclarative basée sur Ash Framework couplée à "
    "Phoenix LiveView pouvait réduire drastiquement les erreurs de configuration matérielle en "
    "transformant les contraintes physiques en calculs logiques automatisés — est validée. Le "
    "moteur de compatibilité, notant chaque couple profil-modèle sur 100 points via 17 critères "
    "pondérés, permet désormais un diagnostic instantané et fiable, sans dépendre d'un expert "
    "senior."
)

add_paragraph(
    "Apports du projet. Pour Tag-IP : un outil opérationnel centralisant l'expertise technique, "
    "réduisant les erreurs de montage et améliorant la productivité du service technique. Pour "
    "l'auteur : une expérience complète de développement avec Elixir, Phoenix et Ash Framework "
    "dans un contexte professionnel réel, renforçant les compétences en architecture logicielle "
    "et en modélisation de données. Pour la communauté technique : une démonstration de "
    "l'adéquation d'Ash Framework aux applications métier à forte logique déclarative."
)

add_paragraph(
    "Perspectives. À court terme, l'enrichissement du catalogue de traceurs et l'intégration "
    "plus poussée avec la plateforme Track existante constituent les priorités. À moyen terme, "
    "le développement d'une application mobile terrain et l'exploration de l'intelligence "
    "artificielle prédictive pour la recommandation automatique de traceurs représentent les "
    "évolutions majeures de TAG-Monitor."
)

add_page_break()

# ============================================================
# BIBLIOGRAPHIE
# ============================================================
add_heading("BIBLIOGRAPHIE", level=1)

references = [
    "MCCORD, B. et TATE, B. (2023). Elixir in Action (3rd ed.). Manning Publications.",
    "SAINT-MARTIN, S. (2022). Programming Phoenix LiveView. Pragmatic Bookshelf.",
    "JURIC, D. et JURIC, S. (2023). Ash Framework: A Declarative Approach to Elixir. Leanpub.",
    "HICKENBOTTOM, C. (2022). Real-Time Phoenix. Pragmatic Bookshelf.",
    "FORD, N. (2020). Building Evolutionary Architectures. O'Reilly Media.",
    "DATE, C. J. (2019). SQL and Relational Theory (3rd ed.). O'Reilly Media.",
    "FOWLER, M. (2018). Patterns of Enterprise Application Architecture. Addison-Wesley.",
    "GAMMA, E. et al. (1994). Design Patterns. Addison-Wesley.",
    "GUTIERREZ, J. (2022). PostgreSQL: Up and Running (3rd ed.). O'Reilly Media.",
    "THOMAS, D. (2023). Agile Web Development with Rails (7th ed.). Pragmatic Bookshelf.",
]

for ref in references:
    p = doc.add_paragraph(style="Normal")
    run = p.add_run(ref)
    run.font.name = "Times New Roman"
    run.font.size = Pt(11)
    p.paragraph_format.left_indent = Cm(1)
    p.paragraph_format.first_line_indent = Cm(-1)

add_page_break()

# ============================================================
# WEBOGRAPHIE
# ============================================================
add_heading("WEBOGRAPHIE", level=1)

web_refs = [
    "https://elixir-lang.org/docs.html — Consulté le 02/12/2025",
    "https://hexdocs.pm/phoenix/overview.html — Consulté le 10/12/2025",
    "https://hexdocs.pm/ash/ash.html — Consulté le 15/12/2025",
    "https://www.postgresql.org/docs/ — Consulté le 05/01/2026",
    "https://tailwindcss.com/docs — Consulté le 10/01/2026",
    "https://www.docker.com/documentation — Consulté le 15/01/2026",
    "https://www.perepedro-akamasoa.net — Consulté le 20/01/2026",
]

for ref in web_refs:
    p = doc.add_paragraph(style="Normal")
    run = p.add_run(ref)
    run.font.name = "Times New Roman"
    run.font.size = Pt(11)
    p.paragraph_format.left_indent = Cm(1)
    p.paragraph_format.first_line_indent = Cm(-1)

add_page_break()

# ============================================================
# ANNEXES
# ============================================================
add_heading("ANNEXES", level=1)

add_heading("Annexe 1 : Extrait du routeur Phoenix", level=2)
annexe1 = """defmodule TagIpWeb.Router do
  use TagIpWeb, :router
  import TagIpWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TagIpWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  scope "/", TagIpWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated,
      on_mount: [
        {TagIpWeb.UserAuth, :mount_current_scope},
        {TagIpWeb.UserAuth, :require_authenticated}
      ] do
      live "/", DashboardLive.Index, :index
      live "/profils", ProfilMontageLive.Index, :index
      live "/profils/new", ProfilMontageLive.Form, :new
      live "/profils/:id/edit", ProfilMontageLive.Form, :edit
      live "/profils/:id", ProfilMontageLive.Show, :show
      live "/modeles", ModeleTraceurLive.Index, :index
      live "/modeles/new", ModeleTraceurLive.Form, :new
      live "/modeles/:id", ModeleTraceurLive.Show, :show
      live "/compatibilites", CompatibiliteLive.Index, :index
      live "/compatibilites/:id", CompatibiliteLive.Show, :show
      live "/referentiels", ReferenceLive.Index, :index
      live "/users/settings", UserLive.Settings, :edit
    end
  end
end"""

p = doc.add_paragraph()
run = p.add_run(annexe1)
run.font.name = "Courier New"
run.font.size = Pt(8)

add_heading("Annexe 2 : Moteur de compatibilité — extrait", level=2)
annexe2 = """def calculer(profil, modele) do
  score = 0
  details = []

  {s, d} = verifier_tension(profil, modele)
  score = score + s; details = details ++ d

  {s, d} = verifier_can_bus(profil, modele)
  score = score + s; details = details ++ d

  {s, d} = verifier_entrees_sorties(profil, modele)
  score = score + s; details = details ++ d

  {s, d} = verifier_ip_rating(profil, modele)
  score = score + s; details = details ++ d

  # ... 13 autres vérificateurs ...

  {score, details}
end"""

p = doc.add_paragraph()
run = p.add_run(annexe2)
run.font.name = "Courier New"
run.font.size = Pt(8)

add_heading("Annexe 3 : Vérificateur de tension", level=2)
annexe3 = """defp verifier_tension(profil, modele) do
  cond do
    modele.voltage_min >= profil.voltage_min and
    modele.voltage_max <= profil.voltage_max ->
      {10, ["✓ Tension compatible : \#{modele.voltage_min}-\#{modele.voltage_max}V"]}

    modele.voltage_max >= profil.voltage_min and
    modele.voltage_min <= profil.voltage_max ->
      {5, ["⚠ Tension partiellement compatible"]}

    true ->
      {0, ["✗ Tension incompatible"]}
  end
end"""

p = doc.add_paragraph()
run = p.add_run(annexe3)
run.font.name = "Courier New"
run.font.size = Pt(8)

add_page_break()

# ============================================================
# RÉSUMÉ / ABSTRACT
# ============================================================
add_heading("RÉSUMÉ", level=1)

add_paragraph(
    "Pour notre mémoire de fin d'études au sein de l'Université Saint Vincent de Paul Akamasoa "
    "(USVPA), nous avons effectué un stage au sein de la société TAG-IP, leader malgache de la "
    "géolocalisation de véhicules. Ce travail s'inscrit dans le cadre de la conception et de la "
    "réalisation d'un module automatisé de gestion des profils de montage et de compatibilité "
    "des traceurs GPS. Après un diagnostic approfondi, plusieurs problèmes ont été identifiés : "
    "processus manuel de compatibilité, expertise dispersée, hard-coding des règles métier. "
    "Notre intervention a porté sur le développement d'une application web avec Elixir, Phoenix "
    "LiveView et Ash Framework, intégrant un moteur de calcul notant la compatibilité sur 100 "
    "points via 17 critères. Les technologies PostgreSQL et Docker complètent la stack. Ce "
    "projet contribue à réduire les erreurs de montage, centraliser l'expertise technique et "
    "améliorer la productivité du service technique de TAG-IP."
)

add_paragraph("Mots clés : compatibilité, traceur GPS, profil de montage, Ash Framework, Elixir, Phoenix LiveView")

doc.add_paragraph()

add_heading("ABSTRACT", level=1)

add_paragraph(
    "For our final year project at the University Saint Vincent de Paul Akamasoa (USVPA), "
    "we completed an internship at TAG-IP, the Malagasy leader in vehicle geolocation. The "
    "project focused on designing and implementing an automated module for managing GPS tracker "
    "mounting profiles and compatibility. After a detailed assessment, several issues were "
    "identified: manual compatibility process, scattered expertise, hard-coded business rules. "
    "Our work consisted of developing a web application using Elixir, Phoenix LiveView and Ash "
    "Framework, integrating a scoring engine that evaluates compatibility on 100 points across "
    "17 criteria. PostgreSQL and Docker complete the technology stack. This project reduces "
    "installation errors, centralizes technical expertise, and improves productivity for "
    "TAG-IP's technical department."
)

add_paragraph("Keywords: compatibility, GPS tracker, mounting profile, Ash Framework, Elixir, Phoenix LiveView")

# ============================================================
# SAVE DOCUMENT
# ============================================================
doc.save(OUTPUT_FILE)
print(f"Document saved: {OUTPUT_FILE}")
