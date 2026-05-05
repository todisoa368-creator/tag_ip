defmodule TagIpWeb.ProfilMontageLive.Index do
  use TagIpWeb, :live_view
  alias TagIp.Resources.ProfilMontage

  @impl true
  def mount(_params, _session, socket) do
    # On lit les profils via Ash
   profils = Ash.read!(ProfilMontage)
   {:ok, assign(socket, :profils, profils)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # Utilisation correcte d'Ash pour récupérer et supprimer
    profil = ProfilMontage |> Ash.get!(id)
    Ash.destroy!(profil)

    {:noreply, assign(socket, :profils, Ash.read!(ProfilMontage))}
  end

  @impl true
  def handle_event("duplicate", %{"id" => id}, socket) do
    # Récupération via le module de ressource
    profil_source = ProfilMontage |> Ash.get!(id)

    params = %{
      "name" => "#{profil_source.name} (Copie)",
      "description" => profil_source.description,
      "object_type" => profil_source.object_type,
      "reporting_interval" => profil_source.reporting_interval,
      "voltage_min" => profil_source.voltage_min,
      "voltage_max" => profil_source.voltage_max,
      "buzzer" => profil_source.buzzer,
      "fuel_probe_type" => profil_source.fuel_probe_type,
      "geofence_enabled" => profil_source.geofence_enabled,
      "driver_id_type" => profil_source.driver_id_type,
      "organization_id" => profil_source.organization_id
    }

    {:noreply, push_patch(socket, to: ~p"/profils/new?#{params}")}
  end
end
