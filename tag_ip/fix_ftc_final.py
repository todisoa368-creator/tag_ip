#!/usr/bin/env python3
"""Final fix: accents + page breaks for chapters/parts."""

import re
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from docx.shared import Pt

SRC = "/Users/fitahiana/Desktop/ftc.docx"
DST = "/Users/fitahiana/Desktop/ftc_corrige.docx"

# ── 1. ACCENT FIXES (word boundary regex) ────────────────────
FIXES = {
    r"\bUniversite\b": "Université",
    r"\buniversite\b": "université",
    r"\bEcole\b": "École",
    r"\becole\b": "école",
    r"\bEtat\b": "État",
    r"\belabore\b": "élaboré",
    r"\belaboree\b": "élaborée",
    r"\belabores\b": "élaborés",
    r"\belaboration\b": "élaboration",
    r"\belement\b": "élément",
    r"\belements\b": "éléments",
    r"\bdecoupage\b": "découpage",
    r"\bdecrit\b": "décrit",
    r"\bdecrite\b": "décrite",
    r"\bdecrire\b": "décrire",
    r"\bdecrits\b": "décrits",
    r"\bdecrites\b": "décrites",
    r"\becrit\b": "écrit",
    r"\becrite\b": "écrite",
    r"\becrire\b": "écrire",
    r"\becrits\b": "écrits",
    r"\becrites\b": "écrites",
    r"\becran\b": "écran",
    r"\becrans\b": "écrans",
    r"\belimine\b": "éliminé",
    r"\beliminee\b": "éliminée",
    r"\beliminer\b": "éliminer",
    r"\belimination\b": "élimination",
    r"\beliminees\b": "éliminées",
    r"\bgenerateur\b": "générateur",
    r"\bgenerer\b": "générer",
    r"\bgenere\b": "généré",
    r"\bgeneree\b": "générée",
    r"\bgeneres\b": "générés",
    r"\bgenerees\b": "générées",
    r"\bgeneration\b": "génération",
    r"\beleve\b": "élevé",
    r"\belevee\b": "élevée",
    r"\belevation\b": "élévation",
    r"\bsysteme\b": "système",
    r"\bsystemes\b": "systèmes",
    r"\bSysteme\b": "Système",
    r"\bSystemes\b": "Systèmes",
    r"\breseau\b": "réseau",
    r"\breseaux\b": "réseaux",
    r"\bReseau\b": "Réseau",
    r"\bReseaux\b": "Réseaux",
    r"\bverificateur\b": "vérificateur",
    r"\bverificateurs\b": "vérificateurs",
    r"\bverifie\b": "vérifié",
    r"\bverifiee\b": "vérifiée",
    r"\bverifies\b": "vérifiés",
    r"\bverifier\b": "vérifier",
    r"\bverification\b": "vérification",
    r"\bverifications\b": "vérifications",
    r"\bplafonne\b": "plafonné",
    r"\bplafonnee\b": "plafonnée",
    r"\bplafonnes\b": "plafonnés",
    r"\bvalidee\b": "validée",
    r"\bvalides\b": "validés",
    r"\bvalidees\b": "validées",
    r"\bagrege\b": "agrégé",
    r"\bagregation\b": "agrégation",
    r"\betranger\b": "étranger",
    r"\betrangere\b": "étrangère",
    r"\betrangeres\b": "étrangères",
    r"\baccreditee\b": "accréditée",
    r"\bproprietaire\b": "propriétaire",
    r"\bproprietaires\b": "propriétaires",
    r"\bcomplement\b": "complément",
    r"\bcomplementaire\b": "complémentaire",
    r"\bcomplementaires\b": "complémentaires",
    r"\bcomplementarite\b": "complémentarité",
    r"\bsupplementaire\b": "supplémentaire",
    r"\bsupplementaires\b": "supplémentaires",
    r"\bheterogene\b": "hétérogène",
    r"\bheterogenes\b": "hétérogènes",
    r"\bpremiere\b": "première",
    r"\bpremieres\b": "premières",
    r"\bderniere\b": "dernière",
    r"\bdernieres\b": "dernières",
    r"\bentiere\b": "entière",
    r"\bentierement\b": "entièrement",
    r"\bimmediat\b": "immédiat",
    r"\bimmediate\b": "immédiate",
    r"\bimmediatement\b": "immédiatement",
    r"\bintermediaire\b": "intermédiaire",
    r"\bnecessaire\b": "nécessaire",
    r"\bnecessaires\b": "nécessaires",
    r"\bnecessite\b": "nécessité",
    r"\breel\b": "réel",
    r"\breelle\b": "réelle",
    r"\breels\b": "réels",
    r"\breelles\b": "réelles",
    r"\breellement\b": "réellement",
    r"\binteret\b": "intérêt",
    r"\binterets\b": "intérêts",
    r"\bpole\b": "pôle",
    r"\bpoles\b": "pôles",
    r"\bmemoire\b": "mémoire",
    r"\bmemoires\b": "mémoires",
    r"\bconcu\b": "conçu",
    r"\bconcue\b": "conçue",
    r"\bconcus\b": "conçus",
    r"\bconcues\b": "conçues",
    r"\bprocede\b": "procédé",
    r"\bproceder\b": "procéder",
    r"\bprocedure\b": "procédure",
    r"\bprocedures\b": "procédures",
    r"\bdecoulent\b": "découlent",
    r"\bdecoule\b": "découle",
    r"\bdecoulant\b": "découlant",
    r"\bproposer\b": "proposer",
    r"\bpropose\b": "proposé",
    r"\bproposee\b": "proposée",
    r"\bproposes\b": "proposés",
    r"\bproposees\b": "proposées",
    r"\btransfert\b": "transfert",
    r"\bvehicule\b": "véhicule",
    r"\bvehicules\b": "véhicules",
    r"\bsecurite\b": "sécurité",
    r"\bsecuriser\b": "sécuriser",
    r"\bsecurise\b": "sécurisé",
    r"\bsecurisee\b": "sécurisée",
    r"\bsecurises\b": "sécurisés",
    r"\bdisponibilite\b": "disponibilité",
    r"\bresponsabilite\b": "responsabilité",
    r"\bresponsabilites\b": "responsabilités",
    r"\bcapacite\b": "capacité",
    r"\bcapacites\b": "capacités",
    r"\bcompatibilite\b": "compatibilité",
    r"\bcompatibilites\b": "compatibilités",
    r"\bincompatibilite\b": "incompatibilité",
    r"\bincompatibilites\b": "incompatibilités",
    r"\bqualite\b": "qualité",
    r"\bqualites\b": "qualités",
    r"\bscalabilite\b": "scalabilité",
    r"\bcategorie\b": "catégorie",
    r"\bcategories\b": "catégories",
    r"\bspecifique\b": "spécifique",
    r"\bspecifiques\b": "spécifiques",
    r"\bspecifiquement\b": "spécifiquement",
    r"\bcaracteristique\b": "caractéristique",
    r"\bcaracteristiques\b": "caractéristiques",
    r"\bautomatise\b": "automatisé",
    r"\bautomatisee\b": "automatisée",
    r"\bautomatises\b": "automatisés",
    r"\bautomatisees\b": "automatisées",
    r"\bcentralise\b": "centralisé",
    r"\bcentralisee\b": "centralisée",
    r"\bcentralises\b": "centralisés",
    r"\bdetaille\b": "détaillé",
    r"\bdetaillee\b": "détaillée",
    r"\bdetaillees\b": "détaillées",
    r"\bdetail\b": "détail",
    r"\bdetailles\b": "détails",
    r"\bjustifie\b": "justifié",
    r"\bjustifiee\b": "justifiée",
    r"\bjustifies\b": "justifiés",
    r"\bpondere\b": "pondéré",
    r"\bponderee\b": "pondérée",
    r"\bponderes\b": "pondérés",
    r"\bponderer\b": "pondérer",
    r"\bponderation\b": "pondération",
    r"\bponderations\b": "pondérations",
    r"\balimenter\b": "alimenter",
    r"\balimente\b": "alimenté",
    r"\balimentee\b": "alimentée",
    r"\balimentes\b": "alimentés",
    r"\bdeploiement\b": "déploiement",
    r"\bdeployer\b": "déployer",
    r"\bdeploye\b": "déployé",
    r"\bdeployee\b": "déployée",
    r"\bdeployes\b": "déployés",
    r"\bdeveloppement\b": "développement",
    r"\bDeveloppement\b": "Développement",
    r"\bdeveloppeur\b": "développeur",
    r"\bdeveloppeurs\b": "développeurs",
    r"\bdevelopper\b": "développer",
    r"\bdeveloppe\b": "développé",
    r"\bdeveloppee\b": "développée",
    r"\bdeveloppes\b": "développés",
    r"\bpresence\b": "présence",
    r"\bpresentation\b": "présentation",
    r"\bpresenter\b": "présenter",
    r"\bpresente\b": "présenté",
    r"\bpresentee\b": "présentée",
    r"\brepresentation\b": "représentation",
    r"\brepresenter\b": "représenter",
    r"\brepresente\b": "représenté",
    r"\brepresentee\b": "représentée",
    r"\bimplementation\b": "implémentation",
    r"\bimplementer\b": "implémenter",
    r"\bimplemente\b": "implémenté",
    r"\bimplementee\b": "implémentée",
    r"\bimplementes\b": "implémentés",
    r"\bintegration\b": "intégration",
    r"\bintegre\b": "intégré",
    r"\bintegree\b": "intégrée",
    r"\bintegres\b": "intégrés",
    r"\bconfigurer\b": "configurer",
    r"\bconfigure\b": "configuré",
    r"\bconfiguree\b": "configurée",
    r"\bconfiguration\b": "configuration",
    r"\boptimiser\b": "optimiser",
    r"\boptimise\b": "optimisé",
    r"\boptimisee\b": "optimisée",
    r"\boptimises\b": "optimisés",
    r"\boptimisation\b": "optimisation",
    r"\bacces\b": "accès",
    r"\bacceder\b": "accéder",
    r"\binteroperabilite\b": "interopérabilité",
    r"\bmaintenabilite\b": "maintenabilité",
    r"\breutilisable\b": "réutilisable",
    r"\breutilisabilite\b": "réutilisabilité",
    r"\bextensibilite\b": "extensibilité",
    r"\bextensible\b": "extensible",
    r"\bmaintenable\b": "maintenable",
    r"\bheterogeneite\b": "hétérogénéité",
    r"\btransparence\b": "transparence",
    r"\brobustesse\b": "robustesse",
    r"\bflexibilite\b": "flexibilité",
    r"\bfiabilite\b": "fiabilité",
    r"\befficacite\b": "efficacité",
    r"\bpertinence\b": "pertinence",
    r"\bpertinent\b": "pertinent",
    r"\bpertinente\b": "pertinente",
    r"\bexigence\b": "exigence",
    r"\bexigences\b": "exigences",
    r"\bstatistique\b": "statistique",
    r"\bstatistiques\b": "statistiques",
    r"\bgraphique\b": "graphique",
    r"\bgraphiques\b": "graphiques",
    r"\bgeolocalisation\b": "géolocalisation",
    r"\bgeolocaliser\b": "géolocaliser",
    r"\bgeospatial\b": "géospatial",
    r"\bmateriel\b": "matériel",
    r"\bmateriels\b": "matériels",
    r"\blogiciel\b": "logiciel",
    r"\blogiciels\b": "logiciels",
    r"\btechnicien\b": "technicien",
    r"\btechniciens\b": "techniciens",
    r"\bsociete\b": "société",
    r"\bdonnees\b": "données",
    r"\bsuperieur\b": "supérieur",
    r"\bsuperieurs\b": "supérieurs",
    r"\bsuperieure\b": "supérieure",
    r"\bsuperieures\b": "supérieures",
    r"\bentite\b": "entité",
    r"\bentites\b": "entités",
    r"\bprobleme\b": "problème",
    r"\bproblemes\b": "problèmes",
    r"\bproblematique\b": "problématique",
    r"\bschema\b": "schéma",
    r"\bschemas\b": "schémas",
    r"\bmethode\b": "méthode",
    r"\bmethodes\b": "méthodes",
    r"\bmethodologie\b": "méthodologie",
    r"\bparametre\b": "paramètre",
    r"\bparametres\b": "paramètres",
    r"\bregle\b": "règle",
    r"\bregles\b": "règles",
    r"\betape\b": "étape",
    r"\betapes\b": "étapes",
    r"\bconsequence\b": "conséquence",
    r"\bconsequences\b": "conséquences",
    r"\bevenement\b": "événement",
    r"\bevenements\b": "événements",
    r"\barchitecture\b": "architecture",
    r"\benvironnement\b": "environnement",
    r"\bexploitation\b": "exploitation",
    r"\bobjectif\b": "objectif",
    r"\bobjectifs\b": "objectifs",
    r"\bressource\b": "ressource",
    r"\bressources\b": "ressources",
    r"\binterface\b": "interface",
    r"\blimite\b": "limite",
    r"\blimites\b": "limites",
    r"\blimitation\b": "limitation",
    r"\bmaitrise\b": "maîtrise",
    r"\bmarche\b": "marché",
    r"\bmarchés\b": "marchés",
    r"\bmigration\b": "migration",
    r"\bmigrations\b": "migrations",
    r"\bmodification\b": "modification",
    r"\bmodule\b": "module",
    r"\bmontage\b": "montage",
    r"\bmoteur\b": "moteur",
    r"\bmoteurs\b": "moteurs",
    r"\bmotivation\b": "motivation",
    r"\bmoyen\b": "moyen",
    r"\bmoyens\b": "moyens",
    r"\bnombreux\b": "nombreux",
    r"\borganisation\b": "organisation",
    r"\bparticulier\b": "particulier",
    r"\bparticuliere\b": "particulière",
    r"\bparticulierement\b": "particulièrement",
    r"\bperformance\b": "performance",
    r"\bperformances\b": "performances",
    r"\bperspective\b": "perspective",
    r"\bperspectives\b": "perspectives",
    r"\bplateforme\b": "plateforme",
    r"\btolerance\b": "tolérance",
    r"\btolerer\b": "tolérer",
    r"\bstructure\b": "structure",
    r"\bstructurer\b": "structurer",
    r"\bstructuree\b": "structurée",
    r"\bsucces\b": "succès",
    r"\bsuppression\b": "suppression",
    r"\bsurveillance\b": "surveillance",
    r"\bsynchronisation\b": "synchronisation",
    r"\btableau\b": "tableau",
    r"\btache\b": "tâche",
    r"\btaches\b": "tâches",
    r"\btendance\b": "tendance",
    r"\btension\b": "tension",
    r"\btensions\b": "tensions",
    r"\bterminologie\b": "terminologie",
    r"\btest\b": "test",
    r"\btests\b": "tests",
    r"\btraceur\b": "traceur",
    r"\btraceurs\b": "traceurs",
    r"\btraitement\b": "traitement",
    r"\btraitements\b": "traitements",
    r"\btransaction\b": "transaction",
    r"\btransformation\b": "transformation",
    r"\btransmettre\b": "transmettre",
    r"\butilisation\b": "utilisation",
    r"\butiliser\b": "utiliser",
    r"\butilise\b": "utilisé",
    r"\butilisee\b": "utilisée",
    r"\brealisation\b": "réalisation",
    r"\brealiser\b": "réaliser",
    r"\brealise\b": "réalisé",
    r"\breduction\b": "réduction",
    r"\breduire\b": "réduire",
    r"\breduit\b": "réduit",
    r"\breference\b": "référence",
    r"\breferences\b": "références",
    r"\breferentiel\b": "référentiel",
    r"\breflexion\b": "réflexion",
    r"\bregion\b": "région",
    r"\bregional\b": "régional",
    r"\bregionale\b": "régionale",
    r"\bregulierement\b": "régulièrement",
    r"\brelation\b": "relation",
    r"\brelations\b": "relations",
    r"\brenouvellement\b": "renouvellement",
    r"\brentabilite\b": "rentabilité",
    r"\breprise\b": "reprise",
    r"\bresponsable\b": "responsable",
    r"\bresponsables\b": "responsables",
    r"\brestitution\b": "restitution",
    r"\bresultat\b": "résultat",
    r"\bresultats\b": "résultats",
    r"\bresume\b": "résumé",
    r"\bretard\b": "retard",
    r"\bretour\b": "retour",
    r"\breunion\b": "réunion",
    r"\breunions\b": "réunions",
    r"\breutilisation\b": "réutilisation",
    r"\breussite\b": "réussite",
    r"\bvalidation\b": "validation",
    r"\bvalorisation\b": "valorisation",
    r"\bvariabilite\b": "variabilité",
    r"\bvariante\b": "variante",
    r"\bvariantes\b": "variantes",
    r"\bversion\b": "version",
    r"\bversions\b": "versions",
    r"\bviabilite\b": "viabilité",
    r"\bviable\b": "viable",
    r"\bvolume\b": "volume",
    r"\bvolumes\b": "volumes",
    r"\bcapitaliser\b": "capitaliser",
    r"\bcapture\b": "capture",
    r"\bcertification\b": "certification",
    r"\bchaine\b": "chaîne",
    r"\bchaines\b": "chaînes",
    r"\bchangement\b": "changement",
    r"\bchapitre\b": "chapitre",
    r"\bchapitres\b": "chapitres",
    r"\bcharge\b": "charge",
    r"\bcollecte\b": "collecte",
    r"\bcollecter\b": "collecter",
    r"\bcomite\b": "comité",
    r"\bcommande\b": "commande",
    r"\bcommandes\b": "commandes",
    r"\bcommentaire\b": "commentaire",
    r"\bcommentaires\b": "commentaires",
    r"\bcommission\b": "commission",
    r"\bcommunication\b": "communication",
    r"\bcompatible\b": "compatible",
    r"\bcompatibles\b": "compatibles",
    r"\bcomposant\b": "composant",
    r"\bcomposants\b": "composants",
    r"\bcomportement\b": "comportement",
    r"\bcomprehension\b": "compréhension",
    r"\bIngenierie\b": "Ingénierie",
    r"\bingenierie\b": "ingénierie",
    r"\bIngenieur\b": "Ingénieur",
    r"\bingenieur\b": "ingénieur",
    r"\bModele\b": "Modèle",
    r"\bmodele\b": "modèle",
    r"\bModeles\b": "Modèles",
    r"\bmodeles\b": "modèles",
    r"\bMemoire\b": "Mémoire",
    r"\bConcu\b": "Conçu",
    r"\bConcue\b": "Conçue",
    r"\bCompatible\b": "Compatible",
    r"\bComposant\b": "Composant",
    r"\bStructure\b": "Structure",
    r"\bProcede\b": "Procédé",
    r"\bProjet\b": "Projet",
    r"\bProbleme\b": "Problème",
    r"\bProblemes\b": "Problèmes",
    r"\bProcedure\b": "Procédure",
    r"\bProcedures\b": "Procédures",
    r"\bSchema\b": "Schéma",
    r"\bSchemas\b": "Schémas",
    r"\bMethode\b": "Méthode",
    r"\bMethodes\b": "Méthodes",
    r"\btelémetrie\b": "télémétrie",
    r"\bTélémétrie\b": "Télémétrie",
    r"\bparamétrage\b": "paramétrage",
    r"\bParamétrage\b": "Paramétrage",
    r"\bmappé\b": "mappé",
    r"\bpropriétaire\b": "propriétaire",
    r"\bPropriétaire\b": "Propriétaire",
    r"\bPartie\b": "Partie",
    r"\bpartie\b": "partie",
    r"\bParties\b": "Parties",
    r"\bparties\b": "parties",
}

# ── 2. PAGE BREAKS ────────────────────────────────────────────
PAGE_BREAK_BEFORE = [
    "INTRODUCTION",
    "PARTIE I",
    "PARTIE II",
    "PARTIE III",
    "CONCLUSION",
    "BIBLIOGRAPHIE",
    "ANNEXES",
]

PAGE_BREAK_CONTAINS = [
    "Chapitre 1",
    "Chapitre 2",
    "Chapitre 3",
    "Chapitre 4",
    "Chapitre 5",
    "Chapitre 6",
]


def is_code_paragraph(text):
    code_indicators = ["def ", "defp ", "defmodule", "fn ", "|>",
                       "socket", "_attrs", "@", "%{"]
    return any(indicator in text for indicator in code_indicators)


def add_page_break_before(paragraph):
    """Add w:pageBreakBefore to paragraph properties."""
    pPr = paragraph._p.find(qn('w:pPr'))
    if pPr is None:
        pPr = OxmlElement('w:pPr')
        paragraph._p.insert(0, pPr)
    # Check if already exists
    existing = pPr.find(qn('w:pageBreakBefore'))
    if existing is None:
        pPr.append(OxmlElement('w:pageBreakBefore'))


def process_document():
    doc = Document(SRC)
    in_annex = False
    total_fixes = 0
    breaks_added = 0

    for para in doc.paragraphs:
        text = para.text.strip()

        # Track annex section
        if text in ("ANNEXES",) or text.startswith("ANNEXES"):
            in_annex = True
        if text == "BIBLIOGRAPHIE":
            in_annex = False

        # ── Apply accent fixes ──
        use_code = in_annex and is_code_paragraph(para.text)
        for run in para.runs:
            old = run.text
            if not old:
                continue
            new = old
            for pattern, replacement in FIXES.items():
                new = re.sub(pattern, replacement, new)
            if use_code:
                # In code, undo French accents on Elixir identifiers
                new = new.replace("vérifier", "verifier")
                new = new.replace("Vérifier", "Verifier")
                new = new.replace("vérificateur", "verificateur")
                new = new.replace("Vérificateur", "Verificateur")
                new = new.replace("End", "end")
                new = new.replace("voltage min", "voltage_min")
                new = new.replace("voltage max", "voltage_max")
                new = new.replace("profil montage_id", "profil_montage_id")
                new = new.replace("modele traceur id", "modele_traceur_id")
            if new != old:
                run.text = new
                total_fixes += 1

        # ── Add page breaks ──
        should_break = False
        for marker in PAGE_BREAK_BEFORE:
            if text == marker or text.startswith(marker):
                should_break = True
                break
        for marker in PAGE_BREAK_CONTAINS:
            if marker in text:
                should_break = True
                break

        if should_break and text:  # skip empty paragraphs
            add_page_break_before(para)
            breaks_added += 1

    # ── Fix tables ──
    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for para in cell.paragraphs:
                    for run in para.runs:
                        old = run.text
                        if not old:
                            continue
                        new = old
                        for pattern, replacement in FIXES.items():
                            new = re.sub(pattern, replacement, new)
                        if new != old:
                            run.text = new
                            total_fixes += 1

    doc.save(DST)
    print(f"✅ Saved: {DST}")
    print(f"🔧 {total_fixes} run(s) modified (accents & spelling)")
    print(f"📄 {breaks_added} page break(s) added")

    # Final verification
    remaining = []
    seen = set()
    for para in doc.paragraphs:
        for pattern, _ in FIXES.items():
            wrong = pattern.strip("\\b")
            if wrong in seen:
                continue
            if re.search(pattern, para.text):
                remaining.append(wrong)
                seen.add(wrong)
    if remaining:
        print(f"⚠️  {len(remaining)} word(s) may still need accents:")
        for w in remaining[:20]:
            print(f"   - {w}")


if __name__ == "__main__":
    process_document()
