# Script de configuration des 11 types d'actifs
# Usage: mix run priv/repo/data_setup.exs


alias TagIp.Resources.TypeVehicule
alias TagIp.Resources.ProfilMontage
alias TagIp.Resources.ModeleTraceur
alias TagIp.Resources.ModeleTraceurTypeVehicule
alias TagIp.Resources.Compatibilite

IO.puts("=== Configuration des 11 types d'actifs ===")
IO.puts("")

# =========================================================
# 1. Définition des 11 types avec leurs spécifications
# =========================================================
IO.puts("1. Insertion/mise à jour des 11 types...")

types_data = [
  %{slug: "railway-vehicle", label: "Véhicule ferroviaire",   voltage_min: 24,   voltage_max: 48,   inputs_requis: 4, outputs_requis: 2, description: "Matériel mobile roulant sur rails"},
  %{slug: "construction_machine", label: "Engin de chantier", voltage_min: 12,   voltage_max: 36,   inputs_requis: 2, outputs_requis: 0, description: "Engins utilisés dans le bâtiment et les travaux publics"},
  %{slug: "truck", label: "Camion",                            voltage_min: 12,   voltage_max: 36,   inputs_requis: 2, outputs_requis: 0, description: "Véhicule motorisé destiné au transport de marchandises"},
  %{slug: "smart_lock", label: "Cadenas intelligent",         voltage_min: 3.7,  voltage_max: 5,    inputs_requis: 0, outputs_requis: 1, description: "Dispositif de verrouillage connecté"},
  %{slug: "moto", label: "Moto",                               voltage_min: 12,   voltage_max: 15,   inputs_requis: 1, outputs_requis: 0, description: "Véhicule à deux roues motorisé"},
  %{slug: "forklift", label: "Chariot élévateur",              voltage_min: 12,   voltage_max: 48,   inputs_requis: 2, outputs_requis: 0, description: "Engin motorisé de manutention"},
  %{slug: "person", label: "Personne",                         voltage_min: 3.7,  voltage_max: 5,    inputs_requis: 0, outputs_requis: 0, description: "Personne équipée d'un traceur portable"},
  %{slug: "car", label: "Voiture",                             voltage_min: 12,   voltage_max: 15,   inputs_requis: 1, outputs_requis: 0, description: "Véhicule motorisé à quatre roues"},
  %{slug: "bus", label: "Bus / Taxibe",                        voltage_min: 12,   voltage_max: 36,   inputs_requis: 2, outputs_requis: 0, description: "Véhicule motorisé pour le transport de passagers"},
  %{slug: "object", label: "Objet",                            voltage_min: 3.7,  voltage_max: 12,   inputs_requis: 0, outputs_requis: 0, description: "Objet équipé d'un traceur (conteneur, outillage, etc.)"},
  %{slug: "boat", label: "Bateau",                             voltage_min: 12,   voltage_max: 24,   inputs_requis: 1, outputs_requis: 2, description: "Embarcation motorisée"}
]

type_by_slug =
  Enum.map(types_data, fn attrs ->
    {:ok, tv} = TypeVehicule.create(attrs, action: :create)
    {tv.slug, tv.id}
  end)
  |> Map.new()

IO.puts("  → #{map_size(type_by_slug)} types configurés")

# =========================================================
# 2. Profils de montage pour les 11 types
# =========================================================
IO.puts("2. Création/mise à jour des profils de montage...")

profils_data = [
  %{
    name: "Véhicule ferroviaire",
    description: "Profil pour véhicules ferroviaires (train, tram, métro)",
    object_type: "railway-vehicle",
    voltage_min: 24,
    voltage_max: 48,
    inputs_requis: 4,
    outputs_requis: 2,
    buzzer: true,
    geofence_enabled: true,
    can_bus_requis: true,
    accelerometre_requis: true
  },
  %{
    name: "Engin de chantier",
    description: "Profil pour engins de chantier (pelle, bulldozer, etc.)",
    object_type: "construction_machine",
    voltage_min: 12,
    voltage_max: 36,
    inputs_requis: 2,
    montage_exterieur: true,
    geofence_enabled: true,
    accelerometre_requis: true
  },
  %{
    name: "Camion transport",
    description: "Profil pour camions de transport de marchandises",
    object_type: "truck",
    voltage_min: 12,
    voltage_max: 36,
    inputs_requis: 2,
    can_bus_requis: true,
    buzzer: true,
    geofence_enabled: true,
    accelerometre_requis: true,
    antenne_deportee: true
  },
  %{
    name: "Cadenas intelligent",
    description: "Profil pour cadenas et serrures connectés",
    object_type: "smart_lock",
    voltage_min: 3.7,
    voltage_max: 5,
    outputs_requis: 1,
    ultra_low_power_requis: true,
    antenne_deportee: true
  },
  %{
    name: "Moto / Scooter",
    description: "Profil pour motos et scooters",
    object_type: "moto",
    voltage_min: 12,
    voltage_max: 15,
    inputs_requis: 1,
    geofence_enabled: true,
    ultra_low_power_requis: true,
    accelerometre_requis: true
  },
  %{
    name: "Chariot élévateur",
    description: "Profil pour chariots élévateurs et engins de manutention",
    object_type: "forklift",
    voltage_min: 12,
    voltage_max: 48,
    inputs_requis: 2,
    geofence_enabled: true,
    accelerometre_requis: true
  },
  %{
    name: "Personne",
    description: "Profil pour traceur portable personnel",
    object_type: "person",
    voltage_min: 3.7,
    voltage_max: 5,
    ultra_low_power_requis: true
  },
  %{
    name: "Voiture tourisme",
    description: "Profil standard pour voitures de tourisme",
    object_type: "car",
    voltage_min: 12,
    voltage_max: 15,
    inputs_requis: 1,
    geofence_enabled: true,
    accelerometre_requis: true
  },
  %{
    name: "Bus / Taxibe",
    description: "Profil pour bus et taxis collectifs",
    object_type: "bus",
    voltage_min: 12,
    voltage_max: 36,
    inputs_requis: 2,
    can_bus_requis: true,
    buzzer: true,
    geofence_enabled: true,
    accelerometre_requis: true
  },
  %{
    name: "Objet",
    description: "Profil pour objets équipés d'un traceur (conteneurs, outillage)",
    object_type: "object",
    voltage_min: 3.7,
    voltage_max: 12,
    ultra_low_power_requis: true,
    antenne_deportee: true
  },
  %{
    name: "Bateau",
    description: "Profil pour bateaux et embarcations motorisés",
    object_type: "boat",
    voltage_min: 12,
    voltage_max: 24,
    inputs_requis: 1,
    outputs_requis: 2,
    geofence_enabled: true,
    accelerometre_requis: true,
    antenne_deportee: true
  }
]

Enum.each(profils_data, fn attrs ->
  try do
    ProfilMontage.create!(attrs, action: :create)
  rescue
    _ -> :ok
  end
end)

IO.puts("  → #{length(profils_data)} profils créés/mis à jour")

# =========================================================
# 3. Lier tous les types à tous les modèles de traceurs
# =========================================================
IO.puts("3. Liaison des 11 types à tous les traceurs...")

modeles = ModeleTraceur.read!()

Enum.each(modeles, fn modele ->
  Enum.each(type_by_slug, fn {_slug, type_id} ->
    try do
      ModeleTraceurTypeVehicule.create(%{
        modele_traceur_id: modele.id,
        type_vehicule_id: type_id
      })
    rescue
      _ -> :ok
    end
  end)
end)

IO.puts("  → #{length(modeles)} traceurs liés aux #{map_size(type_by_slug)} types")

# =========================================================
# 4. Définir les plages de tension sur les traceurs (3V-50V)
# =========================================================
IO.puts("4. Configuration des plages de tension des traceurs...")

Enum.each(modeles, fn modele ->
  ModeleTraceur.update!(modele, %{voltage_min: 3, voltage_max: 50}, action: :update)
end)

IO.puts("  → #{length(modeles)} traceurs configurés avec plage 3V-50V")

# =========================================================
# 5. Supprimer tout l'historique des compatibilités
# =========================================================
IO.puts("5. Nettoyage de l'historique des compatibilités...")

Compatibilite
|> Ash.Query.new()
|> Ash.read!()
|> Enum.each(fn compat ->
  Ash.destroy!(compat)
end)

IO.puts("  → Historique vidé")

IO.puts("")
IO.puts("=== Configuration terminée avec succès ! ===")
