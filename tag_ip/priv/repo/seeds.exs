defmodule Csv do
  @comma 44
  @dquote 34

  def parse(content) do
    content
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.map(&parse_line/1)
  end

  @doc """
  Prend une chaîne brute PostgreSQL/CSV du type "{ignition,engine}"
  et la transforme en une liste propre de chaînes Elixir : ["ignition", "engine"]
  """
  def clean_monitors(nil), do: []
  def clean_monitors(""), do: []

  def clean_monitors(monitors_string) do
    monitors_string
    |> String.replace("{", "")
    |> String.replace("}", "")
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.to_charlist()
    |> do_parse([], [])
    |> Enum.reverse()
  end

  defp do_parse([], current, acc), do: [List.to_string(Enum.reverse(current)) | acc]

  defp do_parse([@dquote | rest], [], acc), do: do_parse_quoted(rest, [], acc)

  defp do_parse([@comma | rest], current, acc) do
    do_parse(rest, [], [List.to_string(Enum.reverse(current)) | acc])
  end

  defp do_parse([c | rest], current, acc), do: do_parse(rest, [c | current], acc)

  defp do_parse_quoted([@dquote, @dquote | rest], current, acc) do
    do_parse_quoted(rest, [@dquote | current], acc)
  end

  defp do_parse_quoted([@dquote | rest], current, acc), do: do_parse(rest, current, acc)

  defp do_parse_quoted([c | rest], current, acc), do: do_parse_quoted(rest, [c | current], acc)
end

alias TagIp.Resources.ProfilMontage
alias TagIp.Resources.ModeleTraceur
alias TagIp.Resources.TrackableType
alias TagIp.Resources.PortType
alias TagIp.Resources.Feature
alias TagIp.Resources.ModelFeature
alias TagIp.Resources.ModelPort
alias TagIp.Resources.Peripheral
alias TagIp.Resources.Alimentation
alias TagIp.Resources.TypeVehicule
alias TagIp.Resources.Capteur
alias TagIp.Resources.ModeleTraceurAlimentation
alias TagIp.Resources.ModeleTraceurTypeVehicule
alias TagIp.Resources.ModeleTraceurCapteur
alias TagIp.Accounts.User
alias TagIp.Repo

IO.puts("--- Début du peuplement de la base de données ---")

# =========================================================
# 1. Utilisateur par défaut
# =========================================================
admin_email = "admin@tag-ip.com"
admin_password = "password1234"

case Repo.get_by(User, email: admin_email) do
  nil ->
    IO.puts("Création de l'utilisateur : #{admin_email}")

    {:ok, user} =
      TagIp.Accounts.register_user(%{
        email: admin_email,
        password: admin_password
      })

    user
    |> Ecto.Changeset.change(%{
      confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)
    })
    |> Repo.update!()

    IO.puts("Admin créé avec succès.")

  user ->
    IO.puts("L'admin existe déjà.")

    if is_nil(user.hashed_password) do
      IO.puts("Mise à jour du mot de passe admin.")

      user
      |> User.password_changeset(%{password: admin_password})
      |> Repo.update!()
    end

    if is_nil(user.confirmed_at) do
      user
      |> Ecto.Changeset.change(%{confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)})
      |> Repo.update!()
    end
end

# =========================================================
# 2. Profils de montage
# =========================================================
profils = [
  %{
    name: "Véhicule ferroviaire",
    description: "Profil pour les véhicules ferroviaires",
    object_type: "railway-vehicle",
    voltage_min: 24,
    voltage_max: 48,
    buzzer: true,
    geofence_enabled: true,
    can_bus_requis: true,
    accelerometre_requis: true,
    inputs_requis: 4,
    outputs_requis: 2
  },
  %{
    name: "Engin de chantier",
    description: "Profil pour engins de chantier",
    object_type: "construction_machine",
    voltage_min: 12,
    voltage_max: 36,
    montage_exterieur: true,
    geofence_enabled: true,
    accelerometre_requis: true,
    inputs_requis: 2,
    outputs_requis: 0
  },
  %{
    name: "Camion transport",
    description: "Profil pour camions de transport",
    object_type: "truck",
    voltage_min: 12,
    voltage_max: 36,
    can_bus_requis: true,
    buzzer: true,
    geofence_enabled: true,
    accelerometre_requis: true,
    antenne_deportee: true,
    inputs_requis: 2,
    outputs_requis: 0
  },
  %{
    name: "Cadenas intelligent",
    description: "Profil pour cadenas connecté intelligent",
    object_type: "smart_lock",
    voltage_min: 3.7,
    voltage_max: 5,
    ultra_low_power_requis: true,
    antenne_deportee: true,
    inputs_requis: 0,
    outputs_requis: 1
  },
  %{
    name: "Moto / Scooter",
    description: "Profil pour motos et scooters",
    object_type: "moto",
    voltage_min: 12,
    voltage_max: 15,
    geofence_enabled: true,
    ultra_low_power_requis: true,
    accelerometre_requis: true,
    inputs_requis: 1,
    outputs_requis: 0
  },
  %{
    name: "Chariot élévateur",
    description: "Profil pour chariots élévateurs",
    object_type: "forklift",
    voltage_min: 12,
    voltage_max: 48,
    accelerometre_requis: true,
    inputs_requis: 2,
    outputs_requis: 0
  },
  %{
    name: "Personne",
    description: "Profil pour suivi de personne",
    object_type: "person",
    voltage_min: 3.7,
    voltage_max: 5,
    ultra_low_power_requis: true,
    inputs_requis: 0,
    outputs_requis: 0
  },
  %{
    name: "Voiture tourisme",
    description: "Profil pour voitures de tourisme",
    object_type: "car",
    voltage_min: 12,
    voltage_max: 15,
    accelerometre_requis: true,
    inputs_requis: 1,
    outputs_requis: 0
  },
  %{
    name: "Bus / Taxibe",
    description: "Profil pour bus et taxis",
    object_type: "bus",
    voltage_min: 12,
    voltage_max: 36,
    can_bus_requis: true,
    accelerometre_requis: true,
    inputs_requis: 2,
    outputs_requis: 0
  },
  %{
    name: "Objet",
    description: "Profil pour suivi d'objet générique",
    object_type: "object",
    voltage_min: 3.7,
    voltage_max: 12,
    ultra_low_power_requis: true,
    antenne_deportee: true,
    inputs_requis: 0,
    outputs_requis: 0
  },
  %{
    name: "Bateau",
    description: "Profil pour embarcations motorisées",
    object_type: "boat",
    voltage_min: 12,
    voltage_max: 24,
    accelerometre_requis: true,
    antenne_deportee: true,
    inputs_requis: 1,
    outputs_requis: 2
  }
]

IO.puts("Insertion des profils...")

Enum.each(profils, fn attrs ->
  try do
    ProfilMontage.create!(attrs, action: :create)
  rescue
    _ -> :ok
  end
end)

# =========================================================
# 3. Types de véhicules, Alimentations, Capteurs (données de référence)
# =========================================================
IO.puts("Insertion des types de véhicules...")

types_vehicule_data = [
  %{
    slug: "truck",
    label: "Camion",
    description: "Véhicule motorisé destiné au transport de marchandises",
    voltage_min: 12,
    voltage_max: 36,
    inputs_requis: 2,
    outputs_requis: 0
  },
  %{
    slug: "bus",
    label: "Bus / Taxibe",
    description: "Véhicule motorisé pour le transport de passagers",
    voltage_min: 12,
    voltage_max: 36,
    inputs_requis: 2,
    outputs_requis: 0
  },
  %{
    slug: "asset",
    label: "Actif générique",
    description: "Actif équipé d'un traceur (conteneur, outillage, équipement)",
    voltage_min: 3.7,
    voltage_max: 12,
    inputs_requis: 0,
    outputs_requis: 0
  },
  %{
    slug: "padlock",
    label: "Cadenas connecté",
    description: "Cadenas intelligent connecté (NFC, Bluetooth, GSM)",
    voltage_min: 3.7,
    voltage_max: 5,
    inputs_requis: 0,
    outputs_requis: 1
  },
  %{
    slug: "construction_machine",
    label: "Engin de chantier",
    description: "Engins utilisés dans le bâtiment et les travaux publics",
    voltage_min: 12,
    voltage_max: 36,
    inputs_requis: 2,
    outputs_requis: 0
  },
  %{
    slug: "car",
    label: "Voiture",
    description: "Véhicule motorisé à quatre roues",
    voltage_min: 12,
    voltage_max: 15,
    inputs_requis: 1,
    outputs_requis: 0
  },
  %{
    slug: "van",
    label: "Van / Utilitaire",
    description: "Véhicule utilitaire léger",
    voltage_min: 12,
    voltage_max: 15,
    inputs_requis: 1,
    outputs_requis: 0
  },
  %{
    slug: "moto",
    label: "Moto",
    description: "Véhicule à deux roues motorisé",
    voltage_min: 12,
    voltage_max: 15,
    inputs_requis: 1,
    outputs_requis: 0
  },
  %{
    slug: "forklift",
    label: "Chariot élévateur",
    description: "Engin motorisé de manutention",
    voltage_min: 12,
    voltage_max: 48,
    inputs_requis: 2,
    outputs_requis: 0
  },
  %{
    slug: "boat",
    label: "Bateau",
    description: "Embarcation motorisée",
    voltage_min: 12,
    voltage_max: 24,
    inputs_requis: 1,
    outputs_requis: 2
  },
  %{
    slug: "railway-vehicle",
    label: "Véhicule ferroviaire",
    description: "Matériel mobile roulant sur rails",
    voltage_min: 24,
    voltage_max: 48,
    inputs_requis: 4,
    outputs_requis: 2
  },
  %{
    slug: "person",
    label: "Personne",
    description: "Suivi de personne",
    voltage_min: 3.7,
    voltage_max: 5,
    inputs_requis: 0,
    outputs_requis: 0
  },
  %{
    slug: "smart_lock",
    label: "Cadenas intelligent",
    description: "Cadenas connecté intelligent",
    voltage_min: 3.7,
    voltage_max: 5,
    inputs_requis: 0,
    outputs_requis: 1
  },
  %{
    slug: "object",
    label: "Objet",
    description: "Suivi d'objet générique",
    voltage_min: 3.7,
    voltage_max: 12,
    inputs_requis: 0,
    outputs_requis: 0
  }
]

tv_by_slug =
  Enum.map(types_vehicule_data, fn attrs ->
    {:ok, tv} = TypeVehicule.create(attrs, action: :create)
    {tv.slug, tv.id}
  end)
  |> Map.new()

IO.puts("Insertion des alimentations...")

alimentations_data = [
  # Alimentations par plage de tension (rétrocompatibilité)
  %{
    slug: "12V",
    label: "12V",
    description: "Alimentation 12V (batterie voiture)",
    category: "voltage"
  },
  %{
    slug: "24V",
    label: "24V",
    description: "Alimentation 24V (poids lourds)",
    category: "voltage"
  },
  %{
    slug: "9-36V",
    label: "9-36V (Large Plage)",
    description: "Alimentation large plage 9V à 36V",
    category: "voltage"
  },
  # Modes d'alimentation
  %{
    slug: "filaire",
    label: "Filaire",
    description: "Alimentation directe sur batterie véhicule",
    category: "power_type"
  },
  %{slug: "obd", label: "OBD", description: "Alimentation via prise OBD", category: "power_type"},
  %{
    slug: "batterie",
    label: "Batterie interne",
    description: "Alimentation sur batterie interne rechargeable",
    category: "power_type"
  },
  %{
    slug: "solaire",
    label: "Solaire",
    description: "Alimentation par panneau solaire",
    category: "power_type"
  }
]

alim_by_slug =
  Enum.map(alimentations_data, fn attrs ->
    {:ok, alim} = Alimentation.create(attrs, action: :create)
    {alim.slug, alim.id}
  end)
  |> Map.new()

IO.puts("Insertion des capteurs...")

capteurs_data = [
  # === Énergie ===
  %{slug: "engine", label: "Moteur", description: "Surveillance état moteur", category: "energy"},
  %{
    slug: "battery_level_monitor",
    label: "Niveau batterie",
    description: "Surveillance du niveau de charge de la batterie",
    category: "energy"
  },
  %{
    slug: "engine_speed",
    label: "Régime moteur",
    description: "Mesure du régime moteur (RPM)",
    category: "energy"
  },
  %{
    slug: "fuel_level_monitor",
    label: "Niveau carburant",
    description: "Surveillance niveau carburant",
    category: "energy"
  },
  %{
    slug: "fuel_cap_monitor",
    label: "Bouchon carburant",
    description: "Détection ouverture bouchon réservoir",
    category: "energy"
  },
  %{
    slug: "fuel_probe_analog",
    label: "Jauge carburant (Analogique)",
    description: "Sonde carburant analogique",
    category: "energy"
  },
  %{
    slug: "fuel_probe_digital",
    label: "Jauge carburant (Numérique)",
    description: "Sonde carburant numérique",
    category: "energy"
  },
  %{
    slug: "fuel_probe_can_bus",
    label: "Jauge carburant (CAN-Bus)",
    description: "Sonde carburant sur bus CAN",
    category: "energy"
  },
  # === Sécurité ===
  %{
    slug: "ignition",
    label: "Contact (Ignition)",
    description: "Détection allumage moteur",
    category: "safety"
  },
  %{
    slug: "alert_button_monitor",
    label: "Bouton d'alerte (SOS)",
    description: "Détection activation bouton d'urgence SOS",
    category: "safety"
  },
  %{
    slug: "lock_status_monitor",
    label: "Statut verrouillage",
    description: "Surveillance de l'état verrouillé/déverrouillé",
    category: "safety"
  },
  %{
    slug: "body_tracker_activity_monitor",
    label: "Activité personne",
    description: "Détection d'activité et de mouvement pour traceur personnel",
    category: "safety"
  },
  %{
    slug: "buzzer",
    label: "Buzzer",
    description: "Avertisseur sonore intégré",
    category: "safety"
  },
  %{
    slug: "geofence",
    label: "Géofence",
    description: "Gestion de zones géographiques",
    category: "safety"
  },
  # === Environnement ===
  # === Conducteur ===
  %{
    slug: "driver_identification_monitor",
    label: "Identification conducteur",
    description: "Lecteur d'identification conducteur",
    category: "driver"
  },
  # === État du véhicule ===
  %{
    slug: "movement_monitor",
    label: "Mouvement",
    description: "Détection de mouvement",
    category: "vehicle_status"
  },
  %{
    slug: "odometer_monitor",
    label: "Odomètre",
    description: "Compteur kilométrique",
    category: "vehicle_status"
  },
  %{
    slug: "availability_monitor",
    label: "Disponibilité (For Hire)",
    description: "Surveillance de l'état de disponibilité du véhicule",
    category: "vehicle_status"
  },
  # === Connectivité ===
  %{
    slug: "connectivity_monitor",
    label: "Connectivité",
    description: "Surveillance de la connexion réseau",
    category: "connectivity"
  }
]

cap_by_slug =
  Enum.map(capteurs_data, fn attrs ->
    {:ok, cap} = Capteur.create(attrs, action: :create)
    {cap.slug, cap.id}
  end)
  |> Map.new()

# =========================================================
# 4. Import CSV
# =========================================================
to_nil = fn
  "" -> nil
  val -> String.trim(val)
end

types_path = Path.join(__DIR__, "trackable_types.csv")

if File.exists?(types_path) do
  IO.puts("Import des types...")

  types_path
  |> File.read!()
  |> Csv.parse()
  |> Enum.each(fn row ->
    case row do
      [slug, _, desc, label | _] ->
        try do
          TrackableType.create!(
            %{slug: to_nil.(slug), label: to_nil.(label), description: to_nil.(desc)},
            action: :create
          )
        rescue
          _ -> :ok
        end

      _ ->
        :ok
    end
  end)
end

IO.puts("Mise à jour des seuils de tension pour les types d'objets...")

voltage_by_slug =
  Enum.into(types_vehicule_data, %{}, fn tv ->
    {tv.slug, %{voltage_min: tv.voltage_min, voltage_max: tv.voltage_max}}
  end)

TrackableType.read!()
|> Enum.each(fn tt ->
  if voltage_data = voltage_by_slug[tt.slug] do
    TrackableType.create!(
      Map.merge(%{slug: tt.slug, label: tt.label, description: tt.description}, voltage_data),
      action: :create
    )
  end
end)

# =========================================================
# 5. Port Types
# =========================================================
IO.puts("Insertion des types de ports...")

port_types = [
  %{
    slug: "digital_input",
    label: "Digital Input (DIN)",
    description: "Entrée numérique (On/Off, contact clé, bouton SOS)"
  },
  %{
    slug: "analog_input",
    label: "Analog Input (AIN)",
    description: "Entrée analogique (Mesure de tension variable, jauge)"
  },
  %{
    slug: "digital_output",
    label: "Digital Output (DOUT)",
    description: "Sortie numérique (Commande de relais, buzzer, sirène)"
  },
  %{
    slug: "one_wire",
    label: "1-Wire",
    description: "Bus unifilaire pour puces Dallas/Maxim (Température, iButton)"
  },
  %{
    slug: "rs232",
    label: "RS232",
    description: "Port série standard pour communication point à point"
  },
  %{slug: "rs485", label: "RS485", description: "Bus série industriel pour chaînage de capteurs"},
  %{
    slug: "can_bus",
    label: "CAN-Bus",
    description: "Bus réseau véhicule (J1939, J1708, FMS, OBD)"
  },
  %{
    slug: "tachograph",
    label: "Tachograph (K-Line)",
    description: "Interface spécifique pour chronotachygraphe"
  },
  %{
    slug: "bluetooth_ble",
    label: "Bluetooth BLE",
    description: "Connectivité sans fil courte portée pour capteurs autonomes"
  }
]

port_type_ids =
  Enum.map(port_types, fn attrs ->
    {:ok, pt} = PortType.create(attrs, action: :create)
    {pt.slug, pt.id}
  end)
  |> Map.new()

# =========================================================
# 6. Features
# =========================================================
IO.puts("Insertion des fonctionnalités...")

features = [
  %{
    slug: "real_time_tracking",
    label: "Real-time Tracking",
    description: "Suivi de position en temps réel par intervalle"
  },
  %{
    slug: "green_driving",
    label: "Green Driving",
    description: "Éco-conduite — analyse du comportement de conduite (freinage, accélération)"
  },
  %{
    slug: "eco_driving",
    label: "Eco-driving",
    description: "Analyse du comportement de conduite (freinage, accélération)"
  },
  %{
    slug: "crash_detection",
    label: "Crash Detection",
    description: "Détection d'accident via accéléromètre interne"
  },
  %{
    slug: "geofencing",
    label: "Geofencing",
    description: "Gestion de zones géographiques embarquées"
  },
  %{
    slug: "fuel_monitoring",
    label: "Fuel Monitoring",
    description: "Suivi précis de la consommation et des vols de carburant"
  },
  %{
    slug: "driver_id",
    label: "Driver ID",
    description: "Identification du conducteur (iButton, RFID, BLE)"
  },
  %{
    slug: "cold_chain",
    label: "Cold Chain Monitoring",
    description: "Suivi de température et humidité (Chaîne du froid)"
  },
  %{
    slug: "tacho_download",
    label: "Tacho Download",
    description: "Téléchargement à distance des données légales du chronotachygraphe"
  },
  %{
    slug: "engine_immobilization",
    label: "Engine Immobilization",
    description: "Coupure moteur à distance via relais"
  },
  # === Fonctionnalités de la Matrice de Capacités (Assistant) ===
  %{
    slug: "alert_button",
    label: "Alerte bouton (SOS)",
    description: "Bouton d'alerte panique / SOS"
  },
  %{
    slug: "buzzer_feature",
    label: "Buzzer",
    description: "Avertisseur sonore intégré"
  },
  %{
    slug: "fuel_cap",
    label: "Bouchon réservoir",
    description: "Détection ouverture bouchon réservoir"
  },
  %{
    slug: "fuel_analog",
    label: "Carburant (Analogique)",
    description: "Sonde carburant analogique"
  },
  %{
    slug: "fuel_rs232",
    label: "Carburant (RS232)",
    description: "Sonde carburant sur port série RS232"
  },
  %{
    slug: "fuel_ble",
    label: "Carburant (BLE)",
    description: "Sonde carburant sans fil Bluetooth BLE"
  },
  %{
    slug: "fuel_can",
    label: "Carburant (CAN)",
    description: "Sonde carburant sur bus CAN"
  }
]

feature_ids =
  Enum.map(features, fn attrs ->
    {:ok, feat} = Feature.create(attrs, action: :create)
    {feat.slug, feat.id}
  end)
  |> Map.new()

# =========================================================
# 7. Modèles de traceurs pour la comparaison technique
# =========================================================
IO.puts("Insertion des modèles de traceurs pour la comparaison technique...")

teltonika_vehicle_features =
  ~w(alert_button driver_id green_driving buzzer_feature fuel_cap fuel_analog fuel_rs232 fuel_ble fuel_can crash_detection)

teltonika_body_features = ~w(alert_button)
systech_features = ~w(alert_button driver_id buzzer_feature fuel_analog)
wonderproud_features = ~w(alert_button driver_id buzzer_feature fuel_analog)
jointech_features = []

teltonika_vehicle_capteurs =
  ~w(ignition alert_button_monitor buzzer fuel_cap_monitor fuel_probe_analog fuel_probe_digital fuel_probe_can_bus driver_identification_monitor geofence engine)

teltonika_body_capteurs = ~w(alert_button_monitor body_tracker_activity_monitor)

systech_vehicle_capteurs =
  ~w(ignition alert_button_monitor buzzer driver_identification_monitor fuel_probe_analog geofence)

wonderproud_vehicle_capteurs =
  ~w(ignition alert_button_monitor buzzer driver_identification_monitor fuel_probe_analog geofence)

jointech_capteurs = ~w(lock_status_monitor movement_monitor)

teltonika_vehicle_types =
  ~w(truck car bus van construction_machine railway-vehicle moto forklift boat)

teltonika_body_types = ~w(person)
systech_types = ~w(truck car bus van construction_machine)
wonderproud_types = ~w(truck car bus van)
jointech_types = ~w(smart_lock padlock)

new_tracker_models = [
  # === Teltonika — Catégorie: vehicle ===
  %{
    nom: "FMB003",
    brand: "Teltonika",
    reference: "TLT-FMB003",
    description: "Traceur GPS véhicule — gamme FMB",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 2,
    can_bus: false,
    one_wire: true,
    rs232: false,
    rs485: false,
    accelerometer: true,
    buffer_memory: 128,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V 24V),
    capteur_slugs: teltonika_vehicle_capteurs,
    type_vehicule_slugs: teltonika_vehicle_types,
    feature_slugs: teltonika_vehicle_features
  },
  %{
    nom: "FMB020",
    brand: "Teltonika",
    reference: "TLT-FMB020",
    description: "Traceur GPS véhicule — gamme FMB",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 2,
    can_bus: false,
    one_wire: true,
    rs232: false,
    rs485: false,
    accelerometer: true,
    buffer_memory: 128,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V 24V),
    capteur_slugs: teltonika_vehicle_capteurs,
    type_vehicule_slugs: teltonika_vehicle_types,
    feature_slugs: teltonika_vehicle_features
  },
  %{
    nom: "FMB120",
    brand: "Teltonika",
    reference: "TLT-FMB120",
    description: "Traceur GPS véhicule — gamme FMB",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 2,
    can_bus: false,
    one_wire: true,
    rs232: false,
    rs485: false,
    accelerometer: true,
    buffer_memory: 128,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V 24V),
    capteur_slugs: teltonika_vehicle_capteurs,
    type_vehicule_slugs: teltonika_vehicle_types,
    feature_slugs: teltonika_vehicle_features
  },
  %{
    nom: "FMB125",
    brand: "Teltonika",
    reference: "TLT-FMB125",
    description: "Traceur GPS véhicule — gamme FMB",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 2,
    can_bus: false,
    one_wire: true,
    rs232: false,
    rs485: false,
    accelerometer: true,
    buffer_memory: 128,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V 24V),
    capteur_slugs: teltonika_vehicle_capteurs,
    type_vehicule_slugs: teltonika_vehicle_types,
    feature_slugs: teltonika_vehicle_features
  },
  %{
    nom: "FMB130",
    brand: "Teltonika",
    reference: "TLT-FMB130",
    description: "Traceur GPS véhicule — gamme FMB",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 2,
    can_bus: false,
    one_wire: true,
    rs232: false,
    rs485: false,
    accelerometer: true,
    buffer_memory: 128,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V 24V),
    capteur_slugs: teltonika_vehicle_capteurs,
    type_vehicule_slugs: teltonika_vehicle_types,
    feature_slugs: teltonika_vehicle_features
  },
  %{
    nom: "FMB140",
    brand: "Teltonika",
    reference: "TLT-FMB140",
    description: "Traceur GPS véhicule — gamme FMB",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 2,
    can_bus: false,
    one_wire: true,
    rs232: false,
    rs485: false,
    accelerometer: true,
    buffer_memory: 128,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V 24V),
    capteur_slugs: teltonika_vehicle_capteurs,
    type_vehicule_slugs: teltonika_vehicle_types,
    feature_slugs: teltonika_vehicle_features
  },
  %{
    nom: "FMB204",
    brand: "Teltonika",
    reference: "TLT-FMB204",
    description: "Traceur GPS véhicule — gamme FMB",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 2,
    can_bus: false,
    one_wire: true,
    rs232: false,
    rs485: false,
    accelerometer: true,
    buffer_memory: 128,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V 24V),
    capteur_slugs: teltonika_vehicle_capteurs,
    type_vehicule_slugs: teltonika_vehicle_types,
    feature_slugs: teltonika_vehicle_features
  },
  %{
    nom: "FMB640",
    brand: "Teltonika",
    reference: "TLT-FMB640",
    description: "Traceur GPS véhicule haut de gamme",
    nb_digital_inputs: 4,
    nb_analog_inputs: 2,
    nb_outputs: 4,
    can_bus: true,
    one_wire: true,
    rs232: true,
    rs485: true,
    accelerometer: true,
    buffer_memory: 512,
    ip_rating: "IP65",
    voltage_min: 10,
    voltage_max: 50,
    alimentation_slugs: ~w(12V 24V 9-36V),
    capteur_slugs: teltonika_vehicle_capteurs,
    type_vehicule_slugs: teltonika_vehicle_types,
    feature_slugs: teltonika_vehicle_features
  },
  %{
    nom: "FMB641",
    brand: "Teltonika",
    reference: "TLT-FMB641",
    description: "Traceur GPS véhicule haut de gamme",
    nb_digital_inputs: 4,
    nb_analog_inputs: 2,
    nb_outputs: 4,
    can_bus: true,
    one_wire: true,
    rs232: true,
    rs485: true,
    accelerometer: true,
    buffer_memory: 512,
    ip_rating: "IP65",
    voltage_min: 10,
    voltage_max: 50,
    alimentation_slugs: ~w(12V 24V 9-36V),
    capteur_slugs: teltonika_vehicle_capteurs,
    type_vehicule_slugs: teltonika_vehicle_types,
    feature_slugs: teltonika_vehicle_features
  },
  %{
    nom: "FMB920",
    brand: "Teltonika",
    reference: "TLT-FMB920",
    description: "Traceur GPS véhicule — gamme FMB",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 2,
    can_bus: false,
    one_wire: true,
    rs232: false,
    rs485: false,
    accelerometer: true,
    buffer_memory: 128,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V 24V),
    capteur_slugs: teltonika_vehicle_capteurs,
    type_vehicule_slugs: teltonika_vehicle_types,
    feature_slugs: teltonika_vehicle_features
  },
  %{
    nom: "FMC130",
    brand: "Teltonika",
    reference: "TLT-FMC130",
    description: "Traceur GPS 4G avec entrées négatives, Bluetooth BLE, 1-Wire et accéléromètre.",
    nb_digital_inputs: 3,
    nb_analog_inputs: 1,
    nb_outputs: 3,
    can_bus: false,
    one_wire: true,
    rs232: false,
    rs485: false,
    accelerometer: true,
    buffer_memory: 256,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V 24V),
    capteur_slugs: teltonika_vehicle_capteurs,
    type_vehicule_slugs: teltonika_vehicle_types,
    feature_slugs: teltonika_vehicle_features
  },
  %{
    nom: "FMC230",
    brand: "Teltonika",
    reference: "TLT-FMC230",
    description: "Traceur GPS 4G véhicule",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 2,
    can_bus: false,
    one_wire: true,
    rs232: false,
    rs485: false,
    accelerometer: true,
    buffer_memory: 128,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V 24V),
    capteur_slugs: teltonika_vehicle_capteurs,
    type_vehicule_slugs: teltonika_vehicle_types,
    feature_slugs: teltonika_vehicle_features
  },
  %{
    nom: "FMP100",
    brand: "Teltonika",
    reference: "TLT-FMP100",
    description: "Traceur GPS véhicule haut de gamme — gamme FMP",
    nb_digital_inputs: 4,
    nb_analog_inputs: 2,
    nb_outputs: 4,
    can_bus: true,
    one_wire: true,
    rs232: true,
    rs485: true,
    accelerometer: true,
    buffer_memory: 512,
    ip_rating: "IP65",
    voltage_min: 10,
    voltage_max: 50,
    alimentation_slugs: ~w(12V 24V 9-36V),
    capteur_slugs: teltonika_vehicle_capteurs,
    type_vehicule_slugs: teltonika_vehicle_types,
    feature_slugs: teltonika_vehicle_features
  },

  # === Teltonika — Catégorie: body_tracker ===
  %{
    nom: "GH5200",
    brand: "Teltonika",
    reference: "TLT-GH5200",
    description: "Traceur GPS personnel / body tracker",
    nb_digital_inputs: 0,
    nb_analog_inputs: 0,
    nb_outputs: 0,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: true,
    buffer_memory: 32,
    ip_rating: "IP67",
    voltage_min: 3.7,
    voltage_max: 5,
    alimentation_slugs: ~w(batterie),
    capteur_slugs: teltonika_body_capteurs,
    type_vehicule_slugs: teltonika_body_types,
    feature_slugs: teltonika_body_features
  },
  %{
    nom: "TMT250",
    brand: "Teltonika",
    reference: "TLT-TMT250",
    description: "Traceur GPS personnel / body tracker",
    nb_digital_inputs: 0,
    nb_analog_inputs: 0,
    nb_outputs: 0,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: true,
    buffer_memory: 32,
    ip_rating: "IP67",
    voltage_min: 3.7,
    voltage_max: 5,
    alimentation_slugs: ~w(batterie),
    capteur_slugs: teltonika_body_capteurs,
    type_vehicule_slugs: teltonika_body_types,
    feature_slugs: teltonika_body_features
  },

  # === Systech — Catégorie: vehicle ===
  %{
    nom: "A1",
    brand: "Systech",
    reference: "SYS-CAREU-A1",
    description: "Traceur GPS économique Systech",
    nb_digital_inputs: 1,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 64,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V),
    capteur_slugs: systech_vehicle_capteurs,
    type_vehicule_slugs: systech_types,
    feature_slugs: systech_features
  },
  %{
    nom: "CAREU U1",
    brand: "Systech",
    reference: "SYS-CAREU-U1",
    description: "Traceur GPS avec interpréteur OBDII/CAN, RS232 multi-port, RS485.",
    nb_digital_inputs: 2,
    nb_analog_inputs: 0,
    nb_outputs: 1,
    can_bus: true,
    one_wire: true,
    rs232: true,
    rs485: true,
    accelerometer: false,
    buffer_memory: 256,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 50,
    alimentation_slugs: ~w(12V 24V),
    capteur_slugs:
      ~w(ignition alert_button_monitor buzzer driver_identification_monitor geofence fuel_probe_analog),
    type_vehicule_slugs: ~w(truck car bus van construction_machine railway-vehicle),
    feature_slugs: systech_features
  },
  %{
    nom: "CAREU U1+",
    brand: "Systech",
    reference: "SYS-CAREU-U1PLUS",
    description: "Traceur GPS Systech U1+",
    nb_digital_inputs: 2,
    nb_analog_inputs: 0,
    nb_outputs: 1,
    can_bus: true,
    one_wire: true,
    rs232: true,
    rs485: true,
    accelerometer: false,
    buffer_memory: 256,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 50,
    alimentation_slugs: ~w(12V 24V),
    capteur_slugs: systech_vehicle_capteurs,
    type_vehicule_slugs: systech_types,
    feature_slugs: systech_features
  },
  %{
    nom: "CAREU U1 Lite",
    brand: "Systech",
    reference: "SYS-CAREU-U1LITE",
    description: "Traceur GPS Systech U1 Lite",
    nb_digital_inputs: 2,
    nb_analog_inputs: 0,
    nb_outputs: 1,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 64,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V),
    capteur_slugs: systech_vehicle_capteurs,
    type_vehicule_slugs: systech_types,
    feature_slugs: systech_features
  },
  %{
    nom: "WR",
    brand: "Systech",
    reference: "SYS-WR",
    description: "Traceur GPS Systech WR",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 64,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V),
    capteur_slugs: systech_vehicle_capteurs,
    type_vehicule_slugs: systech_types,
    feature_slugs: systech_features
  },
  %{
    nom: "CAREU U1 UW1",
    brand: "Systech",
    reference: "SYS-CAREU-U1UW1",
    description: "Traceur GPS Systech U1 UW1",
    nb_digital_inputs: 2,
    nb_analog_inputs: 0,
    nb_outputs: 1,
    can_bus: true,
    one_wire: true,
    rs232: true,
    rs485: true,
    accelerometer: false,
    buffer_memory: 256,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 50,
    alimentation_slugs: ~w(12V 24V),
    capteur_slugs: systech_vehicle_capteurs,
    type_vehicule_slugs: systech_types,
    feature_slugs: systech_features
  },
  %{
    nom: "CAREU Ueco",
    brand: "Systech",
    reference: "SYS-CAREU-UECO",
    description: "Traceur GPS économique Systech",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 64,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V),
    capteur_slugs: systech_vehicle_capteurs,
    type_vehicule_slugs: systech_types,
    feature_slugs: systech_features
  },
  %{
    nom: "COBAN 103-B",
    brand: "Systech",
    reference: "SYS-COBAN-103B",
    description: "Traceur GPS COBAN 103-B",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 64,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V),
    capteur_slugs: systech_vehicle_capteurs,
    type_vehicule_slugs: systech_types,
    feature_slugs: systech_features
  },
  %{
    nom: "P1",
    brand: "Systech",
    reference: "SYS-P1",
    description: "Traceur GPS Systech P1",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 64,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V),
    capteur_slugs: systech_vehicle_capteurs,
    type_vehicule_slugs: systech_types,
    feature_slugs: systech_features
  },
  %{
    nom: "P2",
    brand: "Systech",
    reference: "SYS-P2",
    description: "Traceur GPS Systech P2",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 64,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V),
    capteur_slugs: systech_vehicle_capteurs,
    type_vehicule_slugs: systech_types,
    feature_slugs: systech_features
  },
  %{
    nom: "Ucan",
    brand: "Systech",
    reference: "SYS-UCAN",
    description: "Traceur GPS Systech Ucan",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    can_bus: true,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 64,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 50,
    alimentation_slugs: ~w(12V 24V),
    capteur_slugs: systech_vehicle_capteurs,
    type_vehicule_slugs: systech_types,
    feature_slugs: systech_features
  },
  %{
    nom: "UGO",
    brand: "Systech",
    reference: "SYS-CAREU-UGO",
    description: "Traceur GPS économique Systech",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 64,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V),
    capteur_slugs: systech_vehicle_capteurs,
    type_vehicule_slugs: systech_types,
    feature_slugs: systech_features
  },

  # === WonderProud — Catégorie: vehicle ===
  %{
    nom: "VT10",
    brand: "WonderProud",
    reference: "WON-VT10",
    description: "Traceur GPS véhicule WonderProud",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 64,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V),
    capteur_slugs: wonderproud_vehicle_capteurs,
    type_vehicule_slugs: wonderproud_types,
    feature_slugs: wonderproud_features
  },
  %{
    nom: "VT200",
    brand: "WonderProud",
    reference: "WON-VT200",
    description: "Traceur GPS basique WonderProud",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 64,
    ip_rating: "IP54",
    voltage_min: 10,
    voltage_max: 30,
    alimentation_slugs: ~w(12V),
    capteur_slugs: wonderproud_vehicle_capteurs,
    type_vehicule_slugs: wonderproud_types,
    feature_slugs: wonderproud_features
  },

  # === Jointech — Catégorie: cadenas ===
  %{
    nom: "JT700 solar",
    brand: "Jointech",
    reference: "JTC-JT700",
    description: "Cadenas connecté GPS",
    nb_digital_inputs: 0,
    nb_analog_inputs: 0,
    nb_outputs: 0,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 16,
    ip_rating: "IP68",
    voltage_min: 3.7,
    voltage_max: 5,
    alimentation_slugs: ~w(batterie),
    capteur_slugs: jointech_capteurs,
    type_vehicule_slugs: jointech_types,
    feature_slugs: jointech_features
  },
  %{
    nom: "JT701",
    brand: "Jointech",
    reference: "JTC-JT701",
    description: "Cadenas connecté GPS",
    nb_digital_inputs: 0,
    nb_analog_inputs: 0,
    nb_outputs: 0,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 16,
    ip_rating: "IP68",
    voltage_min: 3.7,
    voltage_max: 5,
    alimentation_slugs: ~w(batterie),
    capteur_slugs: jointech_capteurs,
    type_vehicule_slugs: jointech_types,
    feature_slugs: jointech_features
  },
  %{
    nom: "JT701D",
    brand: "Jointech",
    reference: "JTC-JT701D",
    description: "Cadenas connecté GPS",
    nb_digital_inputs: 0,
    nb_analog_inputs: 0,
    nb_outputs: 0,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 16,
    ip_rating: "IP68",
    voltage_min: 3.7,
    voltage_max: 5,
    alimentation_slugs: ~w(batterie),
    capteur_slugs: jointech_capteurs,
    type_vehicule_slugs: jointech_types,
    feature_slugs: jointech_features
  },
  %{
    nom: "JT709A",
    brand: "Jointech",
    reference: "JTC-JT709A",
    description: "Cadenas connecté GPS haut de gamme",
    nb_digital_inputs: 0,
    nb_analog_inputs: 0,
    nb_outputs: 0,
    can_bus: false,
    one_wire: false,
    rs232: false,
    rs485: false,
    accelerometer: false,
    buffer_memory: 32,
    ip_rating: "IP68",
    voltage_min: 3.7,
    voltage_max: 5,
    alimentation_slugs: ~w(batterie),
    capteur_slugs: jointech_capteurs,
    type_vehicule_slugs: jointech_types,
    feature_slugs: jointech_features
  }
]

new_model_ids =
  Enum.map(new_tracker_models, fn attrs ->
    feature_slugs = attrs[:feature_slugs]
    alim_slugs = attrs[:alimentation_slugs] || []
    cap_slugs = attrs[:capteur_slugs] || []
    tv_slugs = attrs[:type_vehicule_slugs] || []

    attrs =
      Map.drop(attrs, [:feature_slugs, :alimentation_slugs, :capteur_slugs, :type_vehicule_slugs])

    case ModeleTraceur.create(attrs, action: :create) do
      {:ok, modele} ->
        Enum.each(feature_slugs, fn slug ->
          if fid = feature_ids[slug] do
            ModelFeature.create(%{
              modele_traceur_id: modele.id,
              feature_id: fid
            })
          end
        end)

        Enum.each(alim_slugs, fn slug ->
          if aid = alim_by_slug[slug] do
            ModeleTraceurAlimentation.create(%{
              modele_traceur_id: modele.id,
              alimentation_id: aid
            })
          end
        end)

        Enum.each(cap_slugs, fn slug ->
          if cid = cap_by_slug[slug] do
            ModeleTraceurCapteur.create(%{
              modele_traceur_id: modele.id,
              capteur_id: cid
            })
          end
        end)

        Enum.each(tv_slugs, fn slug ->
          if tvid = tv_by_slug[slug] do
            ModeleTraceurTypeVehicule.create(%{
              modele_traceur_id: modele.id,
              type_vehicule_id: tvid
            })
          end
        end)

        modele

      {:error, _} ->
        nil
    end
  end)
  |> Enum.reject(&is_nil/1)

IO.puts("Modèles de référence insérés: #{length(new_model_ids)}")

# =========================================================
# 8. Model Ports (Broches Physiques)
# =========================================================
IO.puts("Insertion des ports physiques...")

all_modeles = ModeleTraceur.read!()
model_by_ref = Map.new(all_modeles, &{&1.reference, &1.id})

pin_defs = [
  # Teltonika FMC130
  {model_by_ref["TLT-FMC130"], port_type_ids["digital_input"], "DIN1 (Ignition)"},
  {model_by_ref["TLT-FMC130"], port_type_ids["digital_input"], "DIN2 (Negative Input support)"},
  {model_by_ref["TLT-FMC130"], port_type_ids["digital_input"], "DIN3 (Configurable AIN2)"},
  {model_by_ref["TLT-FMC130"], port_type_ids["analog_input"], "AIN1"},
  {model_by_ref["TLT-FMC130"], port_type_ids["digital_output"], "DOUT1"},
  {model_by_ref["TLT-FMC130"], port_type_ids["digital_output"], "DOUT2"},
  {model_by_ref["TLT-FMC130"], port_type_ids["digital_output"], "DOUT3"},
  {model_by_ref["TLT-FMC130"], port_type_ids["one_wire"], "1-Wire Data"},
  {model_by_ref["TLT-FMC130"], port_type_ids["bluetooth_ble"], "Bluetooth BLE Channel"},

  # Systech CAREU U1
  {model_by_ref["SYS-CAREU-U1"], port_type_ids["digital_input"], "DIN1 (Ignition)"},
  {model_by_ref["SYS-CAREU-U1"], port_type_ids["digital_input"], "DIN2 (Panic Button)"},
  {model_by_ref["SYS-CAREU-U1"], port_type_ids["digital_output"], "DOUT1 (Relay Control)"},
  {model_by_ref["SYS-CAREU-U1"], port_type_ids["one_wire"], "1-Wire Interface"},
  {model_by_ref["SYS-CAREU-U1"], port_type_ids["rs232"], "RS232 Main"},
  {model_by_ref["SYS-CAREU-U1"], port_type_ids["rs232"], "RS232 Extension 1"},
  {model_by_ref["SYS-CAREU-U1"], port_type_ids["rs232"], "RS232 Extension 2"},
  {model_by_ref["SYS-CAREU-U1"], port_type_ids["rs485"], "RS485 Bus"},
  {model_by_ref["SYS-CAREU-U1"], port_type_ids["can_bus"], "Internal OBDII/CAN Interpreter"},

  # Systech A1
  {model_by_ref["SYS-CAREU-A1"], port_type_ids["digital_input"], "DIN1 (Ignition)"},
  {model_by_ref["SYS-CAREU-A1"], port_type_ids["analog_input"], "AIN1 (Fuel Gauge)"},
  {model_by_ref["SYS-CAREU-A1"], port_type_ids["digital_output"], "DOUT1 (Immobilizer)"},

  # Wondeproud VT200
  {model_by_ref["WON-VT200"], port_type_ids["digital_input"], "DIN1 (Ignition)"},
  {model_by_ref["WON-VT200"], port_type_ids["digital_input"], "DIN2 (SOS)"},
  {model_by_ref["WON-VT200"], port_type_ids["analog_input"], "AIN1"},
  {model_by_ref["WON-VT200"], port_type_ids["digital_output"], "DOUT1 (Cut-Off)"}
]

Enum.each(pin_defs, fn {modele_id, port_type_id, pin_label} ->
  if modele_id do
    ModelPort.create(%{
      modele_traceur_id: modele_id,
      port_type_id: port_type_id,
      pin_label: pin_label
    })
  end
end)

IO.puts("Ports physiques insérés: #{length(pin_defs)}")

# =========================================================
# 9. Peripherals
# =========================================================
IO.puts("Insertion des périphériques...")

peripherals = [
  %{
    port_type_id: port_type_ids["one_wire"],
    name: "DS18B20 Temperature Probe",
    description: "Sonde de température 1-Wire"
  },
  %{
    port_type_id: port_type_ids["one_wire"],
    name: "iButton Driver ID Reader",
    description: "Lecteur d'identification conducteur iButton"
  },
  %{
    port_type_id: port_type_ids["rs232"],
    name: "Omnicomm Fuel Level Sensor LLS",
    description: "Jauge de niveau carburant RS232"
  },
  %{
    port_type_id: port_type_ids["rs232"],
    name: "Garmin FMI Navigation Display",
    description: "Affichage navigation FMI"
  },
  %{
    port_type_id: port_type_ids["rs232"],
    name: "ADAS Fatigue Camera",
    description: "Caméra anti-fatigue ADAS"
  },
  %{
    port_type_id: port_type_ids["rs485"],
    name: "Industrial RFID Reader",
    description: "Lecteur RFID industriel RS485"
  },
  %{
    port_type_id: port_type_ids["bluetooth_ble"],
    name: "Teltonika EYE Sensor (Temp/Hum)",
    description: "Capteur température/humidité BLE"
  },
  %{
    port_type_id: port_type_ids["bluetooth_ble"],
    name: "Wireless Escort Fuel Sensor",
    description: "Capteur carburant sans fil BLE"
  },
  %{
    port_type_id: port_type_ids["digital_output"],
    name: "12V Automotive Relay",
    description: "Relais 12V pour sortie numérique"
  },
  %{
    port_type_id: port_type_ids["digital_output"],
    name: "Driver Alarm Buzzer",
    description: "Buzzer d'alerte conducteur"
  },
  %{
    port_type_id: port_type_ids["digital_input"],
    name: "Waterproof SOS Emergency Button",
    description: "Bouton d'urgence SOS étanche"
  }
]

Enum.each(peripherals, fn attrs ->
  Peripheral.create(attrs)
end)

IO.puts("Périphériques insérés: #{length(peripherals)}")

IO.puts("--- Terminé ! ---")
