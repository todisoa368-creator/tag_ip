defmodule TagIpWeb.ModeleTraceurLive.Show do
  use TagIpWeb, :live_view

  alias TagIp.Resources.ModeleTraceur

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    modele = ModeleTraceur.get_by_id!(id)
    compatibilites = list_compatibilites(id)

    {:noreply,
     socket
     |> assign(:page_title, "Modèle: #{modele.nom}")
     |> assign(:modele, modele)
     |> assign(:compatibilites, compatibilites)}
  end

  defp list_compatibilites(modele_id) do
    TagIp.Resources.Compatibilite
    |> Ash.Query.new()
    |> Ash.Query.limit(100)
    |> Ash.read!(load: [:profil_montage], filter: [modele_traceur_id: modele_id])
  end

  defp format_datetime(nil), do: ""

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y %H:%M")
  end
end
