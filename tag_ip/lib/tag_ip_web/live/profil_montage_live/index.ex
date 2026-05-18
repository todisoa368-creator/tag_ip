defmodule TagIpWeb.ProfilMontageLive.Index do
  use TagIpWeb, :live_view

  alias TagIp.Resources.ProfilMontage

  @page_size 10

  @impl true
  def mount(_params, _session, socket) do
    results = list_profils("", 1)
    trackable_types = Ash.read!(TagIp.Resources.TrackableType)
    type_labels = Enum.into(trackable_types, %{}, fn t -> {t.slug, t.label} end)

    {:ok,
     socket
     |> assign(:profils, results.results)
     |> assign(:total_count, results.count)
     |> assign(:search, "")
     |> assign(:page, 1)
     |> assign(:page_size, @page_size)
     |> assign(:page_title, "Profils de montage")
     |> assign(:type_labels, type_labels)
     |> assign(:pending_delete_id, nil)
     |> assign(:pending_delete_label, nil)}
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply, socket |> assign(:current_path, URI.parse(url).path)}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    results = list_profils(search, 1)

    {:noreply,
     socket
     |> assign(:profils, results.results)
     |> assign(:search, search)
     |> assign(:page, 1)
     |> assign(:total_count, results.count)}
  end

  @impl true
  def handle_event("paginate", %{"page" => page}, socket) do
    page = String.to_integer(page)
    results = list_profils(socket.assigns.search, page)

    {:noreply,
     socket
     |> assign(:profils, results.results)
     |> assign(:page, page)
     |> assign(:total_count, results.count)}
  end

  @impl true
  def handle_event("confirm_delete", %{"id" => id}, socket) do
    case ProfilMontage |> Ash.get(id) do
      {:ok, profil} ->
        {:noreply,
         socket
         |> assign(:pending_delete_id, id)
         |> assign(:pending_delete_label, profil.name)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Profil introuvable.")}
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

    case ProfilMontage |> Ash.get(id) do
      {:ok, profil} ->
        nom = profil.name

        case Ash.destroy(profil) do
          :ok ->
            TagIp.Notification.broadcast({:notification, :info, "Profil « #{nom} » supprimé."})

            {:noreply,
             socket
             |> put_flash(:info, "Profil « #{nom} » supprimé avec succès.")
             |> assign(:pending_delete_id, nil)
             |> assign(:pending_delete_label, nil)
             |> assign(:profils, list_profils(socket.assigns.search, socket.assigns.page).results)}

          {:error, reason} ->
            msg = "Erreur lors de la suppression du profil « #{nom} » : #{inspect(reason)}"

            {:noreply,
             socket
             |> put_flash(:error, msg)
             |> assign(:pending_delete_id, nil)
             |> assign(:pending_delete_label, nil)}
        end

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Profil introuvable.")
         |> assign(:pending_delete_id, nil)
         |> assign(:pending_delete_label, nil)}
    end
  end

  @impl true
  def handle_event("duplicate", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> push_navigate(to: ~p"/profils/new?duplicate_from=#{id}")}
  end

  defp list_profils(search, page) do
    query =
      ProfilMontage
      |> Ash.Query.sort(name: :asc)

    query =
      if search != "" do
        Ash.Query.do_filter(query, name: [contains: search])
      else
        query
      end

    Ash.read!(query, page: [limit: @page_size, offset: (page - 1) * @page_size, count: true])
  end
end
