defmodule TagIpWeb.CompatibiliteLive.Show do
  use TagIpWeb, :live_view

  # Importation des composants de layout pour corriger l'erreur de compilation
  import TagIpWeb.Layouts

  alias TagIp.Resources.Compatibilite

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    # On récupère la compatibilité avec ses relations pour l'affichage
    compatibilite = Ash.get!(Compatibilite, id, load: [:profil_montage, :modele_traceur])

    {:noreply,
     socket
     |> assign(:page_title, "Détails Compatibilité")
     |> assign(:compatibilite, compatibilite)}
  end

  # Cette fonction est utilisée dans ton template .heex
  defp format_datetime(nil), do: ""
  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y à %H:%M")
  end
end
