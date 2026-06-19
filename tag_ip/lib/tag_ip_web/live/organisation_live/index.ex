defmodule TagIpWeb.OrganisationLive.Index do
  use TagIpWeb, :live_view

  alias TagIp.Resources.Organisation

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: TagIp.Notification.subscribe()

    {:ok,
     socket
     |> assign(:organisations, list_organisations())
     |> assign(:page_title, "Organisations")
     |> assign(:pending_delete_id, nil)
     |> assign(:pending_delete_label, nil)}
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Organisations")
     |> assign(:current_path, URI.parse(url).path)}
  end

  @impl true
  def handle_info({:notification, _, _}, socket) do
    {:noreply, assign(socket, :organisations, list_organisations())}
  end

  @impl true
  def handle_event("confirm_delete", %{"id" => id}, socket) do
    org = Ash.get!(Organisation, id, domain: TagIp.TagIp)

    {:noreply,
     socket
     |> assign(:pending_delete_id, id)
     |> assign(:pending_delete_label, org.name)}
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
    org = Ash.get!(Organisation, id, domain: TagIp.TagIp)
    name = org.name

    case Organisation.destroy(org) do
      {:ok, _} ->
        TagIp.Notification.broadcast(
          {:notification, :info, "Organisation « #{name} » supprimée."}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Organisation « #{name} » supprimée avec succès.")
         |> assign(:pending_delete_id, nil)
         |> assign(:pending_delete_label, nil)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Erreur lors de la suppression : #{inspect(reason)}")
         |> assign(:pending_delete_id, nil)
         |> assign(:pending_delete_label, nil)}
    end
  end

  defp list_organisations do
    Organisation.read!() |> Enum.sort_by(& &1.name)
  end
end
