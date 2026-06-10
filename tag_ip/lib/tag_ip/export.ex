defmodule TagIp.Export do
  @moduledoc false

  alias TagIp.Resources.ModeleTraceur
  alias TagIp.Resources.ProfilMontage

  @sep ";"

  def modeles_csv do
    modeles =
      Ash.read!(ModeleTraceur,
        load: [:types_vehicule, :alimentations, :capteurs, :features, :model_ports]
      )

    headers = [
      "Nom",
      "Marque",
      "Référence",
      "Description",
      "Tension min (V)",
      "Tension max (V)",
      "Consommation veille (mA)",
      "Ultra Low Power",
      "CAN-Bus",
      "1-Wire",
      "RS232",
      "RS485",
      "Bluetooth BLE",
      "Entrées numériques",
      "Entrées analogiques",
      "Sorties",
      "IP",
      "Antennes externes",
      "Accéléromètre",
      "Mémoire tampon (MB)",
      "Types de véhicules",
      "Alimentations",
      "Capteurs",
      "Fonctionnalités",
      "Ports physiques"
    ]

    rows = Enum.map(modeles, &modele_to_row/1)
    [Enum.join(headers, @sep) | rows] |> Enum.join("\n")
  end

  def profils_csv do
    profils =
      Ash.read!(ProfilMontage, load: [:capteurs])

    headers = [
      "Nom",
      "Description",
      "Type d'objet",
      "Intervalle de rapport",
      "Tension min (V)",
      "Tension max (V)",
      "CAN-Bus requis",
      "1-Wire requis",
      "RS232 requis",
      "RS485 requis",
      "Bluetooth BLE requis",
      "Entrées numériques req.",
      "Entrées analogiques req.",
      "Sorties req.",
      "Montage extérieur",
      "Antenne déportée",
      "Accéléromètre requis",
      "Ultra Low Power requis",
      "Buzzer",
      "Sonde carburant",
      "Geofence",
      "Identification conducteur",
      "Capteurs"
    ]

    rows = Enum.map(profils, &profil_to_row/1)
    [Enum.join(headers, @sep) | rows] |> Enum.join("\n")
  end

  defp modele_to_row(m) do
    [
      m.nom,
      m.brand,
      m.reference,
      m.description,
      m.voltage_min,
      m.voltage_max,
      m.standby_current,
      bool(m.ultra_low_power),
      bool(m.can_bus),
      bool(m.one_wire),
      bool(m.rs232),
      bool(m.rs485),
      bool(m.bluetooth_ble),
      m.nb_digital_inputs,
      m.nb_analog_inputs,
      m.nb_outputs,
      m.ip_rating,
      bool(m.antennes_externes),
      bool(m.accelerometer),
      m.buffer_memory,
      join_slugs(m.types_vehicule),
      join_slugs(m.alimentations),
      join_slugs(m.capteurs),
      join_slugs(m.features),
      join_labels(m.model_ports)
    ]
    |> Enum.map(&to_string/1)
    |> Enum.join(@sep)
  end

  defp profil_to_row(p) do
    [
      p.name,
      p.description,
      p.object_type,
      p.reporting_interval,
      p.voltage_min,
      p.voltage_max,
      bool(p.can_bus_requis),
      bool(p.one_wire_requis),
      bool(p.rs232_requis),
      bool(p.rs485_requis),
      bool(p.bluetooth_ble_requis),
      p.inputs_requis,
      p.analog_inputs_requis,
      p.outputs_requis,
      bool(p.montage_exterieur),
      bool(p.antenne_deportee),
      bool(p.accelerometre_requis),
      bool(p.ultra_low_power_requis),
      bool(p.buzzer),
      p.fuel_probe_type,
      bool(p.geofence_enabled),
      p.driver_id_type,
      join_slugs(p.capteurs)
    ]
    |> Enum.map(&to_string/1)
    |> Enum.join(@sep)
  end

  defp bool(nil), do: "Non"
  defp bool(false), do: "Non"
  defp bool(true), do: "Oui"
  defp bool(v) when is_binary(v), do: v

  defp join_slugs(nil), do: ""

  defp join_slugs(list) do
    list |> Enum.map(& &1.slug) |> Enum.join(", ")
  end

  defp join_labels(nil), do: ""

  defp join_labels(list) do
    list |> Enum.map(& &1.pin_label) |> Enum.join(", ")
  end
end
