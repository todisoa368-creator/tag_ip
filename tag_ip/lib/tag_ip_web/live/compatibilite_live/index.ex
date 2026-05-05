defmodule TagIpWeb.CompatibiliteLive.Index do
  use TagIpWeb, :live_view

  alias TagIp.Resources.Compatibilite

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:compatibilites, list_compatibilites())}
  end

  defp list_compatibilites do
    Compatibilite
    |> Ash.Query.limit(100)
    |> Ash.read!(load: [:profil_montage, :modele_traceur])
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply,
     socket |> assign(:page_title, "Compatibilités") |> assign(:current_path, URI.parse(url).path)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    compatibilite = Compatibilite.get_by_id!(id)
    Compatibilite.destroy!(compatibilite)

    {:noreply, socket |> assign(:compatibilites, list_compatibilites())}
  end
  # Dans votre fichier LiveView
def handle_event("duplicate_profil", %{"id" => id}, socket) do
  # 1. On récupère le profil existant
  profil_source = ProfilMontage.get_by_id!(id)

  # 2. On prépare les attributs pour un nouveau profil (on retire l'ID)
  attrs =
    profil_source
    |> Map.from_struct()
    |> Map.drop([:id, :inserted_at, :updated_at])
    |> Map.put(:name, "#{profil_source.name} (Copie)")

  # 3. On redirige vers le formulaire de création avec les données pré-remplies
  {:noreply, push_patch(socket, to: ~p"/profils/new?#{attrs}")}
end
end
