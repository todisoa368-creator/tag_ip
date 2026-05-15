defmodule TagIp.Resources.Compatibilite do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  alias TagIp.Resources.ModeleTraceur
  alias TagIp.Resources.ProfilMontage

  postgres do
    table("compatibilites")
    repo(TagIp.Repo)
  end

  identities do
    identity(:unique_compatibilite, [:profil_montage_id, :modele_traceur_id])
  end

  attributes do
    uuid_primary_key(:id)

    attribute :score_compatibilite, :integer do
      allow_nil?(false)
      default(0)
    end

    attribute(:details, :string)

    timestamps()
  end

  relationships do
    belongs_to :profil_montage, TagIp.Resources.ProfilMontage do
      allow_nil?(false)
      attribute_type(:uuid)
    end

    belongs_to :modele_traceur, TagIp.Resources.ModeleTraceur do
      allow_nil?(false)
      attribute_type(:uuid)
    end
  end

  actions do
    defaults([:read, :update, :destroy])

    create :create do
      accept([:score_compatibilite, :details, :profil_montage_id, :modele_traceur_id])
    end

    read :get_by_id do
      argument(:id, :uuid, allow_nil?: false)
      get?(true)
      filter(expr(id == ^arg(:id)))
    end

    action :calculer_compatibilite do
      argument(:profil_id, :uuid, allow_nil?: false)
      argument(:modele_id, :uuid, allow_nil?: false)
      returns(:map)

      run(fn input, _ ->
        profil = Ash.get!(ProfilMontage, input.arguments.profil_id)

        modele =
          ModeleTraceur
          |> Ash.get!(input.arguments.modele_id)
          |> Ash.load!([:types_vehicule, :alimentations, :capteurs])

        {score, compatible, reasons} = calculer(profil, modele)
        details = Enum.join(reasons, "\n")

        attrs = %{
          profil_montage_id: input.arguments.profil_id,
          modele_traceur_id: input.arguments.modele_id,
          score_compatibilite: score,
          details: details
        }

        __MODULE__
        |> Ash.Changeset.for_create(:create, attrs,
          upsert?: true,
          upsert_identity: :unique_compatibilite
        )
        |> Ash.create!()

        {:ok, %{compatible: compatible, score: score, details: details}}
      end)
    end
  end

  def calculer(profil, modele) do
    checks = [
      &check_type_vehicule/2,
      &check_alimentation/2,
      &check_can_bus/2,
      &check_one_wire/2,
      &check_rs232/2,
      &check_rs485/2,
      &check_digital_inputs/2,
      &check_analog_inputs/2,
      &check_outputs/2,
      &check_ip_rating/2,
      &check_ultra_low_power/2,
      &check_accelerometer/2,
      &check_buffer_memory/2,
      &check_antennes_externes/2,
      &check_buzzer/2,
      &check_fuel_probe/2,
      &check_geofence/2
    ]

    results = Enum.map(checks, fn check -> check.(profil, modele) end)

    reasons =
      results |> Enum.map(&elem(&1, 1)) |> Enum.reject(&is_nil/1)

    score = results |> Enum.map(&elem(&1, 0)) |> Enum.sum()
    compatible = score >= 40

    {score, compatible, reasons}
  end

  def calculer_depuis_params(profil_params, modele) do
    profil_params = Map.new(profil_params, fn {k, v} -> {to_string(k), v} end)

    profil = %TagIp.Resources.ProfilMontage{
      object_type: profil_params["object_type"],
      voltage_min: parse_float(profil_params["voltage_min"]),
      voltage_max: parse_float(profil_params["voltage_max"]),
      buzzer: profil_params["buzzer"] in [true, "true"],
      fuel_probe_type: profil_params["fuel_probe_type"],
      geofence_enabled: profil_params["geofence_enabled"] in [true, "true"],
      can_bus_requis: profil_params["can_bus_requis"] in [true, "true"],
      one_wire_requis: profil_params["one_wire_requis"] in [true, "true"],
      rs232_requis: profil_params["rs232_requis"] in [true, "true"],
      rs485_requis: profil_params["rs485_requis"] in [true, "true"],
      inputs_requis: parse_int(profil_params["inputs_requis"]),
      analog_inputs_requis: parse_int(profil_params["analog_inputs_requis"]),
      outputs_requis: parse_int(profil_params["outputs_requis"]),
      ip_rating: profil_params["ip_rating"],
      montage_exterieur: profil_params["montage_exterieur"] in [true, "true"],
      antenne_deportee: profil_params["antenne_deportee"] in [true, "true"],
      accelerometre_requis: profil_params["accelerometre_requis"] in [true, "true"],
      buffer_requis: parse_int(profil_params["buffer_requis"]),
      ultra_low_power_requis: profil_params["ultra_low_power_requis"] in [true, "true"]
    }

    {score, compatible, reasons} = calculer(profil, modele)
    %{score: score, compatible: compatible, details: reasons}
  end

  defp parse_float(nil), do: nil
  defp parse_float(""), do: nil
  defp parse_float(val) when is_number(val), do: val * 1.0

  defp parse_float(val) when is_binary(val) do
    case Float.parse(val) do
      {f, _} -> f
      :error -> nil
    end
  end

  defp parse_int(nil), do: nil
  defp parse_int(""), do: nil
  defp parse_int(val) when is_integer(val), do: val
  defp parse_int(val) when is_binary(val), do: String.to_integer(val)

  # ---------------------------------------------------------------------------
  # 1. Type de véhicule (8 pts)
  # ---------------------------------------------------------------------------
  defp check_type_vehicule(profil, modele) do
    types_compatibles = Enum.map(modele.types_vehicule || [], & &1.slug)

    if is_nil(profil.object_type) or profil.object_type == "" do
      {8, nil}
    else
      if profil.object_type in types_compatibles do
        {8, "✓ Type de véhicule '#{profil.object_type}' compatible"}
      else
        types_str =
          if types_compatibles == [], do: "aucun", else: Enum.join(types_compatibles, ", ")

        {0, "✗ Type de véhicule '#{profil.object_type}' non supporté (disponibles: #{types_str})"}
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 2. Alimentation / Plage de Tension (10 pts)
  # ---------------------------------------------------------------------------
  defp check_alimentation(profil, modele) do
    alims = Enum.map(modele.alimentations || [], & &1.slug)

    if is_nil(profil.voltage_min) or is_nil(profil.voltage_max) do
      {10, nil}
    else
      ranges = parse_voltage_ranges(alims)

      if Enum.any?(ranges, fn {min, max} ->
           profil.voltage_min >= min and profil.voltage_max <= max
         end) do
        {10,
         "✓ Alimentation #{profil.voltage_min}-#{profil.voltage_max}V compatible (#{Enum.join(alims, ", ")})"}
      else
        {0,
         "✗ Alimentation #{profil.voltage_min}-#{profil.voltage_max}V non supportée (disponibles: #{Enum.join(alims, ", ")})"}
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 3. CAN-Bus (8 pts)
  # ---------------------------------------------------------------------------
  defp check_can_bus(profil, modele) do
    if profil.can_bus_requis do
      if modele.can_bus do
        {8, "✓ Interface CAN-Bus supportée"}
      else
        {0, "✗ Interface CAN-Bus non supportée par ce traceur"}
      end
    else
      {8, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 4. 1-Wire (5 pts)
  # ---------------------------------------------------------------------------
  defp check_one_wire(profil, modele) do
    if profil.one_wire_requis do
      if modele.one_wire do
        {5, "✓ Interface 1-Wire supportée"}
      else
        {0, "✗ Interface 1-Wire non supportée par ce traceur"}
      end
    else
      {5, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 5. RS232 (4 pts)
  # ---------------------------------------------------------------------------
  defp check_rs232(profil, modele) do
    if profil.rs232_requis do
      if modele.rs232 do
        {4, "✓ Interface RS232 supportée"}
      else
        {0, "✗ Interface RS232 non supportée par ce traceur"}
      end
    else
      {4, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 6. RS485 (4 pts)
  # ---------------------------------------------------------------------------
  defp check_rs485(profil, modele) do
    if profil.rs485_requis do
      if modele.rs485 do
        {4, "✓ Interface RS485 supportée"}
      else
        {0, "✗ Interface RS485 non supportée par ce traceur"}
      end
    else
      {4, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 7. Entrées Numériques — Digital Inputs (8 pts)
  # ---------------------------------------------------------------------------
  defp check_digital_inputs(profil, modele) do
    requis = profil.inputs_requis
    dispo = modele.nb_digital_inputs

    cond do
      is_nil(requis) or requis == 0 ->
        {8, nil}

      is_nil(dispo) ->
        {0, "✗ Nombre d'entrées numériques requis: #{requis}, mais le modèle ne les déclare pas"}

      dispo >= requis ->
        {8, "✓ Entrées numériques: #{dispo} disponibles (≥ #{requis} requis)"}

      true ->
        {0, "✗ Entrées numériques insuffisantes: #{dispo} disponibles, #{requis} requises"}
    end
  end

  # ---------------------------------------------------------------------------
  # 8. Entrées Analogiques (5 pts)
  # ---------------------------------------------------------------------------
  defp check_analog_inputs(profil, modele) do
    requis = profil.analog_inputs_requis
    dispo = modele.nb_analog_inputs

    cond do
      is_nil(requis) or requis == 0 ->
        {5, nil}

      is_nil(dispo) ->
        {0, "✗ Nombre d'entrées analogiques requis: #{requis}, mais le modèle ne les déclare pas"}

      dispo >= requis ->
        {5, "✓ Entrées analogiques: #{dispo} disponibles (≥ #{requis} requis)"}

      true ->
        {0, "✗ Entrées analogiques insuffisantes: #{dispo} disponibles, #{requis} requises"}
    end
  end

  # ---------------------------------------------------------------------------
  # 9. Sorties Numériques — Outputs (5 pts)
  # ---------------------------------------------------------------------------
  defp check_outputs(profil, modele) do
    requis = profil.outputs_requis
    dispo = modele.nb_outputs

    cond do
      is_nil(requis) or requis == 0 ->
        {5, nil}

      is_nil(dispo) ->
        {0, "✗ Nombre de sorties requis: #{requis}, mais le modèle ne les déclare pas"}

      dispo >= requis ->
        {5, "✓ Sorties: #{dispo} disponibles (≥ #{requis} requis)"}

      true ->
        {0, "✗ Sorties insuffisantes: #{dispo} disponibles, #{requis} requises"}
    end
  end

  # ---------------------------------------------------------------------------
  # 10. Indice de Protection IP (10 pts)
  # ---------------------------------------------------------------------------
  defp check_ip_rating(profil, modele) do
    cond do
      profil.montage_exterieur ->
        required_ip = profil.ip_rating || "IP67"

        if modele.ip_rating && ip_rating_ge?(modele.ip_rating, required_ip) do
          {10, "✓ Indice de protection #{modele.ip_rating} ≥ #{required_ip} (montage extérieur)"}
        else
          {0,
           "✗ Indice de protection insuffisant: #{modele.ip_rating || "non spécifié"} requis: #{required_ip} pour montage extérieur"}
        end

      not is_nil(profil.ip_rating) and profil.ip_rating != "" ->
        if modele.ip_rating && ip_rating_ge?(modele.ip_rating, profil.ip_rating) do
          {10, "✓ Indice de protection #{modele.ip_rating} ≥ #{profil.ip_rating} requis"}
        else
          {0,
           "✗ Indice de protection #{modele.ip_rating || "non spécifié"} < #{profil.ip_rating} requis"}
        end

      true ->
        {10, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 11. Ultra Low Power (5 pts)
  # ---------------------------------------------------------------------------
  defp check_ultra_low_power(profil, modele) do
    if profil.ultra_low_power_requis do
      if modele.ultra_low_power do
        {5, "✓ Mode Ultra-Low Power supporté (consommation réduite)"}
      else
        {0, "✗ Mode Ultra-Low Power non supporté par ce traceur"}
      end
    else
      {5, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 12. Accéléromètre 3 axes (5 pts)
  # ---------------------------------------------------------------------------
  defp check_accelerometer(profil, modele) do
    if profil.accelerometre_requis do
      if modele.accelerometer do
        {5, "✓ Accéléromètre 3 axes supporté"}
      else
        {0, "✗ Accéléromètre 3 axes non supporté par ce traceur"}
      end
    else
      {5, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 13. Mémoire tampon / Buffer (5 pts)
  # ---------------------------------------------------------------------------
  defp check_buffer_memory(profil, modele) do
    requis = profil.buffer_requis
    dispo = modele.buffer_memory

    cond do
      is_nil(requis) or requis == 0 ->
        {5, nil}

      is_nil(dispo) ->
        {0, "✗ Mémoire tampon requise: #{requis} MB, mais le modèle ne la déclare pas"}

      dispo >= requis ->
        {5, "✓ Mémoire tampon: #{dispo} MB (≥ #{requis} MB requis)"}

      true ->
        {0, "✗ Mémoire tampon insuffisante: #{dispo} MB disponibles, #{requis} MB requis"}
    end
  end

  # ---------------------------------------------------------------------------
  # 14. Antennes externes / déportées (4 pts)
  # ---------------------------------------------------------------------------
  defp check_antennes_externes(profil, modele) do
    if profil.antenne_deportee do
      if modele.antennes_externes do
        {4, "✓ Connecteurs pour antennes externes supportés"}
      else
        {0, "✗ Antennes externes non supportées par ce traceur"}
      end
    else
      {4, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 15. Buzzer (4 pts)
  # ---------------------------------------------------------------------------
  defp check_buzzer(profil, modele) do
    capteurs = Enum.map(modele.capteurs || [], & &1.slug)

    if profil.buzzer do
      if "buzzer" in capteurs do
        {4, "✓ Buzzer supporté"}
      else
        {0, "✗ Buzzer non supporté"}
      end
    else
      {4, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 16. Sonde carburant (5 pts)
  # ---------------------------------------------------------------------------
  defp check_fuel_probe(profil, modele) do
    capteurs = Enum.map(modele.capteurs || [], & &1.slug)

    if is_nil(profil.fuel_probe_type) or profil.fuel_probe_type == "" or
         profil.fuel_probe_type == "none" do
      {5, nil}
    else
      probe_key = "fuel_probe_#{profil.fuel_probe_type}"

      if probe_key in capteurs or profil.fuel_probe_type in capteurs do
        {5, "✓ Sonde carburant '#{profil.fuel_probe_type}' supportée"}
      else
        {0,
         "✗ Sonde carburant '#{profil.fuel_probe_type}' non supportée (capteurs: #{Enum.join(capteurs, ", ")})"}
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 17. Geofence (5 pts)
  # ---------------------------------------------------------------------------
  defp check_geofence(profil, modele) do
    capteurs = Enum.map(modele.capteurs || [], & &1.slug)

    if profil.geofence_enabled do
      if "geofence" in capteurs do
        {5, "✓ Géofencing supporté"}
      else
        {0, "✗ Géofencing non supporté"}
      end
    else
      {5, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  # Compare deux indices IP. ex: ip_rating_ge?("IP67", "IP65") => true
  defp ip_rating_ge?(a, b) do
    level_a = parse_ip_level(a)
    level_b = parse_ip_level(b)
    level_a >= level_b
  end

  defp parse_ip_level(ip) do
    ip = String.upcase(ip)
    digits = String.replace(ip, ~r/[^0-9]/, "")

    case Integer.parse(digits) do
      {n, _} -> n
      :error -> 0
    end
  end

  # Parse les chaînes d'alimentation en plages de tension
  # Ex: "12V" -> {9, 16}, "24V" -> {18, 32}, "12/24V" -> [{9,16}, {18,32}]
  # "9-36V" -> {9, 36}
  defp parse_voltage_ranges(alimentations) do
    alimentations
    |> Enum.flat_map(fn str ->
      str = String.upcase(str)

      cond do
        String.contains?(str, "/") ->
          str |> String.split("/") |> Enum.map(&parse_single_alim/1)

        String.contains?(str, "-") ->
          [parse_range_alim(str)]

        true ->
          [parse_single_alim(str)]
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp parse_single_alim(str) do
    volts = str |> String.replace(~r/[^0-9]/, "") |> String.to_integer()

    case volts do
      12 -> {9.0, 16.0}
      24 -> {18.0, 32.0}
      n -> {n * 0.75, n * 1.25}
    end
  rescue
    _ -> nil
  end

  defp parse_range_alim(str) do
    [min_str, max_str] = String.split(str, "-")
    min = min_str |> String.replace(~r/[^0-9.]/, "") |> String.to_float()
    max_val = max_str |> String.replace(~r/[^0-9.]/, "") |> String.to_float()
    {min, max_val}
  rescue
    _ ->
      try do
        [min_str, max_str] = String.split(str, "-")
        min = min_str |> String.replace(~r/[^0-9]/, "") |> String.to_integer()
        max_val = max_str |> String.replace(~r/[^0-9]/, "") |> String.to_integer()
        {min * 1.0, max_val * 1.0}
      rescue
        _ -> nil
      end
  end
end
