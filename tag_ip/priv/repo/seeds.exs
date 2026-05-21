defmodule Csv do
  @comma 44
  @dquote 34

  def parse(content) do
    content
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.map(&parse_line/1)
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
alias TagIp.Resources.ModeleTraceurAlimentation
alias TagIp.Accounts.User
alias TagIp.Repo

IO.puts("--- Début du peuplement de la base de données ---")

# 1. Utilisateur par défaut
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
    |> Ecto.Changeset.change(%{confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)})
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

# 2. Profils de montage
profils = [
  %{
    name: "Véhicule utilitaire léger",
    description: "Profil pour les véhicules utilitaires légers",
    object_type: "car",
    voltage_min: 10800,
    voltage_max: 32000,
    buzzer: true,
    geofence_enabled: true,
    inputs_requis: 1,
    outputs_requis: 1,
    ip_rating: "IP54",
    accelerometre_requis: true
  },
  %{
    name: "Camion transport longue distance",
    description: "Profil pour les camions longue distance avec FMS",
    object_type: "truck",
    voltage_min: 18000,
    voltage_max: 32000,
    buzzer: true,
    fuel_probe_type: "can_bus",
    geofence_enabled: true,
    can_bus_requis: true,
    inputs_requis: 2,
    analog_inputs_requis: 1,
    outputs_requis: 1,
    ip_rating: "IP65",
    accelerometre_requis: true,
    buffer_requis: 256,
    antenne_deportee: true
  },
  %{
    name: "Voiture tourisme",
    description: "Profil standard pour voitures de tourisme",
    object_type: "car",
    voltage_min: 10800,
    voltage_max: 16000,
    buzzer: false,
    geofence_enabled: true,
    inputs_requis: 1
  },
  %{
    name: "Moto",
    description: "Profil pour motos et scooters",
    object_type: "moto",
    voltage_min: 10800,
    voltage_max: 16000,
    geofence_enabled: true,
    ultra_low_power_requis: true,
    inputs_requis: 1
  },
  %{
    name: "Engin de chantier",
    description: "Profil pour engins de chantier et conteneurs",
    object_type: "construction_machine",
    voltage_min: 18000,
    voltage_max: 36000,
    geofence_enabled: true,
    montage_exterieur: true,
    ip_rating: "IP67",
    accelerometre_requis: true,
    buffer_requis: 512,
    inputs_requis: 2,
    outputs_requis: 1
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

# 3. Modèles de traceurs
modeles = [
  %{
    nom: "Teltonika FMB920",
    reference: "TLT-FMB920",
    types_vehicule_compatibles: ["car", "moto", "bus", "truck"],
    alimentations_compatibles: ["12V", "24V"],
    capteurs_supportes: [
      "buzzer",
      "geofence",
      "fuel_probe_rs232",
      "fuel_probe_analog",
      "immobilizer"
    ],
    description:
      "Traceur GPS compact polyvalent 2G avec entrées numériques/analogiques, idéal pour véhicules légers et poids lourds.",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    ip_rating: "IP54",
    accelerometer: true,
    buffer_memory: 128
  },
  %{
    nom: "Teltonika FMB125",
    reference: "TLT-FMB125",
    types_vehicule_compatibles: ["car", "moto"],
    alimentations_compatibles: ["12V", "24V"],
    capteurs_supportes: ["buzzer", "geofence", "immobilizer"],
    description: "Traceur GPS 2G entrée de gamme pour véhicules légers, compatible 12/24V.",
    nb_digital_inputs: 1,
    nb_outputs: 1,
    ip_rating: "IP54",
    buffer_memory: 64
  },
  %{
    nom: "Teltonika FMC650",
    reference: "TLT-FMC650",
    types_vehicule_compatibles: ["truck", "bus", "construction_machine"],
    alimentations_compatibles: ["12V", "24V", "9-36V"],
    capteurs_supportes: [
      "buzzer",
      "geofence",
      "fuel_probe_rs232",
      "fuel_probe_can_bus",
      "temp",
      "rfid"
    ],
    description:
      "Traceur GPS 4G robuste pour flottes professionnelles et engins de chantier, alimentation large plage.",
    can_bus: true,
    nb_digital_inputs: 3,
    nb_analog_inputs: 1,
    nb_outputs: 2,
    ip_rating: "IP65",
    accelerometer: true,
    buffer_memory: 256,
    antennes_externes: true
  },
  %{
    nom: "Teltonika FMM130",
    reference: "TLT-FMM130",
    types_vehicule_compatibles: ["car", "truck", "bus", "boat", "construction_machine"],
    alimentations_compatibles: ["12V", "24V", "9-36V"],
    capteurs_supportes: [
      "buzzer",
      "geofence",
      "fuel_probe_rs232",
      "fuel_probe_can_bus",
      "immobilizer",
      "acceleration"
    ],
    description:
      "Traceur GPS 4G tout-terrain avec GNSS, accéléromètre et large plage de tension.",
    can_bus: true,
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    ip_rating: "IP65",
    accelerometer: true,
    buffer_memory: 256,
    antennes_externes: true
  },
  %{
    nom: "Teltonika FMB003",
    reference: "TLT-FMB003",
    types_vehicule_compatibles: ["car", "moto"],
    alimentations_compatibles: ["12V"],
    capteurs_supportes: ["buzzer", "geofence"],
    description: "Mini traceur GPS 2G économique pour véhicules légers 12V.",
    nb_digital_inputs: 1,
    ip_rating: "IP54"
  },
  %{
    nom: "Queclink GV350",
    reference: "QCL-GV350",
    types_vehicule_compatibles: ["car", "moto", "truck"],
    alimentations_compatibles: ["12V", "24V"],
    capteurs_supportes: ["buzzer", "geofence", "fuel_probe_rs232", "immobilizer", "sos"],
    description: "Traceur GPS 2G avec batterie de secours, conçu pour la gestion de flotte.",
    nb_digital_inputs: 2,
    nb_outputs: 1,
    ip_rating: "IP54",
    buffer_memory: 128
  },
  %{
    nom: "Queclink GV55",
    reference: "QCL-GV55",
    types_vehicule_compatibles: ["truck", "construction_machine"],
    alimentations_compatibles: ["12V", "24V", "9-36V"],
    capteurs_supportes: [
      "buzzer",
      "geofence",
      "fuel_probe_rs232",
      "fuel_probe_can_bus",
      "temp",
      "rfid",
      "sos"
    ],
    description: "Traceur GPS 4G renforcé IP65 pour véhicules lourds et engins de chantier.",
    can_bus: true,
    nb_digital_inputs: 3,
    nb_analog_inputs: 1,
    nb_outputs: 2,
    ip_rating: "IP65",
    accelerometer: true,
    buffer_memory: 256,
    antennes_externes: true
  },
  %{
    nom: "Queclink GL300",
    reference: "QCL-GL300",
    types_vehicule_compatibles: ["asset", "person"],
    alimentations_compatibles: ["battery"],
    capteurs_supportes: ["geofence", "sos", "acceleration"],
    description:
      "Mini traceur GPS portable à batterie rechargeable pour suivi de personnes et d'objets.",
    accelerometer: true,
    ultra_low_power: true,
    ip_rating: "IP65"
  },
  %{
    nom: "Queclink GL310",
    reference: "QCL-GL310",
    types_vehicule_compatibles: ["asset", "person", "padlock"],
    alimentations_compatibles: ["battery"],
    capteurs_supportes: ["geofence", "sos", "acceleration", "gyro"],
    description: "Traceur GPS compact à batterie avec gyroscope, idéal pour cadenas connectés.",
    accelerometer: true,
    ultra_low_power: true,
    ip_rating: "IP65",
    buffer_memory: 64
  },
  %{
    nom: "Concox GT06N",
    reference: "CNC-GT06N",
    types_vehicule_compatibles: ["car", "truck", "moto"],
    alimentations_compatibles: ["12V", "24V"],
    capteurs_supportes: ["buzzer", "geofence", "fuel_probe_analog", "immobilizer", "sos"],
    description: "Traceur GPS 2G avec coupe-circuit et entrée jauge carburant analogique.",
    nb_digital_inputs: 1,
    nb_outputs: 1,
    ip_rating: "IP54"
  },
  %{
    nom: "Concox TR06",
    reference: "CNC-TR06",
    types_vehicule_compatibles: ["car", "truck"],
    alimentations_compatibles: ["12V", "24V"],
    capteurs_supportes: ["buzzer", "geofence", "fuel_probe_rs232", "temp", "immobilizer"],
    description: "Traceur GPS 4G robuste avec 2 entrées numériques et 1 entrée analogique.",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    ip_rating: "IP65",
    rs232: true,
    buffer_memory: 128
  },
  %{
    nom: "Concox GL300W",
    reference: "CNC-GL300W",
    types_vehicule_compatibles: ["asset", "person", "padlock"],
    alimentations_compatibles: ["battery"],
    capteurs_supportes: ["geofence", "sos", "acceleration"],
    description: "Mini traceur GPS portable à batterie avec aimant intégré.",
    accelerometer: true,
    ultra_low_power: true,
    ip_rating: "IP65"
  },
  %{
    nom: "Meitrack MVT380",
    reference: "MTK-MVT380",
    types_vehicule_compatibles: ["truck", "bus", "construction_machine"],
    alimentations_compatibles: ["12V", "24V", "9-36V"],
    capteurs_supportes: [
      "buzzer",
      "geofence",
      "fuel_probe_rs232",
      "fuel_probe_can_bus",
      "temp",
      "rfid",
      "immobilizer"
    ],
    description: "Traceur GPS 4G professionnel pour poids lourds avec interface CAN bus et RFID.",
    can_bus: true,
    nb_digital_inputs: 3,
    nb_analog_inputs: 1,
    nb_outputs: 2,
    ip_rating: "IP65",
    rs232: true,
    accelerometer: true,
    buffer_memory: 256,
    antennes_externes: true
  },
  %{
    nom: "Meitrack MVT600",
    reference: "MTK-MVT600",
    types_vehicule_compatibles: ["car", "truck", "bus", "railway-vehicle", "construction_machine"],
    alimentations_compatibles: ["12V", "24V", "9-36V"],
    capteurs_supportes: [
      "buzzer",
      "geofence",
      "fuel_probe_rs232",
      "fuel_probe_can_bus",
      "temp",
      "rfid",
      "nfc",
      "acceleration"
    ],
    description: "Traceur GPS 4G haut de gamme avec NFC, RS232, CAN bus et accéléromètre 3 axes.",
    can_bus: true,
    rs232: true,
    nb_digital_inputs: 4,
    nb_analog_inputs: 2,
    nb_outputs: 2,
    ip_rating: "IP65",
    accelerometer: true,
    buffer_memory: 512,
    antennes_externes: true,
    ultra_low_power: true
  },
  %{
    nom: "TK103",
    reference: "TK103-B",
    types_vehicule_compatibles: ["car", "truck", "moto"],
    alimentations_compatibles: ["12V", "24V"],
    capteurs_supportes: ["buzzer", "geofence", "immobilizer", "sos"],
    description: "Traceur GPS 2G économique avec microphone et coupe-moteur intégré.",
    nb_digital_inputs: 1,
    nb_outputs: 1,
    ip_rating: "IP54"
  },
  %{
    nom: "TKSTAR TK905",
    reference: "TKS-TK905",
    types_vehicule_compatibles: ["car", "moto", "truck", "asset"],
    alimentations_compatibles: ["12V", "24V", "battery"],
    capteurs_supportes: ["buzzer", "geofence", "sos", "acceleration"],
    description:
      "Traceur GPS magnétique à batterie pour véhicules et objets, installation sans fil.",
    accelerometer: true,
    ultra_low_power: true,
    ip_rating: "IP67",
    buffer_memory: 128
  },
  %{
    nom: "Suntech ST90",
    reference: "SUN-ST90",
    types_vehicule_compatibles: ["car", "truck"],
    alimentations_compatibles: ["12V", "24V"],
    capteurs_supportes: ["buzzer", "geofence", "fuel_probe_rs232", "immobilizer", "temp"],
    description: "Traceur GPS 4G avec 2 entrées numériques, 1 sortie et entrée analogique.",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    ip_rating: "IP54",
    rs232: true,
    buffer_memory: 128
  },
  %{
    nom: "iStartek GM02",
    reference: "IST-GM02",
    types_vehicule_compatibles: ["car", "truck", "moto", "bus"],
    alimentations_compatibles: ["12V", "24V"],
    capteurs_supportes: ["buzzer", "geofence", "fuel_probe_analog", "rfid", "immobilizer", "sos"],
    description: "Traceur GPS 4G avec lecteur RFID et entrée jauge carburant.",
    nb_digital_inputs: 2,
    nb_outputs: 1,
    ip_rating: "IP54",
    buffer_memory: 128
  },
  %{
    nom: "Jimiiot JT701",
    reference: "JIM-JT701",
    types_vehicule_compatibles: ["truck", "construction_machine", "bus"],
    alimentations_compatibles: ["12V", "24V", "9-36V"],
    capteurs_supportes: [
      "buzzer",
      "geofence",
      "fuel_probe_rs232",
      "fuel_probe_can_bus",
      "temp",
      "acceleration"
    ],
    description:
      "Traceur GPS 4G robuste IP67 pour environnements difficiles et véhicules lourds.",
    can_bus: true,
    nb_digital_inputs: 3,
    nb_analog_inputs: 1,
    nb_outputs: 2,
    ip_rating: "IP67",
    rs232: true,
    accelerometer: true,
    buffer_memory: 256,
    antennes_externes: true
  },
  %{
    nom: "Jimiiot JT700",
    reference: "JIM-JT700",
    types_vehicule_compatibles: ["car", "moto", "truck"],
    alimentations_compatibles: ["12V", "24V"],
    capteurs_supportes: ["buzzer", "geofence", "fuel_probe_rs232", "immobilizer"],
    description: "Traceur GPS 4G compact pour véhicules standards avec sortie coupe-circuit.",
    nb_digital_inputs: 2,
    nb_outputs: 1,
    ip_rating: "IP54",
    buffer_memory: 128
  },
  %{
    nom: "Eelink CDMA",
    reference: "EEL-CDMA",
    types_vehicule_compatibles: ["asset", "car", "moto"],
    alimentations_compatibles: ["12V", "24V", "battery"],
    capteurs_supportes: ["geofence", "acceleration"],
    description: "Traceur GPS 2G CDMA, modèle entrée de gamme pour usage polyvalent.",
    accelerometer: true,
    ultra_low_power: true,
    ip_rating: "IP54"
  },
  %{
    nom: "Eelink LTE Cat 1",
    reference: "EEL-LTE",
    types_vehicule_compatibles: ["car", "moto", "truck", "bus", "boat"],
    alimentations_compatibles: ["12V", "24V", "9-36V"],
    capteurs_supportes: [
      "buzzer",
      "geofence",
      "fuel_probe_rs232",
      "fuel_probe_analog",
      "immobilizer"
    ],
    description:
      "Traceur GPS 4G LTE Cat 1 avec batterie de secours, large compatibilité véhicules.",
    nb_digital_inputs: 2,
    nb_analog_inputs: 1,
    nb_outputs: 1,
    ip_rating: "IP54",
    buffer_memory: 128
  },
  %{
    nom: "Trackimo TRK002",
    reference: "TRK-TRK002",
    types_vehicule_compatibles: ["asset", "person", "padlock"],
    alimentations_compatibles: ["battery"],
    capteurs_supportes: ["geofence", "sos", "acceleration", "gyro"],
    description:
      "Traceur GPS mondial portable à batterie, idéal pour bagages, animaux et personnes.",
    accelerometer: true,
    ultra_low_power: true,
    ip_rating: "IP65",
    buffer_memory: 64
  },
  %{
    nom: "Bofan M95",
    reference: "BOF-M95",
    types_vehicule_compatibles: ["car", "moto", "truck"],
    alimentations_compatibles: ["12V", "24V"],
    capteurs_supportes: ["buzzer", "geofence", "immobilizer", "sos"],
    description: "Traceur GPS 2G économique avec sortie de relais pour coupe-circuit.",
    nb_digital_inputs: 1,
    nb_outputs: 1,
    ip_rating: "IP54"
  },
  %{
    nom: "SpyTec STI_GL300",
    reference: "SPY-GL300",
    types_vehicule_compatibles: ["car", "asset", "person"],
    alimentations_compatibles: ["battery"],
    capteurs_supportes: ["geofence", "sos", "acceleration"],
    description: "Mini traceur GPS magnétique à batterie rechargeable pour véhicules et objets.",
    accelerometer: true,
    ultra_low_power: true,
    ip_rating: "IP65"
  }
]

IO.puts("Insertion des modèles...")

Enum.each(modeles, fn attrs ->
  try do
    ModeleTraceur.create!(attrs, action: :create)
  rescue
    _ -> :ok
  end
end)

# 4. Import CSV
to_nil = fn
  "" -> nil
  val -> String.trim(val)
end

# --- Types ---
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

# =========================================================
# 5. Port Types (Data Initialization & Reference Guide)
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
# 6. Features (Data Initialization & Reference Guide)
# =========================================================
IO.puts("Insertion des fonctionnalités...")

features = [
  %{
    slug: "real_time_tracking",
    label: "Real-time Tracking",
    description: "Suivi de position en temps réel par intervalle"
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
  }
]

feature_ids =
  Enum.map(features, fn attrs ->
    {:ok, feat} = Feature.create(attrs, action: :create)
    {feat.slug, feat.id}
  end)
  |> Map.new()

# =========================================================
# 7. Nouveaux modèles de traceurs (données du chef de projet)
# =========================================================
IO.puts("Insertion des modèles du guide de référence...")

# Helper for alimentations
new_alims = Alimentation.read!()
alim_by_slug = Map.new(new_alims, &{&1.slug, &1.id})

new_tracker_models = [
  %{
    nom: "FMC120 (FMx120)",
    brand: "Teltonika",
    reference: "TLT-FMC120",
    description: "Traceur GPS 4G avec accéléromètre, Bluetooth BLE, 1-Wire.",
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
    feature_slugs:
      ~w(real_time_tracking eco_driving crash_detection geofencing fuel_monitoring driver_id cold_chain engine_immobilization),
    alimentation_slugs: []
  },
  %{
    nom: "FMC130 (FMx130)",
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
    feature_slugs:
      ~w(real_time_tracking eco_driving crash_detection geofencing fuel_monitoring driver_id cold_chain engine_immobilization),
    alimentation_slugs: []
  },
  %{
    nom: "FMC640 (FMx640)",
    brand: "Teltonika",
    reference: "TLT-FMC640",
    description: "Traceur GPS 4G robuste avec CAN, RS232, RS485, K-Line.",
    nb_digital_inputs: 4,
    nb_analog_inputs: 4,
    nb_outputs: 4,
    can_bus: true,
    one_wire: true,
    rs232: true,
    rs485: true,
    accelerometer: true,
    buffer_memory: 512,
    ip_rating: "IP65",
    feature_slugs:
      ~w(real_time_tracking eco_driving crash_detection geofencing fuel_monitoring driver_id cold_chain tacho_download engine_immobilization),
    alimentation_slugs: []
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
    feature_slugs:
      ~w(real_time_tracking geofencing fuel_monitoring driver_id cold_chain engine_immobilization),
    alimentation_slugs: []
  },
  %{
    nom: "CAREU A1",
    brand: "Systech",
    reference: "SYS-CAREU-A1",
    description:
      "Traceur GPS économique avec entrée analogique jauge carburant et coupure moteur.",
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
    feature_slugs: ~w(real_time_tracking geofencing fuel_monitoring engine_immobilization),
    alimentation_slugs: []
  },
  %{
    nom: "VT200",
    brand: "Wondeproud",
    reference: "WON-VT200",
    description: "Traceur GPS basique avec entrée SOS et sortie coupure moteur.",
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
    feature_slugs: ~w(real_time_tracking geofencing engine_immobilization),
    alimentation_slugs: []
  }
]

new_model_ids =
  Enum.map(new_tracker_models, fn attrs ->
    feature_slugs = attrs[:feature_slugs]
    alim_slugs = attrs[:alimentation_slugs]
    attrs = Map.drop(attrs, [:feature_slugs, :alimentation_slugs])

    case ModeleTraceur.create(attrs, action: :create) do
      {:ok, modele} ->
        # Link features
        Enum.each(feature_slugs, fn slug ->
          if fid = feature_ids[slug] do
            ModelFeature.create(%{
              modele_traceur_id: modele.id,
              feature_id: fid
            })
          end
        end)

        # Link alimentations
        Enum.each(alim_slugs, fn slug ->
          if aid = alim_by_slug[slug] do
            ModeleTraceurAlimentation.create(%{
              modele_traceur_id: modele.id,
              alimentation_id: aid
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
# 8. Model Ports (Cartographie Physique des Broches)
# =========================================================
IO.puts("Insertion des ports physiques...")

# Lookup models by reference
all_modeles = ModeleTraceur.read!()
model_by_ref = Map.new(all_modeles, &{&1.reference, &1.id})

pin_defs = [
  # Teltonika FMC120
  {model_by_ref["TLT-FMC120"], port_type_ids["digital_input"], "DIN1 (Ignition)"},
  {model_by_ref["TLT-FMC120"], port_type_ids["digital_input"], "DIN2"},
  {model_by_ref["TLT-FMC120"], port_type_ids["analog_input"], "AIN1"},
  {model_by_ref["TLT-FMC120"], port_type_ids["digital_output"], "DOUT1 (Immobilizer)"},
  {model_by_ref["TLT-FMC120"], port_type_ids["digital_output"], "DOUT2"},
  {model_by_ref["TLT-FMC120"], port_type_ids["one_wire"], "1-Wire Data"},
  {model_by_ref["TLT-FMC120"], port_type_ids["bluetooth_ble"], "Bluetooth BLE Channel"},

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

  # Teltonika FMC640
  {model_by_ref["TLT-FMC640"], port_type_ids["digital_input"], "DIN1"},
  {model_by_ref["TLT-FMC640"], port_type_ids["digital_input"], "DIN2"},
  {model_by_ref["TLT-FMC640"], port_type_ids["digital_input"], "DIN3"},
  {model_by_ref["TLT-FMC640"], port_type_ids["digital_input"], "DIN4"},
  {model_by_ref["TLT-FMC640"], port_type_ids["analog_input"], "AIN1"},
  {model_by_ref["TLT-FMC640"], port_type_ids["analog_input"], "AIN2"},
  {model_by_ref["TLT-FMC640"], port_type_ids["analog_input"], "AIN3"},
  {model_by_ref["TLT-FMC640"], port_type_ids["analog_input"], "AIN4"},
  {model_by_ref["TLT-FMC640"], port_type_ids["digital_output"], "DOUT1"},
  {model_by_ref["TLT-FMC640"], port_type_ids["digital_output"], "DOUT2"},
  {model_by_ref["TLT-FMC640"], port_type_ids["digital_output"], "DOUT3"},
  {model_by_ref["TLT-FMC640"], port_type_ids["digital_output"], "DOUT4"},
  {model_by_ref["TLT-FMC640"], port_type_ids["one_wire"], "1-Wire Data"},
  {model_by_ref["TLT-FMC640"], port_type_ids["rs232"], "RS232 Port"},
  {model_by_ref["TLT-FMC640"], port_type_ids["rs485"], "RS485 Port"},
  {model_by_ref["TLT-FMC640"], port_type_ids["can_bus"], "CAN1 High/Low (FMS/J1939)"},
  {model_by_ref["TLT-FMC640"], port_type_ids["can_bus"], "CAN2 High/Low (J1708)"},
  {model_by_ref["TLT-FMC640"], port_type_ids["tachograph"], "K-Line (Tachograph)"},

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

  # Systech CAREU A1
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
# 9. Peripherals (Exemples de périphériques catalogués)
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
