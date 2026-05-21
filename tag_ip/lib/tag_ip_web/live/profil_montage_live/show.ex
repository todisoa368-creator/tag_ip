defmodule TagIpWeb.ProfilMontageLive.Show do
  use TagIpWeb, :live_view

  alias TagIp.Resources.Compatibilite
  alias TagIp.Resources.ProfilMontage

  @impl true
  def mount(_params, _session, socket) do
    trackable_types = Ash.read!(TagIp.Resources.TrackableType)
    type_labels = Enum.into(trackable_types, %{}, fn t -> {t.slug, t.label} end)

    {:ok,
     socket
     |> assign(:type_labels, type_labels)
     |> assign(:pending_delete_id, nil)
     |> assign(:pending_delete_label, nil)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    profil = Ash.get!(TagIp.Resources.ProfilMontage, id)
    compatibilites = list_compatibilites(id)
    inserted_at_formatted = format_datetime(profil.inserted_at)

    {:noreply,
     socket
     |> assign(:page_title, "Profil: #{profil.name}")
     |> assign(:profil, profil)
     |> assign(:compatibilites, compatibilites)
     |> assign(:inserted_at_formatted, inserted_at_formatted)}
  end

  defp list_compatibilites(profil_id) do
    Compatibilite
    |> Ash.Query.new()
    |> Ash.Query.limit(100)
    |> Ash.Query.do_filter(profil_montage_id: profil_id)
    |> Ash.Query.load([:modele_traceur])
    |> Ash.read!()
  end

  defp format_datetime(nil), do: ""

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y %H:%M")
  end

  @impl true
  def handle_event("duplicate", %{"id" => id}, socket) do
    {:noreply, socket |> push_navigate(to: ~p"/profils/new?duplicate_from=#{id}")}
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
             |> push_navigate(to: ~p"/profils")}

          {:error, reason} ->
            {:noreply,
             socket
             |> put_flash(
               :error,
               "Erreur lors de la suppression du profil « #{nom} » : #{inspect(reason)}"
             )
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
end
