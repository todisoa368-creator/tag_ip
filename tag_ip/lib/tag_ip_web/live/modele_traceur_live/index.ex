defmodule TagIpWeb.ModeleTraceurLive.Index do
  use TagIpWeb, :live_view

  alias TagIp.Resources.ModeleTraceur

  @page_size 10

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: TagIp.Notification.subscribe()

    results = list_modeles("", 1)

    {:ok,
     socket
     |> assign(:modeles, results.results)
     |> assign(:total_count, results.count)
     |> assign(:search, "")
     |> assign(:page, 1)
     |> assign(:page_size, @page_size)
     |> assign(:page_title, "Modèles de traceurs")
     |> assign(:pending_delete_id, nil)
     |> assign(:pending_delete_label, nil)}
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Modèles de traceurs")
     |> assign(:current_path, URI.parse(url).path)}
  end

  @impl true
  def handle_info({:notification, _, _}, socket) do
    results = list_modeles(socket.assigns.search, socket.assigns.page)

    {:noreply,
     socket
     |> assign(:modeles, results.results)
     |> assign(:total_count, results.count)}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    results = list_modeles(search, 1)

    {:noreply,
     socket
     |> assign(:modeles, results.results)
     |> assign(:search, search)
     |> assign(:page, 1)
     |> assign(:total_count, results.count)}
  end

  @impl true
  def handle_event("paginate", %{"page" => page}, socket) do
    page = String.to_integer(page)
    results = list_modeles(socket.assigns.search, page)

    {:noreply,
     socket
     |> assign(:modeles, results.results)
     |> assign(:page, page)
     |> assign(:total_count, results.count)}
  end

  @impl true
  def handle_event("confirm_delete", %{"id" => id}, socket) do
    case ModeleTraceur.get_by_id(id) do
      {:ok, modele} ->
        {:noreply,
         socket
         |> assign(:pending_delete_id, id)
         |> assign(:pending_delete_label, modele.nom)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Modèle introuvable.")}
    end
  end

  @impl true
  def handle_event("cancel_delete", _params, socket) do
    {:noreply,
     socket
     |> assign(:pending_delete_id, nil)
     |> assign(:pending_delete_label, nil)}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    id = socket.assigns.pending_delete_id

    case ModeleTraceur.get_by_id(id) do
      {:ok, modele} ->
        nom = modele.nom

        case ModeleTraceur.destroy(modele) do
          :ok ->
            TagIp.Notification.broadcast({:notification, :info, "Modèle « #{nom} » supprimé."})

            {:noreply,
             socket
             |> put_flash(:info, "Modèle « #{nom} » supprimé avec succès.")
             |> assign(:pending_delete_id, nil)
             |> assign(:pending_delete_label, nil)
             |> assign(
               :modeles,
               list_modeles(socket.assigns.search, socket.assigns.page).results
             )}

          _ ->
            {:noreply,
             socket
             |> put_flash(:error, "Erreur lors de la suppression du modèle « #{nom} ».")
             |> assign(:pending_delete_id, nil)
             |> assign(:pending_delete_label, nil)}
        end

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Erreur lors de la récupération du modèle.")
         |> assign(:pending_delete_id, nil)
         |> assign(:pending_delete_label, nil)}
    end
  end

  @impl true
  def handle_event("duplicate", %{"id" => id} = _params, socket) do
    case ModeleTraceur.get_by_id(id) do
      {:ok, modele_source} ->
        modele_source = Ash.load!(modele_source, [:types_vehicule, :alimentations, :capteurs])

        attrs = %{
          nom: modele_source.nom,
          reference: "#{modele_source.reference}-COPY",
          description: modele_source.description,
          brand: modele_source.brand,
          can_bus: modele_source.can_bus,
          one_wire: modele_source.one_wire,
          rs232: modele_source.rs232,
          rs485: modele_source.rs485,
          nb_digital_inputs: modele_source.nb_digital_inputs,
          nb_analog_inputs: modele_source.nb_analog_inputs,
          nb_outputs: modele_source.nb_outputs,
          ip_rating: modele_source.ip_rating,
          antennes_externes: modele_source.antennes_externes,
          standby_current: modele_source.standby_current,
          ultra_low_power: modele_source.ultra_low_power,
          accelerometer: modele_source.accelerometer,
          buffer_memory: modele_source.buffer_memory
        }

        case ModeleTraceur.create(attrs) do
          {:ok, modele} ->
            Enum.each(
              modele_source.types_vehicule,
              &TagIp.Resources.ModeleTraceurTypeVehicule.create(%{
                modele_traceur_id: modele.id,
                type_vehicule_id: &1.id
              })
            )

            Enum.each(
              modele_source.alimentations,
              &TagIp.Resources.ModeleTraceurAlimentation.create(%{
                modele_traceur_id: modele.id,
                alimentation_id: &1.id
              })
            )

            Enum.each(
              modele_source.capteurs,
              &TagIp.Resources.ModeleTraceurCapteur.create(%{
                modele_traceur_id: modele.id,
                capteur_id: &1.id
              })
            )

            TagIp.Notification.broadcast(
              {:notification, :info, "Modèle « #{modele.nom} » dupliqué."}
            )

            {:noreply,
             socket
             |> put_flash(:info, "Modèle dupliqué")
             |> assign(
               :modeles,
               list_modeles(socket.assigns.search, socket.assigns.page).results
             )}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Erreur lors de la duplication")}
        end

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Source introuvable")}
    end
  end

  defp list_modeles(search, page) do
    query =
      ModeleTraceur
      |> Ash.Query.sort(nom: :asc)

    query =
      if search != "" do
        Ash.Query.do_filter(query, nom: [contains: search])
      else
        query
      end

    Ash.read!(query, page: [limit: @page_size, offset: (page - 1) * @page_size, count: true])
  end
end
