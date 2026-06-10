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

    action :clear_all, :integer do
      run(fn _input, _context ->
        {count, _} = TagIp.Repo.delete_all(TagIp.Resources.Compatibilite)
        {:ok, count}
      end)
    end

    action :calculer_compatibilite do
      argument(:profil_id, :uuid, allow_nil?: false)
      argument(:modele_id, :uuid, allow_nil?: false)
      returns(:map)

      run(fn input, _ ->
        profil =
          ProfilMontage
          |> Ash.get!(input.arguments.profil_id)
          |> Ash.load!([:peripherals])

        modele =
          ModeleTraceur
          |> Ash.get!(input.arguments.modele_id)
          |> Ash.load!([:types_vehicule, :alimentations, :capteurs, :model_ports])

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

  def calculer(profil, modele, capteur_slugs \\ nil, peripheral_ids \\ []) do
    captured_capteur_slugs =
      if capteur_slugs in [nil, []] do
        if is_list(profil.capteurs), do: Enum.map(profil.capteurs, & &1.slug), else: []
      else
        capteur_slugs
      end

    captured_peripheral_ids =
      if peripheral_ids in [nil, []] do
        if is_list(profil.peripherals), do: Enum.map(profil.peripherals, & &1.id), else: []
      else
        peripheral_ids
      end

    checks = [
      &check_type_vehicule/2,
      &check_alimentation/2,
      &check_can_bus/2,
      &check_one_wire/2,
      &check_rs232/2,
      &check_rs485/2,
      &check_bluetooth_ble/2,
      &check_digital_inputs/2,
      &check_analog_inputs/2,
      &check_outputs/2,
      &check_ip_rating/2,
      &check_ultra_low_power/2,
      &check_accelerometer/2,
      &check_buffer_memory/2,
      &check_antennes_externes/2,
      &check_buzzer/3,
      &check_geofence/3,
      &check_fuel_probe/3,
      &check_capteurs/3,
      &check_peripheral_ports/3
    ]

    results =
      Enum.map(checks, fn check ->
        case check do
          f when is_function(f, 2) -> f.(profil, modele)
          f when is_function(f, 3) -> f.(profil, modele, captured_capteur_slugs)
        end
      end)

    reasons =
      results |> Enum.map(&elem(&1, 1)) |> Enum.reject(&is_nil/1)

    earned = results |> Enum.map(&elem(&1, 0)) |> Enum.sum()
    max_possible = calculate_max_possible(profil, captured_capteur_slugs, captured_peripheral_ids)

    score = if max_possible > 0, do: min(100, round(earned / max_possible * 100)), else: 0

    type_supported? =
      is_nil(profil.object_type) or profil.object_type == "" or
        profil.object_type in Enum.map(modele.types_vehicule || [], & &1.slug)

    compatible = type_supported? and score >= 40

    {score, compatible, reasons}
  end

  def calculer_depuis_params(profil_params, modele, capteur_slugs \\ [], peripheral_ids \\ []) do
    profil_params = Map.new(profil_params, fn {k, v} -> {to_string(k), v} end)

    capteur_slugs = Enum.map(capteur_slugs || [], &to_string(&1))
    peripheral_ids = peripheral_ids || []

    profil = %TagIp.Resources.ProfilMontage{
      object_type: profil_params["object_type"],
      voltage_min: parse_float(profil_params["voltage_min"]),
      voltage_max: parse_float(profil_params["voltage_max"]),
      can_bus_requis: profil_params["can_bus_requis"] in [true, "true"],
      one_wire_requis: profil_params["one_wire_requis"] in [true, "true"],
      rs232_requis: profil_params["rs232_requis"] in [true, "true"],
      rs485_requis: profil_params["rs485_requis"] in [true, "true"],
      bluetooth_ble_requis: profil_params["bluetooth_ble_requis"] in [true, "true"],
      inputs_requis: parse_int(profil_params["inputs_requis"]),
      analog_inputs_requis: parse_int(profil_params["analog_inputs_requis"]),
      outputs_requis: parse_int(profil_params["outputs_requis"]),
      buzzer: profil_params["buzzer"] in [true, "true"],
      geofence_enabled: profil_params["geofence_enabled"] in [true, "true"],
      fuel_probe_type: profil_params["fuel_probe_type"],
      montage_exterieur: profil_params["montage_exterieur"] in [true, "true"],
      antenne_deportee: profil_params["antenne_deportee"] in [true, "true"],
      accelerometre_requis: profil_params["accelerometre_requis"] in [true, "true"],
      ultra_low_power_requis: profil_params["ultra_low_power_requis"] in [true, "true"]
    }

    {score, compatible, reasons} = calculer(profil, modele, capteur_slugs, peripheral_ids)
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
  # Points maximum possibles
  # ---------------------------------------------------------------------------
  defp calculate_max_possible(profil, capteur_slugs, peripheral_ids) do
    criteria = [
      if(profil.object_type not in [nil, ""], do: 8, else: 0),
      if(profil.voltage_min not in [nil, ""] and profil.voltage_max not in [nil, ""],
        do: 10,
        else: 0
      ),
      if(profil.can_bus_requis, do: 8, else: 0),
      if(profil.one_wire_requis, do: 5, else: 0),
      if(profil.rs232_requis, do: 4, else: 0),
      if(profil.rs485_requis, do: 4, else: 0),
      if(profil.bluetooth_ble_requis, do: 4, else: 0),
      if(profil.inputs_requis not in [nil, 0], do: 8, else: 0),
      if(profil.analog_inputs_requis not in [nil, 0], do: 5, else: 0),
      if(profil.outputs_requis not in [nil, 0], do: 5, else: 0),
      if(profil.montage_exterieur, do: 10, else: 0),
      if(profil.ultra_low_power_requis, do: 5, else: 0),
      if(profil.accelerometre_requis, do: 5, else: 0),
      if(profil.antenne_deportee, do: 4, else: 0),
      if(profil.buzzer, do: 4, else: 0),
      if(profil.geofence_enabled, do: 5, else: 0),
      if(profil.fuel_probe_type not in [nil, "", "none"], do: 5, else: 0),
      if(capteur_slugs not in [nil, []], do: 5, else: 0),
      if(peripheral_ids not in [nil, []], do: 5, else: 0)
    ]

    active_criteria? = Enum.any?(criteria, &(&1 > 0))

    if active_criteria? do
      Enum.sum(criteria) + 5
    else
      0
    end
  end

  # ---------------------------------------------------------------------------
  # 1. Type de véhicule (8 pts)
  # ---------------------------------------------------------------------------
  defp check_type_vehicule(profil, modele) do
    types_compatibles = Enum.map(modele.types_vehicule || [], & &1.slug)

    if is_nil(profil.object_type) or profil.object_type == "" do
      {0, nil}
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
    if is_nil(profil.voltage_min) or is_nil(profil.voltage_max) do
      {0, nil}
    else
      direct_match? =
        !is_nil(modele.voltage_min) && !is_nil(modele.voltage_max) &&
          profil.voltage_min >= modele.voltage_min &&
          profil.voltage_max <= modele.voltage_max

      alims = Enum.map(modele.alimentations || [], & &1.slug)
      ranges = parse_voltage_ranges(alims)

      slug_match? =
        Enum.any?(ranges, fn {min, max} ->
          profil.voltage_min >= min and profil.voltage_max <= max
        end)

      dispo_str =
        cond do
          modele.voltage_min && modele.voltage_max ->
            "plage #{modele.voltage_min}V-#{modele.voltage_max}V"

          alims != [] ->
            Enum.join(alims, ", ")

          true ->
            "aucune"
        end

      if direct_match? or slug_match? do
        {10,
         "✓ Alimentation #{profil.voltage_min}V-#{profil.voltage_max}V compatible (#{dispo_str})"}
      else
        {0,
         "✗ Alimentation #{profil.voltage_min}V-#{profil.voltage_max}V non supportée (disponibles: #{dispo_str})"}
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
      {0, nil}
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
      {0, nil}
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
      {0, nil}
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
      {0, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 7. Bluetooth BLE (4 pts)
  # ---------------------------------------------------------------------------
  defp check_bluetooth_ble(profil, modele) do
    if profil.bluetooth_ble_requis do
      if modele.bluetooth_ble do
        {4, "✓ Bluetooth BLE supporté"}
      else
        {0, "✗ Bluetooth BLE non supporté par ce traceur"}
      end
    else
      {0, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 8. Entrées Numériques — Digital Inputs (8 pts)
  # ---------------------------------------------------------------------------
  defp check_digital_inputs(profil, modele) do
    requis = profil.inputs_requis
    dispo = modele.nb_digital_inputs

    cond do
      is_nil(requis) or requis == 0 ->
        {0, nil}

      is_nil(dispo) ->
        {0, "✗ Nombre d'entrées numériques requis: #{requis}, mais le modèle ne les déclare pas"}

      dispo >= requis ->
        {8, "✓ Entrées numériques: #{dispo} disponibles (≥ #{requis} requis)"}

      true ->
        {0, "✗ Entrées numériques insuffisantes: #{dispo} disponibles, #{requis} requises"}
    end
  end

  # ---------------------------------------------------------------------------
  # 9. Entrées Analogiques (5 pts)
  # ---------------------------------------------------------------------------
  defp check_analog_inputs(profil, modele) do
    requis = profil.analog_inputs_requis
    dispo = modele.nb_analog_inputs

    cond do
      is_nil(requis) or requis == 0 ->
        {0, nil}

      is_nil(dispo) ->
        {0, "✗ Nombre d'entrées analogiques requis: #{requis}, mais le modèle ne les déclare pas"}

      dispo >= requis ->
        {5, "✓ Entrées analogiques: #{dispo} disponibles (≥ #{requis} requis)"}

      true ->
        {0, "✗ Entrées analogiques insuffisantes: #{dispo} disponibles, #{requis} requises"}
    end
  end

  # ---------------------------------------------------------------------------
  # 10. Sorties Numériques — Outputs (5 pts)
  # ---------------------------------------------------------------------------
  defp check_outputs(profil, modele) do
    requis = profil.outputs_requis
    dispo = modele.nb_outputs

    cond do
      is_nil(requis) or requis == 0 ->
        {0, nil}

      is_nil(dispo) ->
        {0, "✗ Nombre de sorties requis: #{requis}, mais le modèle ne les déclare pas"}

      dispo >= requis ->
        {5, "✓ Sorties: #{dispo} disponibles (≥ #{requis} requis)"}

      true ->
        {0, "✗ Sorties insuffisantes: #{dispo} disponibles, #{requis} requises"}
    end
  end

  # ---------------------------------------------------------------------------
  # 11. Indice de Protection IP (10 pts)
  # ---------------------------------------------------------------------------
  defp check_ip_rating(profil, modele) do
    if profil.montage_exterieur do
      if modele.ip_rating && ip_rating_ge?(modele.ip_rating, "IP67") do
        {10, "✓ Indice de protection #{modele.ip_rating} ≥ IP67 (montage extérieur)"}
      else
        {0,
         "✗ Indice de protection insuffisant: #{modele.ip_rating || "non spécifié"} requis: IP67 pour montage extérieur"}
      end
    else
      {0, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 12. Ultra Low Power (5 pts)
  # ---------------------------------------------------------------------------
  defp check_ultra_low_power(profil, modele) do
    if profil.ultra_low_power_requis do
      if modele.ultra_low_power do
        {5, "✓ Mode Ultra-Low Power supporté (consommation réduite)"}
      else
        {0, "✗ Mode Ultra-Low Power non supporté par ce traceur"}
      end
    else
      {0, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 13. Accéléromètre 3 axes (5 pts)
  # ---------------------------------------------------------------------------
  defp check_accelerometer(profil, modele) do
    if profil.accelerometre_requis do
      if modele.accelerometer do
        {5, "✓ Accéléromètre 3 axes supporté"}
      else
        {0, "✗ Accéléromètre 3 axes non supporté par ce traceur"}
      end
    else
      {0, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 14. Mémoire tampon / Buffer (5 pts)
  # ---------------------------------------------------------------------------
  defp check_buffer_memory(profil, _modele) do
    has_active_criteria? =
      profil.object_type not in [nil, ""] or
        (not is_nil(profil.voltage_min) and not is_nil(profil.voltage_max)) or
        profil.can_bus_requis or
        profil.one_wire_requis or
        profil.rs232_requis or
        profil.rs485_requis or
        profil.bluetooth_ble_requis or
        profil.inputs_requis not in [nil, 0] or
        profil.analog_inputs_requis not in [nil, 0] or
        profil.outputs_requis not in [nil, 0] or
        profil.montage_exterieur or
        profil.ultra_low_power_requis or
        profil.accelerometre_requis or
        profil.antenne_deportee or
        profil.buzzer or
        profil.geofence_enabled or
        profil.fuel_probe_type not in [nil, "", "none"]

    if has_active_criteria?, do: {5, nil}, else: {0, nil}
  end

  # ---------------------------------------------------------------------------
  # 15. Antennes externes / déportées (4 pts)
  # ---------------------------------------------------------------------------
  defp check_antennes_externes(profil, modele) do
    if profil.antenne_deportee do
      if modele.antennes_externes do
        {4, "✓ Connecteurs pour antennes externes supportés"}
      else
        {0, "✗ Antennes externes non supportées par ce traceur"}
      end
    else
      {0, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 16. Buzzer (4 pts) — via capteurs
  # ---------------------------------------------------------------------------
  defp check_buzzer(profil, modele, _capteur_slugs) do
    if profil.buzzer do
      if "buzzer" in Enum.map(modele.capteurs || [], & &1.slug) do
        {4, "✓ Buzzer supporté"}
      else
        {0, "✗ Buzzer non supporté par ce traceur"}
      end
    else
      {0, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 17. Geofence (5 pts) — via capteurs
  # ---------------------------------------------------------------------------
  defp check_geofence(profil, modele, _capteur_slugs) do
    if profil.geofence_enabled do
      if "geofence" in Enum.map(modele.capteurs || [], & &1.slug) do
        {5, "✓ Géofencing supporté"}
      else
        {0, "✗ Géofencing non supporté par ce traceur"}
      end
    else
      {0, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 18. Sonde carburant (5 pts) — via capteurs
  # ---------------------------------------------------------------------------
  defp check_fuel_probe(profil, modele, _capteur_slugs) do
    fuel_slugs =
      ~w(fuel_level_monitor fuel_cap_monitor fuel_probe_analog fuel_probe_digital fuel_probe_can_bus)

    if profil.fuel_probe_type not in [nil, "", "none"] do
      model_capteurs = Enum.map(modele.capteurs || [], & &1.slug)
      supported = Enum.filter(fuel_slugs, &(&1 in model_capteurs))

      if supported != [] do
        {5, "✓ Sonde(s) carburant supportée(s): #{Enum.join(supported, ", ")}"}
      else
        {0, "✗ Sonde carburant (#{profil.fuel_probe_type}) non supportée par ce traceur"}
      end
    else
      {0, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # 19. Capteurs génériques (5 pts)
  # ---------------------------------------------------------------------------
  defp check_capteurs(_profil, modele, capteur_slugs)
       when is_list(capteur_slugs) and capteur_slugs != [] do
    modele_capteurs = Enum.map(modele.capteurs || [], & &1.slug)
    missing = Enum.reject(capteur_slugs, &(&1 in modele_capteurs))

    if missing == [] do
      {5, "✓ Capteurs requis supportés (#{Enum.join(capteur_slugs, ", ")})"}
    else
      {0, "✗ Capteurs manquants sur le traceur: #{Enum.join(missing, ", ")}"}
    end
  end

  defp check_capteurs(_profil, _modele, []), do: {0, nil}

  # ---------------------------------------------------------------------------
  # 20. Périphériques — ports requis (5 pts)
  # ---------------------------------------------------------------------------
  defp check_peripheral_ports(_profil, modele, peripheral_ids)
       when is_list(peripheral_ids) and peripheral_ids != [] do
    model_port_type_ids = Enum.map(modele.model_ports || [], & &1.port_type_id)

    peripherals = Ash.read!(TagIp.Resources.Peripheral)

    required_port_type_ids =
      peripherals
      |> Enum.filter(&(&1.id in peripheral_ids))
      |> Enum.map(& &1.port_type_id)

    missing = Enum.reject(required_port_type_ids, &(&1 in model_port_type_ids))

    if missing == [] do
      {5, "✓ Périphériques requis supportés (ports disponibles)"}
    else
      {0, "✗ Certains ports requis par les périphériques ne sont pas disponibles"}
    end
  end

  defp check_peripheral_ports(_profil, _modele, []), do: {0, nil}

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

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
