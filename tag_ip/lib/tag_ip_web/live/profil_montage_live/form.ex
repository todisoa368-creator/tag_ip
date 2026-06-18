defmodule TagIpWeb.ProfilMontageLive.Form do
  use TagIpWeb, :live_view

  alias TagIp.Resources.ProfilMontage
  alias TagIp.Resources.ModeleTraceur
  alias TagIp.Resources.Capteur
  alias TagIp.Resources.CapabilityMatrix
  alias TagIp.Resources.ProfilMontageCapteur
  alias TagIp.Resources.TypeVehicule
  alias TagIp.Resources.Organisation
  alias TagIp.Resources.Alimentation

  @steps [
    %{
      num: 1,
      title: "Étape 1 : Identification",
      description: "Étape 1 — Nom du profil et type de véhicule"
    },
    %{
      num: 2,
      title: "Étape 2 : Modèle traceur",
      description: "Étape 2 — Fournisseur et modèle du traceur"
    },
    %{
      num: 3,
      title: "Étape 3 : Fonctionnalités",
      description: "Étape 3 — Fonctionnalités supportées par le modèle"
    },
    %{
      num: 4,
      title: "Étape 4 : Validation",
      description: "Étape 4 — Récapitulatif et vérification"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    modeles =
      ModeleTraceur.read!()
      |> Enum.map(&Ash.load!(&1, [:types_vehicule]))

    brands =
      modeles |> Enum.map(& &1.brand) |> Enum.uniq() |> Enum.reject(&is_nil/1) |> Enum.sort()

    matrix_features = CapabilityMatrix.matrix_features()
    types_vehicule = TypeVehicule.read!() |> Enum.sort_by(& &1.label)

    organisations = Organisation.read!() |> Enum.sort_by(& &1.name)
    alimentations = Alimentation.read!() |> Enum.sort_by(& &1.label)

    {:ok,
     socket
     |> assign(:step, 1)
     |> assign(:total_steps, length(@steps))
     |> assign(:steps, @steps)
     |> assign(:modeles, modeles)
     |> assign(:brands, brands)
     |> assign(:matrix_features, matrix_features)
     |> assign(:types_vehicule, types_vehicule)
     |> assign(:organisations, organisations)
     |> assign(:alimentations, alimentations)
     |> assign(:selected_supplier, nil)
     |> assign(:available_models, [])
     |> assign(:selected_model_id, nil)
     |> assign(:selected_model, nil)
     |> assign(:selected_features, MapSet.new())
     |> assign(:selected_type_vehicule_id, nil)
     |> assign(:selected_type_vehicule, nil)
     |> assign(:selected_organisation_id, nil)
     |> assign(:selected_alimentation_id, nil)
     |> assign(:profile_name, "")
     |> assign(:profile_description, "")
     |> assign(:object_type, nil)
     |> assign(:voltage_min, nil)
     |> assign(:voltage_max, nil)
     |> assign(:inputs_requis, nil)
     |> assign(:outputs_requis, nil)
     |> assign(:validation_result, nil)
     |> assign(:profile_saved, false)}
  end

  @impl true
  def handle_params(params, url, socket) do
    path = URI.parse(url).path

    {:noreply,
     socket
     |> assign(:current_path, path)
     |> apply_action(socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("select_supplier", %{"supplier" => supplier}, socket) do
    tv_id = socket.assigns.selected_type_vehicule_id

    available =
      socket.assigns.modeles
      |> Enum.filter(&(&1.brand == supplier))
      |> then(fn models ->
        if tv_id do
          tv = Enum.find(socket.assigns.types_vehicule, &(&1.id == tv_id))
          tv_slug = tv && tv.slug

          if tv_slug do
            Enum.filter(models, fn m ->
              m.types_vehicule && Enum.any?(m.types_vehicule, &(&1.slug == tv_slug))
            end)
          else
            models
          end
        else
          models
        end
      end)
      |> Enum.sort_by(& &1.nom)

    {:noreply,
     socket
     |> assign(:selected_supplier, supplier)
     |> assign(:available_models, available)
     |> assign(:selected_model_id, nil)
     |> assign(:selected_model, nil)
     |> assign(:selected_features, MapSet.new())
     |> assign(:validation_result, nil)}
  end

  def handle_event("select_organisation", %{"organisation_id" => org_id}, socket) do
    org_id = if org_id not in [nil, "", "0"], do: org_id, else: nil

    {:noreply, assign(socket, :selected_organisation_id, org_id)}
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
     |> assign(:selected_supplier, nil)
     |> assign(:available_models, [])
     |> assign(:selected_model_id, nil)
     |> assign(:selected_model, nil)
     |> assign(:selected_features, MapSet.new())
     |> assign(:validation_result, nil)}
  end

  def handle_event("select_model", %{"model_id" => model_id}, socket) do
    modele =
      socket.assigns.modeles
      |> Enum.find(&(&1.id == model_id))

    modele = modele && Ash.load!(modele, [:features, :capteurs])

    {:noreply,
     socket
     |> assign(:selected_model_id, model_id)
     |> assign(:selected_model, modele)
     |> assign(:selected_features, MapSet.new())
     |> assign(:validation_result, nil)}
  end

  def handle_event("toggle_feature", %{"slug" => slug}, socket) do
    current = socket.assigns.selected_features

    updated =
      if MapSet.member?(current, slug) do
        MapSet.delete(current, slug)
      else
        MapSet.put(current, slug)
      end

    {:noreply, assign(socket, :selected_features, updated)}
  end

  def handle_event("next-step", params, socket) do
    step = socket.assigns.step
    total = socket.assigns.total_steps

    socket = sync_form_data(socket, params)

    {socket, can_advance} = validate_step(socket, step)

    if can_advance && step < total do
      socket =
        if step + 1 == 4 do
          run_final_validation(socket)
        else
          socket
        end

      {:noreply, assign(socket, :step, step + 1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("prev-step", _params, socket) do
    step = socket.assigns.step

    if step > 1 do
      {:noreply, assign(socket, :step, step - 1)}
    else
      {:noreply, socket}
    end
  end

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
        alimentation_id
      )

    result =
      case socket.assigns.profil do
        nil ->
          case ProfilMontage.create(profile_params, action: :create) do
            {:ok, profil} ->
              capteur_ids = resolve_required_capteur_ids(features)
              sync_capteurs(profil.id, capteur_ids)
              ProfilMontage.compute_compatibilities(profil.id)
              {:ok, profil, "créé"}

            {:error, reason} ->
              {:error, reason}
          end

        profil ->
          case ProfilMontage.update(profil, profile_params, action: :update) do
            {:ok, profil} ->
              capteur_ids = resolve_required_capteur_ids(features)
              sync_capteurs(profil.id, capteur_ids)
              ProfilMontage.compute_compatibilities(profil.id)
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

  defp apply_action(socket, :new, %{"duplicate_from" => source_id}) do
    source = Ash.get!(ProfilMontage, source_id, domain: TagIp.TagIp)
    source = Ash.load!(source, [:capteurs])

    tv =
      if source.type_vehicule_id do
        Ash.get!(TypeVehicule, source.type_vehicule_id)
      end

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
    |> assign(:selected_supplier, nil)
    |> assign(:available_models, [])
    |> assign(:selected_model_id, nil)
    |> assign(:selected_model, nil)
    |> assign(:selected_features, MapSet.new())
    |> assign(:validation_result, nil)
    |> assign(:profile_saved, false)
  end

  defp apply_action(socket, :new, params) do
    supplier = params["supplier"]
    type_vehicule_id = params["type_vehicule_id"]

    tv =
      if type_vehicule_id && type_vehicule_id != "" do
        Ash.get!(TypeVehicule, type_vehicule_id)
      end

    available =
      if supplier do
        socket.assigns.modeles
        |> Enum.filter(&(&1.brand == supplier))
        |> Enum.sort_by(& &1.nom)
      else
        []
      end

    socket
    |> assign(:page_title, "Nouveau profil de montage")
    |> assign(:profil, nil)
    |> assign(:profile_name, "")
    |> assign(:profile_description, "")
    |> assign(:selected_type_vehicule_id, tv && tv.id)
    |> assign(:selected_type_vehicule, tv)
    |> assign(:object_type, tv && tv.slug)
    |> assign(:voltage_min, tv && tv.voltage_min)
    |> assign(:voltage_max, tv && tv.voltage_max)
    |> assign(:inputs_requis, tv && tv.inputs_requis)
    |> assign(:outputs_requis, tv && tv.outputs_requis)
    |> assign(:selected_supplier, supplier)
    |> assign(:available_models, available)
    |> assign(:selected_model_id, nil)
    |> assign(:selected_model, nil)
    |> assign(:selected_features, MapSet.new())
    |> assign(:validation_result, nil)
    |> assign(:profile_saved, false)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    profil =
      Ash.get!(ProfilMontage, id)
      |> Ash.load!(:modele_traceur)

    modele = profil.modele_traceur
    modele = modele && Ash.load!(modele, [:features, :capteurs])

    supplier = modele && modele.brand
    tv_id = profil.type_vehicule_id

    available =
      if supplier do
        socket.assigns.modeles
        |> Enum.filter(&(&1.brand == supplier))
        |> then(fn models ->
          if tv_id do
            tv = Enum.find(socket.assigns.types_vehicule, &(&1.id == tv_id))
            tv_slug = tv && tv.slug

            if tv_slug do
              Enum.filter(models, fn m ->
                m.types_vehicule && Enum.any?(m.types_vehicule, &(&1.slug == tv_slug))
              end)
            else
              models
            end
          else
            models
          end
        end)
        |> Enum.sort_by(& &1.nom)
      else
        []
      end

    features = MapSet.new(profil.feature_slugs || [])

    tv =
      if tv_id do
        Ash.get!(TypeVehicule, tv_id)
      end

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
    |> assign(:selected_supplier, supplier)
    |> assign(:available_models, available)
    |> assign(:selected_model_id, modele && modele.id)
    |> assign(:selected_model, modele)
    |> assign(:selected_features, features)
    |> assign(:validation_result, nil)
    |> assign(:profile_saved, false)
  end

  defp sync_form_data(socket, params) do
    socket =
      socket
      |> assign(:profile_name, params["profile_name"] || socket.assigns.profile_name || "")
      |> assign(
        :profile_description,
        params["profile_description"] || socket.assigns.profile_description || ""
      )

    supplier = params["supplier"]

    if supplier && supplier != "" do
      tv_id = socket.assigns.selected_type_vehicule_id

      available =
        socket.assigns.modeles
        |> Enum.filter(&(&1.brand == supplier))
        |> then(fn models ->
          if tv_id do
            tv = Enum.find(socket.assigns.types_vehicule, &(&1.id == tv_id))
            tv_slug = tv && tv.slug

            if tv_slug do
              Enum.filter(models, fn m ->
                m.types_vehicule && Enum.any?(m.types_vehicule, &(&1.slug == tv_slug))
              end)
            else
              models
            end
          else
            models
          end
        end)
        |> Enum.sort_by(& &1.nom)

      socket =
        socket
        |> assign(:selected_supplier, supplier)
        |> assign(:available_models, available)

      model_id = params["model_id"]

      if model_id && model_id != "" do
        modele = Enum.find(socket.assigns.modeles, &(&1.id == model_id))
        modele = modele && Ash.load!(modele, [:features, :capteurs])

        socket
        |> assign(:selected_model_id, model_id)
        |> assign(:selected_model, modele)
      else
        socket
      end
    else
      socket
    end
  end

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
    cond do
      is_nil(socket.assigns.selected_supplier) ->
        {put_flash(socket, :error, "Veuillez sélectionner un fournisseur."), false}

      is_nil(socket.assigns.selected_model_id) ->
        {put_flash(socket, :error, "Veuillez sélectionner un modèle de traceur."), false}

      true ->
        {socket, true}
    end
  end

  defp validate_step(socket, 3) do
    {socket, true}
  end

  defp run_final_validation(socket) do
    modele_id = socket.assigns.selected_model_id
    features = MapSet.to_list(socket.assigns.selected_features)
    result = CapabilityMatrix.check_full_compatibility(modele_id, features)
    assign(socket, :validation_result, result)
  end

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
         alimentation_id
       ) do
    feature_map = MapSet.new(feature_slugs)
    fuel_type = resolve_fuel_type(feature_map)

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
      buzzer: MapSet.member?(feature_map, "buzzer_feature"),
      driver_id_type: if(MapSet.member?(feature_map, "driver_id"), do: "rfid", else: nil),
      fuel_probe_type: fuel_type,
      accelerometre_requis: needs_accelerometer?(feature_map),
      geofence_enabled: true,
      can_bus_requis: fuel_type == "can",
      one_wire_requis: false,
      rs232_requis: fuel_type == "rs232",
      rs485_requis: false,
      bluetooth_ble_requis: fuel_type == "ble",
      analog_inputs_requis: if(fuel_type == "analog", do: 1, else: nil),
      montage_exterieur: false,
      antenne_deportee: false,
      ultra_low_power_requis: false
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

  defp needs_accelerometer?(feature_map) do
    MapSet.member?(feature_map, "green_driving") or
      MapSet.member?(feature_map, "crash_detection")
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

  def supported_for_model(modele_id, matrix_features) do
    supported_slugs = CapabilityMatrix.supported_feature_slugs(modele_id) |> MapSet.new()

    matrix_features
    |> Enum.map(& &1.slug)
    |> Enum.filter(&MapSet.member?(supported_slugs, &1))
  end
end
