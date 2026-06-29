#!/usr/bin/env python3
"""Generate professional diagrams for the FTC thesis using Graphviz.

Outputs PNG files to ~/Desktop/fitahiana/
"""

import os
import graphviz

OUT = "/Users/fitahiana/Desktop/fitahiana"
os.makedirs(OUT, exist_ok=True)

COMMON = {
    "fontname": "Helvetica",
    "fontsize": "11",
    "labelfontname": "Helvetica",
    "labelfontsize": "12",
}


def organigramme():
    dot = graphviz.Digraph(
        "Organigramme",
        format="png",
        graph_attr={
            **COMMON,
            "rankdir": "TB",
            "splines": "ortho",
            "nodesep": "0.3",
            "ranksep": "0.5",
        },
    )
    dot.attr("node", shape="box", style="filled,rounded", fillcolor="#E8F0FE",
             fontname="Helvetica", fontsize="10")

    # Root
    dot.node("DG", "Directeur Général\nMarc Rivera", fillcolor="#1A73E8",
             fontcolor="white", fontsize="11", shape="box", style="filled,rounded")

    # Level 2
    dot.node("RH", "Direction RH\n& Exploitation", fillcolor="#E8F0FE")
    dot.node("MKT", "Direction Marketing\n& Commercial", fillcolor="#E8F0FE")
    dot.node("DSI", "Direction des\nSystèmes d'Information\nGilles Chapoton",
             fillcolor="#E8F0FE")

    dot.edge("DG", "RH")
    dot.edge("DG", "MKT")
    dot.edge("DG", "DSI")

    # Level 3 - DSI sub-teams
    dot.node("INFRA", "Infrastructure\nRéseau & Serveurs", fillcolor="#FFF3E0")
    dot.node("DEV", "Pôle Ingénierie\nLogicielle", fillcolor="#FFF3E0",
             style="filled,rounded,bold", color="#FB8C00")
    dot.node("OPS", "Support & \nExploitation", fillcolor="#FFF3E0")

    dot.edge("DSI", "INFRA")
    dot.edge("DSI", "DEV")
    dot.edge("DSI", "OPS")

    # Highlight the stage position
    dot.node("STAGE", "👤 Stagiaire\nDTS ESTIA\nTAG-Monitor",
             fillcolor="#FF6D00", fontcolor="white", fontsize="10",
             style="filled,rounded", shape="box")
    dot.edge("DEV", "STAGE", style="dashed", color="#FF6D00", penwidth="2")

    dot.render(os.path.join(OUT, "organigramme_tagip"), cleanup=True)
    print("✅ organigramme_tagip.png")


def architecture_reseau():
    dot = graphviz.Digraph(
        "ArchitectureReseau",
        format="png",
        graph_attr={
            **COMMON,
            "rankdir": "TB",
            "splines": "ortho",
            "nodesep": "0.3",
            "ranksep": "0.4",
            "dpi": "200",
        },
    )

    # External
    dot.node("EXTERNAL", "Internet &\nRéseau Mobile (3G/GPRS)",
             shape="box", style="filled,rounded", fillcolor="#E3F2FD")

    dot.node("FW", "Pare-feu\nIDS/IPS",
             shape="box", style="filled,rounded", fillcolor="#FFCDD2")

    dot.edge("EXTERNAL", "FW", label="Trafic entrant")

    # VLANs
    with dot.subgraph(name="cluster_vlans") as s:
        s.attr(label="VLANs (segmentation)", style="filled,rounded,dashed",
               fillcolor="#F3E5F5", fontname="Helvetica", fontsize="11")
        s.node("VLAN_ADMIN", "VLAN Administration\n(VLAN 20)\nOutils métier & postes",
               shape="box", style="filled,rounded", fillcolor="#CE93D8")
        s.node("VLAN_GPS", "VLAN GPS / Tracking\n(VLAN 10)\nFlux données traceurs",
               shape="box", style="filled,rounded", fillcolor="#CE93D8")
        s.node("VLAN_DEV", "VLAN Développement\n(VLAN 30)\nTest & intégration",
               shape="box", style="filled,rounded", fillcolor="#CE93D8")

    dot.edge("FW", "VLAN_ADMIN", style="dashed")
    dot.edge("FW", "VLAN_GPS", style="dashed")
    dot.edge("FW", "VLAN_DEV", style="dashed")

    # Infrastructure
    dot.node("SERV", "Cluster serveurs\n(HA - Haute disponibilité)",
             shape="box", style="filled,rounded", fillcolor="#C8E6C9")
    dot.node("RAID", "Stockage RAID\n(Réplication temps réel)",
             shape="box", style="filled,rounded", fillcolor="#C8E6C9")
    dot.node("DB", "PostgreSQL 16\n+ PostGIS",
             shape="cylinder", style="filled", fillcolor="#BBDEFB")

    dot.edge("VLAN_ADMIN", "SERV")
    dot.edge("VLAN_GPS", "SERV")
    dot.edge("SERV", "RAID", style="dashed")
    dot.edge("SERV", "DB", label="Données")

    # Data flow annotation
    dot.node("FLOW", "Cycle de traitement :\n① Réception trame → ② Parsing\n③ Calcul compatibilité → ④ Notification",
             shape="box", style="filled,rounded", fillcolor="#FFF9C4",
             fontsize="9")

    dot.edge("VLAN_GPS", "FLOW", style="dotted", constraint="false")

    dot.render(os.path.join(OUT, "architecture_reseau"), cleanup=True)
    print("✅ architecture_reseau.png")


def architecture_globale():
    dot = graphviz.Digraph(
        "ArchitectureGlobale",
        format="png",
        graph_attr={
            **COMMON,
            "rankdir": "TB",
            "splines": "ortho",
            "nodesep": "0.2",
            "ranksep": "0.4",
            "dpi": "200",
        },
    )

    # Presentation layer
    with dot.subgraph(name="cluster_presentation") as s:
        s.attr(label="Couche Présentation (Phoenix LiveView)", style="filled,rounded",
               fillcolor="#E3F2FD", fontname="Helvetica", fontsize="11",
               fontcolor="#1565C0")
        s.node("LV", "LiveViews\n(Wizard, Dashboard,\nCatalogue, etc.)",
               shape="box", style="filled,rounded", fillcolor="#90CAF9")
        s.node("HEEx", "Composants HEEx\n(Cartes, formulaires,\ntableaux, graphiques)",
               shape="box", style="filled,rounded", fillcolor="#90CAF9")
        s.node("WS", "WebSocket\n(PubSub temps réel)",
               shape="box", style="filled,rounded", fillcolor="#90CAF9")

    # Business / Ash layer
    with dot.subgraph(name="cluster_ash") as s:
        s.attr(label="Couche Métier (Ash Framework)", style="filled,rounded",
               fillcolor="#E8F5E9", fontname="Helvetica", fontsize="11",
               fontcolor="#2E7D32")
        s.node("RESS", "Ressources Ash\n(ProfilMontage,\nModeleTraceur,\nCompatibilité,\netc.)",
               shape="box", style="filled,rounded", fillcolor="#81C784")
        s.node("POL", "Politiques\n(Ash Policies)\nSécurité & ACL",
               shape="box", style="filled,rounded", fillcolor="#81C784")
        s.node("MOTEUR", "Moteur compatibilité\n(20 critères,\npatron Strategy)",
               shape="box", style="filled,rounded", fillcolor="#A5D6A7",
               fontcolor="#1B5E20")

    # Data layer
    with dot.subgraph(name="cluster_data") as s:
        s.attr(label="Couche Persistance (PostgreSQL)", style="filled,rounded",
               fillcolor="#FFF3E0", fontname="Helvetica", fontsize="11",
               fontcolor="#E65100")
        s.node("PG", "PostgreSQL 16\n+ AshPostgres\n(22 migrations, requêtes\noptimisées)",
               shape="cylinder", style="filled", fillcolor="#FFCC80")

    # Edges
    dot.edge("LV", "RESS", label="Requêtes Ash")
    dot.edge("HEEx", "LV")
    dot.edge("WS", "LV")
    dot.edge("RESS", "MOTEUR", label="Calcul scoring")
    dot.edge("RESS", "PG", label="CRUD / Queries")
    dot.edge("POL", "RESS", style="dashed", label="Contrôle")
    dot.edge("MOTEUR", "RESS", style="dotted", label="Résultat")

    dot.render(os.path.join(OUT, "architecture_globale"), cleanup=True)
    print("✅ architecture_globale.png")


def mcd():
    """Modèle Conceptuel de Données (Merise) – comme le MLD avec relations."""
    dot = graphviz.Digraph(
        "MCD",
        format="png",
        graph_attr={
            **COMMON,
            "rankdir": "TB",
            "nodesep": "0.15",
            "ranksep": "0.25",
            "dpi": "200",
        },
    )

    def entity(name, columns, color="#E3F2FD"):
        rows = ""
        for col in columns:
            rows += f'<TR><TD ALIGN="LEFT" BGCOLOR="white">{col}</TD></TR>\n'
        label = f"""<
<TABLE BORDER="0" CELLBORDER="0" CELLSPACING="2">
<TR><TD BGCOLOR="{color}" COLSPAN="1"><B>{name}</B></TD></TR>
{rows}
</TABLE>>"""
        dot.node(name, label, shape="plaintext", fontname="Helvetica", fontsize="9")

    # Entities with their conceptual attributes (no FK, pure business concepts)
    entity("ProfilMontage",
           ["Identifiant (UUID)",
            "Nom du profil",
            "Description technique",
            "Type de véhicule",
            "Alimentation",
            "Tension min (V)",
            "Tension max (V)",
            "Capteurs requis",
            "Fonctionnalités souhaitées",
            "Date de création"],
           "#1A73E8")

    entity("ModeleTraceur",
           ["Identifiant (UUID)",
            "Nom du modèle",
            "Marque (constructeur)",
            "Type de bus",
            "Tension min (V)",
            "Tension max (V)",
            "Alimentation supportée",
            "Types de véhicule supportés",
            "Capteurs compatibles",
            "Périphériques intégrables",
            "Fonctionnalités disponibles"],
           "#2E7D32")

    entity("Compatibilité",
           ["Identifiant (UUID)",
            "Profil de montage concerné",
            "Modèle de traceur évalué",
            "Score (0-100)",
            "Détails du calcul (JSON)",
            "Date d'évaluation"],
           "#E65100")

    entity("TypeVehicule",
           ["Identifiant (UUID)",
            "Nom du type",
            "Description"],
           "#6A1B9A")

    entity("Alimentation",
           ["Identifiant (UUID)",
            "Type (12V filaire, 24V, OBD, etc.)",
            "Tension min (V)",
            "Tension max (V)"],
           "#F57F17")

    entity("Capteur",
           ["Identifiant (UUID)",
            "Nom du capteur",
            "Catégorie (énergie, environnement, etc.)"],
           "#C62828")

    entity("Feature",
           ["Identifiant (UUID)",
            "Nom de la fonctionnalité",
            "Description"],
           "#558B2F")

    entity("Peripheral",
           ["Identifiant (UUID)",
            "Nom du périphérique",
            "Type de port"],
           "#00838F")

    # ── Relationships with cardinalities ──
    dot.attr("edge", fontname="Helvetica", fontsize="8", color="#555555")

    dot.edge("ProfilMontage", "TypeVehicule",
             label="concerne\n1,1 → 1,N", style="dashed")
    dot.edge("ProfilMontage", "Alimentation",
             label="définit\n1,1 → 1,N", style="dashed")
    dot.edge("ProfilMontage", "Capteur",
             label="nécessite\n1,1 → 0,N")
    dot.edge("ProfilMontage", "Feature",
             label="supporte\n1,1 → 0,N")
    dot.edge("ProfilMontage", "Compatibilité",
             label="évalué par\n1,1 → 0,N", style="dotted",
             color="#E65100")
    dot.edge("ModeleTraceur", "Compatibilité",
             label="évalue\n1,1 → 0,N", style="dotted",
             color="#E65100")
    dot.edge("ModeleTraceur", "TypeVehicule",
             label="supporté par\n1,N → 1,1")
    dot.edge("ModeleTraceur", "Alimentation",
             label="alimenté par\n1,1 → 1,N")
    dot.edge("ModeleTraceur", "Feature",
             label="propose\n1,1 → 0,N")
    dot.edge("ModeleTraceur", "Peripheral",
             label="équipé de\n1,1 → 0,N")
    dot.edge("ModeleTraceur", "Capteur",
             label="compatible\n1,N → 0,N")

    dot.render(os.path.join(OUT, "mcd_tag_monitor"), cleanup=True)
    print("✅ mcd_tag_monitor.png")


def mld():
    """Modèle Logique de Données – Tables relationnelles."""
    dot = graphviz.Digraph(
        "MLD",
        format="png",
        graph_attr={
            **COMMON,
            "rankdir": "TB",
            "nodesep": "0.15",
            "ranksep": "0.25",
            "dpi": "200",
        },
    )

    def table(name, columns, color="#E3F2FD"):
        """Create a table node with proper HTML-like label."""
        rows = ""
        for col in columns:
            rows += f'<TR><TD ALIGN="LEFT" BGCOLOR="white">{col}</TD></TR>\n'
        label = f"""<
<TABLE BORDER="0" CELLBORDER="0" CELLSPACING="2">
<TR><TD BGCOLOR="{color}" COLSPAN="1"><B>{name}</B></TD></TR>
{rows}
</TABLE>>"""
        dot.node(name, label, shape="plaintext", fontname="Helvetica", fontsize="9")

    # Tables
    table("mounting_profiles", [
        "PK id (UUID)",
        "name VARCHAR(255)",
        "description TEXT",
        "type_vehicule_id (FK)",
        "alimentation_id (FK)",
        "voltage_min INT",
        "voltage_max INT",
        "created_at TIMESTAMP",
        "updated_at TIMESTAMP",
    ], "#1A73E8")

    table("modele_traceurs", [
        "PK id (UUID)",
        "nom VARCHAR(255)",
        "marque VARCHAR(100)",
        "type_bus VARCHAR(50)",
        "voltage_min INT",
        "voltage_max INT",
        "alimentation_id (FK)",
        "created_at TIMESTAMP",
    ], "#2E7D32")

    table("compatibilities", [
        "PK id (UUID)",
        "profil_montage_id (FK)",
        "modele_traceur_id (FK)",
        "score INT",
        "details JSONB",
        "UNIQUE(profil, modèle)",
    ], "#E65100")

    table("type_vehicules", [
        "PK id (UUID)",
        "nom VARCHAR(100)",
        "description TEXT",
    ], "#6A1B9A")

    table("alimentations", [
        "PK id (UUID)",
        "type VARCHAR(50)",
        "voltage_min INT",
        "voltage_max INT",
    ], "#F57F17")

    table("capteurs", [
        "PK id (UUID)",
        "nom VARCHAR(100)",
        "categorie VARCHAR(50)",
    ], "#C62828")

    table("features", [
        "PK id (UUID)",
        "nom VARCHAR(100)",
        "description TEXT",
    ], "#558B2F")

    table("peripherals", [
        "PK id (UUID)",
        "nom VARCHAR(100)",
        "type_port VARCHAR(50)",
    ], "#00838F")

    # Junction tables
    table("profil_montage_capteurs", [
        "profil_montage_id (FK)",
        "capteur_id (FK)",
        "UNIQUE(profil, capteur)",
    ], "#78909C")

    table("modele_traceur_features", [
        "modele_traceur_id (FK)",
        "feature_id (FK)",
        "UNIQUE(modèle, feature)",
    ], "#78909C")

    table("modele_traceur_peripherals", [
        "modele_traceur_id (FK)",
        "peripheral_id (FK)",
        "UNIQUE(modèle, périphérique)",
    ], "#78909C")

    # Relationships
    dot.edge("mounting_profiles", "type_vehicules", style="dashed", arrowhead="normal")
    dot.edge("mounting_profiles", "alimentations", style="dashed", arrowhead="normal")
    dot.edge("modele_traceurs", "alimentations", style="dashed", arrowhead="normal")
    dot.edge("modele_traceurs", "type_vehicules", style="dashed")
    dot.edge("compatibilities", "mounting_profiles", style="dashed", color="#E65100")
    dot.edge("compatibilities", "modele_traceurs", style="dashed", color="#E65100")
    dot.edge("profil_montage_capteurs", "mounting_profiles", style="dotted")
    dot.edge("profil_montage_capteurs", "capteurs", style="dotted")
    dot.edge("modele_traceur_features", "modele_traceurs", style="dotted")
    dot.edge("modele_traceur_features", "features", style="dotted")
    dot.edge("modele_traceur_peripherals", "modele_traceurs", style="dotted")
    dot.edge("modele_traceur_peripherals", "peripherals", style="dotted")

    dot.render(os.path.join(OUT, "mld_tag_monitor"), cleanup=True)
    print("✅ mld_tag_monitor.png")


def architecture_couches():
    """Layered architecture diagram (3-tier)."""
    dot = graphviz.Digraph(
        "Couches",
        format="png",
        graph_attr={
            **COMMON,
            "rankdir": "TB",
            "splines": "ortho",
            "nodesep": "0.1",
            "ranksep": "0.15",
            "dpi": "200",
        },
    )

    dot.attr("node", shape="box", style="filled,rounded", fontname="Helvetica")

    # Layer 1 - Presentation
    with dot.subgraph(name="cluster_pres") as s:
        s.attr(label="Couche Présentation (Frontend)", style="filled,rounded",
               fillcolor="#E3F2FD", fontname="Helvetica", fontsize="12",
               fontcolor="#1565C0")
        s.node("LV", "LiveView (HTML/HEEx)\nRendu côté serveur", fillcolor="#90CAF9")
        s.node("WS2", "WebSocket / PubSub\nTemps réel", fillcolor="#90CAF9")
        s.node("CSS", "Tailwind CSS\nDesign system responsive", fillcolor="#90CAF9")

    # Layer 2 - Business
    with dot.subgraph(name="cluster_biz") as s:
        s.attr(label="Couche Métier (Backend)", style="filled,rounded",
               fillcolor="#E8F5E9", fontname="Helvetica", fontsize="12",
               fontcolor="#2E7D32")
        s.node("ASH", "Ash Framework\nRessources, Actions,\nPolitiques, Validations",
               fillcolor="#81C784")
        s.node("COMPAT", "Moteur Compatibilité\n20 critères, Strategy Pattern,\nscoring 0-100",
               fillcolor="#A5D6A7")
        s.node("AUTH", "Authentification\nphx.gen.auth,\n3 profils utilisateurs",
               fillcolor="#81C784")

    # Layer 3 - Persistence
    with dot.subgraph(name="cluster_pers") as s:
        s.attr(label="Couche Persistance (Données)", style="filled,rounded",
               fillcolor="#FFF3E0", fontname="Helvetica", fontsize="12",
               fontcolor="#E65100")
        s.node("PG2", "PostgreSQL 16\n+ PostGIS (géospatial)",
               shape="cylinder", style="filled", fillcolor="#FFCC80")
        s.node("ASHPG", "AshPostgres\nMigrations, requêtes\noptimisées, contraintes",
               fillcolor="#FFCC80")

    dot.edge("LV", "ASH")
    dot.edge("WS2", "ASH")
    dot.edge("ASH", "COMPAT", style="dashed")
    dot.edge("ASH", "AUTH", style="dashed")
    dot.edge("ASH", "ASHPG")
    dot.edge("ASHPG", "PG2")

    dot.render(os.path.join(OUT, "architecture_couches"), cleanup=True)
    print("✅ architecture_couches.png")


if __name__ == "__main__":
    organigramme()
    architecture_reseau()
    architecture_globale()
    mcd()
    mld()
    architecture_couches()
    print("\n✅ Tous les diagrammes générés dans", OUT)
