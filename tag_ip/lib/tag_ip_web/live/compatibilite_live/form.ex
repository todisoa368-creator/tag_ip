defmodule TagIpWeb.CompatibiliteLive.Form do
  use TagIpWeb, :live_view

  alias TagIp.Resources.Compatibilite
  alias TagIp.Resources.ProfilMontage
  alias TagIp.Resources.ModeleTraceur

  @impl true
  def mount(_params, _session, socket) do
    # Récupération des données avec limite pour éviter l'erreur "Limit is required"
    modeles = Ash.read!(ModeleTraceur, page: [limit: 50])
    profils = Ash.read!(ProfilMontage, page: [limit: 50])

    {:ok,
     socket
     |> assign(:modeles, modeles.results) # Utilisation de .results pour la pagination Ash
     |> assign(:profils, profils.results)
     |> assign(:compatibilite, nil)}
  end

  @impl true
def handle_params(params, url, socket) do
  # On extrait le chemin (path) de l'URL complète
  path = URI.parse(url).path

  {:noreply,
   socket
   |> assign(:current_path, path) # On ajoute cette ligne
   |> apply_action(socket.assigns.live_action, params)}
end

  # Gestion des titres de page selon l'action définie dans le routeur
  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Calculer une compatibilité")
  end

  defp apply_action(socket, _action, _params) do
    socket
  end

  @impl true
  def handle_event("calculer", %{"profil_id" => profil_id, "modele_id" => modele_id}, socket) do
    # Logique de calcul liée à la gestion des profils de montage
    case Compatibilite.calculer_compatibilite(profil_id, modele_id) do
      {:ok, compatibilite} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Compatibilité calculée avec succès (Score: #{compatibilite.score_compatibilite}%)"
         )
         |> push_navigate(to: ~p"/compatibilites/#{compatibilite.id}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Erreur lors du calcul de la compatibilité")}
    end
  end
end
