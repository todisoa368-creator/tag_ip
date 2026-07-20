# =========================================================
# Seeds de Démonstration — Données Réalistes d'Entreprise
# =========================================================
# Ce fichier contient des données réalistes pour TAG-IP Solutions,
# modélisant les vrais besoins de ses clients malgaches.
#
# Usage: mix run priv/repo/seeds_demo.exs
#
# Prérequis: les seeds de base (seeds.exs) doivent avoir été exécutées
# au moins une fois pour peupler les référentiels (types, capteurs, etc.)
# =========================================================

alias TagIp.Resources.ProfilMontage
alias TagIp.Resources.ModeleTraceur
alias TagIp.Resources.TypeVehicule
alias TagIp.Resources.Alimentation
alias TagIp.Resources.Capteur
alias TagIp.Resources.Organisation
alias TagIp.Resources.ProfilMontageCapteur
alias TagIp.Resources.Compatibilite
alias TagIp.Repo

IO.puts("==========================================")
IO.puts("  Seeds de Démonstration — TAG-IP Solutions")
IO.puts("==========================================")

# =========================================================
# 1. Organisations Clients Réalistes
# =========================================================
IO.puts("\n[1/6] Insertion des organisations clients...")

organisations_data = [
  %{
    slug: "tag-ip",
    name: "TAG-IP Solutions",
    description: "Société de géolocalisation GPS — 10 000+ véhicules suivis à Madagascar"
  },
  %{
    slug: "jirama",
    name: "JIRAMA",
    description: "Jiro sy Rano Malagasy — Entreprise nationale d'électricité et d'eau. Parc de véhicules utilitaires et engins de maintenance."
  },
  %{
    slug: "omo-tsena",
    name: "Omo Tsena",
    description: "Réseau de transport en commun d'Antananarivo — 300+ minibus et busnavettes"
  },
  %{
    slug: "dhl-madagascar",
    name: "DHL Madagascar",
    description: "DHL Express — Logistique express internationale. Véhicules de livraison et conteneurs."
  },
  %{
    slug: "transports-mada",
    name: "Transports Madagascar",
    description: "Société de transport interurbain — Flotte de bus et camions longue distance"
  },
  %{
    slug: "bollar-logistics",
    name: "Bolloré Logistics Madagascar",
    description: "Logistique portuaire et terrestre — Conteneurs, camions, chariots élévateurs"
  },
  %{
    slug: "star-taxi",
    name: "Star Taxi Antananarivo",
    description: "Réseau de taxis — 200+ voitures de tourisme"
  },
  %{
    slug: "soa-pharma",
    name: "Soa Pharma Distribution",
    description: "Distribution pharmaceutique — Chaîne du froid médicale, véhicules réfrigérés"
  },
  %{
    slug: "cna-ps",
    name: "CNA-PS (Chantiers Navals)",
    description: "Chantiers Navals et Portuaires de Toamasina — Engins portuaires et embarcations"
  },
  %{
    slug: "crafo-jirama",
    name: "CRAFO — Centre de Recherche Agronomique",
    description: "Centre de Recherche sur le Fonctionnement des Systèmes Agraires — Véhicules terrain"
  }
]

org_by_slug =
  Enum.map(organisations_data, fn attrs ->
    case Organisation.create(attrs, action: :create) do
      {:ok, org} ->
        IO.puts("  ✓ #{org.name}")
        {org.slug, org.id}

      {:error, _} ->
        existing = Organisation.read!() |> Enum.find(&(&1.slug == attrs.slug))
        if existing, do: {attrs.slug, existing.id}, else: nil
    end
  end)
  |> Enum.reject(&is_nil/1)
  |> Map.new()

# =========================================================
# 2. Types de véhicules et alimentations (référentiels)
# =========================================================
IO.puts("\n[2/6] Récupération des référentiels...")

tv_by_slug =
  TypeVehicule.read!()
  |> Map.new(fn tv -> {tv.slug, tv.id} end)

alim_by_slug =
  Alimentation.read!()
  |> Map.new(fn a -> {a.slug, a.id} end)

cap_by_slug =
  Capteur.read!()
  |> Map.new(fn c -> {c.slug, c.id} end)

modeles = ModeleTraceur.read!()
model_by_ref = Map.new(modeles, &{&1.reference, &1.id})

IO.puts("  Types de véhicules: #{map_size(tv_by_slug)}")
IO.puts("  Alimentations: #{map_size(alim_by_slug)}")
IO.puts("  Capteurs: #{map_size(cap_by_slug)}")
IO.puts("  Modèles traceurs: #{length(modeles)}")

# =========================================================
# 3. Profils de Montage Réalistes — Par Entreprise
# =========================================================
IO.puts("\n[3/6] Insertion des profils de montage réalistes...")

# Helper pour insérer un profil avec capteurs
insert_profil = fn profil_attrs, capteur_slugs ->
  org_slug = profil_attrs[:org_slug]
  org_id = org_by_slug[org_slug]

  attrs =
    profil_attrs
    |> Map.drop([:org_slug, :capteur_slugs])
    |> Map.put(:organisation_id, org_id)

  case ProfilMontage.create(attrs, action: :create) do
    {:ok, profil} ->
      Enum.each(capteur_slugs || [], fn slug ->
        if cid = cap_by_slug[slug] do
          ProfilMontageCapteur.create(%{
            profil_montage_id: profil.id,
            capteur_id: cid
          })
        end
      end)

      IO.puts("  ✓ #{profil.name}")
      profil

    {:error, changeset} ->
      IO.puts("  ✗ Erreur: #{inspect(changeset.errors)}")
      nil
  end
end

# -----------------------------------------------------------------------
# 3.1 JIRAMA — Entreprise nationale d'électricité
# -----------------------------------------------------------------------
IO.puts("\n  --- JIRAMA ---")

insert_profil.(%{
  name: "Camion de maintenance électrique JIRAMA",
  description: "Véhicule utilitaire pour intervention sur lignes électriques. Nécessite CAN bus pour diagnostics moteur et géofence pour zone de service.",
  org_slug: "jirama",
  object_type: "truck",
  type_vehicule_id: tv_by_slug["truck"],
  voltage_min: 12,
  voltage_max: 24,
  can_bus_requis: true,
  geofence_enabled: true,
  accelerometre_requis: true,
  inputs_requis: 2,
  outputs_requis: 1
}, ~w(ignition engine geofence movement_monitor))

insert_profil.(%{
  name: "Chariot élévateur entrepôt JIRAMA",
  description: "Engin de manutention pour manutention de transformateurs. Montage intérieur, pas de protection extérieure requise.",
  org_slug: "jirama",
  object_type: "forklift",
  type_vehicule_id: tv_by_slug["forklift"],
  voltage_min: 24,
  voltage_max: 48,
  inputs_requis: 2,
  outputs_requis: 0
}, ~w(ignition movement_monitor odometer_monitor))

insert_profil.(%{
  name: "Moto d'intervention rapide JIRAMA",
  description: "Moto pour techniciens d'intervention urgente. Ultra low power pour autonomie longue, accéléromètre pour détection chute.",
  org_slug: "jirama",
  object_type: "moto",
  type_vehicule_id: tv_by_slug["moto"],
  voltage_min: 12,
  voltage_max: 15,
  ultra_low_power_requis: true,
  accelerometre_requis: true,
  geofence_enabled: true,
  inputs_requis: 1,
  outputs_requis: 0
}, ~w(ignition alert_button_monitor))

# -----------------------------------------------------------------------
# 3.2 Omo Tsena — Transport en commun Antananarivo
# -----------------------------------------------------------------------
IO.puts("\n  --- Omo Tsena ---")

insert_profil.(%{
  name: "Minibus Omo Tsena — Ligne 105 (Ambohijanaka → Analakely)",
  description: "Navette urbaine 15 places. Identification conducteur obligatoire, géofence sur itinéraire, buzzer pour arrêts.",
  org_slug: "omo-tsena",
  object_type: "bus",
  type_vehicule_id: tv_by_slug["bus"],
  voltage_min: 12,
  voltage_max: 24,
  can_bus_requis: true,
  buzzer: true,
  geofence_enabled: true,
  accelerometre_requis: true,
  inputs_requis: 2,
  outputs_requis: 1
}, ~w(ignition driver_identification_monitor geofence alert_button_monitor))

insert_profil.(%{
  name: "Bus interurbain Antananarivo → Toamasina",
  description: "Bus longue distance. Suivi carburant essentiel, CAN bus pour consommation, géofence pour zones d'escale.",
  org_slug: "omo-tsena",
  object_type: "bus",
  type_vehicule_id: tv_by_slug["bus"],
  voltage_min: 24,
  voltage_max: 36,
  can_bus_requis: true,
  fuel_probe_type: "can_bus",
  geofence_enabled: true,
  inputs_requis: 2,
  outputs_requis: 0
}, ~w(ignition fuel_level_monitor fuel_probe_can_bus geofence odometer_monitor))

# -----------------------------------------------------------------------
# 3.3 DHL Madagascar — Logistique Express
# -----------------------------------------------------------------------
IO.puts("\n  --- DHL Madagascar ---")

insert_profil.(%{
  name: "Camion de livraison DHL — Zone urbaine",
  description: "Fourgon de livraison express. Géofence stricte, identification conducteur, suivi carburant, buzzer pour alertes.",
  org_slug: "dhl-madagascar",
  object_type: "truck",
  type_vehicule_id: tv_by_slug["truck"],
  voltage_min: 12,
  voltage_max: 24,
  can_bus_requis: true,
  buzzer: true,
  geofence_enabled: true,
  fuel_probe_type: "analogique",
  accelerometre_requis: true,
  inputs_requis: 2,
  outputs_requis: 1
}, ~w(ignition fuel_level_monitor driver_identification_monitor geofence alert_button_monitor))

insert_profil.(%{
  name: "Conteneur DHL — Suivi fret maritime",
  description: "Cadenas connecté pour conteneur shipping. Ultra low power, batterie longue autonomie, antenne déportée pour conteneur métallique.",
  org_slug: "dhl-madagascar",
  object_type: "smart_lock",
  type_vehicule_id: tv_by_slug["padlock"],
  voltage_min: 3.7,
  voltage_max: 5,
  ultra_low_power_requis: true,
  antenne_deportee: true,
  montage_exterieur: false,
  geofence_enabled: true,
  inputs_requis: 0,
  outputs_requis: 1
}, ~w(lock_status_monitor geofence movement_monitor))

# -----------------------------------------------------------------------
# 3.4 Transports Madagascar — Transport interurbain
# -----------------------------------------------------------------------
IO.puts("\n  --- Transports Madagascar ---")

insert_profil.(%{
  name: "Camion cargo longue distance",
  description: "Transport de marchandises interurbain. CAN bus obligatoire, suivi carburant détaillé, géofence nationale.",
  org_slug: "transports-mada",
  object_type: "truck",
  type_vehicule_id: tv_by_slug["truck"],
  voltage_min: 12,
  voltage_max: 36,
  can_bus_requis: true,
  rs232_requis: true,
  fuel_probe_type: "rs232",
  geofence_enabled: true,
  accelerometre_requis: true,
  antenne_deportee: true,
  inputs_requis: 3,
  outputs_requis: 1
}, ~w(ignition fuel_level_monitor fuel_probe_analog geofence odometer_monitor alert_button_monitor))

insert_profil.(%{
  name: "Bus interurbain Antananarivo — Fianarantsoa",
  description: "Bus 40 places. Identification conducteur, géofence, buzzer, CAN bus.",
  org_slug: "transports-mada",
  object_type: "bus",
  type_vehicule_id: tv_by_slug["bus"],
  voltage_min: 24,
  voltage_max: 36,
  can_bus_requis: true,
  buzzer: true,
  geofence_enabled: true,
  inputs_requis: 2,
  outputs_requis: 1
}, ~w(ignition driver_identification_monitor geofence alert_button_monitor))

# -----------------------------------------------------------------------
# 3.5 Bolloré Logistics — Logistique portuaire
# -----------------------------------------------------------------------
IO.puts("\n  --- Bolloré Logistics ---")

insert_profil.(%{
  name: "Chariot élévateur portuaire Toamasina",
  description: "Manutention de conteneurs au port. Voltage large plage, RS485 pour capteurs industriels, montage extérieur IP67+.",
  org_slug: "bollar-logistics",
  object_type: "forklift",
  type_vehicule_id: tv_by_slug["forklift"],
  voltage_min: 24,
  voltage_max: 48,
  rs485_requis: true,
  montage_exterieur: true,
  geofence_enabled: true,
  inputs_requis: 4,
  outputs_requis: 2
}, ~w(ignition movement_monitor odometer_monitor geofence))

insert_profil.(%{
  name: "Camion porte-conteneurs portuaire",
  description: "Transport conteneurs intra-port. CAN bus, géofence stricte, suivi carburant, buzzer.",
  org_slug: "bollar-logistics",
  object_type: "truck",
  type_vehicule_id: tv_by_slug["truck"],
  voltage_min: 24,
  voltage_max: 36,
  can_bus_requis: true,
  buzzer: true,
  geofence_enabled: true,
  fuel_probe_type: "can_bus",
  inputs_requis: 2,
  outputs_requis: 1
}, ~w(ignition fuel_level_monitor fuel_probe_can_bus geofence alert_button_monitor))

# -----------------------------------------------------------------------
# 3.6 Star Taxi — Flotte de taxis
# -----------------------------------------------------------------------
IO.puts("\n  --- Star Taxi ---")

insert_profil.(%{
  name: "Taxi urbain Antananarivo — Berliet",
  description: "Voiture de taxi 4 places. Géofence ville, accéléromètre pour éco-conduction, identification chauffeur.",
  org_slug: "star-taxi",
  object_type: "car",
  type_vehicule_id: tv_by_slug["car"],
  voltage_min: 12,
  voltage_max: 15,
  geofence_enabled: true,
  accelerometre_requis: true,
  inputs_requis: 1,
  outputs_requis: 0
}, ~w(ignition driver_identification_monitor geofence movement_monitor))

insert_profil.(%{
  name: "Taxi aéroport — Transfer VIP",
  description: "Véhicule transfer aéroport. Suivi précis, géofence aéroport + ville, buzzer pour alertes retard.",
  org_slug: "star-taxi",
  object_type: "car",
  type_vehicule_id: tv_by_slug["car"],
  voltage_min: 12,
  voltage_max: 15,
  buzzer: true,
  geofence_enabled: true,
  accelerometre_requis: true,
  inputs_requis: 1,
  outputs_requis: 1
}, ~w(ignition geofence alert_button_monitor movement_monitor))

# -----------------------------------------------------------------------
# 3.7 Soa Pharma — Distribution pharmaceutique
# -----------------------------------------------------------------------
IO.puts("\n  --- Soa Pharma ---")

insert_profil.(%{
  name: "Camion réfrigéré — Chaîne du froid vaccins",
  description: "Transport de vaccins et médicaments thermosensibles. Sonde température 1-Wire obligatoire, RS232 pour sonde précise, géofence stricte.",
  org_slug: "soa-pharma",
  object_type: "truck",
  type_vehicule_id: tv_by_slug["truck"],
  voltage_min: 12,
  voltage_max: 24,
  one_wire_requis: true,
  rs232_requis: true,
  can_bus_requis: true,
  geofence_enabled: true,
  accelerometre_requis: true,
  inputs_requis: 2,
  outputs_requis: 1
}, ~w(ignition fuel_level_monitor geofence engine))

insert_profil.(%{
  name: "Utilitaire livraison pharmacies",
  description: "Fourgon de livraison quotidienne. Géofence itinéraires, identification livreur, buzzer alertes.",
  org_slug: "soa-pharma",
  object_type: "van",
  type_vehicule_id: tv_by_slug["van"],
  voltage_min: 12,
  voltage_max: 15,
  buzzer: true,
  geofence_enabled: true,
  accelerometre_requis: true,
  inputs_requis: 1,
  outputs_requis: 1
}, ~w(ignition driver_identification_monitor geofence alert_button_monitor))

# -----------------------------------------------------------------------
# 3.8 CNA-PS — Chantiers Navals et Portuaires
# -----------------------------------------------------------------------
IO.puts("\n  --- CNA-PS ---")

insert_profil.(%{
  name: "Embarcation de patrol portuaire",
  description: "Petit bateau de surveillance du port de Toamasina. Montage extérieur obligatoire, antenne déportée, accéléromètre.",
  org_slug: "cna-ps",
  object_type: "boat",
  type_vehicule_id: tv_by_slug["boat"],
  voltage_min: 12,
  voltage_max: 24,
  montage_exterieur: true,
  antenne_deportee: true,
  accelerometre_requis: true,
  geofence_enabled: true,
  inputs_requis: 1,
  outputs_requis: 2
}, ~w(ignition geofence alert_button_monitor movement_monitor))

insert_profil.(%{
  name: "Grue portuaire — Engin lourd",
  description: "Grue de chargement/déchargement. CAN bus obligatoire, RS485 pour instruments, montage extérieur, haute tension.",
  org_slug: "cna-ps",
  object_type: "construction_machine",
  type_vehicule_id: tv_by_slug["construction_machine"],
  voltage_min: 24,
  voltage_max: 48,
  can_bus_requis: true,
  rs485_requis: true,
  montage_exterieur: true,
  geofence_enabled: true,
  inputs_requis: 4,
  outputs_requis: 2
}, ~w(ignition movement_monitor geofence engine))

# -----------------------------------------------------------------------
# 3.9 CRAFO — Recherche Agronomique
# -----------------------------------------------------------------------
IO.puts("\n  --- CRAFO ---")

insert_profil.(%{
  name: "4x4 terrain recherche agronomique",
  description: "Véhicule tout-terrain pour parcelles expérimentales. Géofence rurale, accéléromètre, suivi carburant.",
  org_slug: "crafo-jirama",
  object_type: "car",
  type_vehicule_id: tv_by_slug["car"],
  voltage_min: 12,
  voltage_max: 15,
  geofence_enabled: true,
  accelerometre_requis: true,
  fuel_probe_type: "analogique",
  inputs_requis: 2,
  outputs_requis: 0
}, ~w(ignition fuel_level_monitor geofence movement_monitor odometer_monitor))

insert_profil.(%{
  name: "Moto de terrain — Chargé de mission",
  description: "Moto pour accès zones enclavées. Ultra low power, accéléromètre, géofence.",
  org_slug: "crafo-jirama",
  object_type: "moto",
  type_vehicule_id: tv_by_slug["moto"],
  voltage_min: 12,
  voltage_max: 15,
  ultra_low_power_requis: true,
  accelerometre_requis: true,
  geofence_enabled: true,
  inputs_requis: 1,
  outputs_requis: 0
}, ~w(ignition geofence movement_monitor))



# =========================================================
# 4. Calcul des Compatibilités pour tous les profils
# =========================================================
IO.puts("\n[4/6] Calcul des compatibilités...")

profils = ProfilMontage.read!()
IO.puts("  #{length(profils)} profils à évaluer")

all_modeles =
  ModeleTraceur
  |> Ash.read!()
  |> Enum.map(&Ash.load!(&1, [:types_vehicule, :alimentations, :capteurs, :model_ports]))

Enum.each(profils, fn profil ->
  try do
    profil_loaded =
      profil
      |> Ash.load!([:capteurs, :peripherals])

    capteur_slugs = Enum.map(profil_loaded.capteurs || [], & &1.slug)
    peripheral_ids = Enum.map(profil_loaded.peripherals || [], & &1.id)

    profil_params = %{
      "object_type" => profil_loaded.object_type,
      "voltage_min" => profil_loaded.voltage_min,
      "voltage_max" => profil_loaded.voltage_max,
      "can_bus_requis" => profil_loaded.can_bus_requis,
      "one_wire_requis" => profil_loaded.one_wire_requis,
      "rs232_requis" => profil_loaded.rs232_requis,
      "rs485_requis" => profil_loaded.rs485_requis,
      "bluetooth_ble_requis" => profil_loaded.bluetooth_ble_requis,
      "inputs_requis" => profil_loaded.inputs_requis,
      "analog_inputs_requis" => profil_loaded.analog_inputs_requis,
      "outputs_requis" => profil_loaded.outputs_requis,
      "montage_exterieur" => profil_loaded.montage_exterieur,
      "antenne_deportee" => profil_loaded.antenne_deportee,
      "accelerometre_requis" => profil_loaded.accelerometre_requis,
      "ultra_low_power_requis" => profil_loaded.ultra_low_power_requis,
      "buzzer" => profil_loaded.buzzer,
      "geofence_enabled" => profil_loaded.geofence_enabled,
      "fuel_probe_type" => profil_loaded.fuel_probe_type
    }

    count =
      Enum.reduce(all_modeles, 0, fn modele, acc ->
        result =
          TagIp.Resources.Compatibilite.calculer_depuis_params(
            profil_params,
            modele,
            capteur_slugs,
            peripheral_ids
          )

        if result.compatible do
          TagIp.Resources.Compatibilite
          |> Ash.Changeset.for_create(:create, %{
            profil_montage_id: profil_loaded.id,
            modele_traceur_id: modele.id,
            score_compatibilite: result.score,
            details: Enum.join(result.details, "\n")
          },
            upsert?: true,
            upsert_identity: :unique_compatibilite
          )
          |> Ash.create!()

          acc + 1
        else
          acc
        end
      end)

    IO.puts("  ✓ #{profil.name} → #{count} modèles compatibles")
  rescue
    e ->
      IO.puts("  ✗ #{profil.name} → Erreur: #{Exception.message(e)}")
  end
end)

# =========================================================
# 5. Statistiques de démonstration
# =========================================================
IO.puts("\n[5/6] Statistiques de démonstration...")

all_compat =
  TagIp.Resources.Compatibilite
  |> Ash.read!()

total_compat = length(all_compat)

if total_compat > 0 do
  scores = Enum.map(all_compat, & &1.score_compatibilite)
  avg_score = Float.round(Enum.sum(scores) / total_compat, 1)
  max_score = Enum.max(scores)
  min_score = Enum.min(scores)
  compatible_count = Enum.count(scores, &(&1 >= 40))

  IO.puts("  Total compatibilités calculées: #{total_compat}")
  IO.puts("  Score moyen: #{avg_score}/100")
  IO.puts("  Score max: #{max_score}/100")
  IO.puts("  Score min: #{min_score}/100")
  IO.puts("  Modèles compatibles (≥40): #{compatible_count}")
  IO.puts("  Modèles incompatibles (<40): #{total_compat - compatible_count}")
else
  IO.puts("  Aucune compatibilité calculée.")
end

# =========================================================
# 6. Résumé final
# =========================================================
IO.puts("\n[6/6] Résumé final...")

orgs = Organisation.read!()
profils_final = ProfilMontage.read!()

IO.puts("\n==========================================")
IO.puts("  RÉSUMÉ DE LA DÉMONSTRATION")
IO.puts("==========================================")
IO.puts("  Organisations: #{length(orgs)}")
IO.puts("  Profils de montage: #{length(profils_final)}")
IO.puts("  Modèles traceurs: #{length(modeles)}")
IO.puts("  Compatibilités: #{total_compat}")
IO.puts("")
IO.puts("  Comptes de démonstration:")
IO.puts("    Email: admin@tag-ip.com")
IO.puts("    Mot de passe: password1234")
IO.puts("")
IO.puts("  Pour accéder à l'application:")
IO.puts("    mix phx.server")
IO.puts("    → http://localhost:4000")
IO.puts("==========================================")
IO.puts("\n--- Terminé ! ---")
