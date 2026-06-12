defmodule TagIpWeb.DashboardLive.Index do
  use TagIpWeb, :live_view

  alias TagIp.Resources.ProfilMontage
  alias TagIp.Resources.ModeleTraceur

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: TagIp.Notification.subscribe()

    {:ok,
     socket
     |> assign(page_title: "Dashboard · profile de montage ")
     |> assign(:stats, fetch_stats())
     |> stream(:notifications, [], reset: true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <%!-- Notifications toast --%>
      <div id="notifications" class="fixed top-20 right-4 z-50 space-y-2" phx-update="stream">
        <div :for={{id, notif} <- @streams.notifications} id={id} class="transition-all duration-300">
          <div
            class={[
              "w-80 sm:w-96 shadow-lg border-2 rounded-lg p-4 flex items-start gap-3",
              notif.kind == :info && "bg-blue-50 border-blue-400 text-blue-800",
              notif.kind == :error && "bg-red-50 border-red-500 text-red-800"
            ]}
            phx-click={JS.push("dismiss", value: %{id: notif.id}) |> hide("##{id}")}
          >
            <.icon
              name={
                if notif.kind == :info, do: "hero-information-circle", else: "hero-exclamation-circle"
              }
              class={[
                "size-5 shrink-0 mt-0.5",
                notif.kind == :info && "text-blue-600",
                notif.kind == :error && "text-red-600"
              ]}
            />
            <p class="text-sm font-medium flex-1">{notif.message}</p>
            <button type="button" class="shrink-0">
              <.icon name="hero-x-mark" class="size-4 opacity-60 hover:opacity-100" />
            </button>
          </div>
        </div>
      </div>

      <%!-- Hero/Welcome Section --%>
      <div class="relative overflow-hidden rounded-2xl bg-linear-to-br from-blue-600 via-indigo-600 to-violet-600 p-8 sm:p-10">
        <div class="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHZpZXdCb3g9IjAgMCA2MCA2MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZyBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPjxnIGZpbGw9IiNmZmYiIGZpbGwtb3BhY2l0eT0iMC4wNSI+PGNpcmNsZSBjeD0iMzAiIGN5PSIzMCIgcj0iMiIvPjwvZz48L2c+PC9zdmc+')] opacity-30" />
        <div class="relative">
          <div class="flex items-center gap-3 mb-2">
            <.icon name="hero-sparkles" class="size-6 text-blue-200" />
            <span class="text-blue-200 text-sm font-medium tracking-wider uppercase">
              Tableau de bord
            </span>
          </div>
          <h1 class="text-3xl sm:text-4xl font-bold text-white">
            Bienvenue sur la plateforme de gestion des profils de montage
          </h1>
          <p class="mt-3 text-blue-100 text-lg max-w-2xl">
            Gérez les profils de montage et consultez les compatibilités
            entre les modèles de traceurs GPS.
          </p>
          <div class="mt-6 flex flex-wrap gap-3">
            <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white/15 text-white text-sm font-medium backdrop-blur-sm">
              <.icon name="hero-shield-check" class="size-4" /> Administrateur
            </span>
            <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white/15 text-white text-sm font-medium backdrop-blur-sm">
              <.icon name="hero-calendar" class="size-4" />
              {Date.utc_today() |> Date.to_string()}
            </span>
          </div>
        </div>
      </div>

      <%!-- Toolbar actions --%>
      <div class="flex items-center justify-between mt-4 mb-2">
        <div class="flex items-center gap-3"></div>
        <div class="text-sm text-gray-200 hidden sm:block">
          Dernière mise à jour : {Date.utc_today() |> Date.to_string()}
        </div>
      </div>

      <%!-- Cartes de statistiques --%>
      <div class="grid grid-cols-1 gap-5 sm:grid-cols-3">
        <div class="group relative bg-white overflow-hidden rounded-xl shadow-sm border border-gray-100 hover:shadow-lg hover:-translate-y-1 transition-all duration-300">
          <div class="absolute inset-0 bg-linear-to-r from-blue-500/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
          <div class="relative px-5 py-6 sm:px-6">
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 rounded-xl bg-blue-100 flex items-center justify-center shrink-0 group-hover:scale-110 group-hover:bg-blue-200 transition-all duration-300">
                <.icon name="hero-document-text" class="size-6 text-blue-600" />
              </div>
              <div>
                <dt class="text-sm font-medium text-gray-500">Profils de montage</dt>
                <dd class="mt-0.5 text-3xl font-bold text-gray-900">{@stats.profils}</dd>
              </div>
            </div>
            <div class="mt-3 w-full bg-gray-100 rounded-full h-1.5 overflow-hidden">
              <div class="bg-blue-500 h-1.5 rounded-full w-3/4 transition-all duration-500" />
            </div>
          </div>
        </div>

        <div class="group relative bg-white overflow-hidden rounded-xl shadow-sm border border-gray-100 hover:shadow-lg hover:-translate-y-1 transition-all duration-300">
          <div class="absolute inset-0 bg-linear-to-r from-indigo-500/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
          <div class="relative px-5 py-6 sm:px-6">
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 rounded-xl bg-indigo-100 flex items-center justify-center shrink-0 group-hover:scale-110 group-hover:bg-indigo-200 transition-all duration-300">
                <.icon name="hero-cpu-chip" class="size-6 text-indigo-600" />
              </div>
              <div>
                <dt class="text-sm font-medium text-gray-500">Modèles de traceurs</dt>
                <dd class="mt-0.5 text-3xl font-bold text-gray-900">{@stats.modeles}</dd>
              </div>
            </div>
            <div class="mt-3 w-full bg-gray-100 rounded-full h-1.5 overflow-hidden">
              <div class="bg-indigo-500 h-1.5 rounded-full w-1/2 transition-all duration-500" />
            </div>
          </div>
        </div>

        <div class="group relative bg-white overflow-hidden rounded-xl shadow-sm border border-gray-100 hover:shadow-lg hover:-translate-y-1 transition-all duration-300">
          <div class="absolute inset-0 bg-linear-to-r from-emerald-500/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
          <div class="relative px-5 py-6 sm:px-6">
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 rounded-xl bg-emerald-100 flex items-center justify-center shrink-0 group-hover:scale-110 group-hover:bg-emerald-200 transition-all duration-300">
                <.icon name="hero-shield-exclamation" class="size-6 text-emerald-600" />
              </div>
              <div>
                <dt class="text-sm font-medium text-gray-500">Compatibilités</dt>
                <dd class="mt-0.5 text-3xl font-bold text-gray-900">{@stats.alertes}</dd>
              </div>
            </div>
            <div class="mt-3 w-full bg-gray-100 rounded-full h-1.5 overflow-hidden">
              <div class="bg-emerald-500 h-1.5 rounded-full w-1/3 transition-all duration-500" />
            </div>
          </div>
        </div>
      </div>

      <%!-- Section Accès Rapides --%>
      <div>
        <div class="flex items-center gap-2 mb-5">
          <div class="h-px flex-1 bg-linear-to-r from-gray-200 to-transparent" />
          <h2 class="text-sm font-semibold text-gray-500 uppercase tracking-wider">Accès rapides</h2>
          <div class="h-px flex-1 bg-linear-to-l from-gray-200 to-transparent" />
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <.link
            navigate={~p"/profils"}
            class="group relative overflow-hidden bg-white rounded-xl border border-gray-200 shadow-sm hover:shadow-xl hover:-translate-y-1.5 transition-all duration-300"
          >
            <div class="absolute inset-0 bg-linear-to-br from-blue-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
            <div class="relative p-5 flex items-center gap-4">
              <div class="w-12 h-12 rounded-xl bg-linear-to-br from-blue-500 to-blue-600 flex items-center justify-center shrink-0 shadow-lg shadow-blue-200 group-hover:shadow-blue-300 group-hover:scale-110 transition-all duration-300">
                <.icon name="hero-document-text" class="size-6 text-white" />
              </div>
              <div>
                <p class="font-semibold text-gray-900 group-hover:text-blue-600 transition-colors">
                  Profils de montage
                </p>
                <p class="text-sm text-gray-500">{@stats.profils} enregistrés &#x2197;</p>
              </div>
            </div>
          </.link>

          <.link
            navigate={~p"/modeles"}
            class="group relative overflow-hidden bg-white rounded-xl border border-gray-200 shadow-sm hover:shadow-xl hover:-translate-y-1.5 transition-all duration-300"
          >
            <div class="absolute inset-0 bg-linear-to-br from-indigo-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
            <div class="relative p-5 flex items-center gap-4">
              <div class="w-12 h-12 rounded-xl bg-linear-to-br from-indigo-500 to-indigo-600 flex items-center justify-center shrink-0 shadow-lg shadow-indigo-200 group-hover:shadow-indigo-300 group-hover:scale-110 transition-all duration-300">
                <.icon name="hero-cpu-chip" class="size-6 text-white" />
              </div>
              <div>
                <p class="font-semibold text-gray-900 group-hover:text-indigo-600 transition-colors">
                  Modèles de traceurs
                </p>
                <p class="text-sm text-gray-500">{@stats.modeles} enregistrés &#x2197;</p>
              </div>
            </div>
          </.link>

          <.link
            navigate={~p"/compatibilites"}
            class="group relative overflow-hidden bg-white rounded-xl border border-gray-200 shadow-sm hover:shadow-xl hover:-translate-y-1.5 transition-all duration-300"
          >
            <div class="absolute inset-0 bg-linear-to-br from-emerald-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
            <div class="relative p-5 flex items-center gap-4">
              <div class="w-12 h-12 rounded-xl bg-linear-to-br from-emerald-500 to-emerald-600 flex items-center justify-center shrink-0 shadow-lg shadow-emerald-200 group-hover:shadow-emerald-300 group-hover:scale-110 transition-all duration-300">
                <.icon name="hero-shield-exclamation" class="size-6 text-white" />
              </div>
              <div>
                <p class="font-semibold text-gray-900 group-hover:text-emerald-600 transition-colors">
                  Compatibilités
                </p>
                <p class="text-sm text-gray-500">Calculer &#x2197;</p>
              </div>
            </div>
          </.link>

          <.link
            navigate={~p"/referentiels"}
            class="group relative overflow-hidden bg-white rounded-xl border border-gray-200 shadow-sm hover:shadow-xl hover:-translate-y-1.5 transition-all duration-300"
          >
            <div class="absolute inset-0 bg-linear-to-br from-amber-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
            <div class="relative p-5 flex items-center gap-4">
              <div class="w-12 h-12 rounded-xl bg-linear-to-br from-amber-500 to-amber-600 flex items-center justify-center shrink-0 shadow-lg shadow-amber-200 group-hover:shadow-amber-300 group-hover:scale-110 transition-all duration-300">
                <.icon name="hero-book-open" class="size-6 text-white" />
              </div>
              <div>
                <p class="font-semibold text-gray-900 group-hover:text-amber-600 transition-colors">
                  Référentiels
                </p>
                <p class="text-sm text-gray-500">Ports, fonctionnalités &#x2197;</p>
              </div>
            </div>
          </.link>
        </div>
      </div>

      <%!-- Carte d'information système --%>
      <div class="bg-linear-to-r from-gray-50 to-white rounded-xl border border-gray-200 p-6">
        <div>
          <div class="flex items-center gap-2">
            <.icon name="hero-information-circle" class="size-5 text-blue-600" />
            <h3 class="font-semibold text-gray-900">
              À propos du système
            </h3>
          </div>

          <p class="mt-2 text-sm text-gray-600 leading-relaxed">
            Cette plateforme permet de gérer les profils de montage, consulter le catalogue des modèles de traceurs GPS et visualiser les compatibilités calculées automatiquement entre les profils et les équipements.
          </p>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_info({:notification, kind, message}, socket) do
    notif = %{id: System.monotonic_time(), kind: kind, message: message}
    Process.send_after(self(), {:dismiss, notif.id}, 10_000)

    {:noreply,
     socket
     |> assign(:stats, fetch_stats())
     |> stream_insert(:notifications, notif, at: 0)}
  end

  @impl true
  def handle_info({:dismiss, id}, socket) do
    {:noreply, stream_delete(socket, :notifications, %{id: id})}
  end

  @impl true
  def handle_event("dismiss", %{"id" => id}, socket) do
    {:noreply, stream_delete(socket, :notifications, %{id: String.to_integer(id)})}
  end

  @impl true
  def handle_event("refresh", _params, socket) do
    {:noreply,
     socket
     |> assign(:stats, fetch_stats())
     |> put_flash(:info, "Statistiques rafraîchies")}
  end

  defp fetch_stats do
    %{
      profils: Ash.count!(ProfilMontage, domain: TagIp.TagIp),
      modeles: Ash.count!(ModeleTraceur, domain: TagIp.TagIp),
      alertes: Ash.count!(TagIp.Resources.Compatibilite, domain: TagIp.TagIp)
    }
  end
end
