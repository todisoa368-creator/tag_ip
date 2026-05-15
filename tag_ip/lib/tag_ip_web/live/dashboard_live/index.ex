defmodule TagIpWeb.DashboardLive.Index do
  use TagIpWeb, :live_view

  alias TagIp.Resources.ProfilMontage
  alias TagIp.Resources.ModeleTraceur

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: TagIp.Notification.subscribe()

    {:ok,
     socket
     |> assign(page_title: "Dashboard · TAG-Monitor")
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

      <%!-- Header du Dashboard --%>
      <div>
        <h1 class="text-3xl font-bold text-gray-900">Tableau de bord</h1>
        <p class="mt-2 text-sm text-gray-600">
          Bienvenue sur l'interface de supervision TAG-Monitor.
        </p>
      </div>

      <%!-- Cartes de statistiques --%>
      <div class="grid grid-cols-1 gap-5 sm:grid-cols-3">
        <div class="bg-white overflow-hidden shadow rounded-lg border border-gray-100">
          <div class="px-4 py-5 sm:p-6">
            <dt class="text-sm font-medium text-gray-500 truncate">Profils de montage</dt>
            <dd class="mt-1 text-3xl font-semibold text-blue-600">{@stats.profils}</dd>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg border border-gray-100">
          <div class="px-4 py-5 sm:p-6">
            <dt class="text-sm font-medium text-gray-500 truncate">Modèles de traceurs</dt>
            <dd class="mt-1 text-3xl font-semibold text-indigo-600">{@stats.modeles}</dd>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg border border-gray-100">
          <div class="px-4 py-5 sm:p-6">
            <dt class="text-sm font-medium text-gray-500 truncate">Alertes système</dt>
            <dd class="mt-1 text-3xl font-semibold text-green-600">{@stats.alertes}</dd>
          </div>
        </div>
      </div>

      <%!-- Section d'information projet --%>
      <div class="bg-blue-50 border-l-4 border-blue-400 p-4">
        <div class="flex">
          <div class="ml-3">
            <p class="text-sm text-blue-700">
              Vous êtes connectée en tant qu'administrateur. Utilisez le menu supérieur pour gérer les profils et les équipements de Tag-IP.
            </p>
          </div>
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

  defp fetch_stats do
    %{
      profils: Ash.count!(ProfilMontage, domain: TagIp.Resources),
      modeles: Ash.count!(ModeleTraceur, domain: TagIp.TagIp),
      alertes: Ash.count!(TagIp.Resources.Compatibilite, domain: TagIp.TagIp)
    }
  end
end
