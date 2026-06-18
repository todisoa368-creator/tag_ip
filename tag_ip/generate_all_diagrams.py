#!/usr/bin/env python3
"""Generate remaining diagrams for the thesis."""
import graphviz
import os

OUTPUT_DIR = os.path.expanduser("~/Desktop/fitahiana")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ============================================================
# Figure 2: Schéma de l'architecture réseau
# ============================================================
dot = graphviz.Digraph(
    name="Architecture_reseau",
    format="png",
    graph_attr={"rankdir": "LR", "dpi": "200", "fontname": "Helvetica", "bgcolor": "white", "pad": "0.5", "splines": "true"},
    node_attr={"fontname": "Helvetica", "fontsize": "10", "shape": "box", "style": "filled,rounded"},
    edge_attr={"fontname": "Helvetica", "fontsize": "9"},
)

dot.node("GPS", "Traceurs GPS\n(10 000+ véhicules)", fillcolor="#E3F2FD", shape="ellipse")
dot.node("GPRS", "Réseau GPRS/3G\nTelma", fillcolor="#BBDEFB", shape="box")
dot.node("VLAN_GPS", "VLAN GPS\n(Flux trames)", fillcolor="#90CAF9")
dot.node("FIREWALL", "Firewall\nIDS/IPS", fillcolor="#FFCC80", shape="diamond")
dot.node("CLUSTER", "Cluster Serveurs\n(HA)", fillcolor="#A5D6A7")
dot.node("DB", "PostgreSQL\n+ PostGIS", fillcolor="#81C784", shape="cylinder")
dot.node("VLAN_ADMIN", "VLAN Admin\n(Outils métier)", fillcolor="#90CAF9")
dot.node("VLAN_DEV", "VLAN Dev\n(Test/Préprod)", fillcolor="#90CAF9")
dot.node("ADMIN", "Postes\nAdministration", fillcolor="#E0E0E0")
dot.node("DEV", "Postes\nDéveloppeurs", fillcolor="#E0E0E0")
dot.node("TRACK", "Plateforme\nTrack", fillcolor="#CE93D8")

dot.edge("GPS", "GPRS", label="trames GPRS")
dot.edge("GPRS", "VLAN_GPS", label="décodage")
dot.edge("VLAN_GPS", "FIREWALL")
dot.edge("FIREWALL", "CLUSTER")
dot.edge("CLUSTER", "DB", label="écriture temps réel")
dot.edge("DB", "TRACK", label="requêtes")
dot.edge("TRACK", "VLAN_ADMIN", style="dashed")
dot.edge("VLAN_ADMIN", "ADMIN", style="dashed")
dot.edge("VLAN_DEV", "DEV", style="dashed")
dot.edge("FIREWALL", "VLAN_ADMIN", style="dashed", label="règles")
dot.edge("FIREWALL", "VLAN_DEV", style="dashed", label="règles")

# Add global network label
dot.node("INTERNET", "INTERNET", fillcolor="#EF5350", fontcolor="white", shape="ellipse")
dot.edge("INTERNET", "GPS", style="dashed", color="#888888")

dot.render(os.path.join(OUTPUT_DIR, "architecture_reseau"), cleanup=True)
print("✓ Figure 2: architecture_reseau.png")

# ============================================================
# Figure 3: Diagramme de cas d'utilisation UML
# ============================================================
dot = graphviz.Digraph(
    name="Cas_utilisation",
    format="png",
    graph_attr={"rankdir": "TB", "dpi": "200", "fontname": "Helvetica", "bgcolor": "white", "pad": "0.5", "fontsize": "11", "ranksep": "1.2", "nodesep": "0.6"},
    node_attr={"fontname": "Helvetica", "fontsize": "10"},
    edge_attr={"fontname": "Helvetica", "fontsize": "9"},
)

# System boundary
dot.node("SYSTEM", "<<system>>\nTAG-Monitor", shape="box", style="dashed", fontsize="11")

# Actors
dot.node("ADMIN", "Administrateur", shape="box", style="filled", fillcolor="#E3F2FD")
dot.node("TECH_EXPL", "Technicien\nExploitation", shape="box", style="filled", fillcolor="#E8F5E9")
dot.node("TECH_TERR", "Technicien\nTerrain", shape="box", style="filled", fillcolor="#FFF3E0")

# Use cases
ucases = [
    ("UC1", "Gérer les profils\nde montage"),
    ("UC2", "Consulter le catalogue\nde traceurs"),
    ("UC3", "Calculer la\ncompatibilité"),
    ("UC4", "Gérer les modèles\nde traceurs"),
    ("UC5", "Visualiser le\ntableau de bord"),
    ("UC6", "Gérer les\ntilisateurs"),
    ("UC7", "Consulter une fiche\nde compatibilité"),
    ("UC8", "Exporter les\ndonnées CSV"),
]

for uid, label in ucases:
    dot.node(uid, label, shape="ellipse", style="filled", fillcolor="white")

# Admin edges
for uc in ["UC4", "UC6", "UC8"]:
    dot.edge("ADMIN", uc, arrowhead="open", style="solid")

# Tech exploitation edges
for uc in ["UC1", "UC2", "UC3", "UC5", "UC7"]:
    dot.edge("TECH_EXPL", uc, arrowhead="open", style="solid")

# Tech terrain edges
for uc in ["UC2", "UC7"]:
    dot.edge("TECH_TERR", uc, arrowhead="open", style="dashed")

# Include relationships
dot.edge("UC1", "UC3", arrowhead="open", style="dotted", label="\\<\\<include\\>\\>")

dot.render(os.path.join(OUTPUT_DIR, "cas_utilisation"), cleanup=True)
print("✓ Figure 3: cas_utilisation.png")

# ============================================================
# Figure 4: Architecture globale du système (couches)
# ============================================================
dot = graphviz.Digraph(
    name="Architecture_globale",
    format="png",
    graph_attr={"rankdir": "TB", "dpi": "200", "fontname": "Helvetica", "bgcolor": "white", "pad": "0.5", "ranksep": "0.4", "nodesep": "0.3"},
    node_attr={"fontname": "Helvetica", "fontsize": "10", "shape": "box", "style": "filled,rounded", "penwidth": "1.5"},
    edge_attr={"fontname": "Helvetica", "fontsize": "9"},
)

dot.node("NAV", "Navigateur Web", fillcolor="#E3F2FD", shape="house")
dot.node("LIVEW", "Phoenix LiveView\n(HEEx + Streaming)", fillcolor="#42A5F5", fontcolor="white")
dot.node("PHX", "Phoenix Router\n+ Contrôleurs", fillcolor="#64B5F6", fontcolor="white")
dot.node("ASH", "Ash Framework\n(18 Ressources, Actions,\nValidations, Policies)", fillcolor="#66BB6A", fontcolor="white")
dot.node("ECTO", "Ecto / AshPostgres\n(Repo, Migrations)", fillcolor="#FFA726", fontcolor="white")
dot.node("DB", "PostgreSQL\n+ PostGIS", fillcolor="#EF5350", fontcolor="white", shape="cylinder")

dot.edge("NAV", "LIVEW", label="HTTP / WebSocket")
dot.edge("LIVEW", "PHX", label="LiveView callbacks")
dot.edge("PHX", "ASH", label="Domain actions")
dot.edge("ASH", "ECTO", label="DataLayer")
dot.edge("ECTO", "DB", label="SQL queries")

# Side notes
dot.node("AUTH", "Authentification\nphx.gen.auth\n(bcrypt + Magic Links)", fillcolor="#AB47BC", fontcolor="white", shape="note")
dot.node("PUBSUB", "Phoenix PubSub\n(Notifications\ntemps réel)", fillcolor="#26C6DA", fontcolor="white", shape="note")
dot.node("DOCKER", "Docker\n(Conteneurisation)", fillcolor="#8D6E63", fontcolor="white", shape="note")

dot.edge("AUTH", "PHX", style="dashed", arrowhead="none")
dot.edge("PUBSUB", "LIVEW", style="dashed", arrowhead="none")
dot.edge("DOCKER", "DB", style="dotted", arrowhead="none", color="#888888")

dot.render(os.path.join(OUTPUT_DIR, "architecture_globale"), cleanup=True)
print("✓ Figure 4: architecture_globale.png")

# ============================================================
# Figure 7: Schéma d'architecture MVC / n-tiers
# ============================================================
dot = graphviz.Digraph(
    name="Architecture_n_tiers",
    format="png",
    graph_attr={"rankdir": "TB", "dpi": "200", "fontname": "Helvetica", "bgcolor": "white", "pad": "0.6", "ranksep": "0.5", "nodesep": "0.4"},
    node_attr={"fontname": "Helvetica", "fontsize": "10", "shape": "box", "style": "filled,rounded", "penwidth": "1.5"},
    edge_attr={"fontname": "Helvetica", "fontsize": "9"},
)

# -- Couche Présentation --
dot.node("PRES", "COUCHE PRÉSENTATION", fillcolor="#1565C0", fontcolor="white", shape="box", penwidth="2.5")
dot.node("LV", "LiveViews\n(Dashboard, Profils,\nModèles, etc.)", fillcolor="#1E88E5", fontcolor="white")
dot.node("COMP", "Composants\n(CoreComponents,\nInput, Form, etc.)", fillcolor="#42A5F5", fontcolor="white")
dot.node("CSS", "Tailwind CSS v4\n+ app.css", fillcolor="#64B5F6", fontcolor="white")

# -- Couche Métier --
dot.node("METIER", "COUCHE MÉTIER", fillcolor="#2E7D32", fontcolor="white", shape="box", penwidth="2.5")
dot.node("DOM", "TagIp.TagIp\n(Domain Ash)", fillcolor="#43A047", fontcolor="white")
dot.node("RESS", "Ressources Ash\n(ProfilMontage,\nModeleTraceur, etc.)", fillcolor="#66BB6A", fontcolor="white")
dot.node("ACT", "Actions métier\n(calculer_compatibilite,\nCRUD, etc.)", fillcolor="#81C784", fontcolor="white")
dot.node("CAP", "CapabilityMatrix\n(Validation\nfonctionnelle)", fillcolor="#A5D6A7")

# -- Couche Persistance --
dot.node("PERS", "COUCHE PERSISTANCE", fillcolor="#E65100", fontcolor="white", shape="box", penwidth="2.5")
dot.node("REPO", "TagIp.Repo\n(AshPostgres)", fillcolor="#EF6C00", fontcolor="white")
dot.node("PG", "PostgreSQL 16\n+ PostGIS", fillcolor="#FF9800", fontcolor="white", shape="cylinder")
dot.node("MIG", "Migrations\nPriv/Repo", fillcolor="#FFB74D")

# Edges
dot.edge("PRES", "LV")
dot.edge("LV", "COMP")
dot.edge("COMP", "CSS", style="dashed")

dot.edge("METIER", "DOM")
dot.edge("DOM", "RESS")
dot.edge("RESS", "ACT")
dot.edge("RESS", "CAP", style="dashed")

dot.edge("PERS", "REPO")
dot.edge("REPO", "PG")
dot.edge("REPO", "MIG", style="dashed")

# Inter-layer edges
dot.edge("LV", "DOM", label="appels actions", style="bold")
dot.edge("ACT", "REPO", label="persistence", style="bold")

dot.render(os.path.join(OUTPUT_DIR, "architecture_n_tiers"), cleanup=True)
print("✓ Figure 7: architecture_n_tiers.png")

print("\nTous les diagrammes générés dans:", OUTPUT_DIR)
