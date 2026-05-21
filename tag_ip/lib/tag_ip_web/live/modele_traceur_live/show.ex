defmodule TagIpWeb.ModeleTraceurLive.Show do
  use TagIpWeb, :live_view

  alias TagIp.Resources.ModeleTraceur

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:pending_delete_id, nil)
     |> assign(:pending_delete_label, nil)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    [modele] = ModeleTraceur.get_by_id!(id)

    modele =
      Ash.load!(modele, [:types_vehicule, :alimentations, :capteurs, :features, :model_ports])

    model_ports = Ash.load!(modele.model_ports, [:port_type])

    compatibilites = list_compatibilites(id)

    {:noreply,
     socket
     |> assign(:page_title, "Modèle: #{modele.nom}")
     |> assign(:modele, modele)
     |> assign(:model_ports, model_ports)
     |> assign(:compatibilites, compatibilites)}
  end

  @impl true
  def handle_event("duplicate", %{"id" => id}, socket) do
    {:noreply, socket |> push_navigate(to: ~p"/modeles/new?duplicate_from=#{id}")}
  end

  @impl true
  def handle_event("confirm_delete", %{"id" => id}, socket) do
    case ModeleTraceur.get_by_id(id) do
      {:ok, [modele]} ->
        {:noreply,
         socket
         |> assign(:pending_delete_id, id)
         |> assign(:pending_delete_label, modele.nom)}

      {:ok, []} ->
        {:noreply, put_flash(socket, :error, "Modèle introuvable.")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Erreur lors de la récupération du modèle.")}
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
      {:ok, [modele]} ->
        nom = modele.nom

        case ModeleTraceur.destroy(modele) do
          :ok ->
            TagIp.Notification.broadcast({:notification, :info, "Modèle « #{nom} » supprimé."})

            {:noreply,
             socket
             |> put_flash(:info, "Modèle « #{nom} » supprimé avec succès.")
             |> assign(:pending_delete_id, nil)
             |> assign(:pending_delete_label, nil)
             |> push_navigate(to: ~p"/modeles")}

          {:error, reason} ->
            {:noreply,
             socket
             |> put_flash(
               :error,
               "Erreur lors de la suppression du modèle « #{nom} » : #{inspect(reason)}"
             )
             |> assign(:pending_delete_id, nil)
             |> assign(:pending_delete_label, nil)}
        end

      {:ok, []} ->
        {:noreply,
         socket
         |> put_flash(:error, "Modèle introuvable.")
         |> assign(:pending_delete_id, nil)
         |> assign(:pending_delete_label, nil)}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Erreur lors de la récupération du modèle.")
         |> assign(:pending_delete_id, nil)
         |> assign(:pending_delete_label, nil)}
    end
  end

  defp list_compatibilites(modele_id) do
    TagIp.Resources.Compatibilite
    |> Ash.Query.new()
    |> Ash.Query.limit(100)
    |> Ash.Query.do_filter(modele_traceur_id: modele_id)
    |> Ash.Query.load([:profil_montage])
    |> Ash.read!()
  end

  defp format_datetime(nil), do: ""

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y %H:%M")
  end
end
