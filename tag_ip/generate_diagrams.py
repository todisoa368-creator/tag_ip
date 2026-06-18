"""Generate MCD and MLD diagrams for the thesis using Graphviz."""
import graphviz
import os

OUTPUT_DIR = os.path.expanduser("~/Desktop/fitahiana")
os.makedirs(OUTPUT_DIR, exist_ok=True)

def generate_mcd():
    """Generate Conceptual Data Model (MCD) diagram."""
    dot = graphviz.Digraph(
        name="MCD_TAG_Monitor",
        format="png",
        graph_attr={
            "rankdir": "TB",
            "dpi": "200",
            "fontname": "Helvetica",
            "fontsize": "12",
            "bgcolor": "white",
            "pad": "0.5",
            "splines": "ortho",
        },
        node_attr={
            "fontname": "Helvetica",
            "fontsize": "10",
            "shape": "plaintext",
            "style": "rounded",
        },
        edge_attr={"fontname": "Helvetica", "fontsize": "9"},
    )

    entities = {
        "ProfilMontage": {
            "label": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4" BGCOLOR="#E8F0FE">
<TR><TD BGCOLOR="#1A73E8" COLSPAN="2"><FONT COLOR="white"><B>ProfilMontage</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">name</TD><TD ALIGN="LEFT">string</TD></TR>
<TR><TD ALIGN="LEFT">voltage_min</TD><TD ALIGN="LEFT">decimal</TD></TR>
<TR><TD ALIGN="LEFT">voltage_max</TD><TD ALIGN="LEFT">decimal</TD></TR>
<TR><TD ALIGN="LEFT">can_bus_requis</TD><TD ALIGN="LEFT">boolean</TD></TR>
<TR><TD ALIGN="LEFT">nb_digital_inputs</TD><TD ALIGN="LEFT">integer</TD></TR>
<TR><TD ALIGN="LEFT">nb_analog_inputs</TD><TD ALIGN="LEFT">integer</TD></TR>
<TR><TD ALIGN="LEFT">nb_outputs</TD><TD ALIGN="LEFT">integer</TD></TR>
<TR><TD ALIGN="LEFT">ip_rating</TD><TD ALIGN="LEFT">string</TD></TR>
<TR><TD ALIGN="LEFT">montage_exterieur</TD><TD ALIGN="LEFT">boolean</TD></TR>
</TABLE>>""",
        },
        "ModeleTraceur": {
            "label": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4" BGCOLOR="#E6F4EA">
<TR><TD BGCOLOR="#34A853" COLSPAN="2"><FONT COLOR="white"><B>ModeleTraceur</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">nom</TD><TD ALIGN="LEFT">string</TD></TR>
<TR><TD ALIGN="LEFT">reference</TD><TD ALIGN="LEFT">string (UQ)</TD></TR>
<TR><TD ALIGN="LEFT">voltage_min</TD><TD ALIGN="LEFT">decimal</TD></TR>
<TR><TD ALIGN="LEFT">voltage_max</TD><TD ALIGN="LEFT">decimal</TD></TR>
<TR><TD ALIGN="LEFT">can_bus</TD><TD ALIGN="LEFT">boolean</TD></TR>
<TR><TD ALIGN="LEFT">nb_digital_inputs</TD><TD ALIGN="LEFT">integer</TD></TR>
<TR><TD ALIGN="LEFT">ip_rating</TD><TD ALIGN="LEFT">string</TD></TR>
<TR><TD ALIGN="LEFT">accelerometer</TD><TD ALIGN="LEFT">boolean</TD></TR>
<TR><TD ALIGN="LEFT">ultra_low_power</TD><TD ALIGN="LEFT">boolean</TD></TR>
</TABLE>>""",
        },
        "Compatibilite": {
            "label": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4" BGCOLOR="#FCE8E6">
<TR><TD BGCOLOR="#EA4335" COLSPAN="2"><FONT COLOR="white"><B>Compatibilite</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">profil_montage_id</TD><TD ALIGN="LEFT">UUID FK</TD></TR>
<TR><TD ALIGN="LEFT">modele_traceur_id</TD><TD ALIGN="LEFT">UUID FK</TD></TR>
<TR><TD ALIGN="LEFT">score_compatibilite</TD><TD ALIGN="LEFT">integer</TD></TR>
<TR><TD ALIGN="LEFT">details</TD><TD ALIGN="LEFT">string</TD></TR>
</TABLE>>""",
        },
        "TypeVehicule": {
            "label": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4" BGCOLOR="#FFF3E0">
<TR><TD BGCOLOR="#FBBC04" COLSPAN="2"><FONT COLOR="white"><B>TypeVehicule</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">slug</TD><TD ALIGN="LEFT">string</TD></TR>
<TR><TD ALIGN="LEFT">label</TD><TD ALIGN="LEFT">string</TD></TR>
</TABLE>>""",
        },
        "Alimentation": {
            "label": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4" BGCOLOR="#F3E8FF">
<TR><TD BGCOLOR="#9334E6" COLSPAN="2"><FONT COLOR="white"><B>Alimentation</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">slug</TD><TD ALIGN="LEFT">string</TD></TR>
<TR><TD ALIGN="LEFT">label</TD><TD ALIGN="LEFT">string</TD></TR>
</TABLE>>""",
        },
        "Capteur": {
            "label": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4" BGCOLOR="#E0F7FA">
<TR><TD BGCOLOR="#00ACC1" COLSPAN="2"><FONT COLOR="white"><B>Capteur</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">slug</TD><TD ALIGN="LEFT">string</TD></TR>
<TR><TD ALIGN="LEFT">label</TD><TD ALIGN="LEFT">string</TD></TR>
</TABLE>>""",
        },
        "Feature": {
            "label": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4" BGCOLOR="#FCE4EC">
<TR><TD BGCOLOR="#E91E63" COLSPAN="2"><FONT COLOR="white"><B>Feature</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">slug</TD><TD ALIGN="LEFT">string</TD></TR>
<TR><TD ALIGN="LEFT">label</TD><TD ALIGN="LEFT">string</TD></TR>
</TABLE>>""",
        },
        "PortType": {
            "label": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4" BGCOLOR="#EFEBE9">
<TR><TD BGCOLOR="#795548" COLSPAN="2"><FONT COLOR="white"><B>PortType</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">slug</TD><TD ALIGN="LEFT">string</TD></TR>
<TR><TD ALIGN="LEFT">label</TD><TD ALIGN="LEFT">string</TD></TR>
</TABLE>>""",
        },
        "Peripheral": {
            "label": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4" BGCOLOR="#FFFDE7">
<TR><TD BGCOLOR="#F9A825" COLSPAN="2"><FONT COLOR="white"><B>Peripheral</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">name</TD><TD ALIGN="LEFT">string</TD></TR>
</TABLE>>""",
        },
    }

    for name, attrs in entities.items():
        dot.node(name, attrs["label"])

    edges = [
        ("ProfilMontage", "Compatibilite", "1,N"),
        ("ModeleTraceur", "Compatibilite", "1,N"),
        ("ModeleTraceur", "TypeVehicule", "N,N via MT_TV"),
        ("ModeleTraceur", "Alimentation", "N,N via MT_Alim"),
        ("ModeleTraceur", "Capteur", "N,N via MT_Capt"),
        ("ModeleTraceur", "Feature", "N,N via ModelFeature"),
        ("ModeleTraceur", "PortType", "N,N via ModelPort"),
        ("PortType", "Peripheral", "1,N"),
    ]

    for src, dst, label in edges:
        dot.edge(src, dst, label=label)

    output_path = os.path.join(OUTPUT_DIR, "mcd_tag_monitor")
    dot.render(output_path, cleanup=True)
    print(f"MCD generated: {output_path}.png")


def generate_mld():
    """Generate Logical Data Model (MLD) diagram."""
    dot = graphviz.Digraph(
        name="MLD_TAG_Monitor",
        format="png",
        graph_attr={
            "rankdir": "TB",
            "dpi": "200",
            "fontname": "Helvetica",
            "fontsize": "11",
            "bgcolor": "white",
            "pad": "0.5",
            "splines": "ortho",
            "ranksep": "1.5",
            "nodesep": "0.8",
        },
        node_attr={
            "fontname": "Helvetica",
            "fontsize": "9",
            "shape": "plaintext",
        },
        edge_attr={"fontname": "Helvetica", "fontsize": "8", "color": "#555555"},
    )

    tables = {
        "mounting_profiles": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="3">
<TR><TD BGCOLOR="#1A73E8" COLSPAN="2"><FONT COLOR="white"><B>mounting_profiles</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">name</TD><TD ALIGN="LEFT">VARCHAR(255)</TD></TR>
<TR><TD ALIGN="LEFT">description</TD><TD ALIGN="LEFT">TEXT</TD></TR>
<TR><TD ALIGN="LEFT">voltage_min</TD><TD ALIGN="LEFT">DECIMAL(5,2)</TD></TR>
<TR><TD ALIGN="LEFT">voltage_max</TD><TD ALIGN="LEFT">DECIMAL(5,2)</TD></TR>
<TR><TD ALIGN="LEFT">can_bus_required</TD><TD ALIGN="LEFT">BOOLEAN</TD></TR>
<TR><TD ALIGN="LEFT">nb_digital_inputs</TD><TD ALIGN="LEFT">INTEGER</TD></TR>
<TR><TD ALIGN="LEFT">nb_analog_inputs</TD><TD ALIGN="LEFT">INTEGER</TD></TR>
<TR><TD ALIGN="LEFT">nb_outputs</TD><TD ALIGN="LEFT">INTEGER</TD></TR>
<TR><TD ALIGN="LEFT">ip_rating</TD><TD ALIGN="LEFT">VARCHAR(10)</TD></TR>
<TR><TD ALIGN="LEFT">montage_exterieur</TD><TD ALIGN="LEFT">BOOLEAN</TD></TR>
<TR><TD ALIGN="LEFT">accelerometre_requis</TD><TD ALIGN="LEFT">BOOLEAN</TD></TR>
<TR><TD ALIGN="LEFT">type_vehicule_id</TD><TD ALIGN="LEFT">UUID FK</TD></TR>
<TR><TD ALIGN="LEFT">alimentation_id</TD><TD ALIGN="LEFT">UUID FK</TD></TR>
<TR><TD ALIGN="LEFT">organisation_id</TD><TD ALIGN="LEFT">UUID FK</TD></TR>
</TABLE>>""",
        "modeles_traceur": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="3">
<TR><TD BGCOLOR="#34A853" COLSPAN="2"><FONT COLOR="white"><B>modeles_traceur</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">nom</TD><TD ALIGN="LEFT">VARCHAR(255)</TD></TR>
<TR><TD ALIGN="LEFT">brand</TD><TD ALIGN="LEFT">VARCHAR(100)</TD></TR>
<TR><TD ALIGN="LEFT"><I>reference</I></TD><TD ALIGN="LEFT">VARCHAR(100) UQ</TD></TR>
<TR><TD ALIGN="LEFT">voltage_min</TD><TD ALIGN="LEFT">DECIMAL(5,2)</TD></TR>
<TR><TD ALIGN="LEFT">voltage_max</TD><TD ALIGN="LEFT">DECIMAL(5,2)</TD></TR>
<TR><TD ALIGN="LEFT">can_bus</TD><TD ALIGN="LEFT">BOOLEAN</TD></TR>
<TR><TD ALIGN="LEFT">one_wire</TD><TD ALIGN="LEFT">BOOLEAN</TD></TR>
<TR><TD ALIGN="LEFT">rs232</TD><TD ALIGN="LEFT">BOOLEAN</TD></TR>
<TR><TD ALIGN="LEFT">rs485</TD><TD ALIGN="LEFT">BOOLEAN</TD></TR>
<TR><TD ALIGN="LEFT">nb_digital_inputs</TD><TD ALIGN="LEFT">INTEGER</TD></TR>
<TR><TD ALIGN="LEFT">nb_analog_inputs</TD><TD ALIGN="LEFT">INTEGER</TD></TR>
<TR><TD ALIGN="LEFT">nb_outputs</TD><TD ALIGN="LEFT">INTEGER</TD></TR>
<TR><TD ALIGN="LEFT">ip_rating</TD><TD ALIGN="LEFT">VARCHAR(10)</TD></TR>
<TR><TD ALIGN="LEFT">accelerometer</TD><TD ALIGN="LEFT">BOOLEAN</TD></TR>
<TR><TD ALIGN="LEFT">buffer_memory</TD><TD ALIGN="LEFT">INTEGER</TD></TR>
<TR><TD ALIGN="LEFT">ultra_low_power</TD><TD ALIGN="LEFT">BOOLEAN</TD></TR>
</TABLE>>""",
        "compatibilites": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="3">
<TR><TD BGCOLOR="#EA4335" COLSPAN="2"><FONT COLOR="white"><B>compatibilites</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">profil_montage_id</TD><TD ALIGN="LEFT">UUID FK</TD></TR>
<TR><TD ALIGN="LEFT">modele_traceur_id</TD><TD ALIGN="LEFT">UUID FK</TD></TR>
<TR><TD ALIGN="LEFT">score_compatibilite</TD><TD ALIGN="LEFT">INTEGER</TD></TR>
<TR><TD ALIGN="LEFT">details</TD><TD ALIGN="LEFT">TEXT</TD></TR>
<TR><TD BGCOLOR="#F5F5F5" COLSPAN="2"><FONT POINT-SIZE="8"><I>UQ(profil_montage_id, modele_traceur_id)</I></FONT></TD></TR>
</TABLE>>""",
        "types_vehicule": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="3">
<TR><TD BGCOLOR="#FBBC04" COLSPAN="2"><FONT COLOR="white"><B>types_vehicule</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">slug</TD><TD ALIGN="LEFT">VARCHAR(50) UQ</TD></TR>
<TR><TD ALIGN="LEFT">label</TD><TD ALIGN="LEFT">VARCHAR(100)</TD></TR>
</TABLE>>""",
        "alimentations": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="3">
<TR><TD BGCOLOR="#9334E6" COLSPAN="2"><FONT COLOR="white"><B>alimentations</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">slug</TD><TD ALIGN="LEFT">VARCHAR(50) UQ</TD></TR>
<TR><TD ALIGN="LEFT">label</TD><TD ALIGN="LEFT">VARCHAR(100)</TD></TR>
</TABLE>>""",
        "capteurs": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="3">
<TR><TD BGCOLOR="#00ACC1" COLSPAN="2"><FONT COLOR="white"><B>capteurs</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">slug</TD><TD ALIGN="LEFT">VARCHAR(50) UQ</TD></TR>
<TR><TD ALIGN="LEFT">label</TD><TD ALIGN="LEFT">VARCHAR(100)</TD></TR>
</TABLE>>""",
        "features": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="3">
<TR><TD BGCOLOR="#E91E63" COLSPAN="2"><FONT COLOR="white"><B>features</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">slug</TD><TD ALIGN="LEFT">VARCHAR(50) UQ</TD></TR>
<TR><TD ALIGN="LEFT">label</TD><TD ALIGN="LEFT">VARCHAR(100)</TD></TR>
</TABLE>>""",
        "port_types": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="3">
<TR><TD BGCOLOR="#795548" COLSPAN="2"><FONT COLOR="white"><B>port_types</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">slug</TD><TD ALIGN="LEFT">VARCHAR(50) UQ</TD></TR>
<TR><TD ALIGN="LEFT">label</TD><TD ALIGN="LEFT">VARCHAR(100)</TD></TR>
</TABLE>>""",
        "peripherals": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="3">
<TR><TD BGCOLOR="#F9A825" COLSPAN="2"><FONT COLOR="white"><B>peripherals</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">name</TD><TD ALIGN="LEFT">VARCHAR(255)</TD></TR>
</TABLE>>""",
        "modeles_traceur_types_vehicule": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="3">
<TR><TD BGCOLOR="#666666" COLSPAN="2"><FONT COLOR="white"><B>mt_tv (N:N)</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">modele_traceur_id</TD><TD ALIGN="LEFT">UUID FK</TD></TR>
<TR><TD ALIGN="LEFT">type_vehicule_id</TD><TD ALIGN="LEFT">UUID FK</TD></TR>
<TR><TD BGCOLOR="#F5F5F5" COLSPAN="2"><FONT POINT-SIZE="8"><I>UQ(modele, type)</I></FONT></TD></TR>
</TABLE>>""",
        "model_features": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="3">
<TR><TD BGCOLOR="#666666" COLSPAN="2"><FONT COLOR="white"><B>model_features (N:N)</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">modele_traceur_id</TD><TD ALIGN="LEFT">UUID FK</TD></TR>
<TR><TD ALIGN="LEFT">feature_id</TD><TD ALIGN="LEFT">UUID FK</TD></TR>
<TR><TD BGCOLOR="#F5F5F5" COLSPAN="2"><FONT POINT-SIZE="8"><I>UQ(modele, feature)</I></FONT></TD></TR>
</TABLE>>""",
        "model_ports": """<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="3">
<TR><TD BGCOLOR="#666666" COLSPAN="2"><FONT COLOR="white"><B>model_ports (N:N)</B></FONT></TD></TR>
<TR><TD ALIGN="LEFT"><I>id</I></TD><TD ALIGN="LEFT">UUID PK</TD></TR>
<TR><TD ALIGN="LEFT">modele_traceur_id</TD><TD ALIGN="LEFT">UUID FK</TD></TR>
<TR><TD ALIGN="LEFT">port_type_id</TD><TD ALIGN="LEFT">UUID FK</TD></TR>
<TR><TD ALIGN="LEFT">pin_label</TD><TD ALIGN="LEFT">VARCHAR(50)</TD></TR>
</TABLE>>""",
    }

    for name, label in tables.items():
        dot.node(name, label)

    edges = [
        ("mounting_profiles", "types_vehicule", "FK"),
        ("mounting_profiles", "alimentations", "FK"),
        ("compatibilites", "mounting_profiles", "FK"),
        ("compatibilites", "modeles_traceur", "FK"),
        ("modeles_traceur_types_vehicule", "modeles_traceur", "FK"),
        ("modeles_traceur_types_vehicule", "types_vehicule", "FK"),
        ("model_features", "modeles_traceur", "FK"),
        ("model_features", "features", "FK"),
        ("model_ports", "modeles_traceur", "FK"),
        ("model_ports", "port_types", "FK"),
        ("peripherals", "port_types", "FK"),
    ]

    for src, dst, label in edges:
        dot.edge(src, dst, label=label, dir="both", arrowtail="diamond")

    output_path = os.path.join(OUTPUT_DIR, "mld_tag_monitor")
    dot.render(output_path, cleanup=True)
    print(f"MLD generated: {output_path}.png")


if __name__ == "__main__":
    generate_mcd()
    generate_mld()
