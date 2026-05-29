defmodule TagIpWeb.CompatibiliteLive.Show do
  use TagIpWeb, :live_view

  alias TagIp.Resources.Compatibilite

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:pending_delete_id, nil)
     |> assign(:pending_delete_label, nil)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    compatibilite = Ash.get!(Compatibilite, id, load: [:profil_montage, :modele_traceur])

    {:noreply,
     socket
     |> assign(:page_title, "Détails Compatibilité")
     |> assign(:compatibilite, compatibilite)}
  end

  @impl true
  def handle_event("confirm_delete", %{"id" => id}, socket) do
    case Compatibilite |> Ash.get(id, load: [:profil_montage, :modele_traceur]) do
      {:ok, compat} ->
        profil_nom = if(compat.profil_montage, do: compat.profil_montage.name, else: "N/A")
        modele_nom = if(compat.modele_traceur, do: compat.modele_traceur.nom, else: "N/A")

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
      {:ok, compat} ->
        profil_nom = if(compat.profil_montage, do: compat.profil_montage.name, else: "N/A")
        modele_nom = if(compat.modele_traceur, do: compat.modele_traceur.nom, else: "N/A")

        case Ash.destroy(compat) do
          :ok ->
            TagIp.Notification.broadcast(
              {:notification, :info, "Compatibilité #{profil_nom} / #{modele_nom} supprimée."}
            )

            {:noreply,
             socket
             |> put_flash(:info, "Compatibilité supprimée avec succès.")
             |> assign(:pending_delete_id, nil)
             |> assign(:pending_delete_label, nil)
             |> push_navigate(to: ~p"/compatibilites")}

          {:error, _reason} ->
            {:noreply,
             socket
             |> put_flash(:error, "Erreur lors de la suppression.")
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
end
