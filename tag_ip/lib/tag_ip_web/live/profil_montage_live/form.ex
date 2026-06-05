defmodule TagIpWeb.ProfilMontageLive.Form do
  use TagIpWeb, :live_view

  alias AshPhoenix.Form
  alias TagIp.Resources.ProfilMontage
  alias TagIp.Resources.ModeleTraceur
  alias TagIp.Resources.Compatibilite
  alias TagIp.Resources.Capteur
  alias TagIp.Resources.TrackableType
  alias TagIp.Resources.TypeVehicule

  import Ash.Query, only: [load: 2]

  @steps [
    %{num: 1, title: "Identification", description: "Nom et description du profil"},
    %{num: 2, title: "Configuration", description: "Type d'asset, tension, interfaces"},
    %{num: 3, title: "Équipements", description: "Capteurs et options"},
    %{num: 4, title: "Compatibilités", description: "Modèles de traceurs compatibles"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    trackable_types = TrackableType.read!()

    object_type_options =
      Enum.map(trackable_types, fn tt ->
        {tt.label, tt.slug}
      end)

    trackable_type_by_slug =
      Enum.into(trackable_types, %{}, fn tt -> {tt.slug, tt} end)

    type_vehicule_by_slug =
      TypeVehicule.read!()
      |> Enum.into(%{}, fn tv -> {tv.slug, tv} end)

    modeles =
      ModeleTraceur
      |> load([:types_vehicule, :alimentations, :capteurs])
      |> Ash.read!(page: [limit: 50])

    capteurs = Capteur.read!() |> Enum.sort_by(& &1.label)
    capteur_categories = capteurs |> Enum.map(& &1.category) |> Enum.uniq() |> Enum.sort()

    {:ok,
     socket
     |> assign(:step, 1)
     |> assign(:total_steps, length(@steps))
     |> assign(:steps, @steps)
     |> assign(:object_type_options, object_type_options)
     |> assign(:modeles, modeles.results)
     |> assign(:voltage_compatible_count, nil)
     |> assign(:compatibilities, [])
     |> assign(:capteurs, capteurs)
     |> assign(:capteur_categories, capteur_categories)
     |> assign(:selected_capteur_ids, MapSet.new())
     |> assign(:trackable_type_by_slug, trackable_type_by_slug)
     |> assign(:type_vehicule_by_slug, type_vehicule_by_slug)
     |> assign(:previous_object_type, nil)}
  end

  @impl true
  def handle_params(params, url, socket) do
    path = URI.parse(url).path
    return_to = params["return_to"]

    {:noreply,
     socket
     |> assign(:current_path, path)
     |> assign(:return_to, return_to)
     |> apply_action(socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("next-step", %{"profil_montage" => params}, socket) do
    step = socket.assigns.step
    total = socket.assigns.total_steps

    if step < total do
      params =
        params
        |> normalize_params()
        |> maybe_autofill_voltage(
          socket.assigns.trackable_type_by_slug,
          socket.assigns.type_vehicule_by_slug,
          socket.assigns.previous_object_type
        )

      form =
        socket.assigns.form.source
        |> Form.validate(params)
        |> to_form()

      capteur_slugs =
        resolve_capteur_slugs(socket.assigns.capteurs, socket.assigns.selected_capteur_ids)

      compatibilities = compute_compatibilities(params, socket.assigns.modeles, capteur_slugs)

      voltage_compatible_count =
        count_voltage_compatible(
          socket.assigns.modeles,
          params["voltage_min"],
          params["voltage_max"]
        )

      {:noreply,
       socket
       |> assign(:step, step + 1)
       |> assign(:form, form)
       |> assign(:compatibilities, compatibilities)
       |> assign(:voltage_compatible_count, voltage_compatible_count)
       |> assign(:previous_object_type, params["object_type"])}
    else
      {:noreply, socket}
    end
  end

  def handle_event("next-step", _params, socket) do
    step = socket.assigns.step
    total = socket.assigns.total_steps

    if step < total do
      {:noreply, assign(socket, :step, step + 1)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("prev-step", %{"profil_montage" => params}, socket) do
    step = socket.assigns.step

    if step > 1 do
      params =
        params
        |> normalize_params()
        |> maybe_autofill_voltage(
          socket.assigns.trackable_type_by_slug,
          socket.assigns.type_vehicule_by_slug,
          socket.assigns.previous_object_type
        )

      form =
        socket.assigns.form.source
        |> Form.validate(params)
        |> to_form()

      capteur_slugs =
        resolve_capteur_slugs(socket.assigns.capteurs, socket.assigns.selected_capteur_ids)

      compatibilities = compute_compatibilities(params, socket.assigns.modeles, capteur_slugs)

      voltage_compatible_count =
        count_voltage_compatible(
          socket.assigns.modeles,
          params["voltage_min"],
          params["voltage_max"]
        )

      {:noreply,
       socket
       |> assign(:step, step - 1)
       |> assign(:form, form)
       |> assign(:compatibilities, compatibilities)
       |> assign(:voltage_compatible_count, voltage_compatible_count)
       |> assign(:previous_object_type, params["object_type"])}
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

  @impl true
  def handle_event("validate", %{"profil_montage" => params}, socket) do
    params =
      params
      |> normalize_params()
      |> maybe_autofill_voltage(
        socket.assigns.trackable_type_by_slug,
        socket.assigns.type_vehicule_by_slug,
        socket.assigns.previous_object_type
      )

    form =
      socket.assigns.form.source
      |> Form.validate(params)
      |> to_form()

    capteur_slugs =
      resolve_capteur_slugs(socket.assigns.capteurs, socket.assigns.selected_capteur_ids)

    compatibilities = compute_compatibilities(params, socket.assigns.modeles, capteur_slugs)

    voltage_compatible_count =
      count_voltage_compatible(
        socket.assigns.modeles,
        params["voltage_min"],
        params["voltage_max"]
      )

    {:noreply,
     socket
     |> assign(:form, form)
     |> assign(:compatibilities, compatibilities)
     |> assign(:voltage_compatible_count, voltage_compatible_count)
     |> assign(:previous_object_type, params["object_type"])}
  end

  @impl true
  def handle_event("save", %{"profil_montage" => params}, socket) do
    params = normalize_params(params)

    case AshPhoenix.Form.submit(socket.assigns.form.source, params: params) do
      {:ok, profil} ->
        sync_capteurs(profil.id, socket.assigns.selected_capteur_ids)

        for compat <- socket.assigns.compatibilities, compat.compatible do
          Compatibilite
          |> Ash.ActionInput.for_action(:calculer_compatibilite, %{
            profil_id: profil.id,
            modele_id: compat.modele.id
          })
          |> Ash.run_action!()
        end

        compat_count = Enum.count(socket.assigns.compatibilities, & &1.compatible)

        message =
          if socket.assigns.profil do
            "Profil de montage modifié avec succès !"
          else
            "Profil de montage créé avec succès ! #{compat_count} compatibilité(s) enregistrée(s)."
          end

        TagIp.Notification.broadcast({:notification, :info, message})

        return_to = socket.assigns.return_to || ~p"/profils"

        {:noreply,
         socket
         |> put_flash(:info, message)
         |> push_navigate(to: return_to)}

      {:error, form} ->
        {:noreply, assign(socket, form: to_form(form))}
    end
  end

  @impl true
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

    source_capteur_ids = MapSet.new(source.capteurs || [], & &1.id)

    params = %{
      "name" => source.name,
      "description" => source.description,
      "reporting_interval" => source.reporting_interval,
      "object_type" => source.object_type,
      "voltage_min" => source.voltage_min,
      "voltage_max" => source.voltage_max,
      "buzzer" => source.buzzer,
      "fuel_probe_type" => source.fuel_probe_type,
      "geofence_enabled" => source.geofence_enabled,
      "driver_id_type" => source.driver_id_type,
      "can_bus_requis" => source.can_bus_requis,
      "one_wire_requis" => source.one_wire_requis,
      "rs232_requis" => source.rs232_requis,
      "rs485_requis" => source.rs485_requis,
      "inputs_requis" => source.inputs_requis,
      "analog_inputs_requis" => source.analog_inputs_requis,
      "outputs_requis" => source.outputs_requis,
      "montage_exterieur" => source.montage_exterieur,
      "antenne_deportee" => source.antenne_deportee,
      "accelerometre_requis" => source.accelerometre_requis,
      "ultra_low_power_requis" => source.ultra_low_power_requis
    }

    form =
      Form.for_create(ProfilMontage, :create, as: "profil_montage", domain: TagIp.TagIp)
      |> Form.validate(params)
      |> to_form()

    compatibilities = compute_compatibilities(params, socket.assigns.modeles)

    voltage_compatible_count =
      count_voltage_compatible(
        socket.assigns.modeles,
        params["voltage_min"],
        params["voltage_max"]
      )

    socket
    |> assign(:page_title, "Dupliquer le profil #{source.name}")
    |> assign(:form, form)
    |> assign(:profil, nil)
    |> assign(:compatibilities, compatibilities)
    |> assign(:voltage_compatible_count, voltage_compatible_count)
    |> assign(:selected_capteur_ids, source_capteur_ids)
    |> assign(:previous_object_type, source.object_type)
  end

  defp apply_action(socket, :new, _params) do
    form =
      Form.for_create(ProfilMontage, :create, as: "profil_montage", domain: TagIp.TagIp)
      |> to_form()

    socket
    |> assign(:page_title, "Nouveau profil de montage")
    |> assign(:form, form)
    |> assign(:profil, nil)
    |> assign(:voltage_compatible_count, nil)
    |> assign(:compatibilities, [])
    |> assign(:previous_object_type, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    profil = Ash.get!(ProfilMontage, id, domain: TagIp.TagIp)
    profil = Ash.load!(profil, [:capteurs])

    source_capteur_ids = MapSet.new(profil.capteurs || [], & &1.id)

    form =
      Form.for_update(profil, :update, as: "profil_montage")
      |> to_form()

    params = %{
      "object_type" => profil.object_type,
      "voltage_min" => profil.voltage_min,
      "voltage_max" => profil.voltage_max,
      "buzzer" => profil.buzzer,
      "fuel_probe_type" => profil.fuel_probe_type,
      "geofence_enabled" => profil.geofence_enabled,
      "can_bus_requis" => profil.can_bus_requis,
      "one_wire_requis" => profil.one_wire_requis,
      "rs232_requis" => profil.rs232_requis,
      "rs485_requis" => profil.rs485_requis,
      "inputs_requis" => profil.inputs_requis,
      "analog_inputs_requis" => profil.analog_inputs_requis,
      "outputs_requis" => profil.outputs_requis,
      "montage_exterieur" => profil.montage_exterieur,
      "antenne_deportee" => profil.antenne_deportee,
      "accelerometre_requis" => profil.accelerometre_requis,
      "ultra_low_power_requis" => profil.ultra_low_power_requis
    }

    compatibilities = compute_compatibilities(params, socket.assigns.modeles)

    voltage_compatible_count =
      count_voltage_compatible(
        socket.assigns.modeles,
        params["voltage_min"],
        params["voltage_max"]
      )

    socket
    |> assign(:page_title, "Modifier le profil #{profil.name}")
    |> assign(:form, form)
    |> assign(:profil, profil)
    |> assign(:compatibilities, compatibilities)
    |> assign(:voltage_compatible_count, voltage_compatible_count)
    |> assign(:selected_capteur_ids, source_capteur_ids)
    |> assign(:previous_object_type, profil.object_type)
  end

  defp compute_compatibilities(params, modeles, capteur_slugs \\ []) do
    modeles
    |> Enum.map(fn modele ->
      result = Compatibilite.calculer_depuis_params(params, modele, capteur_slugs)

      %{
        modele: modele,
        score: result.score,
        compatible: result.compatible,
        details: result.details
      }
    end)
    |> Enum.sort_by(fn c -> -c.score end)
  end

  defp count_voltage_compatible(_modeles, nil, _), do: nil
  defp count_voltage_compatible(_modeles, _, nil), do: nil
  defp count_voltage_compatible(_modeles, "", _), do: nil
  defp count_voltage_compatible(_modeles, _, ""), do: nil

  defp count_voltage_compatible(modeles, voltage_min, voltage_max) do
    v_min = parse_float(voltage_min)
    v_max = parse_float(voltage_max)

    if is_nil(v_min) or is_nil(v_max) do
      nil
    else
      modeles
      |> Enum.count(fn modele ->
        modele.voltage_min && modele.voltage_max &&
          v_min >= modele.voltage_min &&
          v_max <= modele.voltage_max
      end)
    end
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

  defp normalize_params(params) when is_map(params) do
    Map.new(params, fn
      {key, val} when is_list(val) -> {key, List.last(val)}
      {key, val} when is_map(val) -> {key, normalize_params(val)}
      {key, val} -> {key, val}
    end)
  end

  defp normalize_params(val), do: val

  defp maybe_autofill_voltage(
         params,
         trackable_type_by_slug,
         type_vehicule_by_slug,
         previous_object_type
       ) do
    object_type = params["object_type"]

    cond do
      is_nil(object_type) or object_type == "" ->
        params

      object_type == previous_object_type ->
        params

      tt = trackable_type_by_slug[object_type] ->
        fill_voltage(params, tt)

      tv = type_vehicule_by_slug[object_type] ->
        fill_voltage(params, tv)

      true ->
        params
    end
  end

  defp fill_voltage(params, source) when not is_struct(source) do
    params
  end

  defp fill_voltage(params, source) do
    if source.voltage_min && source.voltage_max do
      params
      |> Map.put("voltage_min", source.voltage_min)
      |> Map.put("voltage_max", source.voltage_max)
    else
      params
    end
  end

  defp sync_capteurs(profil_id, selected_ids) do
    existing =
      TagIp.Resources.ProfilMontageCapteur.read!()
      |> Enum.filter(&(&1.profil_montage_id == profil_id))

    Enum.each(existing, &TagIp.Resources.ProfilMontageCapteur.destroy(&1))

    Enum.each(selected_ids, fn id ->
      TagIp.Resources.ProfilMontageCapteur.create(%{
        profil_montage_id: profil_id,
        capteur_id: id
      })
    end)
  end

  defp resolve_capteur_slugs(capteurs, selected_ids) do
    capteurs
    |> Enum.filter(&MapSet.member?(selected_ids, &1.id))
    |> Enum.map(& &1.slug)
  end

  defp capteur_category_label(nil), do: "Non catégorisé"
  defp capteur_category_label("energy"), do: "Énergie"
  defp capteur_category_label("safety"), do: "Sécurité"
  defp capteur_category_label("environment"), do: "Environnement"
  defp capteur_category_label("driver"), do: "Conducteur"
  defp capteur_category_label("vehicle_status"), do: "État du véhicule"
  defp capteur_category_label("connectivity"), do: "Connectivité"
  defp capteur_category_label(category), do: category |> String.capitalize()
end
