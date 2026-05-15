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

  _ ->
    IO.puts("L'admin existe déjà.")
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

IO.puts("--- Terminé ! ---")
