defmodule TagIpWeb.ModeleTraceurLive.Index do
  use TagIpWeb, :live_view
   alias TagIp.Resources.ModeleTraceur
   alias TagIp.Resources.ProfilMontage
  @impl true
  def mount(_params, _session, socket) do
  # Récupération des données via Ash
  modeles = Ash.read!(TagIp.Resources.ModeleTraceur)

  {:ok,
   socket
   |> assign(:modeles, modeles) # Indispensable pour le template
   |> assign(:page_title, "Modèles de traceurs")}
end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Modèles de traceurs")
     |> assign(:current_path, URI.parse(url).path)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    modele = Ash.get!(ModeleTraceur, id)
    Ash.destroy!(modele)
    {:noreply, assign(socket, :modeles, Ash.read!(ModeleTraceur))}
  end

  @impl true
  def handle_event("duplicate", %{"id" => id}, socket) do
  # On récupère le profil à dupliquer
profil = TagIp.Resources.get!(TagIp.Resources.ProfilMontage, id)

  # On prépare les paramètres pour le nouveau formulaire
  params = %{
    name: "#{profil.name} (Copie)",
    description: profil.description,
    object_type: profil.object_type,
    voltage_min: profil.voltage_min,
    voltage_max: profil.voltage_max
    # Ajoute les autres champs si nécessaire
  }

  {:noreply,
   socket
   |> push_navigate(to: ~p"/profils/new?#{params}")}
   # ^^^ C'EST ICI : push_navigate au lieu de push_patch
end
end
