defmodule TagIpWeb.ModeleTraceurLive.Form do
  use TagIpWeb, :live_view

  alias AshPhoenix.Form
  alias TagIp.Resources.ModeleTraceur
  alias TagIp.Resources.Feature
  alias TagIp.Resources.ModelFeature

  @impl true
  def mount(_params, _session, socket) do
    features = Feature.read!()
    feature_list = Enum.map(features, &%{id: &1.id, label: &1.label, selected: false})

    {:ok,
     socket
     |> assign(:features, feature_list)
     |> assign(:selected_feature_ids, MapSet.new())}
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
    source = Ash.load!(source, [:features])

    source_feature_ids =
      MapSet.new(source.features || [], & &1.id)

    feature_list =
      Enum.map(socket.assigns.features, fn f ->
        %{f | selected: MapSet.member?(source_feature_ids, f.id)}
      end)

    params = %{
      "nom" => "#{source.nom} (copie)",
      "reference" => "#{source.reference}-COPY",
      "description" => source.description
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
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    modele = Ash.get!(ModeleTraceur, id, domain: TagIp.TagIp)
    modele = Ash.load!(modele, [:features])

    modele_feature_ids =
      MapSet.new(modele.features || [], & &1.id)

    feature_list =
      Enum.map(socket.assigns.features, fn f ->
        %{f | selected: MapSet.member?(modele_feature_ids, f.id)}
      end)

    form =
      Form.for_update(modele, :update, as: "modele_traceur")
      |> to_form()

    socket
    |> assign(:page_title, "Modifier le modèle #{modele.nom}")
    |> assign(:form, form)
    |> assign(:modele, modele)
    |> assign(:features, feature_list)
    |> assign(:selected_feature_ids, modele_feature_ids)
  end

  @impl true
  def handle_event("validate", %{"modele_traceur" => params}, socket) do
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
  def handle_event("save", %{"modele_traceur" => params}, socket) do
    sanitized_params =
      params
      |> Map.update("alimentations_compatibles", [], &String.split(&1, ",", trim: true))
      |> Map.update("types_vehicule_compatibles", [], &String.split(&1, ",", trim: true))
      |> Map.update("capteurs_supportes", [], &String.split(&1, ",", trim: true))

    case Form.submit(socket.assigns.form.source,
           params: sanitized_params
         ) do
      {:ok, modele} ->
        sync_features(modele.id, socket.assigns.selected_feature_ids)

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
end
