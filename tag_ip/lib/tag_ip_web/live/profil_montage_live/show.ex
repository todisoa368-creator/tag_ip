defmodule TagIpWeb.ProfilMontageLive.Show do
  use TagIpWeb, :live_view
  alias TagIp.Resources.Compatibilite

  @impl true
  def mount(_params, _session, socket) do
    trackable_types = Ash.read!(TagIp.Resources.TrackableType)
    type_labels = Enum.into(trackable_types, %{}, fn t -> {t.slug, t.label} end)

    {:ok, socket |> assign(:type_labels, type_labels)}
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
    |> Ash.read!(load: [:modele_traceur], filter: [profil_montage_id: profil_id])
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y %H:%M")
  end
end
