defmodule TagIpWeb.ModeleTraceurLive.Form do
  use TagIpWeb, :live_view

  alias AshPhoenix.Form
  alias TagIp.Resources.ModeleTraceur
  alias TagIp.Resources.Feature
  alias TagIp.Resources.ModelFeature
  alias TagIp.Resources.TypeVehicule
  alias TagIp.Resources.Alimentation
  alias TagIp.Resources.Capteur

  @impl true
  def mount(_params, _session, socket) do
    features = Feature.read!()
    feature_list = Enum.map(features, &%{id: &1.id, label: &1.label, selected: false})

    types_vehicule = TypeVehicule.read!() |> Enum.sort_by(& &1.label)
    alimentations = Alimentation.read!() |> Enum.sort_by(& &1.label)
    capteurs = Capteur.read!() |> Enum.sort_by(& &1.label)

    {:ok,
     socket
     |> assign(:features, feature_list)
     |> assign(:selected_feature_ids, MapSet.new())
     |> assign(:types_vehicule, types_vehicule)
     |> assign(:alimentations, alimentations)
     |> assign(:capteurs, capteurs)
     |> assign(:selected_type_vehicule_ids, MapSet.new())
     |> assign(:selected_alimentation_ids, MapSet.new())
     |> assign(:selected_capteur_ids, MapSet.new())}
  end

  @impl true
  def handle_params(params, url, socket) do
    path = URI.parse(url).path

    {:noreply,
     socket
     |> assign(:current_path, path)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, %{"duplicate_from" => source_id}) do
    source = Ash.get!(ModeleTraceur, source_id, domain: TagIp.TagIp)
    source = Ash.load!(source, [:features, :types_vehicule, :alimentations, :capteurs])

    source_feature_ids = MapSet.new(source.features || [], & &1.id)

    feature_list =
      Enum.map(socket.assigns.features, fn f ->
        %{f | selected: MapSet.member?(source_feature_ids, f.id)}
      end)

    source_type_vehicule_ids = MapSet.new(source.types_vehicule || [], & &1.id)
    source_alimentation_ids = MapSet.new(source.alimentations || [], & &1.id)
    source_capteur_ids = MapSet.new(source.capteurs || [], & &1.id)

    params = %{
      "nom" => source.nom,
      "reference" => "#{source.reference}-COPY",
      "description" => source.description,
      "brand" => source.brand,
      "can_bus" => source.can_bus,
      "one_wire" => source.one_wire,
      "rs232" => source.rs232,
      "rs485" => source.rs485,
      "nb_digital_inputs" => source.nb_digital_inputs,
      "nb_analog_inputs" => source.nb_analog_inputs,
      "nb_outputs" => source.nb_outputs,
      "ip_rating" => source.ip_rating,
      "antennes_externes" => source.antennes_externes,
      "standby_current" => source.standby_current,
      "ultra_low_power" => source.ultra_low_power,
      "accelerometer" => source.accelerometer,
      "buffer_memory" => source.buffer_memory
    }

    form =
      Form.for_create(ModeleTraceur, :create, as: "modele_traceur")
      |> Form.validate(params)
      |> to_form()

    socket
    |> assign(:page_title, "Dupliquer le modèle #{source.nom}")
    |> assign(:form, form)
    |> assign(:modele, nil)
    |> assign(:features, feature_list)
    |> assign(:selected_feature_ids, source_feature_ids)
    |> assign(:selected_type_vehicule_ids, source_type_vehicule_ids)
    |> assign(:selected_alimentation_ids, source_alimentation_ids)
    |> assign(:selected_capteur_ids, source_capteur_ids)
  end

  defp apply_action(socket, :new, _params) do
    form =
      Form.for_create(ModeleTraceur, :create, as: "modele_traceur")
      |> to_form()

    socket
    |> assign(:page_title, "Nouveau modèle de traceur")
    |> assign(:form, form)
    |> assign(:modele, nil)
    |> assign(:selected_feature_ids, MapSet.new())
    |> assign(:selected_type_vehicule_ids, MapSet.new())
    |> assign(:selected_alimentation_ids, MapSet.new())
    |> assign(:selected_capteur_ids, MapSet.new())
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    modele = Ash.get!(ModeleTraceur, id, domain: TagIp.TagIp)
    modele = Ash.load!(modele, [:features, :types_vehicule, :alimentations, :capteurs])

    modele_feature_ids = MapSet.new(modele.features || [], & &1.id)

    feature_list =
      Enum.map(socket.assigns.features, fn f ->
        %{f | selected: MapSet.member?(modele_feature_ids, f.id)}
      end)

    source_type_vehicule_ids = MapSet.new(modele.types_vehicule || [], & &1.id)
    source_alimentation_ids = MapSet.new(modele.alimentations || [], & &1.id)
    source_capteur_ids = MapSet.new(modele.capteurs || [], & &1.id)

    form =
      Form.for_update(modele, :update, as: "modele_traceur")
      |> to_form()

    socket
    |> assign(:page_title, "Modifier le modèle #{modele.nom}")
    |> assign(:form, form)
    |> assign(:modele, modele)
    |> assign(:features, feature_list)
    |> assign(:selected_feature_ids, modele_feature_ids)
    |> assign(:selected_type_vehicule_ids, source_type_vehicule_ids)
    |> assign(:selected_alimentation_ids, source_alimentation_ids)
    |> assign(:selected_capteur_ids, source_capteur_ids)
  end

  @impl true
  def handle_event("validate", %{"modele_traceur" => params}, socket) do
    params = normalize_params(params)

    form =
      socket.assigns.form.source
      |> Form.validate(params)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("toggle_feature", %{"id" => feature_id}, socket) do
    fid = feature_id
    selected = socket.assigns.selected_feature_ids

    updated =
      if MapSet.member?(selected, fid) do
        MapSet.delete(selected, fid)
      else
        MapSet.put(selected, fid)
      end

    feature_list =
      Enum.map(socket.assigns.features, fn f ->
        %{f | selected: MapSet.member?(updated, f.id)}
      end)

    {:noreply,
     socket
     |> assign(:features, feature_list)
     |> assign(:selected_feature_ids, updated)}
  end

  @impl true
  def handle_event("toggle_type_vehicule", %{"id" => id}, socket) do
    {:noreply, toggle_map_set(socket, :selected_type_vehicule_ids, id)}
  end

  @impl true
  def handle_event("toggle_alimentation", %{"id" => id}, socket) do
    {:noreply, toggle_map_set(socket, :selected_alimentation_ids, id)}
  end

  @impl true
  def handle_event("toggle_capteur", %{"id" => id}, socket) do
    {:noreply, toggle_map_set(socket, :selected_capteur_ids, id)}
  end

  @impl true
  def handle_event("save", %{"modele_traceur" => params}, socket) do
    params = normalize_params(params)

    sanitized_params =
      params
      |> Map.drop([
        "alimentations_compatibles",
        "types_vehicule_compatibles",
        "capteurs_supportes"
      ])

    case Form.submit(socket.assigns.form.source,
           params: sanitized_params
         ) do
      {:ok, modele} ->
        sync_features(modele.id, socket.assigns.selected_feature_ids)
        sync_relations(modele.id, socket.assigns.selected_type_vehicule_ids, :type_vehicule)
        sync_relations(modele.id, socket.assigns.selected_alimentation_ids, :alimentation)
        sync_relations(modele.id, socket.assigns.selected_capteur_ids, :capteur)

        message =
          if socket.assigns.modele,
            do: "Modèle de traceur modifié avec succès.",
            else: "Modèle de traceur créé avec succès."

        TagIp.Notification.broadcast({:notification, :info, message})

        {:noreply,
         socket
         |> put_flash(:info, message)
         |> push_navigate(to: ~p"/modeles")}

      {:error, form} ->
        {:noreply, assign(socket, form: to_form(form))}
    end
  end

  defp sync_features(modele_id, selected_ids) do
    existing =
      ModelFeature.read!()
      |> Enum.filter(&(&1.modele_traceur_id == modele_id))

    Enum.each(existing, &ModelFeature.destroy(&1))

    Enum.each(selected_ids, fn feature_id ->
      ModelFeature.create(%{
        modele_traceur_id: modele_id,
        feature_id: feature_id
      })
    end)
  end

  defp sync_relations(modele_id, selected_ids, :type_vehicule) do
    existing =
      TagIp.Resources.ModeleTraceurTypeVehicule.read!()
      |> Enum.filter(&(&1.modele_traceur_id == modele_id))

    Enum.each(existing, &TagIp.Resources.ModeleTraceurTypeVehicule.destroy(&1))

    Enum.each(selected_ids, fn id ->
      TagIp.Resources.ModeleTraceurTypeVehicule.create(%{
        modele_traceur_id: modele_id,
        type_vehicule_id: id
      })
    end)
  end

  defp sync_relations(modele_id, selected_ids, :alimentation) do
    existing =
      TagIp.Resources.ModeleTraceurAlimentation.read!()
      |> Enum.filter(&(&1.modele_traceur_id == modele_id))

    Enum.each(existing, &TagIp.Resources.ModeleTraceurAlimentation.destroy(&1))

    Enum.each(selected_ids, fn id ->
      TagIp.Resources.ModeleTraceurAlimentation.create(%{
        modele_traceur_id: modele_id,
        alimentation_id: id
      })
    end)
  end

  defp sync_relations(modele_id, selected_ids, :capteur) do
    existing =
      TagIp.Resources.ModeleTraceurCapteur.read!()
      |> Enum.filter(&(&1.modele_traceur_id == modele_id))

    Enum.each(existing, &TagIp.Resources.ModeleTraceurCapteur.destroy(&1))

    Enum.each(selected_ids, fn id ->
      TagIp.Resources.ModeleTraceurCapteur.create(%{
        modele_traceur_id: modele_id,
        capteur_id: id
      })
    end)
  end

  defp toggle_map_set(socket, assign_key, id) do
    selected = socket.assigns[assign_key]

    updated =
      if MapSet.member?(selected, id) do
        MapSet.delete(selected, id)
      else
        MapSet.put(selected, id)
      end

    assign(socket, assign_key, updated)
  end

  defp normalize_params(params) when is_map(params) do
    Map.new(params, fn
      {key, val} when is_list(val) -> {key, List.last(val)}
      {key, val} when is_map(val) -> {key, normalize_params(val)}
      {key, val} -> {key, val}
    end)
  end

  defp normalize_params(val), do: val
end
