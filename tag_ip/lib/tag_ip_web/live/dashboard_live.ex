defmodule TagIpWeb.DashboardLive do
  use TagIpWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    # On récupère les données réelles depuis la base de données via Ash
    # Ces compteurs alimenteront ton tableau de bord en temps réel
    profils_count =
      TagIp.Resources.ProfilMontage
      |> Ash.Query.new()
      |> Ash.count!()

    modeles_count =
      TagIp.Resources.ModeleTraceur
      |> Ash.Query.new()
      |> Ash.count!()

    # On regroupe tout dans la map :stats attendue par le render
    stats = %{
      profils_count: profils_count,
      modeles_count: modeles_count,
      tests_count: 0 # À lier ultérieurement avec TagIp.Resources.Compatibilite
    }

    {:ok, assign(socket, stats: stats)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <div class="border-b border-gray-200 pb-5">
        <h1 class="text-2xl font-bold text-gray-900 italic">TAG-Monitor</h1>
        <p class="text-sm text-gray-500 mt-1">
          Surveillance et gestion des profils de montage pour Tag-IP.
        </p>
      </div>

      <%!-- Cartes de Statistiques --%>
      <div class="grid grid-cols-1 gap-6 sm:grid-cols-3">
        <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition">
          <div class="text-sm font-bold text-gray-400 uppercase">Profils enregistrés</div>
          <%!-- Utilisation correcte de @stats pour afficher les données réelles --%>
          <div class="mt-2 text-4xl font-black text-blue-600"><%= @stats.profils_count %></div>
        </div>

        <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition">
          <div class="text-sm font-bold text-gray-400 uppercase">Modèles traceurs</div>
          <div class="mt-2 text-4xl font-black text-gray-900"><%= @stats.modeles_count %></div>
        </div>

        <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition">
          <div class="text-sm font-bold text-gray-400 uppercase">Tests de compatibilité</div>
          <div class="mt-2 text-4xl font-black text-green-600"><%= @stats.tests_count %></div>
        </div>
      </div>

      <%!-- Section Actions Rapides --%>
      <div class="bg-blue-50 border border-blue-100 rounded-2xl p-8 text-center">
        <h3 class="text-lg font-bold text-blue-900">Besoin de configurer un nouveau tracker ?</h3>
        <p class="text-blue-700 mb-6">Accédez directement à la création de profil ou lancez un test.</p>
        <div class="flex justify-center gap-4">
          <.link navigate={~p"/profils/new"} class="bg-blue-600 text-white px-6 py-2 rounded-lg font-bold hover:bg-blue-700 transition">
            Nouveau Profil
          </.link>
          <.link navigate={~p"/compatibilites"} class="bg-white text-blue-600 border border-blue-200 px-6 py-2 rounded-lg font-bold hover:bg-blue-100 transition">
            Tester Compatibilité
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
