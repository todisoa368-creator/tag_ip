defmodule TagIpWeb.ProfilMontageLive.Form do
  use TagIpWeb, :live_view

  alias TagIp.Resources.ProfilMontage
  alias TagIp.Resources.ModeleTraceur
  alias TagIp.Resources.Capteur
  alias TagIp.Resources.Peripheral
  alias TagIp.Resources.CapabilityMatrix
  alias TagIp.Resources.ProfilMontageCapteur
  alias TagIp.Resources.ProfilMontagePeripheral
  alias TagIp.Resources.TypeVehicule
  alias TagIp.Resources.Organisation
  alias TagIp.Resources.Alimentation

  @fuel_probe_slugs ~w(fuel_analog fuel_rs232 fuel_ble fuel_can)

  @steps [
    %{
      num: 1,
      title: "Étape 1 : Identification",
      description: "Étape 1 — Nom du profil et type de véhicule"
    },
    %{
      num: 2,
      title: "Étape 2 : Fonctionnalités",
      description: "Étape 2 — Fonctionnalités et critères du client"
    },
    %{
      num: 3,
      title: "Étape 3 : Modèle traceur",
      description: "Étape 3 — Modèles compatibles suggérés"
    },
    %{
      num: 4,
      title: "Étape 4 : Validation",
      description: "Étape 4 — Récapitulatif et vérification"
    }
  ]

  @impl true
  def mount(params, _session, socket) do
    modeles =
      ModeleTraceur.read!()
      |> Enum.map(&Ash.load!(&1, [:types_vehicule]))

    matrix_features = CapabilityMatrix.matrix_features()
    types_vehicule = TypeVehicule.read!() |> Enum.sort_by(& &1.label)
    organisations = Organisation.read!() |> Enum.sort_by(& &1.name)
    alimentations = Alimentation.read!() |> Enum.sort_by(& &1.label)
    capteurs = Capteur.read!() |> Enum.sort_by(& &1.label)
    peripherals = Peripheral.read!() |> Enum.sort_by(& &1.name)

    step = parse_step(params)

    {:ok,
     socket
     |> assign(:step, step)
     |> assign(:total_steps, length(@steps))
     |> assign(:steps, @steps)
     |> assign(:modeles, modeles)
     |> assign(:matrix_features, matrix_features)
     |> assign(:types_vehicule, types_vehicule)
     |> assign(:organisations, organisations)
     |> assign(:alimentations, alimentations)
     |> assign(:capteurs, capteurs)
     |> assign(:peripherals, peripherals)
     |> assign(:selected_features, MapSet.new())
     |> assign(:selected_type_vehicule_id, nil)
     |> assign(:selected_type_vehicule, nil)
     |> assign(:selected_organisation_id, nil)
     |> assign(:show_new_org_modal, false)
     |> assign(
       :new_org_form,
       to_form(%{"name" => "", "slug" => "", "description" => ""}, as: :organisation)
     )
     |> assign(:selected_alimentation_id, nil)
     |> assign(:profile_name, "")
     |> assign(:profile_description, "")
     |> assign(:object_type, nil)
     |> assign(:voltage_min, nil)
     |> assign(:voltage_max, nil)
     |> assign(:inputs_requis, nil)
     |> assign(:outputs_requis, nil)
     |> assign(:can_bus_requis, false)
     |> assign(:one_wire_requis, false)
     |> assign(:rs232_requis, false)
     |> assign(:rs485_requis, false)
     |> assign(:bluetooth_ble_requis, false)
     |> assign(:analog_inputs_requis, 0)
     |> assign(:montage_exterieur, false)
     |> assign(:antenne_deportee, false)
     |> assign(:accelerometre_requis, false)
     |> assign(:ultra_low_power_requis, false)
     |> assign(:buzzer, false)
     |> assign(:geofence_enabled, false)
     |> assign(:fuel_probe_type, "")
     |> assign(:selected_capteur_ids, MapSet.new())
     |> assign(:selected_peripheral_ids, MapSet.new())
     |> assign(:compatible_models, [])
     |> assign(:selected_model_id, nil)
     |> assign(:selected_model, nil)
     |> assign(:validation_result, nil)
     |> assign(:profile_saved, false)}
  end

  @impl true
  def handle_params(params, url, socket) do
    path = URI.parse(url).path

    step = parse_step(params)

    prev_action = socket.assigns[:applied_action]
    prev_action_params = socket.assigns[:applied_action_params]
    current_action = socket.assigns.live_action
    current_action_params = extract_action_params(current_action, params)

    socket =
      if prev_action != current_action || prev_action_params != current_action_params do
        socket
        |> apply_action(current_action, params)
        |> assign(:applied_action, current_action)
        |> assign(:applied_action_params, current_action_params)
      else
        socket
      end

    {:noreply,
     socket
     |> assign(:current_path, path)
     |> assign(:step, step)}
  end

  defp extract_action_params(:new, %{"duplicate_from" => id}), do: {:new, id}
  defp extract_action_params(:new, _params), do: {:new, nil}
  defp extract_action_params(:edit, %{"id" => id}), do: {:edit, id}
  defp extract_action_params(action, _params), do: {action, nil}

  # ---------------------------------------------------------------------------
  # Basic field updates
  # ---------------------------------------------------------------------------
  @impl true
  def handle_event("update_name", %{"profile_name" => name}, socket) do
    {:noreply, assign(socket, :profile_name, name || "")}
  end

  def handle_event("update_description", %{"profile_description" => desc}, socket) do
    {:noreply, assign(socket, :profile_description, desc || "")}
  end

  def handle_event("select_organisation", %{"organisation_id" => org_id}, socket) do
    org_id = if org_id not in [nil, "", "0"], do: org_id, else: nil
    {:noreply, assign(socket, :selected_organisation_id, org_id)}
  end

  def handle_event("open_new_org_modal", _, socket) do
    {:noreply,
     assign(socket,
       show_new_org_modal: true,
       new_org_form:
         to_form(%{"name" => "", "slug" => "", "description" => ""}, as: :organisation)
     )}
  end

  def handle_event("close_new_org_modal", _, socket) do
    {:noreply, assign(socket, :show_new_org_modal, false)}
  end

  def handle_event("save_new_org", %{"organisation" => org_params}, socket) do
    name = org_params["name"]
    slug = org_params["slug"]
    description = org_params["description"]

    if name == "" || slug == "" do
      {:noreply, put_flash(socket, :error, "Le nom et le slug sont requis.")}
    else
      case Organisation.create(%{name: name, slug: slug, description: description}) do
        {:ok, org} ->
          organisations = Organisation.read!() |> Enum.sort_by(& &1.name)

          {:noreply,
           socket
           |> assign(:organisations, organisations)
           |> assign(:selected_organisation_id, org.id)
           |> assign(:show_new_org_modal, false)
           |> put_flash(:info, "Organisation « #{org.name} » ajoutée.")}

        {:error, reason} ->
          {:noreply, put_flash(socket, :error, "Erreur : #{inspect(reason)}")}
      end
    end
  end

  def handle_event("select_type_vehicule", %{"type_vehicule_id" => tv_id}, socket) do
    tv =
      if tv_id not in [nil, ""] do
        Enum.find(socket.assigns.types_vehicule, &(&1.id == tv_id))
      end

    {:noreply,
     socket
     |> assign(:selected_type_vehicule_id, tv && tv.id)
     |> assign(:selected_type_vehicule, tv)
     |> assign(:object_type, tv && tv.slug)
     |> assign(:voltage_min, tv && tv.voltage_min)
     |> assign(:voltage_max, tv && tv.voltage_max)
     |> assign(:inputs_requis, tv && tv.inputs_requis)
     |> assign(:outputs_requis, tv && tv.outputs_requis)
     |> assign(:selected_features, MapSet.new())
     |> assign(:validation_result, nil)
     |> assign(:compatible_models, [])
     |> assign(:selected_model_id, nil)
     |> assign(:selected_model, nil)}
  end

  def handle_event("select_alimentation", %{"alimentation_id" => alim_id}, socket) do
    alim_id = if alim_id not in [nil, "", "0"], do: alim_id, else: nil
    alim = alim_id && Enum.find(socket.assigns.alimentations, &(&1.id == alim_id))

    {voltage_min, voltage_max} =
      if alim && alim.category == "voltage" do
        parse_alim_voltage(alim.slug)
      else
        {socket.assigns.voltage_min, socket.assigns.voltage_max}
      end

    {:noreply,
     socket
     |> assign(:selected_alimentation_id, alim_id)
     |> assign(:voltage_min, voltage_min)
     |> assign(:voltage_max, voltage_max)}
  end

  # ---------------------------------------------------------------------------
  # Step 2 — Feature & criteria toggles
  # ---------------------------------------------------------------------------
  def handle_event("toggle_feature", %{"slug" => slug}, socket) do
    current = socket.assigns.selected_features

    updated =
      if MapSet.member?(current, slug) do
        MapSet.delete(current, slug)
      else
        if slug in @fuel_probe_slugs do
          Enum.reduce(@fuel_probe_slugs, current, fn s, acc -> MapSet.delete(acc, s) end)
          |> MapSet.put(slug)
        else
          MapSet.put(current, slug)
        end
      end

    {:noreply, assign(socket, :selected_features, updated)}
  end

  def handle_event("toggle_criteria", %{"field" => field}, socket) do
    current = Map.get(socket.assigns, String.to_existing_atom(field))
    {:noreply, assign(socket, String.to_existing_atom(field), !current)}
  end

  def handle_event("update_criteria_int", %{"field" => field, "value" => value}, socket) do
    int_val =
      case Integer.parse(value) do
        {n, _} -> n
        :error -> 0
      end

    {:noreply, assign(socket, String.to_existing_atom(field), int_val)}
  end

  def handle_event("select_fuel_probe", %{"fuel_probe_type" => type}, socket) do
    fuel_slugs = %{
      "analog" => "fuel_analog",
      "rs232" => "fuel_rs232",
      "ble" => "fuel_ble",
      "can" => "fuel_can"
    }

    selected_features =
      if type in ["", "none"] do
        Enum.reduce(@fuel_probe_slugs, socket.assigns.selected_features, fn s, acc ->
          MapSet.delete(acc, s)
        end)
      else
        slug = Map.get(fuel_slugs, type)

        if slug do
          Enum.reduce(@fuel_probe_slugs, socket.assigns.selected_features, fn s, acc ->
            MapSet.delete(acc, s)
          end)
          |> MapSet.put(slug)
        else
          socket.assigns.selected_features
        end
      end

    {:noreply,
     socket
     |> assign(:fuel_probe_type, type)
     |> assign(:selected_features, selected_features)}
  end

  def handle_event("toggle_capteur", %{"id" => id}, socket) do
    selected = socket.assigns.selected_capteur_ids

    updated =
      if MapSet.member?(selected, id) do
        MapSet.delete(selected, id)
      else
        MapSet.put(selected, id)
      end

    {:noreply, assign(socket, :selected_capteur_ids, updated)}
  end

  def handle_event("toggle_peripheral", %{"id" => id}, socket) do
    selected = socket.assigns.selected_peripheral_ids

    updated =
      if MapSet.member?(selected, id) do
        MapSet.delete(selected, id)
      else
        MapSet.put(selected, id)
      end

    {:noreply, assign(socket, :selected_peripheral_ids, updated)}
  end

  # ---------------------------------------------------------------------------
  # Step 3 — Model selection from compatible results
  # ---------------------------------------------------------------------------
  def handle_event("select_model", %{"model_id" => model_id}, socket) do
    modele =
      socket.assigns.modeles
      |> Enum.find(&(&1.id == model_id))

    modele = modele && Ash.load!(modele, [:features, :capteurs])

    {:noreply,
     socket
     |> assign(:selected_model_id, model_id)
     |> assign(:selected_model, modele)
     |> assign(:validation_result, nil)}
  end

  # ---------------------------------------------------------------------------
  # Navigation
  # ---------------------------------------------------------------------------
  def handle_event("next-step", params, socket) do
    step = socket.assigns.step
    total = socket.assigns.total_steps

    socket = sync_form_data(socket, params)

    {socket, can_advance} = validate_step(socket, step)

    socket =
      if can_advance && step == 2 do
        compute_compatible_models(socket)
      else
        socket
      end

    socket =
      if can_advance && step + 1 == 4 do
        run_final_validation(socket)
      else
        socket
      end

    if can_advance && step < total do
      {:noreply, push_patch(socket, step_path(socket, step + 1))}
    else
      {:noreply, socket}
    end
  end

  def handle_event("prev-step", _params, socket) do
    step = socket.assigns.step

    if step > 1 do
      {:noreply, push_patch(socket, step_path(socket, step - 1))}
    else
      {:noreply, socket}
    end
  end

  # ---------------------------------------------------------------------------
  # Save
  # ---------------------------------------------------------------------------
  def handle_event("save", _params, socket) do
    features = MapSet.to_list(socket.assigns.selected_features)
    name = socket.assigns.profile_name
    description = socket.assigns.profile_description
    modele_id = socket.assigns.selected_model_id
    type_vehicule_id = socket.assigns.selected_type_vehicule_id
    object_type = socket.assigns.object_type
    voltage_min = socket.assigns.voltage_min
    voltage_max = socket.assigns.voltage_max
    inputs_requis = socket.assigns.inputs_requis
    outputs_requis = socket.assigns.outputs_requis
    organisation_id = socket.assigns.selected_organisation_id
    alimentation_id = socket.assigns.selected_alimentation_id

    profile_params =
      build_profile_params(
        name,
        description,
        features,
        modele_id,
        type_vehicule_id,
        object_type,
        voltage_min,
        voltage_max,
        inputs_requis,
        outputs_requis,
        organisation_id,
        alimentation_id,
        socket
      )

    result =
      case socket.assigns.profil do
        nil ->
          case ProfilMontage.create(profile_params, action: :create) do
            {:ok, profil} ->
              capteur_ids = resolve_required_capteur_ids(features)
              sync_capteurs(profil.id, capteur_ids)
              sync_peripherals(profil.id, MapSet.to_list(socket.assigns.selected_peripheral_ids))
              {:ok, profil, "créé"}

            {:error, reason} ->
              {:error, reason}
          end

        profil ->
          case ProfilMontage.update(profil, profile_params, action: :update) do
            {:ok, profil} ->
              capteur_ids = resolve_required_capteur_ids(features)
              sync_capteurs(profil.id, capteur_ids)
              sync_peripherals(profil.id, MapSet.to_list(socket.assigns.selected_peripheral_ids))
              {:ok, profil, "modifié"}

            {:error, reason} ->
              {:error, reason}
          end
      end

    case result do
      {:ok, profil, action} ->
        label = if action == "créé", do: "créé", else: "modifié"

        TagIp.Notification.broadcast(
          {:notification, :info, "Profil de montage #{label} avec succès !"}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Profil de montage #{label} avec succès !")
         |> assign(:profile_saved, true)
         |> assign(:saved_profile_id, profil.id)}

      {:error, reason} ->
        {:noreply,
         put_flash(socket, :error, "Erreur lors de l'enregistrement : #{inspect(reason)}")}
    end
  end

  # ---------------------------------------------------------------------------
  # Apply actions (new / edit / duplicate)
  # ---------------------------------------------------------------------------
  defp apply_action(socket, :new, %{"duplicate_from" => source_id}) do
    source = Ash.get!(ProfilMontage, source_id, domain: TagIp.TagIp)
    source = Ash.load!(source, [:capteurs, :peripherals])

    tv =
      if source.type_vehicule_id do
        Ash.get!(TypeVehicule, source.type_vehicule_id)
      end

    features = MapSet.new(source.feature_slugs || [])
    capteur_ids = MapSet.new((source.capteurs || []) |> Enum.map(& &1.id))
    peripheral_ids = MapSet.new((source.peripherals || []) |> Enum.map(& &1.id))

    socket
    |> assign(:page_title, "Dupliquer le profil #{source.name}")
    |> assign(:profil, nil)
    |> assign(:profile_name, source.name)
    |> assign(:profile_description, source.description || "")
    |> assign(:selected_type_vehicule_id, source.type_vehicule_id)
    |> assign(:selected_type_vehicule, tv)
    |> assign(:selected_organisation_id, source.organisation_id)
    |> assign(:selected_alimentation_id, source.alimentation_id)
    |> assign(:object_type, source.object_type)
    |> assign(:voltage_min, source.voltage_min)
    |> assign(:voltage_max, source.voltage_max)
    |> assign(:inputs_requis, source.inputs_requis)
    |> assign(:outputs_requis, source.outputs_requis)
    |> assign(:selected_features, features)
    |> assign(:can_bus_requis, source.can_bus_requis || false)
    |> assign(:one_wire_requis, source.one_wire_requis || false)
    |> assign(:rs232_requis, source.rs232_requis || false)
    |> assign(:rs485_requis, source.rs485_requis || false)
    |> assign(:bluetooth_ble_requis, source.bluetooth_ble_requis || false)
    |> assign(:analog_inputs_requis, source.analog_inputs_requis || 0)
    |> assign(:montage_exterieur, source.montage_exterieur || false)
    |> assign(:antenne_deportee, source.antenne_deportee || false)
    |> assign(:accelerometre_requis, source.accelerometre_requis || false)
    |> assign(:ultra_low_power_requis, source.ultra_low_power_requis || false)
    |> assign(:buzzer, source.buzzer || false)
    |> assign(:geofence_enabled, source.geofence_enabled || false)
    |> assign(:fuel_probe_type, source.fuel_probe_type || "")
    |> assign(:selected_capteur_ids, capteur_ids)
    |> assign(:selected_peripheral_ids, peripheral_ids)
    |> assign(:compatible_models, [])
    |> assign(:selected_model_id, nil)
    |> assign(:selected_model, nil)
    |> assign(:validation_result, nil)
    |> assign(:profile_saved, false)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nouveau profil de montage")
    |> assign(:profil, nil)
    |> assign(:profile_name, "")
    |> assign(:profile_description, "")
    |> assign(:compatible_models, [])
    |> assign(:selected_model_id, nil)
    |> assign(:selected_model, nil)
    |> assign(:validation_result, nil)
    |> assign(:profile_saved, false)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    profil =
      Ash.get!(ProfilMontage, id)
      |> Ash.load!([:modele_traceur, :capteurs, :peripherals])

    modele = profil.modele_traceur
    modele = modele && Ash.load!(modele, [:features, :capteurs])

    tv_id = profil.type_vehicule_id

    tv =
      if tv_id do
        Ash.get!(TypeVehicule, tv_id)
      end

    features = MapSet.new(profil.feature_slugs || [])
    capteur_ids = MapSet.new((profil.capteurs || []) |> Enum.map(& &1.id))
    peripheral_ids = MapSet.new((profil.peripherals || []) |> Enum.map(& &1.id))

    socket
    |> assign(:page_title, "Modifier le profil #{profil.name}")
    |> assign(:profil, profil)
    |> assign(:profile_name, profil.name)
    |> assign(:profile_description, profil.description || "")
    |> assign(:selected_type_vehicule_id, tv_id)
    |> assign(:selected_type_vehicule, tv)
    |> assign(:selected_organisation_id, profil.organisation_id)
    |> assign(:selected_alimentation_id, profil.alimentation_id)
    |> assign(:object_type, profil.object_type)
    |> assign(:voltage_min, profil.voltage_min)
    |> assign(:voltage_max, profil.voltage_max)
    |> assign(:inputs_requis, profil.inputs_requis)
    |> assign(:outputs_requis, profil.outputs_requis)
    |> assign(:selected_features, features)
    |> assign(:can_bus_requis, profil.can_bus_requis || false)
    |> assign(:one_wire_requis, profil.one_wire_requis || false)
    |> assign(:rs232_requis, profil.rs232_requis || false)
    |> assign(:rs485_requis, profil.rs485_requis || false)
    |> assign(:bluetooth_ble_requis, profil.bluetooth_ble_requis || false)
    |> assign(:analog_inputs_requis, profil.analog_inputs_requis || 0)
    |> assign(:montage_exterieur, profil.montage_exterieur || false)
    |> assign(:antenne_deportee, profil.antenne_deportee || false)
    |> assign(:accelerometre_requis, profil.accelerometre_requis || false)
    |> assign(:ultra_low_power_requis, profil.ultra_low_power_requis || false)
    |> assign(:buzzer, profil.buzzer || false)
    |> assign(:geofence_enabled, profil.geofence_enabled || false)
    |> assign(:fuel_probe_type, profil.fuel_probe_type || "")
    |> assign(:selected_capteur_ids, capteur_ids)
    |> assign(:selected_peripheral_ids, peripheral_ids)
    |> assign(:compatible_models, [])
    |> assign(:selected_model_id, modele && modele.id)
    |> assign(:selected_model, modele)
    |> assign(:validation_result, nil)
    |> assign(:profile_saved, false)
  end

  # ---------------------------------------------------------------------------
  # Sync form data from params
  # ---------------------------------------------------------------------------
  defp sync_form_data(socket, params) do
    socket
    |> assign(:profile_name, params["profile_name"] || socket.assigns.profile_name || "")
    |> assign(
      :profile_description,
      params["profile_description"] || socket.assigns.profile_description || ""
    )
  end

  # ---------------------------------------------------------------------------
  # Compute compatible models (transition step 2 -> step 3)
  # ---------------------------------------------------------------------------
  defp compute_compatible_models(socket) do
    criteria = build_criteria_params(socket)

    capteur_slugs =
      socket.assigns.selected_capteur_ids
      |> MapSet.to_list()
      |> resolve_capteur_slugs()

    peripheral_ids = MapSet.to_list(socket.assigns.selected_peripheral_ids)

    compatible_models =
      CapabilityMatrix.find_compatible_models(criteria, capteur_slugs, peripheral_ids)

    socket
    |> assign(:compatible_models, compatible_models)
    |> assign(:selected_model_id, nil)
    |> assign(:selected_model, nil)
  end

  defp build_criteria_params(socket) do
    %{
      "object_type" => to_string(socket.assigns.object_type || ""),
      "voltage_min" => to_string(socket.assigns.voltage_min || ""),
      "voltage_max" => to_string(socket.assigns.voltage_max || ""),
      "montage_exterieur" => to_string(socket.assigns.montage_exterieur),
      "antenne_deportee" => to_string(socket.assigns.antenne_deportee),
      "can_bus_requis" => to_string(socket.assigns.can_bus_requis),
      "one_wire_requis" => to_string(socket.assigns.one_wire_requis),
      "rs232_requis" => to_string(socket.assigns.rs232_requis),
      "rs485_requis" => to_string(socket.assigns.rs485_requis),
      "bluetooth_ble_requis" => to_string(socket.assigns.bluetooth_ble_requis),
      "inputs_requis" => to_string(socket.assigns.inputs_requis || 0),
      "analog_inputs_requis" => to_string(socket.assigns.analog_inputs_requis || 0),
      "outputs_requis" => to_string(socket.assigns.outputs_requis || 0),
      "accelerometre_requis" => to_string(socket.assigns.accelerometre_requis),
      "ultra_low_power_requis" => to_string(socket.assigns.ultra_low_power_requis),
      "buzzer" => to_string(socket.assigns.buzzer),
      "geofence_enabled" => to_string(socket.assigns.geofence_enabled),
      "fuel_probe_type" => to_string(socket.assigns.fuel_probe_type)
    }
  end

  defp resolve_capteur_slugs(capteur_ids) do
    if capteur_ids == [] do
      []
    else
      all_capteurs = Capteur.read!()
      id_to_slug = Enum.into(all_capteurs, %{}, &{&1.id, &1.slug})

      capteur_ids
      |> Enum.map(&Map.get(id_to_slug, &1))
      |> Enum.reject(&is_nil/1)
    end
  end

  # ---------------------------------------------------------------------------
  # Validation
  # ---------------------------------------------------------------------------
  defp validate_step(socket, 1) do
    cond do
      socket.assigns.profile_name == "" ->
        {put_flash(socket, :error, "Veuillez saisir un nom de profil."), false}

      is_nil(socket.assigns.selected_organisation_id) ->
        {put_flash(socket, :error, "Veuillez sélectionner une organisation cliente."), false}

      is_nil(socket.assigns.selected_type_vehicule_id) ->
        {put_flash(socket, :error, "Veuillez sélectionner un type de véhicule."), false}

      true ->
        {socket, true}
    end
  end

  defp validate_step(socket, 2) do
    has_features = MapSet.size(socket.assigns.selected_features) > 0

    has_hardware_criteria =
      socket.assigns.can_bus_requis or
        socket.assigns.one_wire_requis or
        socket.assigns.rs232_requis or
        socket.assigns.rs485_requis or
        socket.assigns.bluetooth_ble_requis or
        socket.assigns.montage_exterieur or
        socket.assigns.antenne_deportee or
        socket.assigns.accelerometre_requis or
        socket.assigns.ultra_low_power_requis or
        socket.assigns.buzzer or
        socket.assigns.geofence_enabled or
        socket.assigns.fuel_probe_type not in ["", "none"] or
        MapSet.size(socket.assigns.selected_capteur_ids) > 0 or
        MapSet.size(socket.assigns.selected_peripheral_ids) > 0

    cond do
      not has_features and not has_hardware_criteria ->
        {put_flash(
           socket,
           :error,
           "Veuillez sélectionner au moins une fonctionnalité ou un critère technique."
         ), false}

      true ->
        {socket, true}
    end
  end

  defp validate_step(socket, 3) do
    cond do
      is_nil(socket.assigns.selected_model_id) ->
        {put_flash(
           socket,
           :error,
           "Veuillez sélectionner un modèle de traceur parmi les résultats."
         ), false}

      true ->
        {socket, true}
    end
  end

  defp run_final_validation(socket) do
    modele_id = socket.assigns.selected_model_id
    features = MapSet.to_list(socket.assigns.selected_features)
    result = CapabilityMatrix.check_full_compatibility(modele_id, features)
    assign(socket, :validation_result, result)
  end

  # ---------------------------------------------------------------------------
  # Build profile params
  # ---------------------------------------------------------------------------
  defp build_profile_params(
         name,
         description,
         feature_slugs,
         modele_traceur_id,
         type_vehicule_id,
         object_type,
         voltage_min,
         voltage_max,
         inputs_requis,
         outputs_requis,
         organisation_id,
         alimentation_id,
         socket
       ) do
    feature_map = MapSet.new(feature_slugs)
    fuel_type = resolve_fuel_type(feature_map)

    modele =
      if modele_traceur_id do
        ModeleTraceur
        |> Ash.get!(modele_traceur_id)
      end

    has_rs232 = socket.assigns.rs232_requis || (modele && modele.rs232)
    has_rs485 = socket.assigns.rs485_requis || (modele && modele.rs485)

    outdoor_types = ~w(construction_machine boat person)
    low_power_types = ~w(person asset object smart_lock padlock)

    %{
      name: name,
      description: description,
      feature_slugs: feature_slugs,
      modele_traceur_id: modele_traceur_id,
      organisation_id: organisation_id,
      alimentation_id: alimentation_id,
      type_vehicule_id: type_vehicule_id,
      object_type: object_type,
      voltage_min: voltage_min,
      voltage_max: voltage_max,
      inputs_requis: inputs_requis,
      outputs_requis: outputs_requis,
      reporting_interval: "interval_30s",
      buzzer: socket.assigns.buzzer,
      driver_id_type: if(MapSet.member?(feature_map, "driver_id"), do: "rfid", else: nil),
      fuel_probe_type: fuel_type,
      accelerometre_requis: socket.assigns.accelerometre_requis,
      geofence_enabled: socket.assigns.geofence_enabled,
      can_bus_requis: socket.assigns.can_bus_requis || fuel_type == "can",
      one_wire_requis:
        MapSet.member?(feature_map, "driver_id") or MapSet.member?(feature_map, "fuel_cap"),
      rs232_requis: fuel_type == "rs232" or has_rs232,
      rs485_requis: has_rs485,
      bluetooth_ble_requis: fuel_type == "ble" || socket.assigns.bluetooth_ble_requis,
      analog_inputs_requis:
        socket.assigns.analog_inputs_requis || if(fuel_type == "analog", do: 1, else: nil),
      montage_exterieur: socket.assigns.montage_exterieur || object_type in outdoor_types,
      antenne_deportee: socket.assigns.antenne_deportee,
      ultra_low_power_requis:
        socket.assigns.ultra_low_power_requis || object_type in low_power_types
    }
  end

  defp resolve_fuel_type(feature_map) do
    cond do
      MapSet.member?(feature_map, "fuel_analog") -> "analog"
      MapSet.member?(feature_map, "fuel_rs232") -> "rs232"
      MapSet.member?(feature_map, "fuel_ble") -> "ble"
      MapSet.member?(feature_map, "fuel_can") -> "can"
      true -> nil
    end
  end

  defp resolve_required_capteur_ids(feature_slugs) do
    required_slugs = CapabilityMatrix.extract_required_capteurs(feature_slugs)

    if required_slugs == [] do
      []
    else
      all_capteurs = Capteur.read!()
      slug_to_id = Enum.into(all_capteurs, %{}, &{&1.slug, &1.id})

      required_slugs
      |> Enum.map(&slug_to_id[&1])
      |> Enum.reject(&is_nil/1)
    end
  end

  defp sync_capteurs(profil_id, capteur_ids) do
    existing =
      ProfilMontageCapteur.read!()
      |> Enum.filter(&(&1.profil_montage_id == profil_id))

    Enum.each(existing, &ProfilMontageCapteur.destroy(&1))

    Enum.each(capteur_ids, fn id ->
      ProfilMontageCapteur.create(%{
        profil_montage_id: profil_id,
        capteur_id: id
      })
    end)
  end

  defp sync_peripherals(profil_id, peripheral_ids) do
    existing =
      ProfilMontagePeripheral.read!()
      |> Enum.filter(&(&1.profil_montage_id == profil_id))

    Enum.each(existing, &ProfilMontagePeripheral.destroy(&1))

    Enum.each(peripheral_ids, fn id ->
      ProfilMontagePeripheral.create(%{
        profil_montage_id: profil_id,
        peripheral_id: id
      })
    end)
  end

  defp parse_alim_voltage(slug) do
    slug = String.upcase(slug)

    cond do
      slug == "12V" ->
        {12, 15}

      slug == "24V" ->
        {24, 32}

      String.contains?(slug, "-") ->
        parts = String.split(slug, "-")
        min = parts |> List.first() |> String.replace(~r/[^0-9]/, "") |> String.to_integer()
        max = parts |> List.last() |> String.replace(~r/[^0-9]/, "") |> String.to_integer()
        {min, max}

      true ->
        volts = slug |> String.replace(~r/[^0-9]/, "") |> String.to_integer()
        {volts, volts}
    end
  rescue
    _ -> {nil, nil}
  end

  def score_color(score) do
    cond do
      score >= 70 -> "bg-green-100 text-green-800 border-green-200"
      score >= 40 -> "bg-yellow-100 text-yellow-800 border-yellow-200"
      true -> "bg-red-100 text-red-800 border-red-200"
    end
  end

  def score_bar_color(score) do
    cond do
      score >= 70 -> "bg-green-500"
      score >= 40 -> "bg-yellow-500"
      true -> "bg-red-500"
    end
  end

  defp parse_step(params) do
    case Map.get(params, "step") do
      nil ->
        1

      step_str ->
        case Integer.parse(step_str) do
          {n, _} when n >= 1 and n <= 4 -> n
          _ -> 1
        end
    end
  end

  defp step_path(socket, step) do
    case socket.assigns do
      %{live_action: :edit, profil: %{id: id}} ->
        ~p"/profils/#{id}/edit?step=#{step}"

      _ ->
        ~p"/profils/new?step=#{step}"
    end
  end
end
