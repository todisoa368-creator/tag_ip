defmodule TagIpWeb.ProfilMontageLive.Show do
  use TagIpWeb, :live_view

  alias TagIp.Resources.ProfilMontage

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    profil = ProfilMontage.get_by_id!(id)
    compatibilites = list_compatibilites(id)
    inserted_at_formatted = format_datetime(profil.inserted_at)

    {:noreply,
     socket
     |> assign(:page_title, "Profil: #{profil.nom}")
     |> assign(:profil, profil)
     |> assign(:compatibilites, compatibilites)
     |> assign(:inserted_at_formatted, inserted_at_formatted)}
  end

  defp list_compatibilites(_profil_id) do
    TagIp.Resources.Compatibilite
    |> Ash.read!(load: [:modele_traceur])
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y %H:%M")
  end
end
