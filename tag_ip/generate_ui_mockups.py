#!/usr/bin/env python3
"""Generate UI mockup diagrams for Figures 8-13."""
import graphviz
import os

OUTPUT_DIR = os.path.expanduser("~/Desktop/fitahiana")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ============================================================
# Figure 8: Assistant création de profil (4 étapes)
# ============================================================
dot = graphviz.Digraph(
    name="Assistant_profil",
    format="png",
    graph_attr={"rankdir": "TB", "dpi": "200", "fontname": "Helvetica", "bgcolor": "white", "pad": "0.5", "ranksep": "0.3", "nodesep": "0.2"},
    node_attr={"fontname": "Helvetica", "fontsize": "9", "shape": "box", "style": "filled,rounded"},
    edge_attr={"fontname": "Helvetica", "fontsize": "8"},
)

dot.node("TITLE", "NOUVEAU PROFIL DE MONTAGE", fillcolor="#1A237E", fontcolor="white", shape="box", penwidth="2", fontsize="11")

dot.node("STEP1", "Étape 1\nIdentification\nNom, client,\nvéhicule", fillcolor="#E3F2FD", penwidth="1")
dot.node("STEP2", "Étape 2\nModèle Traceur\nMarque, modèle,\nvoltage", fillcolor="#E3F2FD", penwidth="1")
dot.node("STEP3", "Étape 3\nFonctionnalités\nCapteurs, options,\nI/O", fillcolor="#E3F2FD", penwidth="1")
dot.node("STEP4", "Étape 4\nValidation\nRécapitulatif +\nscore compatibilité", fillcolor="#FFF9C4", penwidth="2")

dot.edge("STEP1", "STEP2", label="Suivant →")
dot.edge("STEP2", "STEP3", label="Suivant →")
dot.edge("STEP3", "STEP4", label="Vérifier →")

dot.node("FORM1", "Champs :\n• Nom du profil\n• Client (org.)\n• Type véhicule\n• Description", fillcolor="white", shape="note", fontsize="8")
dot.node("FORM2", "Champs :\n• Marque\n• Modèle\n• Tension 12/24V\n• Alimentation", fillcolor="white", shape="note", fontsize="8")
dot.node("FORM3", "Options :\n☑ CAN-Bus\n☑ Accéléromètre\n☑ Montage ext.\n☑ Géofence\nEntrées: 4  Sorties: 2", fillcolor="white", shape="note", fontsize="8")
dot.node("FORM4", "Score: 85/100 ✓\nProfil: Client A\nTraceur: GT100\nTension: OK\nI/O: OK\nIP: OK", fillcolor="white", shape="note", fontsize="8", penwidth="2")

dot.edge("STEP1", "FORM1", style="dashed", arrowhead="none")
dot.edge("STEP2", "FORM2", style="dashed", arrowhead="none")
dot.edge("STEP3", "FORM3", style="dashed", arrowhead="none")
dot.edge("STEP4", "FORM4", style="dashed", arrowhead="none")

dot.render(os.path.join(OUTPUT_DIR, "fig8_assistant_profil"), cleanup=True)
print("✓ Figure 8: fig8_assistant_profil.png")

# ============================================================
# Figure 9: Page d'accueil
# ============================================================
dot = graphviz.Digraph(
    name="Accueil",
    format="png",
    graph_attr={"rankdir": "TB", "dpi": "200", "fontname": "Helvetica", "bgcolor": "white", "pad": "0.5", "ranksep": "0.3", "nodesep": "0.2"},
    node_attr={"fontname": "Helvetica", "fontsize": "9", "shape": "box", "style": "filled,rounded"},
    edge_attr={"fontname": "Helvetica", "fontsize": "8"},
)

dot.node("LOGO", "TAG-Monitor  [Déconnexion]", fillcolor="#1A237E", fontcolor="white", shape="box", penwidth="2", fontsize="11")
dot.node("NAV", "[Dashboard]  [Profils]  [Modèles]  [Compatibilités]  [Référentiels]", fillcolor="#E8EAF6", shape="box", fontsize="9")

dot.node("C1", "Profils\nde montage\n12 enregistrements", fillcolor="#42A5F5", fontcolor="white", fontsize="10")
dot.node("C2", "Modèles\nde traceurs\n6 références", fillcolor="#66BB6A", fontcolor="white", fontsize="10")
dot.node("C3", "Compatibilités\ncalculées\n48 résultats", fillcolor="#FFA726", fontcolor="white", fontsize="10")
dot.node("C4", "Taux de\ncompatibilité\nmoyen: 72%", fillcolor="#AB47BC", fontcolor="white", fontsize="10")

dot.node("RECENT", "Activité récente :\n• Profil 'Client A' créé il y a 5 min\n• Compatibilité GT100 calculée (85/100)\n• Nouveau modèle 'GL200' ajouté", fillcolor="#FFF8E1", shape="note", fontsize="8")

dot.edge("LOGO", "NAV")
dot.edge("NAV", "C1")
dot.edge("C1", "C2")
dot.edge("C2", "C3")
dot.edge("C3", "C4")
dot.edge("C4", "RECENT")

dot.render(os.path.join(OUTPUT_DIR, "fig9_accueil"), cleanup=True)
print("✓ Figure 9: fig9_accueil.png")

# ============================================================
# Figure 10: Page de connexion
# ============================================================
dot = graphviz.Digraph(
    name="Connexion",
    format="png",
    graph_attr={"rankdir": "TB", "dpi": "200", "fontname": "Helvetica", "bgcolor": "white", "pad": "0.5", "ranksep": "0.3", "nodesep": "0.2"},
    node_attr={"fontname": "Helvetica", "fontsize": "9", "shape": "box", "style": "filled,rounded"},
    edge_attr={"fontname": "Helvetica", "fontsize": "8"},
)

dot.node("BANNER", "TAG-Monitor", fillcolor="#1A237E", fontcolor="white", shape="box", penwidth="2", fontsize="14")
dot.node("CARD", "CONNEXION", fillcolor="white", shape="box", penwidth="1.5")

dot.node("EMAIL", "Email :\n_________________\nuser@example.com", fillcolor="#F5F5F5", shape="note")
dot.node("PASS", "Mot de passe :\n_________________\n••••••••", fillcolor="#F5F5F5", shape="note")
dot.node("BTN", "[  Se connecter  ]", fillcolor="#1A237E", fontcolor="white", fontsize="10", penwidth="2")
dot.node("LINK", "Mot de passe oublié ?  |  S'inscrire", fillcolor="white", fontsize="8")

dot.edge("BANNER", "CARD")
dot.edge("CARD", "EMAIL")
dot.edge("EMAIL", "PASS")
dot.edge("PASS", "BTN")
dot.edge("BTN", "LINK")

dot.render(os.path.join(OUTPUT_DIR, "fig10_connexion"), cleanup=True)
print("✓ Figure 10: fig10_connexion.png")

# ============================================================
# Figure 11: Tableau de bord temps réel
# ============================================================
dot = graphviz.Digraph(
    name="Dashboard",
    format="png",
    graph_attr={"rankdir": "TB", "dpi": "200", "fontname": "Helvetica", "bgcolor": "white", "pad": "0.5", "ranksep": "0.3", "nodesep": "0.15"},
    node_attr={"fontname": "Helvetica", "fontsize": "9", "shape": "box", "style": "filled,rounded"},
    edge_attr={"fontname": "Helvetica", "fontsize": "8"},
)

dot.node("HDR", "TABLEAU DE BORD  ● Connecté", fillcolor="#1A237E", fontcolor="white", shape="box", penwidth="2", fontsize="11")

dot.node("STAT1", "12 Profils", fillcolor="#42A5F5", fontcolor="white")
dot.node("STAT2", "6 Modèles", fillcolor="#66BB6A", fontcolor="white")
dot.node("STAT3", "48 Tests", fillcolor="#FFA726", fontcolor="white")
dot.node("STAT4", "72% Score ∅", fillcolor="#AB47BC", fontcolor="white")

dot.node("GRAPH", "Évolution des compatibilités :\n▆▆▆▆▆▆▆▆▆▆ 85% - GT100\n▆▆▆▆▆▆▆▆   65% - GL200\n▆▆▆▆▆▆▆▆▆  78% - GH3000\n▆▆▆▆▆▆     55% - MT100", fillcolor="#FFF8E1", shape="note", fontsize="8")

dot.node("NOTIF", "Notifications temps réel :\n🔔 Nouveau profil créé\n🔔 Compatibilité mise à jour\n🔔 Modèle ajouté au catalogue", fillcolor="#E8F5E9", shape="note", fontsize="8")

dot.edge("HDR", "STAT1")
dot.edge("STAT1", "STAT2")
dot.edge("STAT2", "STAT3")
dot.edge("STAT3", "STAT4")
dot.edge("STAT4", "GRAPH")
dot.edge("GRAPH", "NOTIF", style="dashed")

dot.render(os.path.join(OUTPUT_DIR, "fig11_dashboard"), cleanup=True)
print("✓ Figure 11: fig11_dashboard.png")

# ============================================================
# Figure 12: Catalogue des modèles de traceurs
# ============================================================
dot = graphviz.Digraph(
    name="Catalogue",
    format="png",
    graph_attr={"rankdir": "TB", "dpi": "200", "fontname": "Helvetica", "bgcolor": "white", "pad": "0.5", "ranksep": "0.25", "nodesep": "0.15"},
    node_attr={"fontname": "Helvetica", "fontsize": "8", "shape": "box", "style": "filled,rounded"},
    edge_attr={"fontname": "Helvetica", "fontsize": "7"},
)

dot.node("HDR", "CATALOGUE DES TRACEURS  [+ Nouveau]", fillcolor="#1A237E", fontcolor="white", shape="box", penwidth="2", fontsize="10")
dot.node("SEARCH", "🔍 Rechercher par nom, marque, référence...", fillcolor="white", shape="box", style="filled", fontsize="8")

dot.node("M1", "GT100\nMarque: Queclink\nRef: GT100-4G\nCAN: Oui  I/O: 4/2/2\nVoltage: 12-24V", fillcolor="#E3F2FD", fontsize="7")
dot.node("M2", "GL200\nMarque: Queclink\nRef: GL200-4G\nCAN: Non  I/O: 2/1/1\nVoltage: 12V", fillcolor="#E3F2FD", fontsize="7")
dot.node("M3", "GH3000\nMarque: Teltonika\nRef: GH3000\nCAN: Oui  I/O: 6/3/4\nVoltage: 12-24V", fillcolor="#E3F2FD", fontsize="7")

dot.node("PAG", "Page 1 sur 2  ◀ 1 2 ▶", fillcolor="white", shape="box", fontsize="8")

dot.edge("HDR", "SEARCH")
dot.edge("SEARCH", "M1")
dot.edge("M1", "M2")
dot.edge("M2", "M3")
dot.edge("M3", "PAG")

dot.render(os.path.join(OUTPUT_DIR, "fig12_catalogue"), cleanup=True)
print("✓ Figure 12: fig12_catalogue.png")

# ============================================================
# Figure 13: Interface compatibilité et scoring
# ============================================================
dot = graphviz.Digraph(
    name="Compatibilite",
    format="png",
    graph_attr={"rankdir": "TB", "dpi": "200", "fontname": "Helvetica", "bgcolor": "white", "pad": "0.5", "ranksep": "0.25", "nodesep": "0.15"},
    node_attr={"fontname": "Helvetica", "fontsize": "8", "shape": "box", "style": "filled,rounded"},
    edge_attr={"fontname": "Helvetica", "fontsize": "7"},
)

dot.node("HDR", "RÉSULTAT DE COMPATIBILITÉ", fillcolor="#1A237E", fontcolor="white", shape="box", penwidth="2", fontsize="10")

dot.node("PROFIL", "Profil: Client A\nVéhicule: Poids lourd\nTension: 24V\nCAN: Oui", fillcolor="#E3F2FD", fontsize="8")
dot.node("SCORE", "SCORE\n85/100\n✓ Compatible", fillcolor="#4CAF50", fontcolor="white", fontsize="12", shape="ellipse", penwidth="2.5")

dot.node("DETAILS", "Détail des critères :\n\n✓ Tension (24V) ........ 10/10\n✓ CAN-Bus ............... 8/8\n⚠ Entrées (4/6 req.) .. 6/8\n✓ Sorties (2/2) ........ 5/5\n✓ IP (IP67) ............. 10/10\n✓ Accéléromètre ........ 5/5\n⚠ Mémoire tampon .... 3/5\n...\nTotal ................ 85/100", fillcolor="#F5F5F5", shape="note", fontsize="7")

dot.node("ACTIONS", "Actions :\n[Recalculer]  [Exporter PDF]  [Nouveau test]", fillcolor="#FFF8E1", shape="note", fontsize="8")

dot.edge("HDR", "PROFIL")
dot.edge("PROFIL", "SCORE")
dot.edge("SCORE", "DETAILS")
dot.edge("DETAILS", "ACTIONS")

dot.render(os.path.join(OUTPUT_DIR, "fig13_compatibilite"), cleanup=True)
print("✓ Figure 13: fig13_compatibilite.png")

print("\n✅ Toutes les maquettes UI générées dans:", OUTPUT_DIR)
