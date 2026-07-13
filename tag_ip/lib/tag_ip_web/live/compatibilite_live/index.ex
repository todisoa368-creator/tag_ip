defmodule TagIpWeb.CompatibiliteLive.Index do
  use TagIpWeb, :live_view

  alias TagIp.Resources.Compatibilite
  alias TagIp.Resources.ProfilMontage
  alias TagIp.Resources.ModeleTraceur

  @page_size 10

  @impl true
  def mount(_params, _session, socket) do
    modeles = Ash.read!(ModeleTraceur, page: [limit: 50])
    profils = Ash.read!(ProfilMontage, page: [limit: 50])
    results = list_compatibilites("", 1)

    {:ok,
     socket
     |> assign(:compatibilites, results.results)
     |> assign(:total_count, results.count)
     |> assign(:search, "")
     |> assign(:page, 1)
     |> assign(:page_size, @page_size)
     |> assign(:modeles, modeles.results)
     |> assign(:profils, profils.results)
     |> assign(:pending_delete_id, nil)
     |> assign(:pending_delete_label, nil)}
  end

  defp list_compatibilites(search, page) do
    query =
      Compatibilite
      |> Ash.Query.sort(score_compatibilite: :desc)
      |> Ash.Query.load([:profil_montage, :modele_traceur])

    query =
      if search != "" do
        Ash.Query.do_filter(query, details: [contains: search])
      else
        query
      end

    Ash.read!(query, page: [limit: @page_size, offset: (page - 1) * @page_size, count: true])
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply,
     socket |> assign(:page_title, "Compatibilités") |> assign(:current_path, URI.parse(url).path)}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    results = list_compatibilites(search, 1)

    {:noreply,
     socket
     |> assign(:compatibilites, results.results)
     |> assign(:search, search)
     |> assign(:page, 1)
     |> assign(:total_count, results.count)}
  end

  @impl true
  def handle_event("paginate", %{"page" => page}, socket) do
    page = String.to_integer(page)
    results = list_compatibilites(socket.assigns.search, page)

    {:noreply,
     socket
     |> assign(:compatibilites, results.results)
     |> assign(:page, page)
     |> assign(:total_count, results.count)}
  end

  @impl true
  def handle_event("confirm_delete", %{"id" => id}, socket) do
    case Compatibilite |> Ash.get(id, load: [:profil_montage, :modele_traceur]) do
      {:ok, compatibilite} ->
        profil_nom =
          if compatibilite.profil_montage, do: compatibilite.profil_montage.name, else: "N/A"

        modele_nom =
          if compatibilite.modele_traceur, do: compatibilite.modele_traceur.nom, else: "N/A"

        {:noreply,
         socket
         |> assign(:pending_delete_id, id)
         |> assign(:pending_delete_label, "#{profil_nom} / #{modele_nom}")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Compatibilité introuvable.")}
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

    case Compatibilite |> Ash.get(id, load: [:profil_montage, :modele_traceur]) do
      {:ok, compatibilite} ->
        profil_nom =
          if compatibilite.profil_montage, do: compatibilite.profil_montage.name, else: "N/A"

        modele_nom =
          if compatibilite.modele_traceur, do: compatibilite.modele_traceur.nom, else: "N/A"

        case Ash.destroy(compatibilite) do
          :ok ->
            TagIp.Notification.broadcast(
              {:notification, :info, "Compatibilité #{profil_nom} / #{modele_nom} supprimée."}
            )

            {:noreply,
             socket
             |> put_flash(
               :info,
               "Compatibilité #{profil_nom} / #{modele_nom} supprimée avec succès."
             )
             |> assign(:pending_delete_id, nil)
             |> assign(:pending_delete_label, nil)
             |> assign(
               :compatibilites,
               list_compatibilites(socket.assigns.search, socket.assigns.page).results
             )}

          {:error, _reason} ->
            {:noreply,
             socket
             |> put_flash(:error, "Erreur lors de la suppression de la compatibilité.")
             |> assign(:pending_delete_id, nil)
             |> assign(:pending_delete_label, nil)}
        end

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Compatibilité introuvable.")
         |> assign(:pending_delete_id, nil)
         |> assign(:pending_delete_label, nil)}
    end
  end

  @impl true
  def handle_event("calculer", %{"profil_id" => profil_id, "modele_id" => modele_id}, socket) do
    if profil_id == "" or modele_id == "" do
      {:noreply, put_flash(socket, :error, "Veuillez sélectionner un profil et un modèle.")}
    else
      input =
        Ash.ActionInput.for_action(Compatibilite, :calculer_compatibilite, %{
          profil_id: profil_id,
          modele_id: modele_id
        })

      case Ash.run_action(input) do
        {:ok, %{score: score}} ->
          TagIp.Notification.broadcast(
            {:notification, :info, "Compatibilité recalculée (Score: #{score}%)."}
          )

          {:noreply,
           socket
           |> put_flash(:info, "Compatibilité calculée avec succès (Score: #{score}%)")
           |> assign(
             :compatibilites,
             list_compatibilites(socket.assigns.search, socket.assigns.page).results
           )}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Erreur lors du calcul de la compatibilité")}
      end
    end
  end
end
