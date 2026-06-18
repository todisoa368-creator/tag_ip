#!/usr/bin/env python3
"""Regenerate Figure 7 - smaller but readable."""
import graphviz
import os

OUTPUT_DIR = os.path.expanduser("~/Desktop/fitahiana")

dot = graphviz.Digraph(
    name="Architecture_n_tiers",
    format="png",
    graph_attr={
        "rankdir": "TB",
        "dpi": "150",
        "fontname": "Helvetica",
        "bgcolor": "white",
        "pad": "0.3",
        "ranksep": "0.3",
        "nodesep": "0.2",
        "size": "6,8",
    },
    node_attr={
        "fontname": "Helvetica",
        "fontsize": "9",
        "shape": "box",
        "style": "filled,rounded",
        "penwidth": "1.2",
    },
    edge_attr={"fontname": "Helvetica", "fontsize": "8"},
)

# -- Couche Présentation --
dot.node("PRES", "COUCHE PRÉSENTATION", fillcolor="#1565C0", fontcolor="white", shape="box", penwidth="2", fontsize="10")
dot.node("LV", "LiveViews\n(Dashboard, Profils,\nModèles)", fillcolor="#1E88E5", fontcolor="white")
dot.node("COMP", "Composants\n(CoreComponents,\nInput)", fillcolor="#42A5F5", fontcolor="white")
dot.node("CSS", "Tailwind CSS v4\n+ app.css", fillcolor="#64B5F6", fontcolor="white")

# -- Couche Métier --
dot.node("METIER", "COUCHE MÉTIER", fillcolor="#2E7D32", fontcolor="white", shape="box", penwidth="2", fontsize="10")
dot.node("DOM", "Domain Ash\n(TagIp.TagIp)", fillcolor="#43A047", fontcolor="white")
dot.node("RESS", "Ressources Ash\n(ProfilMontage,\nModeleTraceur)", fillcolor="#66BB6A", fontcolor="white")
dot.node("ACT", "Actions métier\n(calculer_compat.,\nCRUD)", fillcolor="#81C784", fontcolor="white")
dot.node("CAP", "CapabilityMatrix\n(Validation)", fillcolor="#A5D6A7")

# -- Couche Persistance --
dot.node("PERS", "COUCHE PERSISTANCE", fillcolor="#E65100", fontcolor="white", shape="box", penwidth="2", fontsize="10")
dot.node("REPO", "AshPostgres\n(TagIp.Repo)", fillcolor="#EF6C00", fontcolor="white")
dot.node("PG", "PostgreSQL 16\n+ PostGIS", fillcolor="#FF9800", fontcolor="white", shape="cylinder")
dot.node("MIG", "Migrations\nPriv/Repo", fillcolor="#FFB74D")

# Intra-layer edges
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
dot.edge("LV", "DOM", label="actions", style="bold")
dot.edge("ACT", "REPO", label="persistence", style="bold")

dot.render(os.path.join(OUTPUT_DIR, "architecture_n_tiers"), cleanup=True)
print("✓ Figure 7 régénérée (plus petite): architecture_n_tiers.png")
