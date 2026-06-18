#!/usr/bin/env python3
"""Generate TAG-IP organizational chart."""
import graphviz
import os

OUTPUT_DIR = os.path.expanduser("~/Desktop/fitahiana")
os.makedirs(OUTPUT_DIR, exist_ok=True)

dot = graphviz.Digraph(
    name="Organigramme_TAG_IP",
    format="png",
    graph_attr={
        "rankdir": "TB",
        "dpi": "200",
        "fontname": "Helvetica",
        "fontsize": "12",
        "bgcolor": "white",
        "pad": "0.5",
        "splines": "ortho",
        "ranksep": "0.6",
        "nodesep": "0.4",
    },
    node_attr={
        "fontname": "Helvetica",
        "fontsize": "11",
        "shape": "box",
        "style": "filled,rounded",
        "penwidth": "1.5",
    },
    edge_attr={
        "fontname": "Helvetica",
        "fontsize": "9",
        "penwidth": "1.2",
        "color": "#555555",
    },
)

# Direction Générale
dot.node("DG", "Direction Générale\nM. Marc Rivera", fillcolor="#1A237E", fontcolor="white", shape="box")

# Directions
dot.node("RH", "RH / Exploitation\nPôle Terrain TAGOS", fillcolor="#0D47A1", fontcolor="white")
dot.node("COM", "Marketing / Commercial", fillcolor="#0D47A1", fontcolor="white")
dot.node("DSI", "Direction des Systèmes\n d'Information (DSI)\nM. Gilles Chapoton", fillcolor="#0D47A1", fontcolor="white")

# DSI sub-structures
dot.node("INFRA", "Infrastructure\nRéseau & Serveurs", fillcolor="#1565C0", fontcolor="white")
dot.node("IL", "Pôle Ingénierie\nLogicielle", fillcolor="#1976D2", fontcolor="white")
dot.node("SUPPORT", "Support\nTechnique", fillcolor="#1565C0", fontcolor="white")

# Stage position
dot.node("STAGE", "← Poste de stage :\nStagiaire DTS\n(Pôle Ingénierie Logicielle)", fillcolor="#FF6F00", fontcolor="white", shape="box", penwidth="2.5", style="filled,rounded,bold")

dot.edge("DG", "RH")
dot.edge("DG", "COM")
dot.edge("DG", "DSI")

dot.edge("DSI", "INFRA", label="  ")
dot.edge("DSI", "IL", label="  ")
dot.edge("DSI", "SUPPORT", label="  ")

# Connect the stage with a dashed edge to the IL node
dot.edge("IL", "STAGE", style="dashed", arrowhead="none", color="#FF6F00", penwidth="2.0")

output_path = os.path.join(OUTPUT_DIR, "organigramme_tag_ip")
dot.render(output_path, cleanup=True)
print(f"Organigramme generated: {output_path}.png")
